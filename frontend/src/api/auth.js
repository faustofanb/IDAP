import api from './index'

/**
 * 用户登录
 */
export function login(username, password) {
    // TODO: 实现登录 API 调用
    return api.post('/auth/login', { username, password })
}

/**
 * 用户登出
 */
export function logout() {
    // TODO: 实现登出 API 调用
    return api.post('/auth/logout')
}

/**
 * 获取当前用户信息
 */
export function getCurrentUser() {
    // TODO: 实现获取用户信息 API 调用
    return api.get('/auth/me')
}
