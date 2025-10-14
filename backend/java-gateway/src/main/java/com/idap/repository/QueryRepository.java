package com.idap.repository;

import com.idap.entity.Query;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

/**
 * 查询记录数据访问接口
 */
@Repository
public interface QueryRepository extends JpaRepository<Query, Long> {

    List<Query> findBySessionIdOrderByCreatedAtDesc(UUID sessionId);

    List<Query> findByUserIdOrderByCreatedAtDesc(Long userId);
}
