/**
 * 角色管理 API
 */
import request from './request'

// 角色数据类型
export interface RoleVO {
    id?: number
    roleCode?: string
    roleName?: string
    roleType?: string
    description?: string
    status?: string
    sort?: number
    createdAt?: string
    updatedAt?: string
}

export interface RoleCreateRequest {
    roleCode: string
    roleName: string
    roleType?: string
    description?: string
    status?: string
    sort?: number
    permissionIds?: number[]
}

export interface RoleListParams {
    page?: number
    size?: number
    roleName?: string
    roleCode?: string
    status?: string
}

export interface PageResponse<T> {
    records: T[]
    total: number
    size: number
    current: number
    pages: number
}

/**
 * 获取角色列表（分页）
 */
export const getRoleList = (params: RoleListParams) => {
    return request.get<PageResponse<RoleVO>>('/roles', { params })
}

/**
 * 创建角色
 */
export const createRole = (data: RoleCreateRequest) => {
    return request.post('/roles', data)
}

/**
 * 获取角色详情
 */
export const getRoleDetail = (id: number) => {
    return request.get<RoleVO>(`/roles/${id}`)
}

/**
 * 更新角色
 */
export const updateRole = (id: number, data: RoleCreateRequest) => {
    return request.put(`/roles/${id}`, data)
}

/**
 * 删除角色
 */
export const deleteRole = (id: number) => {
    return request.delete(`/roles/${id}`)
}

/**
 * 批量删除角色
 */
export const batchDeleteRoles = (ids: number[]) => {
    return request.delete('/roles/batch', { data: { ids } })
}

/**
 * 分配权限
 */
export const assignPermissions = (roleId: number, permissionIds: number[]) => {
    return request.post(`/roles/${roleId}/permissions`, { permissionIds })
}
