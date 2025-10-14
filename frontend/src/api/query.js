import api from './index'

/**
 * 提交查询
 */
export function submitQuery(question, sessionId) {
    // TODO: 实现查询 API 调用
    return api.post('/query', { question, session_id: sessionId })
}

/**
 * 获取查询历史
 */
export function getQueryHistory(sessionId) {
    // TODO: 实现获取历史记录 API 调用
    return api.get(`/query/history`, { params: { session_id: sessionId } })
}
