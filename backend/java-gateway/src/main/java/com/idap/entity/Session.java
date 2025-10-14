package com.idap.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 会话实体
 */
@Data
@Entity
@Table(name = "sessions")
public class Session {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID sessionId;

    private Long userId;
    private String title;
    private Integer messageCount;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
