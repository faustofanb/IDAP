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
 * 表白名单实体类
 * 对应数据库表: table_whitelist
 */
@Entity
@Table(name = "table_whitelist", uniqueConstraints = @UniqueConstraint(columnNames = { "schema_name",
        "table_name" }), indexes = {
                @Index(name = "idx_table_whitelist_status", columnList = "status")
        })
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TableWhitelist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "whitelist_id")
    private Long whitelistId;

    @Column(name = "schema_name", length = 100)
    @Builder.Default
    private String schemaName = "public";

    @Column(name = "table_name", nullable = false, length = 100)
    private String tableName;

    @Column(name = "display_name", length = 200)
    private String displayName;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "allowed_columns", nullable = false, columnDefinition = "jsonb")
    @Builder.Default
    private String allowedColumns = "[]";

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "sample_queries", columnDefinition = "jsonb")
    @Builder.Default
    private String sampleQueries = "[]";

    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 20)
    @Builder.Default
    private WhitelistStatus status = WhitelistStatus.ACTIVE;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    /**
     * 白名单状态枚举
     */
    public enum WhitelistStatus {
        ACTIVE("active"),
        DISABLED("disabled");

        private final String value;

        WhitelistStatus(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }
}
