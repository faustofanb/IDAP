-- V006: 创建系统管理表
-- 描述: 白名单、审计日志、反馈、系统配置
-- 日期: 2025-01-15

-- 表白名单
CREATE TABLE IF NOT EXISTS table_whitelist (
    whitelist_id BIGSERIAL PRIMARY KEY,
    schema_name VARCHAR(100) DEFAULT 'public',
    table_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(200),
    description TEXT,
    allowed_columns JSONB NOT NULL DEFAULT '[]',
    sample_queries JSONB DEFAULT '[]',
    max_rows INTEGER DEFAULT 1000,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'disabled')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(schema_name, table_name)
);

-- 审计日志
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id) ON DELETE SET NULL,
    action_type VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    details JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    status VARCHAR(20) CHECK (status IN ('success', 'failed')),
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 用户反馈
CREATE TABLE IF NOT EXISTS feedback (
    feedback_id BIGSERIAL PRIMARY KEY,
    query_id BIGINT REFERENCES queries(query_id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    feedback_type VARCHAR(20) CHECK (feedback_type IN ('accurate', 'helpful', 'incorrect', 'slow', 'other')),
    feedback_text TEXT,
    is_resolved BOOLEAN DEFAULT false,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 系统配置
CREATE TABLE IF NOT EXISTS system_config (
    config_id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    config_type VARCHAR(50) DEFAULT 'general' CHECK (config_type IN ('llm', 'database', 'rag', 'feature_flag', 'ui', 'security', 'general')),
    is_public BOOLEAN DEFAULT false,
    is_encrypted BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_table_whitelist_status ON table_whitelist(status);
CREATE INDEX IF NOT EXISTS idx_table_whitelist_table_name ON table_whitelist(table_name);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action_type ON audit_logs(action_type);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_resource ON audit_logs(resource_type, resource_id);

CREATE INDEX IF NOT EXISTS idx_feedback_query_id ON feedback(query_id);
CREATE INDEX IF NOT EXISTS idx_feedback_user_id ON feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_rating ON feedback(rating);
CREATE INDEX IF NOT EXISTS idx_feedback_is_resolved ON feedback(is_resolved);

CREATE INDEX IF NOT EXISTS idx_system_config_config_type ON system_config(config_type);
CREATE INDEX IF NOT EXISTS idx_system_config_is_public ON system_config(is_public);

-- 添加注释
COMMENT ON TABLE table_whitelist IS '表白名单 - SQL查询权限控制';
COMMENT ON TABLE audit_logs IS '审计日志 - 记录所有用户操作';
COMMENT ON TABLE feedback IS '用户反馈 - 收集查询结果反馈';
COMMENT ON TABLE system_config IS '系统配置 - 存储系统参数';
COMMENT ON COLUMN table_whitelist.allowed_columns IS '允许查询的列（JSONB数组）';
COMMENT ON COLUMN audit_logs.details IS '操作详情（JSONB，包含SQL、参数等）';
