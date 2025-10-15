-- V004: 创建 RAG 知识库表
-- 描述: 文档表和文档块表（用于向量检索）
-- 日期: 2025-01-15

-- 文档表
CREATE TABLE IF NOT EXISTS rag_documents (
    doc_id BIGSERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    source_type VARCHAR(50) DEFAULT 'manual' CHECK (source_type IN ('file', 'url', 'manual', 'api')),
    source_url TEXT,
    category VARCHAR(100),
    tags TEXT[],
    content TEXT NOT NULL,
    content_hash VARCHAR(64) UNIQUE,
    file_size INTEGER,
    file_type VARCHAR(50),
    embedding_model VARCHAR(100) DEFAULT 'text-embedding-ada-002',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'indexing', 'active', 'error', 'archived')),
    indexed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES users(user_id)
);

-- 文档块表（用于向量检索）
CREATE TABLE IF NOT EXISTS rag_chunks (
    chunk_id BIGSERIAL PRIMARY KEY,
    doc_id BIGINT NOT NULL REFERENCES rag_documents(doc_id) ON DELETE CASCADE,
    chunk_index INTEGER NOT NULL,
    chunk_text TEXT NOT NULL,
    -- embedding vector(1536),  -- 如果使用 pgvector
    vector_id VARCHAR(100),  -- Milvus 向量 ID
    token_count INTEGER,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(doc_id, chunk_index)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_rag_documents_category ON rag_documents(category);
CREATE INDEX IF NOT EXISTS idx_rag_documents_status ON rag_documents(status);
CREATE INDEX IF NOT EXISTS idx_rag_documents_tags ON rag_documents USING gin(tags);
CREATE INDEX IF NOT EXISTS idx_rag_documents_content_hash ON rag_documents(content_hash);
CREATE INDEX IF NOT EXISTS idx_rag_documents_created_at ON rag_documents(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_rag_chunks_doc_id ON rag_chunks(doc_id);
CREATE INDEX IF NOT EXISTS idx_rag_chunks_vector_id ON rag_chunks(vector_id);

-- 全文搜索索引
CREATE INDEX IF NOT EXISTS idx_rag_documents_content_fts ON rag_documents USING gin(to_tsvector('simple', content));
CREATE INDEX IF NOT EXISTS idx_rag_chunks_text_fts ON rag_chunks USING gin(to_tsvector('simple', chunk_text));

-- 添加注释
COMMENT ON TABLE rag_documents IS 'RAG文档表 - 存储知识库文档';
COMMENT ON TABLE rag_chunks IS 'RAG文档块表 - 存储向量化的文档片段';
COMMENT ON COLUMN rag_documents.content_hash IS 'SHA-256内容哈希（用于去重）';
COMMENT ON COLUMN rag_chunks.vector_id IS 'Milvus向量数据库中的ID';
