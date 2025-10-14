package com.idap.security;

import org.springframework.stereotype.Component;

/**
 * JWT Token 提供者
 * 负责 Token 生成、验证
 */
@Component
public class JwtTokenProvider {

    /**
     * 生成 Token
     */
    public String generateToken(String username) {
        // TODO: 生成 JWT Token
        return null;
    }

    /**
     * 验证 Token
     */
    public boolean validateToken(String token) {
        // TODO: 验证 Token 有效性
        return false;
    }

    /**
     * 从 Token 获取用户名
     */
    public String getUsernameFromToken(String token) {
        // TODO: 解析 Token
        return null;
    }
}
