-- V007: 创建视图
-- 描述: 常用分析视图
-- 日期: 2025-01-15

-- 每日销售汇总视图
CREATE OR REPLACE VIEW daily_sales_summary AS
SELECT
    sale_date,
    COUNT(DISTINCT order_id) as order_count,
    COUNT(DISTINCT customer_id) as customer_count,
    SUM(final_amount) as total_revenue,
    SUM(profit_amount) as total_profit,
    AVG(final_amount) as avg_order_value,
    SUM(quantity) as total_quantity
FROM sales
GROUP BY sale_date
ORDER BY sale_date DESC;

-- 产品销售排名视图
CREATE OR REPLACE VIEW product_sales_ranking AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    p.price,
    COUNT(DISTINCT s.order_id) as order_count,
    SUM(s.quantity) as total_quantity_sold,
    SUM(s.final_amount) as total_revenue,
    SUM(s.profit_amount) as total_profit,
    AVG(s.final_amount) as avg_order_value,
    MAX(s.sale_date) as last_sale_date
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category, p.brand, p.price
ORDER BY total_revenue DESC NULLS LAST;

-- 客户消费分析视图
CREATE OR REPLACE VIEW customer_spending_analysis AS
SELECT
    c.customer_id,
    c.customer_name,
    c.region,
    c.city,
    c.membership_level,
    c.order_count,
    c.total_spent,
    c.first_purchase_date,
    c.last_purchase_date,
    CASE
        WHEN c.last_purchase_date >= CURRENT_DATE - INTERVAL '30 days' THEN '活跃'
        WHEN c.last_purchase_date >= CURRENT_DATE - INTERVAL '90 days' THEN '沉睡'
        ELSE '流失'
    END as customer_status,
    EXTRACT(DAY FROM (c.last_purchase_date - c.first_purchase_date)) as customer_lifetime_days
FROM customers c
WHERE c.order_count > 0
ORDER BY c.total_spent DESC;

-- 区域销售分析视图
CREATE OR REPLACE VIEW regional_sales_analysis AS
SELECT
    region,
    city,
    COUNT(DISTINCT order_id) as order_count,
    COUNT(DISTINCT customer_id) as customer_count,
    SUM(final_amount) as total_revenue,
    SUM(profit_amount) as total_profit,
    AVG(final_amount) as avg_order_value,
    SUM(quantity) as total_quantity
FROM sales
WHERE region IS NOT NULL
GROUP BY region, city
ORDER BY total_revenue DESC;

-- 渠道销售分析视图
CREATE OR REPLACE VIEW channel_sales_analysis AS
SELECT
    channel,
    COUNT(DISTINCT order_id) as order_count,
    COUNT(DISTINCT customer_id) as customer_count,
    SUM(final_amount) as total_revenue,
    SUM(profit_amount) as total_profit,
    AVG(final_amount) as avg_order_value,
    SUM(quantity) as total_quantity
FROM sales
GROUP BY channel
ORDER BY total_revenue DESC;

-- 月度销售趋势视图
CREATE OR REPLACE VIEW monthly_sales_trend AS
SELECT
    DATE_TRUNC('month', sale_date) as sale_month,
    COUNT(DISTINCT order_id) as order_count,
    COUNT(DISTINCT customer_id) as customer_count,
    SUM(final_amount) as total_revenue,
    SUM(profit_amount) as total_profit,
    AVG(final_amount) as avg_order_value
FROM sales
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY sale_month DESC;

-- 添加视图注释
COMMENT ON VIEW daily_sales_summary IS '每日销售汇总 - 用于趋势分析';
COMMENT ON VIEW product_sales_ranking IS '产品销售排名 - 用于商品分析';
COMMENT ON VIEW customer_spending_analysis IS '客户消费分析 - 用于客户分层';
COMMENT ON VIEW regional_sales_analysis IS '区域销售分析 - 用于地域分析';
COMMENT ON VIEW channel_sales_analysis IS '渠道销售分析 - 用于渠道对比';
COMMENT ON VIEW monthly_sales_trend IS '月度销售趋势 - 用于时间序列分析';
