-- V003: 创建查询记录表
-- 描述: 存储用户查询历史和执行结果
-- 日期: 2025-01-15

CREATE TABLE IF NOT EXISTS queries (
    query_id BIGSERIAL PRIMARY KEY,
    session_id UUID REFERENCES sessions(session_id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    intent VARCHAR(50) CHECK (intent IN ('nl2sql', 'rag', 'chat', 'analysis')),
    generated_sql TEXT,
    executed_sql TEXT,
    sql_status VARCHAR(20) DEFAULT 'pending' CHECK (sql_status IN ('pending', 'success', 'error', 'timeout')),
    result_data JSONB,
    result_rows INTEGER,
    chart_config JSONB,
    chart_type VARCHAR(50),
    answer TEXT,
    insights TEXT,
    error_message TEXT,
    execution_time_ms INTEGER,
    token_count INTEGER,
    model_name VARCHAR(100),
    confidence_score DECIMAL(3, 2),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_queries_session_id ON queries(session_id);
CREATE INDEX IF NOT EXISTS idx_queries_user_id ON queries(user_id);
CREATE INDEX IF NOT EXISTS idx_queries_created_at ON queries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_queries_sql_status ON queries(sql_status);
CREATE INDEX IF NOT EXISTS idx_queries_intent ON queries(intent);
CREATE INDEX IF NOT EXISTS idx_queries_user_created ON queries(user_id, created_at DESC);

-- 全文搜索索引（用于搜索问题）
CREATE INDEX IF NOT EXISTS idx_queries_question_fts ON queries USING gin(to_tsvector('simple', question));

-- 添加注释
COMMENT ON TABLE queries IS '查询记录表 - 存储所有用户查询历史';
COMMENT ON COLUMN queries.intent IS '查询意图: nl2sql-SQL查询, rag-知识检索, chat-对话, analysis-分析';
COMMENT ON COLUMN queries.sql_status IS 'SQL执行状态: pending-待执行, success-成功, error-失败, timeout-超时';
COMMENT ON COLUMN queries.result_data IS '查询结果数据（JSONB，限制大小）';
COMMENT ON COLUMN queries.chart_config IS 'ECharts图表配置（JSONB）';
COMMENT ON COLUMN queries.confidence_score IS 'AI生成置信度（0-1）';
