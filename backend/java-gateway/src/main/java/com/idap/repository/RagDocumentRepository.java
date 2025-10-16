package com.idap.repository;

import com.idap.entity.RagDocument;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * RAG 文档 Repository
 */
@Repository
public interface RagDocumentRepository extends JpaRepository<RagDocument, Long> {

    /**
     * 根据标题查找文档
     */
    Optional<RagDocument> findByTitle(String title);

    /**
     * 根据内容哈希查找（去重）
     */
    Optional<RagDocument> findByContentHash(String contentHash);

    /**
     * 根据分类查找文档
     */
    List<RagDocument> findByCategory(String category);

    /**
     * 根据状态查找文档
     */
    List<RagDocument> findByStatus(RagDocument.DocumentStatus status);

    /**
     * 根据状态分页查找
     */
    Page<RagDocument> findByStatus(RagDocument.DocumentStatus status, Pageable pageable);

    /**
     * 根据来源类型查找文档
     */
    List<RagDocument> findBySourceType(RagDocument.SourceType sourceType);

    /**
     * 根据向量存储类型查找文档
     */
    List<RagDocument> findByVectorStoreType(String vectorStoreType);

    /**
     * 查找已索引的文档
     */
    @Query("SELECT d FROM RagDocument d WHERE d.status = 'ACTIVE' AND d.indexedAt IS NOT NULL")
    List<RagDocument> findIndexedDocuments();

    /**
     * 查找待索引的文档
     */
    @Query("SELECT d FROM RagDocument d WHERE d.status = 'PENDING' ORDER BY d.createdAt")
    List<RagDocument> findPendingDocuments();

    /**
     * 查找索引失败的文档
     */
    @Query("SELECT d FROM RagDocument d WHERE d.status = 'ERROR' ORDER BY d.createdAt DESC")
    List<RagDocument> findErrorDocuments();

    /**
     * 按分类统计文档数量
     */
    @Query("SELECT d.category, COUNT(d) FROM RagDocument d GROUP BY d.category")
    List<Object[]> countByCategory();

    /**
     * 按状态统计文档数量
     */
    @Query("SELECT d.status, COUNT(d) FROM RagDocument d GROUP BY d.status")
    List<Object[]> countByStatus();

    /**
     * 搜索文档（标题或内容包含关键词）
     */
    @Query("SELECT d FROM RagDocument d WHERE " +
            "LOWER(d.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(d.content) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    Page<RagDocument> searchDocuments(@Param("keyword") String keyword, Pageable pageable);
}
