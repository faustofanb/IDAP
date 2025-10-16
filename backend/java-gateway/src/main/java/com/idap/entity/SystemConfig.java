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
 * 系统配置实体类
 * 对应数据库表: system_config
 */
@Entity
@Table(name = "system_config", indexes = {
        @Index(name = "idx_system_config_config_type", columnList = "config_type"),
        @Index(name = "idx_system_config_is_public", columnList = "is_public")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SystemConfig {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "config_id")
    private Long configId;

    @Column(name = "config_key", unique = true, nullable = false, length = 100)
    private String configKey;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "config_value", nullable = false, columnDefinition = "jsonb")
    private String configValue;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "config_type", length = 50)
    @Builder.Default
    private ConfigType configType = ConfigType.GENERAL;

    @Column(name = "is_public")
    @Builder.Default
    private Boolean isPublic = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    /**
     * 配置类型枚举
     */
    public enum ConfigType {
        LLM("llm"),
        DATABASE("database"),
        RAG("rag"),
        FEATURE_FLAG("feature_flag"),
        UI("ui"),
        GENERAL("general");

        private final String value;

        ConfigType(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }
}
