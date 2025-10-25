/**
 * 产品管理 API
 */
import type { paths } from '@/types/api'
import request from './request'

// 类型定义
type ProductListParams = paths['/products']['get']['parameters']['query']
type ProductListResponse = paths['/products']['get']['responses']['200']['content']['application/json']
type ProductCreateRequest = paths['/products']['post']['requestBody']['content']['application/json']

/**
 * 获取产品列表（分页）
 */
export const getProductList = (params: ProductListParams) => {
    return request.get<ProductListResponse>('/products', { params })
}

/**
 * 创建产品
 */
export const createProduct = (data: ProductCreateRequest) => {
    return request.post('/products', data)
}

/**
 * 获取产品详情
 */
export const getProductDetail = (id: number) => {
    return request.get(`/products/${id}`)
}

/**
 * 更新产品
 */
export const updateProduct = (id: number, data: ProductCreateRequest) => {
    return request.put(`/products/${id}`, data)
}

/**
 * 删除产品（软删除）
 */
export const deleteProduct = (id: number) => {
    return request.delete(`/products/${id}`)
}
