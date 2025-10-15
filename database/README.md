# 数据库迁移管理

## 📁 目录结构

```
database/
├── migrations/               # 数据库迁移脚本
│   ├── schema/              # DDL 脚本（表结构变更）
│   │   ├── V001__create_extensions.sql
│   │   ├── V002__create_user_tables.sql
│   │   ├── V003__create_query_tables.sql
│   │   ├── V004__create_rag_tables.sql
│   │   ├── V005__create_business_tables.sql
│   │   ├── V006__create_system_tables.sql
│   │   ├── V007__create_views.sql
│   │   └── V008__create_triggers.sql
│   ├── data/                # DML 脚本（数据变更）
│   │   ├── D001__insert_users.sql
│   │   ├── D002__insert_products.sql
│   │   ├── D003__insert_customers.sql
│   │   ├── D004__insert_sales.sql
│   │   └── D005__insert_config.sql
│   └── procedures/          # 存储过程脚本
└── init-db.sh               # 初始化脚本（Docker 启动时自动执行）
```

## 🚀 快速开始

### 1. 自动初始化（推荐）

启动 Docker Compose 时会自动执行所有迁移：

```bash
cd scripts/docker
./01-docker-manager.sh start-dev
```

PostgreSQL 容器启动时会自动：

1. 创建数据库 `idap`
2. 按顺序执行所有 Schema 迁移（V001-V008）
3. 按顺序执行所有 Data 迁移（D001-D005）
4. 显示数据库统计信息

### 2. 手动应用迁移

如果需要手动应用迁移到已存在的数据库：

```bash
cd scripts/dev
./02-migration-manager.sh apply
```

## 📝 创建新的迁移

### 创建 Schema 迁移（DDL）

```bash
cd scripts/dev
./02-migration-manager.sh create schema "add user email index"
```

会生成文件：`database/migrations/schema/V009__add_user_email_index.sql`

### 创建 Data 迁移（DML）

```bash
./02-migration-manager.sh create data "insert new products"
```

会生成文件：`database/migrations/data/D006__insert_new_products.sql`

### 创建存储过程

```bash
./02-migration-manager.sh create procedure "calculate monthly revenue"
```

会生成文件：`database/migrations/procedures/P001__calculate_monthly_revenue.sql`

## 📋 查看所有迁移

```bash
cd scripts/dev
./02-migration-manager.sh list
```

## 🎯 迁移命名规范

### Schema 迁移（V 前缀）

- **格式**: `Vxxx__description.sql`
- **用途**: DDL 操作（CREATE, ALTER, DROP）
- **示例**:
  - `V001__create_extensions.sql` - 创建扩展
  - `V002__create_user_tables.sql` - 创建用户表
  - `V009__add_email_index.sql` - 添加索引

### Data 迁移（D 前缀）

- **格式**: `Dxxx__description.sql`
- **用途**: DML 操作（INSERT, UPDATE, DELETE）
- **示例**:
  - `D001__insert_users.sql` - 插入用户数据
  - `D002__insert_products.sql` - 插入产品数据
  - `D006__update_prices.sql` - 更新价格

### 存储过程（P 前缀）

- **格式**: `Pxxx__description.sql`
- **用途**: 存储过程、函数、触发器
- **示例**:
  - `P001__calculate_revenue.sql` - 收入计算函数
  - `P002__archive_old_data.sql` - 数据归档过程

## ✅ 最佳实践

### 1. 单一职责

每个迁移文件只做一件事：

❌ 不好的做法：

```sql
-- V009__multiple_changes.sql
CREATE TABLE new_table1 (...);
CREATE TABLE new_table2 (...);
ALTER TABLE old_table ADD COLUMN ...;
INSERT INTO config VALUES (...);  -- DML 不应该在 Schema 迁移中
```

✅ 好的做法：

```sql
-- V009__create_table1.sql
CREATE TABLE new_table1 (...);

-- V010__create_table2.sql
CREATE TABLE new_table2 (...);

-- V011__alter_old_table.sql
ALTER TABLE old_table ADD COLUMN ...;

-- D006__insert_config.sql
INSERT INTO config VALUES (...);
```

