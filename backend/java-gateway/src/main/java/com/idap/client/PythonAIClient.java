package com.idap.client;

import org.springframework.stereotype.Component;

/**
 * Python AI Engine WebSocket 客户端
 * 负责与 Python AI Engine 通信
 */
@Component
public class PythonAIClient {

    /**
     * 生成 SQL
     */
    public Object generateSql(String question, Object schema) {
        // TODO: 构建 JSON-RPC 请求
        // TODO: 通过 WebSocket 发送
        // TODO: 等待响应
        return null;
    }

    /**
     * RAG 查询
     */
    public Object ragQuery(String question) {
        // TODO: 调用 Python RAG 服务
        return null;
    }

    /**
     * LLM 对话
     */
    public Object chat(String message) {
        // TODO: 调用 Python LLM 服务
        return null;
    }
}
