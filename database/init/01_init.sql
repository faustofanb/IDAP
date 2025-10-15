-- IDAP 数据库初始化脚本
-- 创建扩展和基础配置

-- 启用 UUID 支持
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 启用全文搜索支持
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 启用向量支持（如果需要在 PostgreSQL 中存储向量）
-- CREATE EXTENSION IF NOT EXISTS vector;

-- 创建测试数据库
CREATE DATABASE idap_test WITH OWNER idap ENCODING 'UTF8';

-- 授予权限
GRANT ALL PRIVILEGES ON DATABASE idap TO idap;
GRANT ALL PRIVILEGES ON DATABASE idap_test TO idap;

-- 连接到 idap 数据库
\c idap

-- 创建 Schema（可选）
CREATE SCHEMA IF NOT EXISTS public;

-- 输出初始化信息
SELECT 'IDAP 数据库初始化完成！' as status;
SELECT version() as postgresql_version;