### 2. 使用事务（可选）

对于复杂操作，使用事务确保原子性：

```sql
BEGIN;

ALTER TABLE users ADD COLUMN phone VARCHAR(20);
UPDATE users SET phone = '未设置' WHERE phone IS NULL;
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;

COMMIT;
```

### 3. 添加注释

```sql
-- V009: 添加用户手机号字段
-- 描述: 为用户表添加手机号字段，用于短信验证
-- 日期: 2025-01-15
-- 作者: Zhang San

ALTER TABLE users ADD COLUMN phone VARCHAR(20);

COMMENT ON COLUMN users.phone IS '用户手机号（用于短信验证）';
```

### 4. 包含验证

在迁移末尾添加验证逻辑：

```sql
-- 验证新列是否创建成功
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'users' AND column_name = 'phone'
    ) THEN
        RAISE EXCEPTION 'Migration failed: phone column not created';
    END IF;
END $$;

SELECT 'Migration V009 completed successfully' as result;
```

### 5. 不可变性

⚠️ **迁移文件一旦创建并应用，就不应该修改！**

如果需要修改，创建新的迁移：

```sql
-- V010__fix_phone_column.sql
ALTER TABLE users ALTER COLUMN phone TYPE VARCHAR(50);
```

## 📊 当前数据库状态

### 表结构（12 张表）

| 表名              | 描述         | 记录数（样例数据） |
| ----------------- | ------------ | ------------------ |
| `users`           | 用户表       | 7                  |
| `sessions`        | 会话表       | 4                  |
| `queries`         | 查询记录表   | 0 (运行时生成)     |
| `rag_documents`   | RAG 文档表   | 3                  |
| `rag_chunks`      | RAG 文档块表 | 0 (需要向量化)     |
| `products`        | 产品表       | 56                 |
| `customers`       | 客户表       | 50                 |
| `sales`           | 销售表       | 2500               |
| `table_whitelist` | 表白名单     | 8                  |
| `audit_logs`      | 审计日志     | 0 (运行时生成)     |
| `feedback`        | 用户反馈     | 0 (运行时生成)     |
| `system_config`   | 系统配置     | 26                 |

### 视图（6 个）

- `daily_sales_summary` - 每日销售汇总
- `product_sales_ranking` - 产品销售排名
- `customer_spending_analysis` - 客户消费分析
- `regional_sales_analysis` - 区域销售分析
- `channel_sales_analysis` - 渠道销售分析
- `monthly_sales_trend` - 月度销售趋势

### 触发器（8 个）

- 自动更新 `updated_at` 字段
- 自动更新客户统计信息
- 自动计算销售利润

## 🔍 常见问题

### Q1: 迁移执行失败怎么办？

查看 PostgreSQL 日志：

```bash
cd scripts/docker
./01-docker-manager.sh logs postgres
```

### Q2: 如何重置数据库？

```bash
cd scripts/docker
./01-docker-manager.sh reset
```

这会删除所有数据并重新初始化。

### Q3: 如何只更新 Schema 不重新插入数据？

手动连接数据库执行：

```bash
cd scripts/docker
./01-docker-manager.sh psql

-- 在 psql 中执行
\i /docker-entrypoint-initdb.d/migrations/schema/V009__your_migration.sql
```

### Q4: 如何备份当前数据？

```bash
pg_dump -h localhost -U idap -d idap > backup_$(date +%Y%m%d).sql
```

## 🎓 学习资源

- [PostgreSQL 官方文档](https://www.postgresql.org/docs/)
- [Flyway 迁移最佳实践](https://flywaydb.org/documentation/concepts/migrations)
- [数据库版本控制](https://www.liquibase.org/get-started/best-practices)

## 📞 技术支持

遇到问题？查看：

1. PostgreSQL 日志：`./scripts/docker/01-docker-manager.sh logs postgres`
2. 健康检查：`./scripts/docker/02-health-check.sh`
3. 项目文档：`docs/02-详细设计-数据库.md`
