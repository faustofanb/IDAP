package com.idap.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

/**
 * 查询控制器
 * 处理用户查询请求（NL2SQL、RAG）
 */
@RestController
@RequestMapping("/query")
public class QueryController {

    /**
     * 提交查询（同步）
     */
    @PostMapping
    public Object submitQuery() {
        // TODO: 实现同步查询
        return null;
    }

    /**
     * 流式查询（SSE）
     */
    @GetMapping(value = "/stream", produces = "text/event-stream")
    public SseEmitter streamQuery() {
        // TODO: 实现流式查询
        return null;
    }

    /**
     * 获取查询历史
     */
    @GetMapping("/history")
    public Object getQueryHistory() {
        // TODO: 实现查询历史
        return null;
    }
}
