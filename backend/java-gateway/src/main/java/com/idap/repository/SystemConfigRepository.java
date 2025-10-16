package com.idap.repository;

import com.idap.entity.SystemConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 系统配置 Repository
 */
@Repository
public interface SystemConfigRepository extends JpaRepository<SystemConfig, Long> {

    /**
     * 根据配置键查找
     */
    Optional<SystemConfig> findByConfigKey(String configKey);

    /**
     * 根据配置类型查找
     */
    List<SystemConfig> findByConfigType(SystemConfig.ConfigType configType);

    /**
     * 查找所有公开的配置
     */
    List<SystemConfig> findByIsPublicTrue();

    /**
     * 查找特定类型的公开配置
     */
    @Query("SELECT c FROM SystemConfig c WHERE c.configType = :configType AND c.isPublic = true")
    List<SystemConfig> findPublicConfigsByType(SystemConfig.ConfigType configType);

    /**
     * 检查配置键是否存在
     */
    boolean existsByConfigKey(String configKey);
}
