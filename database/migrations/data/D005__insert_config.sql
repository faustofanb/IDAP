-- D005: 插入系统配置数据
-- 描述: 表白名单、系统配置、RAG 示例文档
-- 日期: 2025-01-15

-- 插入表白名单（允许 NL2SQL 查询的表）
INSERT INTO table_whitelist (schema_name, table_name, display_name, description, allowed_columns, sample_queries, max_rows, status) VALUES
('public', 'products', '产品表', '商品信息表',
 '["product_id", "product_name", "category", "brand", "price", "stock_quantity", "description"]'::jsonb,
 '["查询所有手机数码类产品", "价格在1000-5000元的商品", "库存最多的10个商品"]'::jsonb,
 1000, 'active'),

('public', 'customers', '客户表', '客户基本信息',
 '["customer_id", "customer_name", "region", "city", "membership_level", "total_spent", "order_count", "first_purchase_date", "last_purchase_date"]'::jsonb,
 '["金卡以上会员", "上海地区的客户", "消费超过10000元的客户"]'::jsonb,
 1000, 'active'),

('public', 'sales', '销售表', '销售订单明细',
 '["sale_id", "order_id", "product_id", "customer_id", "quantity", "unit_price", "total_amount", "discount_amount", "final_amount", "profit_amount", "region", "city", "channel", "sale_date", "salesperson"]'::jsonb,
 '["本月销售额", "销售额TOP10商品", "各地区销售对比", "线上线下销售占比"]'::jsonb,
 5000, 'active'),

('public', 'daily_sales_summary', '每日销售汇总', '每日销售统计视图',
 '["sale_date", "order_count", "customer_count", "total_revenue", "total_profit", "avg_order_value", "total_quantity"]'::jsonb,
 '["最近7天销售趋势", "本月每日销售额"]'::jsonb,
 365, 'active'),

('public', 'product_sales_ranking', '产品销售排名', '产品销售分析视图',
 '["product_id", "product_name", "category", "brand", "price", "order_count", "total_quantity_sold", "total_revenue", "total_profit"]'::jsonb,
 '["销售额TOP20商品", "各品类销售冠军"]'::jsonb,
 1000, 'active'),

('public', 'customer_spending_analysis', '客户消费分析', '客户价值分析视图',
 '["customer_id", "customer_name", "region", "city", "membership_level", "order_count", "total_spent", "customer_status", "customer_lifetime_days"]'::jsonb,
 '["活跃客户列表", "高价值客户分析"]'::jsonb,
 1000, 'active'),

('public', 'regional_sales_analysis', '区域销售分析', '区域销售统计视图',
 '["region", "city", "order_count", "customer_count", "total_revenue", "total_profit", "avg_order_value"]'::jsonb,
 '["各地区销售排名", "华东地区城市销售对比"]'::jsonb,
 100, 'active'),

('public', 'channel_sales_analysis', '渠道销售分析', '销售渠道分析视图',
 '["channel", "order_count", "customer_count", "total_revenue", "total_profit", "avg_order_value"]'::jsonb,
 '["线上线下销售对比", "各渠道销售占比"]'::jsonb,
 10, 'active')
ON CONFLICT (schema_name, table_name) DO NOTHING;

-- 插入系统配置
INSERT INTO system_config (config_key, config_value, description, config_type, is_public) VALUES
-- LLM 配置
('llm.default_model', '"gpt-4"'::jsonb, '默认LLM模型', 'llm', false),
('llm.temperature', '0.7'::jsonb, 'LLM温度参数', 'llm', false),
('llm.max_tokens', '2000'::jsonb, '最大Token数', 'llm', false),
('llm.timeout_seconds', '30'::jsonb, 'LLM超时时间（秒）', 'llm', false),

-- 数据库配置
('database.max_query_rows', '5000'::jsonb, '单次查询最大行数', 'database', true),
('database.query_timeout_seconds', '30'::jsonb, '查询超时时间（秒）', 'database', true),
('database.enable_query_cache', 'true'::jsonb, '是否启用查询缓存', 'database', false),
('database.cache_ttl_seconds', '3600'::jsonb, '缓存过期时间（秒）', 'database', false),

-- RAG 配置
('rag.embedding_model', '"text-embedding-ada-002"'::jsonb, 'Embedding模型', 'rag', false),
('rag.chunk_size', '1000'::jsonb, '文档切分大小', 'rag', false),
('rag.chunk_overlap', '200'::jsonb, '文档切分重叠', 'rag', false),
('rag.top_k', '5'::jsonb, '检索Top-K数量', 'rag', false),
('rag.similarity_threshold', '0.7'::jsonb, '相似度阈值', 'rag', false),

