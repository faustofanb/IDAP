/**
 * 数据字典 API
 */
import type { paths } from '@/types/api'
import request from './request'

// 类型定义
type DictTypeListParams = paths['/dict/types']['get']['parameters']['query']
type DictTypeListResponse = paths['/dict/types']['get']['responses']['200']['content']['application/json']
type DictDataListResponse = paths['/dict/data/{dictCode}']['get']['responses']['200']['content']['application/json']

/**
 * 获取字典类型列表
 */
export const getDictTypeList = (params?: DictTypeListParams) => {
    return request.get<DictTypeListResponse>('/dict/types', { params })
}

/**
 * 获取字典数据列表
 */
export const getDictDataList = (dictCode: string) => {
    return request.get<DictDataListResponse>(`/dict/data/${dictCode}`)
}

/**
 * 根据字典值获取标签
 */
export const getDictLabel = (dictCode: string, dictValue: string) => {
    return request.get<string>(`/dict/label/${dictCode}/${dictValue}`)
}

/**
 * 根据字典类型获取所有字典项（常用于下拉选择）
 */
export const getDictOptions = async (dictCode: string) => {
    const res = await getDictDataList(dictCode)
    return (res.data as any) || []
}
