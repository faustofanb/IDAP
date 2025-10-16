package com.idap.repository;

import com.idap.entity.AuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 审计日志 Repository
 */
@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    /**
     * 根据用户ID查找审计日志
     */
    Page<AuditLog> findByUser_UserId(Long userId, Pageable pageable);

    /**
     * 根据操作类型查找
     */
    List<AuditLog> findByActionType(String actionType);

    /**
     * 根据资源类型查找
     */
    List<AuditLog> findByResourceType(String resourceType);

    /**
     * 根据时间范围查找
     */
    Page<AuditLog> findByCreatedAtBetween(LocalDateTime startTime,
            LocalDateTime endTime,
            Pageable pageable);

    /**
     * 查找特定用户在时间范围内的操作记录
     */
    @Query("SELECT a FROM AuditLog a WHERE a.user.userId = :userId " +
            "AND a.createdAt BETWEEN :startTime AND :endTime " +
            "ORDER BY a.createdAt DESC")
    Page<AuditLog> findUserActivityLogs(@Param("userId") Long userId,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime,
            Pageable pageable);

    /**
     * 统计操作类型分布
     */
    @Query("SELECT a.actionType, COUNT(a) FROM AuditLog a " +
            "WHERE a.createdAt BETWEEN :startTime AND :endTime " +
            "GROUP BY a.actionType " +
            "ORDER BY COUNT(a) DESC")
    List<Object[]> countByActionType(@Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime);

    /**
     * 查找最近的审计日志
     */
    Page<AuditLog> findAllByOrderByCreatedAtDesc(Pageable pageable);

    /**
     * 根据IP地址查找
     */
    List<AuditLog> findByIpAddress(String ipAddress);
}
