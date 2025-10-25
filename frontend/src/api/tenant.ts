/**
 * 租户管理 API
 */
import type { paths } from '@/types/api'
import request from './request'

// 类型定义
type TenantListParams = paths['/tenants']['get']['parameters']['query']
type TenantListResponse = paths['/tenants']['get']['responses']['200']['content']['application/json']
type TenantCreateRequest = paths['/tenants']['post']['requestBody']['content']['application/json']
type TenantDetailResponse = paths['/tenants/{id}']['get']['responses']['200']['content']['application/json']
type TenantUpdateRequest = paths['/tenants/{id}']['put']['requestBody']['content']['application/json']

/**
 * 获取租户列表（分页）
 */
export const getTenantList = (params: TenantListParams) => {
    return request.get<TenantListResponse>('/tenants', { params })
}

/**
 * 创建租户
 */
export const createTenant = (data: TenantCreateRequest) => {
    return request.post('/tenants', data)
}

/**
 * 获取租户详情
 */
export const getTenantDetail = (id: number) => {
    return request.get<TenantDetailResponse>(`/tenants/${id}`)
}

/**
 * 更新租户
 */
export const updateTenant = (id: number, data: TenantUpdateRequest) => {
    return request.put(`/tenants/${id}`, data)
}

/**
 * 删除租户（软删除）
 */
export const deleteTenant = (id: number) => {
    return request.delete(`/tenants/${id}`)
}
