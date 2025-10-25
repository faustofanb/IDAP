/**
 * 用户管理 API
 */
import type { paths } from '@/types/api'
import request from './request'

// 类型定义
type UserListParams = paths['/users']['get']['parameters']['query']
type UserListResponse = paths['/users']['get']['responses']['200']['content']['application/json']
type UserCreateRequest = paths['/users']['post']['requestBody']['content']['application/json']
type UserDetailResponse = paths['/users/{id}']['get']['responses']['200']['content']['application/json']
type UserUpdateRequest = paths['/users/{id}']['put']['requestBody']['content']['application/json']
type ResetPasswordRequest = paths['/users/{id}/reset-password']['post']['requestBody']['content']['application/json']

/**
 * 获取用户列表（分页）
 */
export const getUserList = (params: UserListParams) => {
    return request.get<UserListResponse>('/users', { params })
}

/**
 * 创建用户
 */
export const createUser = (data: UserCreateRequest) => {
    return request.post('/users', data)
}

/**
 * 获取用户详情
 */
export const getUserDetail = (id: number) => {
    return request.get<UserDetailResponse>(`/users/${id}`)
}

/**
 * 更新用户
 */
export const updateUser = (id: number, data: UserUpdateRequest) => {
    return request.put(`/users/${id}`, data)
}

/**
 * 删除用户（软删除）
 */
export const deleteUser = (id: number) => {
    return request.delete(`/users/${id}`)
}

/**
 * 重置用户密码
 */
export const resetPassword = (id: number, data: ResetPasswordRequest) => {
    return request.post(`/users/${id}/reset-password`, data)
}
