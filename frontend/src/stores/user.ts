/**
 * 用户状态管理 Store
 * 管理用户认证、租户信息、权限缓存
 */
import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

/**
 * 用户信息接口
 */
export interface UserInfo {
    id: string
    username: string
    realName: string
    email: string
    phone: string
    avatar?: string
    tenantId: string
    tenantName: string
    roles: string[]
    permissions: string[]
}

/**
 * 用户 Store
 */
export const useUserStore = defineStore('user', () => {
    // 状态
    const token = ref<string>('')
    const refreshToken = ref<string>('')
    const userInfo = ref<UserInfo | null>(null)
    const tenantId = ref<string>('')

    // 计算属性
    const isLoggedIn = computed(() => !!token.value && !!userInfo.value)
    const username = computed(() => userInfo.value?.username || '')
    const realName = computed(() => userInfo.value?.realName || '')
    const roles = computed(() => userInfo.value?.roles || [])
    const permissions = computed(() => userInfo.value?.permissions || [])

    /**
     * 设置 Token
     */
    function setToken(newToken: string, newRefreshToken?: string) {
        token.value = newToken
        if (newRefreshToken) {
            refreshToken.value = newRefreshToken
        }
        // 持久化到 localStorage
        localStorage.setItem('token', newToken)
        if (newRefreshToken) {
            localStorage.setItem('refreshToken', newRefreshToken)
        }
    }

    /**
     * 设置用户信息
     */
    function setUserInfo(info: UserInfo) {
        userInfo.value = info
        tenantId.value = info.tenantId
        // 持久化到 localStorage
        localStorage.setItem('userInfo', JSON.stringify(info))
        localStorage.setItem('tenantId', info.tenantId)
    }

    /**
     * 检查权限
     * 支持通配符 (*:*:*)
     */
    function hasPermission(permission: string): boolean {
        const perms = permissions.value

        // 如果有超级管理员权限，直接通过
        if (perms.includes('*:*:*')) {
            return true
        }

        // 精确匹配
        if (perms.includes(permission)) {
            return true
        }

        // 通配符匹配
        const parts = permission.split(':')
        for (const perm of perms) {
            const permParts = perm.split(':')
            let matched = true

            for (let i = 0; i < Math.max(parts.length, permParts.length); i++) {
                const part = parts[i] || ''
                const permPart = permParts[i] || ''

                if (permPart !== '*' && part !== permPart) {
                    matched = false
                    break
                }
            }

            if (matched) {
                return true
            }
        }

        return false
    }

    /**
     * 检查角色
     */
    function hasRole(role: string): boolean {
        return roles.value.includes(role)
    }

    /**
     * 登出
     */
    function logout() {
        token.value = ''
        refreshToken.value = ''
        userInfo.value = null
        tenantId.value = ''

        // 清除持久化数据
        localStorage.removeItem('token')
        localStorage.removeItem('refreshToken')
        localStorage.removeItem('userInfo')
        localStorage.removeItem('tenantId')
    }

    /**
     * 从 localStorage 恢复状态
     */
    function restoreFromStorage() {
        const storedToken = localStorage.getItem('token')
        const storedRefreshToken = localStorage.getItem('refreshToken')
        const storedUserInfo = localStorage.getItem('userInfo')
        const storedTenantId = localStorage.getItem('tenantId')

        if (storedToken) {
            token.value = storedToken
        }
        if (storedRefreshToken) {
            refreshToken.value = storedRefreshToken
        }
        if (storedUserInfo) {
            try {
                userInfo.value = JSON.parse(storedUserInfo)
            } catch (e) {
                console.error('解析用户信息失败:', e)
            }
        }
        if (storedTenantId) {
            tenantId.value = storedTenantId
        }
    }

    return {
        // 状态
        token,
        refreshToken,
        userInfo,
        tenantId,

        // 计算属性
        isLoggedIn,
        username,
        realName,
        roles,
        permissions,

        // 方法
        setToken,
        setUserInfo,
        hasPermission,
        hasRole,
        logout,
        restoreFromStorage
    }
})
