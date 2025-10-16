-- 修复版: 插入销售数据（简化订单号）
-- 描述: 生成 2500 条销售记录
-- 日期: 2025-01-15

DO $$
DECLARE
    v_product_id BIGINT;
    v_customer_id BIGINT;
    v_quantity INTEGER;
    v_unit_price DECIMAL(10,2);
    v_discount_amount DECIMAL(10,2);
    v_sale_date DATE;
    v_counter INTEGER := 0;
BEGIN
    RAISE NOTICE '开始插入销售数据...';

    -- 2023年下半年数据 (1000条)
    FOR i IN 1..1000 LOOP
        -- 随机选择产品和客户
        SELECT product_id, price INTO v_product_id, v_unit_price
        FROM products
        ORDER BY RANDOM()
        LIMIT 1;

        SELECT customer_id INTO v_customer_id
        FROM customers
        ORDER BY RANDOM()
        LIMIT 1;

        -- 随机数量和折扣
        v_quantity := (RANDOM() * 3 + 1)::INTEGER;
        v_discount_amount := v_unit_price * v_quantity * (RANDOM() * 0.2);

        -- 随机日期 (2023-07 到 2023-12)
        v_sale_date := DATE '2023-07-01' + (RANDOM() * 183)::INTEGER;

        -- 插入销售记录 (简化订单号)
        INSERT INTO sales (
            order_id,
            product_id,
            customer_id,
            quantity,
            unit_price,
            total_amount,
            discount_amount,
            final_amount,
            profit_amount,
            region,
            channel,
            payment_method,
            sale_date,
            sale_time,
            salesperson_id
        ) VALUES (
            'ORD' || TO_CHAR(v_sale_date, 'YYYYMMDD') || LPAD(i::TEXT, 4, '0'),  -- 简化订单号
            v_product_id,
            v_customer_id,
            v_quantity,
            v_unit_price,
            v_unit_price * v_quantity,
            v_discount_amount,
            v_unit_price * v_quantity - v_discount_amount,
            (v_unit_price * v_quantity - v_discount_amount) * 0.25,  -- 25% 利润率
            (SELECT region FROM customers WHERE customer_id = v_customer_id),
            CASE (RANDOM() * 5)::INTEGER
                WHEN 0 THEN 'online'
                WHEN 1 THEN 'offline'
                WHEN 2 THEN 'mobile'
                WHEN 3 THEN 'wechat'
                ELSE 'app'
            END,
            CASE (RANDOM() * 4)::INTEGER
                WHEN 0 THEN 'alipay'
                WHEN 1 THEN 'wechat'
                WHEN 2 THEN 'card'
                ELSE 'cash'
            END,
            v_sale_date,
            v_sale_date + (RANDOM() * INTERVAL '12 hours' + INTERVAL '8 hours'),
            (RANDOM() * 6 + 1)::INTEGER
        );

        v_counter := v_counter + 1;

        -- 每100条提交一次
        IF v_counter % 100 = 0 THEN
            RAISE NOTICE '已插入 % 条记录...', v_counter;
        END IF;
    END LOOP;

    -- 2024年数据 (1500条)
    FOR i IN 1001..2500 LOOP
        SELECT product_id, price INTO v_product_id, v_unit_price
        FROM products
        ORDER BY RANDOM()
        LIMIT 1;

        SELECT customer_id INTO v_customer_id
        FROM customers
        ORDER BY RANDOM()
        LIMIT 1;

        v_quantity := (RANDOM() * 3 + 1)::INTEGER;
        v_discount_amount := v_unit_price * v_quantity * (RANDOM() * 0.2);

        -- 随机日期 (2024-01 到 2024-12)
        v_sale_date := DATE '2024-01-01' + (RANDOM() * 365)::INTEGER;

        INSERT INTO sales (
            order_id,
            product_id,
            customer_id,
            quantity,
            unit_price,
            total_amount,
            discount_amount,
            final_amount,
            profit_amount,
            region,
            channel,
            payment_method,
            sale_date,
            sale_time,
            salesperson_id
        ) VALUES (
            'ORD' || TO_CHAR(v_sale_date, 'YYYYMMDD') || LPAD(i::TEXT, 4, '0'),
            v_product_id,
            v_customer_id,
            v_quantity,
            v_unit_price,
            v_unit_price * v_quantity,
            v_discount_amount,
            v_unit_price * v_quantity - v_discount_amount,
            (v_unit_price * v_quantity - v_discount_amount) * 0.25,
            (SELECT region FROM customers WHERE customer_id = v_customer_id),
            CASE (RANDOM() * 5)::INTEGER
                WHEN 0 THEN 'online'
                WHEN 1 THEN 'offline'
                WHEN 2 THEN 'mobile'
                WHEN 3 THEN 'wechat'
                ELSE 'app'
            END,
            CASE (RANDOM() * 4)::INTEGER
                WHEN 0 THEN 'alipay'
                WHEN 1 THEN 'wechat'
                WHEN 2 THEN 'card'
                ELSE 'cash'
            END,
            v_sale_date,
            v_sale_date + (RANDOM() * INTERVAL '12 hours' + INTERVAL '8 hours'),
            (RANDOM() * 6 + 1)::INTEGER
        );

        v_counter := v_counter + 1;

        IF v_counter % 100 = 0 THEN
            RAISE NOTICE '已插入 % 条记录...', v_counter;
        END IF;
    END LOOP;

    RAISE NOTICE '✅ 销售数据插入完成！';
    RAISE NOTICE '   总记录数: %', v_counter;
END $$;

-- 统计验证
SELECT
    COUNT(*) as total_sales,
    COUNT(DISTINCT order_id) as unique_orders,
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
ORDER BY month;
