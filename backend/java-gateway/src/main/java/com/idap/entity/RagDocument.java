package com.idap.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

/**
 * RAG 文档实体类
 * 对应数据库表: rag_documents
 */
@Entity
@Table(name = "rag_documents", indexes = {
        @Index(name = "idx_rag_documents_category", columnList = "category"),
        @Index(name = "idx_rag_documents_status", columnList = "status"),
        @Index(name = "idx_rag_documents_content_hash", columnList = "content_hash")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RagDocument {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "doc_id")
    private Long docId;

    @Column(name = "title", nullable = false, length = 500)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(name = "source_type", length = 50)
    @Builder.Default
    private SourceType sourceType = SourceType.MANUAL;

    @Column(name = "source_url", columnDefinition = "TEXT")
    private String sourceUrl;

    @Column(name = "category", length = 100)
    private String category;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "tags", columnDefinition = "text[]")
    private String[] tags;

    @Column(name = "content", nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "content_hash", unique = true, length = 64)
    private String contentHash;

    @Column(name = "file_size")
    private Integer fileSize;

    @Column(name = "file_type", length = 50)
    private String fileType;

    @Column(name = "embedding_model", length = 100)
    @Builder.Default
    private String embeddingModel = "text-embedding-ada-002";

    // 新增字段：向量存储类型（根据 V009 迁移）
    @Column(name = "vector_store_type", length = 20)
    @Builder.Default
    private String vectorStoreType = "faiss";

    // 新增字段：向量集合名称
    @Column(name = "vector_collection", length = 100)
    private String vectorCollection;

    // 新增字段：分块数量
    @Column(name = "chunk_count")
    @Builder.Default
    private Integer chunkCount = 0;

    // 新增字段：错误信息
    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 20)
    @Builder.Default
    private DocumentStatus status = DocumentStatus.PENDING;

    @Column(name = "indexed_at")
    private LocalDateTime indexedAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", referencedColumnName = "user_id")
    private User createdBy;

    /**
     * 文档来源类型枚举
     */
    public enum SourceType {
        FILE("file"),
        URL("url"),
        MANUAL("manual"),
        API("api");

        private final String value;

        SourceType(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }

    /**
     * 文档状态枚举
     */
    public enum DocumentStatus {
        PENDING("pending"),
        INDEXING("indexing"),
        ACTIVE("active"),
        ERROR("error");

        private final String value;

        DocumentStatus(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }
}
