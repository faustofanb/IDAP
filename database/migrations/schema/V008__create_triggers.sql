-- V008: 创建触发器和函数
-- 描述: 自动更新时间戳、数据验证
-- 日期: 2025-01-15

-- 自动更新 updated_at 的函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为需要的表添加触发器
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at
    BEFORE UPDATE ON sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rag_documents_updated_at
    BEFORE UPDATE ON rag_documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_table_whitelist_updated_at
    BEFORE UPDATE ON table_whitelist
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_config_updated_at
    BEFORE UPDATE ON system_config
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 自动更新客户统计信息的函数
CREATE OR REPLACE FUNCTION update_customer_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- 更新客户的订单数和总消费
    UPDATE customers
    SET
        order_count = (
            SELECT COUNT(DISTINCT order_id)
            FROM sales
            WHERE customer_id = NEW.customer_id
        ),
        total_spent = (
            SELECT COALESCE(SUM(final_amount), 0)
            FROM sales
            WHERE customer_id = NEW.customer_id
        ),
        last_purchase_date = (
            SELECT MAX(sale_date)
            FROM sales
            WHERE customer_id = NEW.customer_id
        )
    WHERE customer_id = NEW.customer_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为销售表添加触发器（新增销售记录时自动更新客户统计）
CREATE TRIGGER update_customer_stats_on_sale
    AFTER INSERT ON sales
    FOR EACH ROW
    EXECUTE FUNCTION update_customer_stats();

-- 自动计算销售利润的函数
CREATE OR REPLACE FUNCTION calculate_sale_profit()
RETURNS TRIGGER AS $$
BEGIN
    -- 如果没有设置利润，根据成本价自动计算
    IF NEW.profit_amount IS NULL THEN
        NEW.profit_amount = NEW.final_amount - (
            SELECT COALESCE(cost_price, 0) * NEW.quantity
            FROM products
            WHERE product_id = NEW.product_id
        );
    END IF;

    -- 确保 final_amount = total_amount - discount_amount
    IF NEW.final_amount IS NULL OR NEW.final_amount = 0 THEN
        NEW.final_amount = NEW.total_amount - COALESCE(NEW.discount_amount, 0);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为销售表添加触发器（插入前自动计算）
CREATE TRIGGER calculate_sale_profit_trigger
    BEFORE INSERT ON sales
    FOR EACH ROW
    EXECUTE FUNCTION calculate_sale_profit();

-- 添加注释
COMMENT ON FUNCTION update_updated_at_column() IS '自动更新 updated_at 字段为当前时间';
COMMENT ON FUNCTION update_customer_stats() IS '自动更新客户统计信息（订单数、总消费、最后购买日期）';
COMMENT ON FUNCTION calculate_sale_profit() IS '自动计算销售利润和最终金额';
