-- 最终修复版: 插入销售数据
-- 描述: 生成 2500 条销售记录
-- 日期: 2025-01-15
-- 修正: 使用正确的字段名 (salesperson, city)

DO $$
DECLARE
    v_product_id BIGINT;
    v_customer_id BIGINT;
    v_customer_region VARCHAR(50);
    v_customer_city VARCHAR(50);
    v_quantity INTEGER;
    v_unit_price DECIMAL(10,2);
    v_discount_amount DECIMAL(10,2);
    v_sale_date DATE;
    v_counter INTEGER := 0;
BEGIN
    RAISE NOTICE '开始插入销售数据...';

    -- 2023年下半年数据 (1000条)
    FOR i IN 1..1000 LOOP
        -- 随机选择产品
        SELECT product_id, price INTO v_product_id, v_unit_price
        FROM products
        ORDER BY RANDOM()
        LIMIT 1;

        -- 随机选择客户
        SELECT customer_id, region, city
        INTO v_customer_id, v_customer_region, v_customer_city
        FROM customers
        ORDER BY RANDOM()
        LIMIT 1;

        -- 随机数量和折扣
        v_quantity := (RANDOM() * 3 + 1)::INTEGER;
        v_discount_amount := v_unit_price * v_quantity * (RANDOM() * 0.15);  -- 最多15%折扣

        -- 随机日期 (2023-07 到 2023-12)
        v_sale_date := DATE '2023-07-01' + (RANDOM() * 183)::INTEGER;

        -- 插入销售记录
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
            city,
            channel,
            payment_method,
            sale_date,
            sale_time,
            salesperson
        ) VALUES (
            'O' || TO_CHAR(v_sale_date, 'YYYYMMDD') || LPAD(i::TEXT, 4, '0'),  -- 订单号: O202307010001
            v_product_id,
            v_customer_id,
            v_quantity,
            v_unit_price,
            v_unit_price * v_quantity,
            v_discount_amount,
            v_unit_price * v_quantity - v_discount_amount,
            (v_unit_price * v_quantity - v_discount_amount) * 0.25,  -- 25% 利润率
            v_customer_region,
            v_customer_city,
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
            v_sale_date::timestamp + (RANDOM() * INTERVAL '12 hours' + INTERVAL '8 hours'),
            CASE (RANDOM() * 6)::INTEGER
                WHEN 0 THEN '张三'
                WHEN 1 THEN '李四'
                WHEN 2 THEN '王五'
                WHEN 3 THEN '赵六'
                WHEN 4 THEN '孙七'
                ELSE '周八'
            END
        );

        v_counter := v_counter + 1;

        -- 每200条提示一次
        IF v_counter % 200 = 0 THEN
            RAISE NOTICE '  已插入 % 条记录...', v_counter;
        END IF;
    END LOOP;

    RAISE NOTICE '2023年数据插入完成（1000条）';

    -- 2024年数据 (1500条)
    FOR i IN 1001..2500 LOOP
        SELECT product_id, price INTO v_product_id, v_unit_price
        FROM products
        ORDER BY RANDOM()
        LIMIT 1;

        SELECT customer_id, region, city
        INTO v_customer_id, v_customer_region, v_customer_city
        FROM customers
        ORDER BY RANDOM()
        LIMIT 1;

        v_quantity := (RANDOM() * 3 + 1)::INTEGER;
        v_discount_amount := v_unit_price * v_quantity * (RANDOM() * 0.15);

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
            city,
            channel,
            payment_method,
            sale_date,
            sale_time,
            salesperson
        ) VALUES (
            'O' || TO_CHAR(v_sale_date, 'YYYYMMDD') || LPAD(i::TEXT, 4, '0'),
            v_product_id,
            v_customer_id,
            v_quantity,
            v_unit_price,
            v_unit_price * v_quantity,
            v_discount_amount,
            v_unit_price * v_quantity - v_discount_amount,
            (v_unit_price * v_quantity - v_discount_amount) * 0.25,
            v_customer_region,
            v_customer_city,
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
            v_sale_date::timestamp + (RANDOM() * INTERVAL '12 hours' + INTERVAL '8 hours'),
            CASE (RANDOM() * 6)::INTEGER
                WHEN 0 THEN '张三'
                WHEN 1 THEN '李四'
                WHEN 2 THEN '王五'
                WHEN 3 THEN '赵六'
                WHEN 4 THEN '孙七'
                ELSE '周八'
            END
        );

        v_counter := v_counter + 1;

        IF v_counter % 200 = 0 THEN
            RAISE NOTICE '  已插入 % 条记录...', v_counter;
        END IF;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE '✅ 销售数据插入完成！';
    RAISE NOTICE '   总记录数: %', v_counter;
    RAISE NOTICE '';
END $$;

-- 统计验证
RAISE NOTICE '📊 销售数据统计:';
SELECT
    COUNT(*) as total_sales,
    COUNT(DISTINCT order_id) as unique_orders,
    COUNT(DISTINCT customer_id) as unique_customers,
    MIN(sale_date) as earliest_sale,
    MAX(sale_date) as latest_sale,
    TO_CHAR(SUM(final_amount), 'FM999,999,999.00') as total_revenue,
    TO_CHAR(AVG(final_amount), 'FM999,999.00') as avg_order_value
FROM sales;

RAISE NOTICE '';
RAISE NOTICE '📅 月度销售统计（前10个月）:';
SELECT
    TO_CHAR(sale_date, 'YYYY-MM') as month,
    COUNT(*) as order_count,
    TO_CHAR(SUM(final_amount), 'FM999,999,999.00') as revenue
FROM sales
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY month
LIMIT 10;
