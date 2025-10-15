# 数据库快速启动指南 🚀

## 📋 目录

- [1. 首次启动](#1-首次启动)
- [2. 验证数据](#2-验证数据)
- [3. 常用查询](#3-常用查询)
- [4. 测试账号](#4-测试账号)
- [5. 故障排查](#5-故障排查)

---

## 1. 首次启动

### 1.1 启动 Docker 容器

```bash
cd scripts/docker
./01-docker-manager.sh start-dev
```

**预期输出**:

```
✅ PostgreSQL 启动成功
✅ Redis 启动成功
✅ 执行数据库初始化脚本...
✅ Schema 迁移完成 (8 个文件)
✅ Data 迁移完成 (5 个文件)

📊 数据统计:
- 表数量: 12
- 视图数量: 6
- 用户数: 7
- 产品数: 56
- 客户数: 50
- 销售记录: 2500
- RAG 文档: 3
```

### 1.2 使用 psql 连接

```bash
# 方式1: 使用脚本（推荐）
./01-docker-manager.sh psql

# 方式2: 直接连接
psql postgresql://idap:idap123@localhost:5432/idap
```

---

## 2. 验证数据

### 2.1 检查表结构

```sql
-- 查看所有表
\dt

-- 查看表结构（以 users 为例）
\d users

-- 查看所有视图
\dv

-- 查看视图定义
\d+ daily_sales_summary
```

### 2.2 统计数据量

```sql
-- 各表记录数
SELECT
    schemaname,
    tablename,
    n_tup_ins as row_count
FROM pg_stat_user_tables
ORDER BY n_tup_ins DESC;

-- 快速统计
SELECT 'users' as table_name, COUNT(*) FROM users
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'sales', COUNT(*) FROM sales
UNION ALL
SELECT 'rag_documents', COUNT(*) FROM rag_documents;
```

**预期输出**:
| table_name | count |
|------------|-------|
| users | 7 |
| products | 56 |
| customers | 50 |
| sales | 2500 |
| rag_documents | 3 |

---

## 3. 常用查询

### 3.1 用户与权限

```sql
-- 查看所有用户
SELECT
    user_id,
    username,
    email,
    role,
    is_active,
    last_login_at
FROM users
ORDER BY user_id;

-- 查看管理员
SELECT * FROM users WHERE role = 'admin';

-- 查看分析师
SELECT * FROM users WHERE role = 'analyst';
```

### 3.2 商品数据

```sql
-- 按品类统计商品
SELECT
    category,
    COUNT(*) as product_count,
    AVG(price) as avg_price,
    MIN(price) as min_price,
    MAX(price) as max_price
FROM products
GROUP BY category
ORDER BY product_count DESC;

-- 查看畅销品类
SELECT
    p.category,
    COUNT(DISTINCT s.order_id) as order_count,
    SUM(s.quantity) as total_sold,
    SUM(s.final_amount) as revenue
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY revenue DESC;
```

### 3.3 客户分析

```sql
-- 按地区统计客户
SELECT
    region,
    COUNT(*) as customer_count,
    COUNT(CASE WHEN membership_level = 'gold' THEN 1 END) as gold_members,
    COUNT(CASE WHEN membership_level = 'platinum' THEN 1 END) as platinum_members,
    AVG(total_spent) as avg_spent
FROM customers
GROUP BY region
ORDER BY customer_count DESC;

-- 查看 VIP 客户
SELECT
    customer_name,
    region,
    city,
    membership_level,
    total_spent,
    order_count,
    last_purchase_date
FROM customers
WHERE membership_level IN ('platinum', 'diamond')
ORDER BY total_spent DESC
LIMIT 10;
```

### 3.4 销售分析

```sql
-- 每日销售趋势（最近7天）
SELECT * FROM daily_sales_summary
ORDER BY sale_date DESC
LIMIT 7;

-- 按渠道统计销售
SELECT
    channel,
    COUNT(*) as order_count,
    SUM(final_amount) as revenue,
    AVG(final_amount) as avg_order_value
FROM sales
GROUP BY channel
ORDER BY revenue DESC;

-- TOP 10 商品
SELECT * FROM product_sales_ranking
LIMIT 10;

-- 月度销售趋势
SELECT * FROM monthly_sales_trend
ORDER BY sale_year DESC, sale_month DESC;
```

### 3.5 RAG 知识库

```sql
-- 查看文档列表
SELECT
    doc_id,
    title,
    category,
    status,
    LENGTH(content) as content_length,
    created_at
FROM rag_documents
ORDER BY created_at DESC;

-- 查看文档内容（示例）
SELECT title, content
FROM rag_documents
WHERE doc_id = 1;

-- 统计文档块数
SELECT
    d.title,
    COUNT(c.chunk_id) as chunk_count
FROM rag_documents d
LEFT JOIN rag_chunks c ON d.doc_id = c.doc_id
GROUP BY d.doc_id, d.title;
```

---

## 4. 测试账号

### 4.1 用户列表

| 用户名        | 邮箱                   | 密码         | 角色    | 用途       |
| ------------- | ---------------------- | ------------ | ------- | ---------- |
| admin         | admin@idap.com         | Password123! | admin   | 系统管理员 |
| analyst_zhang | analyst_zhang@idap.com | Password123! | analyst | 数据分析师 |
| analyst_li    | analyst_li@idap.com    | Password123! | analyst | 数据分析师 |
| user_wang     | user_wang@idap.com     | Password123! | user    | 普通用户   |
| user_liu      | user_liu@idap.com      | Password123! | user    | 普通用户   |
| user_chen     | user_chen@idap.com     | Password123! | user    | 普通用户   |
| demo          | demo@idap.com          | Password123! | user    | 演示账号   |

### 4.2 登录测试（SQL）

```sql
-- 验证密码（BCrypt 加密）
SELECT
    user_id,
    username,
    role,
    is_active
FROM users
WHERE username = 'demo';

-- 记录登录时间
UPDATE users
SET last_login_at = CURRENT_TIMESTAMP
WHERE username = 'demo';
```

---

## 5. 故障排查

### 5.1 容器未启动

```bash
# 检查容器状态
docker ps -a | grep postgres

# 查看容器日志
docker logs idap-postgres

# 重新启动
cd scripts/docker
./01-docker-manager.sh restart-dev
```

### 5.2 数据库连接失败

```bash
# 测试连接
psql postgresql://idap:idap123@localhost:5432/idap -c "SELECT version();"

# 检查端口占用
lsof -i :5432

# 查看 PostgreSQL 日志
docker logs idap-postgres | tail -50
```

### 5.3 数据未初始化

```bash
# 进入容器检查
docker exec -it idap-postgres bash

# 查看初始化脚本是否执行
ls -la /docker-entrypoint-initdb.d/

# 手动执行初始化（如果需要）
cd /docker-entrypoint-initdb.d/
./00-init.sh
```

### 5.4 数据不一致

```bash
# 停止容器
./01-docker-manager.sh stop-dev

# 删除数据卷（⚠️ 会丢失所有数据）
docker volume rm idap_postgres_data

# 重新启动（将重新初始化）
./01-docker-manager.sh start-dev
```

### 5.5 查看详细日志

```sql
-- 查看审计日志
SELECT
    action_type,
    resource_type,
    COUNT(*) as count
FROM audit_logs
GROUP BY action_type, resource_type
ORDER BY count DESC;

-- 查看查询历史
SELECT
    query_id,
    question,
    intent,
    sql_status,
    execution_time_ms,
    created_at
FROM queries
ORDER BY created_at DESC
LIMIT 10;
```

---

## 🎓 NL2SQL 测试查询

### 基础查询

```sql
-- "本月销售额是多少？"
SELECT SUM(final_amount) as total_revenue
FROM sales
WHERE sale_date >= DATE_TRUNC('month', CURRENT_DATE);

-- "销售额TOP10的商品"
SELECT
    p.product_name,
    SUM(s.final_amount) as revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;
```

### 复杂查询

```sql
-- "各地区金卡以上会员的消费情况"
SELECT
    c.region,
    c.membership_level,
    COUNT(*) as member_count,
    AVG(c.total_spent) as avg_spent,
    SUM(c.total_spent) as total_spent
FROM customers c
WHERE c.membership_level IN ('gold', 'platinum', 'diamond')
GROUP BY c.region, c.membership_level
ORDER BY c.region, c.membership_level;

-- "2024年各月销售趋势"
SELECT
    TO_CHAR(sale_date, 'YYYY-MM') as month,
    COUNT(DISTINCT order_id) as order_count,
    SUM(final_amount) as revenue,
    AVG(final_amount) as avg_order_value
FROM sales
WHERE EXTRACT(YEAR FROM sale_date) = 2024
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY month;
```

---

## 📚 相关文档

- **数据库设计**: [02-详细设计-数据库.md](../docs/02-详细设计-数据库.md)
- **数据库总览**: [08-数据库设计总览.md](../docs/08-数据库设计总览.md)
- **迁移管理**: [database/README.md](./README.md)
- **Docker 配置**: [07-Docker 环境配置.md](../docs/07-Docker环境配置.md)

---

## 🔧 开发工具

### pgAdmin

访问: http://localhost:5050

- Email: `admin@idap.com`
- Password: `admin123`

**添加服务器**:

- Name: IDAP Local
- Host: `postgres` (Docker 网络内) 或 `localhost`
- Port: 5432
- Database: idap
- Username: idap
- Password: idap123

### DBeaver

连接配置:

- Database: PostgreSQL
- Host: localhost
- Port: 5432
- Database: idap
- Username: idap
- Password: idap123

---

**最后更新**: 2025-01-15
**维护者**: IDAP 开发团队
