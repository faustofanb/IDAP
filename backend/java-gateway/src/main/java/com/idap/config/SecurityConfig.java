package com.idap.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

/**
 * Spring Security 配置
 * 配置 JWT 认证、权限控制
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // TODO: 配置 JWT 认证过滤器
    // TODO: 配置密码编码器
    // TODO: 配置权限规则
}
