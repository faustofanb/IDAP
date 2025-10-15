-- V005: 创建业务示例数据表
-- 描述: 产品、客户、销售表（用于演示 NL2SQL）
-- 日期: 2025-01-15

-- 产品表
CREATE TABLE IF NOT EXISTS products (
    product_id BIGSERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    brand VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL,
    cost_price DECIMAL(10, 2),
    stock_quantity INTEGER DEFAULT 0,
    unit VARCHAR(20) DEFAULT '件',
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 客户表
CREATE TABLE IF NOT EXISTS customers (
    customer_id BIGSERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    gender VARCHAR(10) CHECK (gender IN ('男', '女', '未知')),
    birth_date DATE,
    age INTEGER,
    region VARCHAR(50),
    city VARCHAR(50),
    address TEXT,
    membership_level VARCHAR(20) DEFAULT 'regular' CHECK (membership_level IN ('regular', 'silver', 'gold', 'platinum', 'diamond')),
    total_spent DECIMAL(12, 2) DEFAULT 0,
    order_count INTEGER DEFAULT 0,
    first_purchase_date DATE,
    last_purchase_date DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 销售表
CREATE TABLE IF NOT EXISTS sales (
    sale_id BIGSERIAL PRIMARY KEY,
    order_id VARCHAR(100) NOT NULL,
    product_id BIGINT REFERENCES products(product_id),
    customer_id BIGINT REFERENCES customers(customer_id),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    final_amount DECIMAL(12, 2) NOT NULL,
    profit_amount DECIMAL(10, 2),
    region VARCHAR(50),
    city VARCHAR(50),
    channel VARCHAR(20) CHECK (channel IN ('online', 'offline', 'mobile', 'wechat', 'app')),
    payment_method VARCHAR(20) CHECK (payment_method IN ('alipay', 'wechat', 'card', 'cash')),
    sale_date DATE NOT NULL,
    sale_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    salesperson VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);

CREATE INDEX IF NOT EXISTS idx_customers_region ON customers(region);
CREATE INDEX IF NOT EXISTS idx_customers_city ON customers(city);
CREATE INDEX IF NOT EXISTS idx_customers_membership_level ON customers(membership_level);
CREATE INDEX IF NOT EXISTS idx_customers_region_city ON customers(region, city);

CREATE INDEX IF NOT EXISTS idx_sales_product_id ON sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_sale_date ON sales(sale_date DESC);
CREATE INDEX IF NOT EXISTS idx_sales_region ON sales(region);
CREATE INDEX IF NOT EXISTS idx_sales_channel ON sales(channel);
CREATE INDEX IF NOT EXISTS idx_sales_order_id ON sales(order_id);
CREATE INDEX IF NOT EXISTS idx_sales_date_region ON sales(sale_date DESC, region);

-- 添加注释
COMMENT ON TABLE products IS '产品表 - 存储商品信息';
COMMENT ON TABLE customers IS '客户表 - 存储客户信息';
COMMENT ON TABLE sales IS '销售表 - 存储销售订单明细';
COMMENT ON COLUMN customers.membership_level IS '会员等级: regular-普通, silver-银卡, gold-金卡, platinum-白金, diamond-钻石';
COMMENT ON COLUMN sales.channel IS '销售渠道: online-线上商城, offline-线下门店, mobile-移动端, wechat-微信, app-APP';
