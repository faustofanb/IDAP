/**
 * 库存管理 API
 */
import type { paths } from '@/types/api'
import request from './request'

// 类型定义
type StockListParams = paths['/stocks']['get']['parameters']['query']
type StockListResponse = paths['/stocks']['get']['responses']['200']['content']['application/json']
type StockLogParams = paths['/stocks/logs']['get']['parameters']['query']
type StockLogResponse = paths['/stocks/logs']['get']['responses']['200']['content']['application/json']

/**
 * 获取库存列表（分页）
 */
export const getStockList = (params: StockListParams) => {
    return request.get<StockListResponse>('/stocks', { params })
}

/**
 * 获取库存日志（分页）
 */
export const getStockLogs = (params: StockLogParams) => {
    return request.get<StockLogResponse>('/stocks/logs', { params })
}