-- 功能开关
('feature.enable_nl2sql', 'true'::jsonb, '是否启用NL2SQL', 'feature_flag', true),
('feature.enable_rag', 'true'::jsonb, '是否启用RAG', 'feature_flag', true),
('feature.enable_chart_generation', 'true'::jsonb, '是否启用图表生成', 'feature_flag', true),
('feature.enable_insights', 'true'::jsonb, '是否启用AI洞察', 'feature_flag', true),

-- UI 配置
('ui.default_language', '"zh-CN"'::jsonb, '默认语言', 'ui', true),
('ui.theme', '"light"'::jsonb, '默认主题', 'ui', true),
('ui.max_history_items', '100'::jsonb, '历史记录最大数量', 'ui', true),

-- 安全配置
('security.jwt_expiration_hours', '24'::jsonb, 'JWT过期时间（小时）', 'security', false),
('security.max_login_attempts', '5'::jsonb, '最大登录尝试次数', 'security', false),
('security.session_timeout_minutes', '120'::jsonb, '会话超时时间（分钟）', 'security', false),
('security.enable_audit_log', 'true'::jsonb, '是否启用审计日志', 'security', false)
ON CONFLICT (config_key) DO NOTHING;

-- 插入 RAG 示例文档
INSERT INTO rag_documents (title, source_type, category, content, status, indexed_at, created_by) VALUES
('IDAP 产品使用指南', 'manual', '产品文档',
'# IDAP 智能数据分析平台使用指南

## 什么是 IDAP？
IDAP (Intelligent Data Analysis Platform) 是一个企业级智能数据分析平台，让您通过自然语言与数据对话。

## 核心功能

### 1. NL2SQL 自然语言查询
您可以用中文提问，系统会自动生成 SQL 并执行查询。

示例问题：
- "本月销售额是多少？"
- "销售额前10的商品有哪些？"
- "上海地区的金卡会员有多少人？"

### 2. 智能图表
系统会根据查询结果自动生成合适的图表：
- 柱状图：用于对比分析
- 折线图：用于趋势分析
- 饼图：用于占比分析
- 散点图：用于关系分析

### 3. AI 洞察
系统会自动分析数据并提供业务建议。

## 最佳实践

1. 问题要具体明确
2. 包含时间范围会更准确
3. 可以要求特定的统计方式
4. 善用"对比"、"趋势"等关键词

## 常见问题

Q: 查询速度慢怎么办？
A: 尽量缩小时间范围，避免全表查询。

Q: 结果不准确怎么办？
A: 可以换个问法，或者在问题中加入更多限定条件。',
'active', CURRENT_TIMESTAMP, (SELECT user_id FROM users WHERE username = 'admin')),

('数据分析常用 SQL 模式', 'manual', '技术文档',
'# 数据分析常用 SQL 查询模式

## 1. 销售分析

### 统计销售额
```sql
SELECT SUM(final_amount) as total_revenue
FROM sales
WHERE sale_date >= CURRENT_DATE - INTERVAL ''30 days'';
```

### 销售排名
```sql
SELECT
    p.product_name,
    SUM(s.final_amount) as revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;
```

## 2. 客户分析

### 客户分层
按消费金额分为高、中、低价值客户。

### 客户流失分析
超过90天未购买的客户视为流失客户。

## 3. 地域分析

不同地区的销售表现对比，可以指导资源投放。

## 4. 时间序列分析

月度、季度趋势分析，识别业务波动规律。',
'active', CURRENT_TIMESTAMP, (SELECT user_id FROM users WHERE username = 'admin')),

('电商行业数据指标体系', 'manual', '业务知识',
'# 电商数据分析指标体系

## 核心指标

### 1. GMV (Gross Merchandise Volume)
商品交易总额 = 销售额 + 取消订单 + 拒收订单

### 2. 客单价 (AOV - Average Order Value)
客单价 = 总销售额 / 订单数

### 3. 复购率
复购率 = 重复购买客户数 / 总客户数

### 4. 转化率
转化率 = 成交订单数 / 访问人数

### 5. 毛利率
毛利率 = (销售额 - 成本) / 销售额 × 100%

## 会员体系

- 普通会员 (Regular): 注册用户
- 银卡会员 (Silver): 累计消费 > 1000元
- 金卡会员 (Gold): 累计消费 > 5000元
- 白金会员 (Platinum): 累计消费 > 10000元
- 钻石会员 (Diamond): 累计消费 > 50000元

## 渠道分类

- 线上商城 (online)
- 线下门店 (offline)
- 移动端 (mobile)
- 微信小程序 (wechat)
- 手机APP (app)',
'active', CURRENT_TIMESTAMP, (SELECT user_id FROM users WHERE username = 'admin'))
ON CONFLICT DO NOTHING;

-- 显示统计信息
SELECT 'Configured ' || COUNT(*) || ' whitelisted tables' as result FROM table_whitelist WHERE status = 'active';
SELECT 'Created ' || COUNT(*) || ' system configs' as result FROM system_config;
SELECT 'Inserted ' || COUNT(*) || ' RAG documents' as result FROM rag_documents;
