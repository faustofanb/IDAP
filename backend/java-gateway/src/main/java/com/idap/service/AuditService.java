package com.idap.service;

import org.springframework.stereotype.Service;

/**
 * 审计日志服务
 * 记录所有用户操作
 */
@Service
public class AuditService {

    /**
     * 记录查询操作
     */
    public void logQuery(Long userId, String question, String sql) {
        // TODO: 保存到 audit_logs 表
    }

    /**
     * 记录用户操作
     */
    public void logAction(Long userId, String action, String resource) {
        // TODO: 记录操作日志
    }
}
