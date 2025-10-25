/**
 * 认证授权 API
 */
import type { paths } from '@/types/api'
import request from './request'

// 类型定义
type LoginRequest = paths['/auth/login']['post']['requestBody']['content']['application/json']
type LoginResponse = paths['/auth/login']['post']['responses']['200']['content']['application/json']
type UserInfoResponse = paths['/auth/userinfo']['get']['responses']['200']['content']['application/json']

/**
 * 用户登录
 */
export const login = (data: LoginRequest) => {
    return request.post<LoginResponse>('/auth/login', data)
}

/**
 * 退出登录
 */
export const logout = () => {
    return request.post('/auth/logout')
}

/**
 * 刷新令牌
 */
export const refreshToken = (refreshToken: string) => {
    return request.post('/auth/refresh', { refreshToken })
}

/**
 * 获取当前用户信息
 */
export const getUserInfo = () => {
    return request.get<UserInfoResponse>('/auth/userinfo')
}
