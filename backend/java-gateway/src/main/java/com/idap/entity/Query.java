package com.idap.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 查询记录实体
 */
@Data
@Entity
@Table(name = "queries")
public class Query {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long queryId;

    private UUID sessionId;
    private Long userId;
    private String question;
    private String generatedSql;
    private String sqlStatus;
    private Integer executionTimeMs;

    private LocalDateTime createdAt;
}
