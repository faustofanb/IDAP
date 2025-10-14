package com.idap.repository;

import com.idap.entity.Session;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

/**
 * 会话数据访问接口
 */
@Repository
public interface SessionRepository extends JpaRepository<Session, UUID> {

    List<Session> findByUserIdOrderByUpdatedAtDesc(Long userId);
}
