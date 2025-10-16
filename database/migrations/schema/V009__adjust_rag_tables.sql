-- V009: 调整 RAG 表结构 - 移除 rag_chunks 表
-- 描述: 向量存储迁移到 Python 端（FAISS/Milvus），PostgreSQL 只保留文档元数据
-- 日期: 2025-01-15
-- 理由:
--   1. Java 不需要访问向量数据
--   2. Python AI Engine 独占管理向量存储
--   3. 简化数据库设计，提高性能

-- 1. 删除 rag_chunks 表（向量块迁移到 FAISS/Milvus）
DROP TABLE IF EXISTS rag_chunks CASCADE;

-- 2. 调整 rag_documents 表
-- 2.1 删除不需要的字段
ALTER TABLE rag_documents
DROP COLUMN IF EXISTS embedding_model;

-- 2.2 添加向量存储相关字段
ALTER TABLE rag_documents
ADD COLUMN IF NOT EXISTS vector_store_type VARCHAR(20) DEFAULT 'faiss'
    CHECK (vector_store_type IN ('faiss', 'milvus', 'chroma', 'qdrant')),
ADD COLUMN IF NOT EXISTS vector_collection VARCHAR(100),
ADD COLUMN IF NOT EXISTS chunk_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS error_message TEXT;

-- 2.3 创建新索引
CREATE INDEX IF NOT EXISTS idx_rag_documents_vector_store
    ON rag_documents(vector_store_type);
CREATE INDEX IF NOT EXISTS idx_rag_documents_vector_collection
    ON rag_documents(vector_collection);

-- 3. 添加注释
COMMENT ON COLUMN rag_documents.vector_store_type IS '向量存储类型: faiss(开发)/milvus(生产)/chroma(备选)/qdrant(备选)';
COMMENT ON COLUMN rag_documents.vector_collection IS '向量数据库中的集合/索引名称';
COMMENT ON COLUMN rag_documents.chunk_count IS '文档分块数量（用于统计）';
COMMENT ON COLUMN rag_documents.error_message IS '索引失败时的错误信息';

-- 4. 更新现有记录（如果有）
UPDATE rag_documents
SET vector_store_type = 'faiss',
    vector_collection = 'idap_knowledge_' || doc_id,
    chunk_count = 0
WHERE vector_store_type IS NULL;

-- 验证
DO $$
BEGIN
    RAISE NOTICE '✅ RAG 表结构调整完成';
    RAISE NOTICE '   - 已删除 rag_chunks 表';
    RAISE NOTICE '   - 向量存储迁移到 Python 端（FAISS/Milvus）';
    RAISE NOTICE '   - PostgreSQL 只保留文档元数据';
END $$;
