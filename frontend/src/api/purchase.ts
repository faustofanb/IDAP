/**
 * 采购管理 API
 */
import type { paths } from '@/types/api'
import request from './request'

// 类型定义
type PurchaseOrderListParams = paths['/purchase/orders']['get']['parameters']['query']
type PurchaseOrderListResponse = paths['/purchase/orders']['get']['responses']['200']['content']['application/json']
type PurchaseOrderCreateRequest = paths['/purchase/orders']['post']['requestBody']['content']['application/json']
type PurchaseOrderDetailResponse = paths['/purchase/orders/{id}']['get']['responses']['200']['content']['application/json']

/**
 * 获取采购订单列表（分页）
 */
export const getPurchaseOrderList = (params: PurchaseOrderListParams) => {
    return request.get<PurchaseOrderListResponse>('/purchase/orders', { params })
}

/**
 * 创建采购订单
 */
export const createPurchaseOrder = (data: PurchaseOrderCreateRequest) => {
    return request.post('/purchase/orders', data)
}

/**
 * 获取采购订单详情
 */
export const getPurchaseOrderDetail = (id: number) => {
    return request.get<PurchaseOrderDetailResponse>(`/purchase/orders/${id}`)
}

/**
 * 删除采购订单（软删除，仅草稿状态可删除）
 */
export const deletePurchaseOrder = (id: number) => {
    return request.delete(`/purchase/orders/${id}`)
}

/**
 * 提交采购订单审核
 */
export const submitPurchaseOrder = (id: number) => {
    return request.post(`/purchase/orders/${id}/submit`)
}

/**
 * 审核通过采购订单
 */
export const approvePurchaseOrder = (id: number, data: { remark?: string }) => {
    return request.post(`/purchase/orders/${id}/approve`, data)
}

/**
 * 审核拒绝采购订单
 */
export const rejectPurchaseOrder = (id: number, data: { remark: string }) => {
    return request.post(`/purchase/orders/${id}/reject`, data)
}
