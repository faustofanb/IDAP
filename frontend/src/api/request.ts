/**
 * Axios 请求封装
 * 统一处理请求拦截、响应拦截、错误处理和租户上下文
 */
import { useUserStore } from '@/stores/user'
import axios, { type AxiosError, type AxiosInstance, type AxiosRequestConfig, type AxiosResponse } from 'axios'
import { ElMessage } from 'element-plus'

// API 基础配置
const BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api'
const TIMEOUT = 30000

/**
 * 标准响应结构
 */
export interface ApiResponse<T = any> {
    code: number
    message: string
    data: T
    timestamp: number
}

/**
 * 创建 Axios 实例
 */
const service: AxiosInstance = axios.create({
    baseURL: BASE_URL,
    timeout: TIMEOUT,
    headers: {
        'Content-Type': 'application/json'
    }
})

/**
 * 请求拦截器
 * - 注入 JWT Token
 * - 注入租户上下文 (tenantId)
 * - 添加请求追踪 ID
 */
service.interceptors.request.use(
    (config) => {
        const userStore = useUserStore()

        // 注入 JWT Token
        if (userStore.token) {
            config.headers.Authorization = `Bearer ${userStore.token}`
        }

        // 注入租户上下文（多租户隔离核心）
        if (userStore.tenantId) {
            config.headers['X-Tenant-Id'] = userStore.tenantId
        }

        // 生成请求追踪 ID（可观测性）
        const requestId = `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
        config.headers['X-Request-Id'] = requestId

        return config
    },
    (error: AxiosError) => {
        console.error('请求拦截器错误:', error)
        return Promise.reject(error)
    }
)

/**
 * 响应拦截器
 * - 统一处理业务错误码
 * - Token 过期自动刷新
 * - 租户权限检查
 */
service.interceptors.response.use(
    (response: AxiosResponse<ApiResponse>) => {
        const { code, message, data } = response.data

        // 成功响应
        if (code === 200 || code === 0) {
            return data
        }

        // 业务错误
        ElMessage.error(message || '请求失败')
        return Promise.reject(new Error(message || '请求失败'))
    },
    async (error: AxiosError<ApiResponse>) => {
        const { response } = error

        if (!response) {
            ElMessage.error('网络连接失败，请检查网络')
            return Promise.reject(error)
        }

        const { status, data } = response

        switch (status) {
            case 401:
                // Token 过期或未认证
                ElMessage.error('登录已过期，请重新登录')
                const userStore = useUserStore()
                userStore.logout()
                window.location.href = '/login'
                break

            case 403:
                // 权限不足
                ElMessage.error(data?.message || '权限不足，无法访问')
                break

            case 404:
                ElMessage.error('请求的资源不存在')
                break

            case 429:
                // 租户配额超限
                ElMessage.error(data?.message || '请求过于频繁，请稍后再试')
                break

            case 500:
                ElMessage.error(data?.message || '服务器错误，请联系管理员')
                break

            default:
                ElMessage.error(data?.message || `请求失败 (${status})`)
        }

        return Promise.reject(error)
    }
)

/**
 * 通用请求方法
 */
export const request = {
    get<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
        return service.get(url, config)
    },

    post<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
        return service.post(url, data, config)
    },

    put<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
        return service.put(url, data, config)
    },

    delete<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
        return service.delete(url, config)
    },

    patch<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
        return service.patch(url, data, config)
    }
}

export default service
