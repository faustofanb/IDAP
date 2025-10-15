-- D004: 插入销售样例数据（第1部分）
-- 描述: 生成2023年全年和2024年的销售记录
-- 日期: 2025-01-15
-- 注意: 此脚本生成随机但合理的销售数据，用于演示 NL2SQL 功能

-- 临时函数：生成销售数据
DO $$
DECLARE
    v_customer_id BIGINT;
    v_product_id BIGINT;
    v_sale_date DATE;
    v_quantity INTEGER;
    v_unit_price DECIMAL(10,2);
    v_discount DECIMAL(10,2);
    v_region VARCHAR(50);
    v_city VARCHAR(50);
    v_channel VARCHAR(20);
    v_payment VARCHAR(20);
    v_order_prefix VARCHAR(10);
    v_counter INTEGER := 0;
    v_cost_price DECIMAL(10,2);

    v_channels TEXT[] := ARRAY['online', 'offline', 'mobile', 'wechat', 'app'];
    v_payments TEXT[] := ARRAY['alipay', 'wechat', 'card', 'cash'];
    v_salespeople TEXT[] := ARRAY['张三', '李四', '王五', '赵六', '钱七', '孙八', '周九', '吴十'];

BEGIN
    -- 生成 2023 年下半年销售数据（1000条）
    FOR i IN 1..1000 LOOP
        -- 随机选择客户
        SELECT customer_id, region, city INTO v_customer_id, v_region, v_city
        FROM customers
        ORDER BY RANDOM()
        LIMIT 1;

        -- 随机选择产品
        SELECT product_id, price, cost_price INTO v_product_id, v_unit_price, v_cost_price
        FROM products
        WHERE is_active = true
        ORDER BY RANDOM()
        LIMIT 1;

        -- 随机生成销售日期（2023年7月-12月）
        v_sale_date := DATE '2023-07-01' + (RANDOM() * 183)::INTEGER;

        -- 随机数量（1-5件，热门商品可能更多）
        v_quantity := (RANDOM() * 4 + 1)::INTEGER;

        -- 随机折扣（0-20%）
        v_discount := v_unit_price * v_quantity * (RANDOM() * 0.2);

        -- 随机渠道和支付方式
        v_channel := v_channels[1 + (RANDOM() * 4)::INTEGER];
        v_payment := v_payments[1 + (RANDOM() * 3)::INTEGER];

        -- 生成订单号
        v_order_prefix := 'ORD' || TO_CHAR(v_sale_date, 'YYYYMMDD');
        v_counter := v_counter + 1;

        INSERT INTO sales (
            order_id, product_id, customer_id, quantity, unit_price,
            total_amount, discount_amount, final_amount, profit_amount,
            region, city, channel, payment_method, sale_date, sale_time,
            salesperson
        ) VALUES (
            v_order_prefix || LPAD(v_counter::TEXT, 6, '0'),
            v_product_id,
            v_customer_id,
            v_quantity,
            v_unit_price,
            v_unit_price * v_quantity,
            v_discount,
            v_unit_price * v_quantity - v_discount,
            (v_unit_price - v_cost_price) * v_quantity - v_discount,
            v_region,
            v_city,
            v_channel,
            v_payment,
            v_sale_date,
            v_sale_date + (RANDOM() * INTERVAL '24 hours'),
            v_salespeople[1 + (RANDOM() * 7)::INTEGER]
        );

    END LOOP;

    -- 生成 2024 年销售数据（1500条）
    FOR i IN 1..1500 LOOP
        SELECT customer_id, region, city INTO v_customer_id, v_region, v_city
        FROM customers
        ORDER BY RANDOM()
        LIMIT 1;

        SELECT product_id, price, cost_price INTO v_product_id, v_unit_price, v_cost_price
        FROM products
        WHERE is_active = true
        ORDER BY RANDOM()
        LIMIT 1;

        -- 2024年1月-12月
        v_sale_date := DATE '2024-01-01' + (RANDOM() * 365)::INTEGER;

        v_quantity := (RANDOM() * 4 + 1)::INTEGER;
        v_discount := v_unit_price * v_quantity * (RANDOM() * 0.2);
        v_channel := v_channels[1 + (RANDOM() * 4)::INTEGER];
        v_payment := v_payments[1 + (RANDOM() * 3)::INTEGER];

        v_order_prefix := 'ORD' || TO_CHAR(v_sale_date, 'YYYYMMDD');
        v_counter := v_counter + 1;

        INSERT INTO sales (
            order_id, product_id, customer_id, quantity, unit_price,
            total_amount, discount_amount, final_amount, profit_amount,
            region, city, channel, payment_method, sale_date, sale_time,
            salesperson
        ) VALUES (
            v_order_prefix || LPAD(v_counter::TEXT, 6, '0'),
            v_product_id,
            v_customer_id,
            v_quantity,
            v_unit_price,
            v_unit_price * v_quantity,
            v_discount,
            v_unit_price * v_quantity - v_discount,
            (v_unit_price - v_cost_price) * v_quantity - v_discount,
            v_region,
            v_city,
            v_channel,
            v_payment,
            v_sale_date,
            v_sale_date + (RANDOM() * INTERVAL '24 hours'),
            v_salespeople[1 + (RANDOM() * 7)::INTEGER]
        );

    END LOOP;

    RAISE NOTICE 'Generated 2500 sales records for 2023-2024';
END $$;

-- 显示统计信息
SELECT
    COUNT(*) as total_sales,
    COUNT(DISTINCT order_id) as total_orders,
    COUNT(DISTINCT customer_id) as unique_customers,
    MIN(sale_date) as earliest_sale,
    MAX(sale_date) as latest_sale,
    ROUND(SUM(final_amount)::NUMERIC, 2) as total_revenue,
    ROUND(AVG(final_amount)::NUMERIC, 2) as avg_order_value
FROM sales;

-- 按月统计
SELECT
    TO_CHAR(sale_date, 'YYYY-MM') as month,
    COUNT(*) as order_count,
    ROUND(SUM(final_amount)::NUMERIC, 2) as revenue
FROM sales
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY month DESC
LIMIT 12;
