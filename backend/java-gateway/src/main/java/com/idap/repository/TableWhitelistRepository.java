package com.idap.repository;

import com.idap.entity.TableWhitelist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 表白名单 Repository
 */
@Repository
public interface TableWhitelistRepository extends JpaRepository<TableWhitelist, Long> {

    /**
     * 根据schema和表名查找
     */
    Optional<TableWhitelist> findBySchemaNameAndTableName(String schemaName, String tableName);

    /**
     * 根据表名查找（默认schema为public）
     */
    default Optional<TableWhitelist> findByTableName(String tableName) {
        return findBySchemaNameAndTableName("public", tableName);
    }

    /**
     * 查找所有激活的表
     */
    List<TableWhitelist> findByStatus(TableWhitelist.WhitelistStatus status);

    /**
     * 查找激活的表（按schema分组）
     */
    @Query("SELECT w FROM TableWhitelist w WHERE w.status = 'ACTIVE' ORDER BY w.schemaName, w.tableName")
    List<TableWhitelist> findAllActiveTables();

    /**
     * 检查表是否在白名单中
     */
    @Query("SELECT CASE WHEN COUNT(w) > 0 THEN true ELSE false END FROM TableWhitelist w " +
            "WHERE w.schemaName = :schemaName AND w.tableName = :tableName AND w.status = 'ACTIVE'")
    boolean isTableWhitelisted(@Param("schemaName") String schemaName,
            @Param("tableName") String tableName);

    /**
     * 获取所有白名单表名列表
     */
    @Query("SELECT w.tableName FROM TableWhitelist w WHERE w.status = 'ACTIVE'")
    List<String> findAllWhitelistedTableNames();
}
