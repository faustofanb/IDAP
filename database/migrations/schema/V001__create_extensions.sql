-- V001: 创建 PostgreSQL 扩展
-- 描述: 安装项目所需的扩展（UUID、全文搜索、向量）
-- 日期: 2025-01-15

-- UUID 生成扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 全文搜索扩展
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 向量扩展（用于 RAG，如果使用 pgvector）
-- CREATE EXTENSION IF NOT EXISTS vector;

-- 确认扩展安装
SELECT extname, extversion
FROM pg_extension
WHERE extname IN ('uuid-ossp', 'pg_trgm')
ORDER BY extname;
