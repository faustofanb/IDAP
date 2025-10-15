-- D001: 插入用户样例数据
-- 描述: 创建测试用户（包含管理员、分析师、普通用户）
-- 日期: 2025-01-15
-- 注意: 密码为 BCrypt 加密的 "Password123!"

INSERT INTO users (username, email, password_hash, display_name, role, is_active) VALUES
-- 管理员用户
('admin', 'admin@idap.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'System Admin', 'admin', true),

-- 分析师用户
('analyst1', 'analyst1@idap.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Data Analyst Zhang', 'analyst', true),
('analyst2', 'analyst2@idap.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Data Analyst Li', 'analyst', true),

-- 普通用户
('user1', 'user1@idap.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'User Wang', 'user', true),
('user2', 'user2@idap.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'User Chen', 'user', true),
('user3', 'user3@idap.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'User Liu', 'user', true),

-- 演示账号
('demo', 'demo@idap.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Demo User', 'user', true)
ON CONFLICT (username) DO NOTHING;

-- 创建测试会话
INSERT INTO sessions (user_id, title, message_count) VALUES
((SELECT user_id FROM users WHERE username = 'demo'), '销售数据分析', 5),
((SELECT user_id FROM users WHERE username = 'demo'), '客户洞察报告', 3),
((SELECT user_id FROM users WHERE username = 'analyst1'), '产品性能分析', 8),
((SELECT user_id FROM users WHERE username = 'user1'), '月度销售趋势', 2)
ON CONFLICT DO NOTHING;

SELECT 'Inserted ' || COUNT(*) || ' users' as result FROM users;
SELECT 'Created ' || COUNT(*) || ' sessions' as result FROM sessions;
