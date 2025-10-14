package com.idap.controller;

import org.springframework.web.bind.annotation.*;

/**
 * 认证控制器
 * 处理用户登录、登出、Token 刷新
 */
@RestController
@RequestMapping("/auth")
public class AuthController {

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Object login() {
        // TODO: 实现登录逻辑
        return null;
    }

    /**
     * 用户登出
     */
    @PostMapping("/logout")
    public Object logout() {
        // TODO: 实现登出逻辑
        return null;
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/me")
    public Object getCurrentUser() {
        // TODO: 实现获取用户信息
        return null;
    }
}
