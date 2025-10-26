/*
  IDAP 进销存业务系统 — 示例数据 SEED（MySQL 8）
  version: 0.1.0
  约定：统一使用 tenant_id = 1001；ID 使用可读分段（1xxx=UOM/类别，3xxx=商品，4xxx=仓库，5xxx=供应商，6xxx=客户，8xxx=单据，7xxx=出入库流水，9xxx=单据明细）。
*/

USE idap;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

/* ========== 计量单位 UOM ========== */
INSERT INTO biz_uom (id, tenant_id, code, name, description, status)
VALUES
  (1101, 1001, 'PCS', '件', '单件计数', 'ENABLED'),
  (1102, 1001, 'BOX', '箱', '一箱包含若干件', 'ENABLED'),
  (1103, 1001, 'KG',  '千克', '重量单位', 'ENABLED'),
  (1104, 1001, 'L',   '升', '体积单位', 'ENABLED')
ON DUPLICATE KEY UPDATE name=VALUES(name);

/* ========== 商品分类 Category（含父子） ========== */
INSERT INTO biz_category (id, tenant_id, parent_id, name, status)
VALUES
  (2101, 1001, NULL,  'Root',        'ENABLED'),
  (2102, 1001, 2101,  'Electronics', 'ENABLED'),
  (2103, 1001, 2101,  'Beverages',   'ENABLED'),
  (2104, 1001, 2101,  'Groceries',   'ENABLED'),
  (2105, 1001, 2102,  'Accessories', 'ENABLED')
ON DUPLICATE KEY UPDATE name=VALUES(name);

/* ========== 仓库 Warehouse ========== */
INSERT INTO biz_warehouse (id, tenant_id, code, name, country, province, city, district, street, postal_code, status)
VALUES
  (4101, 1001, 'SH01', '上海一号仓', 'CN', '上海', '上海', '浦东新区', '世纪大道 100 号', '200120', 'ENABLED'),
  (4102, 1001, 'SZ01', '深圳一号仓', 'CN', '广东', '深圳', '南山区', '科技园南区 88 号', '518057', 'ENABLED')
ON DUPLICATE KEY UPDATE name=VALUES(name);

/* ========== 供应商 Supplier ========== */
INSERT INTO biz_supplier (id, tenant_id, name, contact, phone, email, country, province, city, district, street, postal_code, status)
VALUES
  (5101, 1001, 'Acme Supplies', '张三', '13800000001', 'supplier@acme.test', 'CN', '上海', '上海', '浦东新区', '花木路 66 号', '200135', 'ENABLED'),
  (5102, 1001, 'Fresh Farms',   '李四', '13800000002', 'sales@farms.test',   'CN', '广东', '深圳', '南山区',   '高新南一路 1 号', '518057', 'ENABLED')
ON DUPLICATE KEY UPDATE contact=VALUES(contact);

/* ========== 客户 Customer ========== */
INSERT INTO biz_customer (id, tenant_id, name, contact, phone, email, country, province, city, district, street, postal_code, status)
VALUES
  (6101, 1001, 'ACME Corp.',   '王五', '13900000001', 'ops@acmecorp.test', 'CN', '上海', '上海', '徐汇区', '漕溪北路 18 号', '200030', 'ENABLED'),
  (6102, 1001, 'Beta Retail',  '赵六', '13900000002', 'it@beta.test',      'CN', '广东', '深圳', '福田区', '深南大道 8008 号', '518031', 'ENABLED')
ON DUPLICATE KEY UPDATE contact=VALUES(contact);

/* ========== 商品 Product ========== */
INSERT INTO biz_product (id, tenant_id, sku, name, category_id, uom_id, price_amount, price_currency, status, attributes)
VALUES
  (3101, 1001, 'EL-USB-CABLE',  'USB-C 数据线 1m', 2105, 1101, 39.90, 'CNY', 'ACTIVE', JSON_OBJECT('color','black','length','1m')),
  (3102, 1001, 'EL-HEADSET',    '蓝牙头戴耳机',   2102, 1101, 299.00,'CNY', 'ACTIVE', JSON_OBJECT('color','white')),
  (3103, 1001, 'BV-COLA-330',   '可乐 330ml',     2103, 1101, 3.50,  'CNY', 'ACTIVE', JSON_OBJECT('package','can')),
  (3104, 1001, 'GR-RICE-5KG',   '优选大米 5kg',   2104, 1103, 68.00, 'CNY', 'ACTIVE', JSON_OBJECT('origin','东北')),
  (3105, 1001, 'EL-POWERBANK',  '移动电源 10000mAh',2102,1101, 159.00,'CNY','ACTIVE', JSON_OBJECT('capacity','10000mAh'))
ON DUPLICATE KEY UPDATE name=VALUES(name);

/* ========== 采购单 Purchase Orders ========== */
INSERT INTO biz_purchase_order (id, tenant_id, supplier_id, warehouse_id, status, order_date, total_amount, total_currency, notes)
VALUES
  (8101, 1001, 5101, 4101, 'RECEIVED', '2025-10-01 10:00:00',  6500.00, 'CNY', '首批电子配件入库'),
  (8102, 1001, 5101, 4101, 'RECEIVED', '2025-10-03 09:00:00',  19000.00,'CNY', '耳机与移动电源入库'),
  (8103, 1001, 5102, 4102, 'RECEIVED', '2025-10-05 15:00:00',  6800.00, 'CNY', '粮油入库'),
  (8104, 1001, 5101, 4102, 'RECEIVED', '2025-10-06 16:30:00',  12000.00,'CNY', '移动电源补货')
ON DUPLICATE KEY UPDATE notes=VALUES(notes);

INSERT INTO biz_purchase_order_item (id, tenant_id, order_id, product_id, quantity, price_amount, price_currency, warehouse_id)
VALUES
  -- PO 8101 → 上海仓：数据线 200、可乐 500
  (9101, 1001, 8101, 3101, 200, 25.00, 'CNY', 4101),
  (9102, 1001, 8101, 3103, 500,  2.00, 'CNY', 4101),
  -- PO 8102 → 上海仓：耳机 50；→ 深圳仓：移动电源 120
  (9103, 1001, 8102, 3102,  50, 220.00, 'CNY', 4101),
  (9104, 1001, 8102, 3105, 120,  95.00, 'CNY', 4102),
  -- PO 8103 → 深圳仓：大米 100（5kg）
  (9105, 1001, 8103, 3104, 100,  68.00, 'CNY', 4102),
  -- PO 8104 → 深圳仓：移动电源 60
  (9106, 1001, 8104, 3105,  60,  92.00, 'CNY', 4102)
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity);

/* ========== 销售单 Sales Orders ========== */
INSERT INTO biz_sales_order (id, tenant_id, customer_id, warehouse_id, status, order_date, total_amount, total_currency, notes)
VALUES
  (8201, 1001, 6101, 4101, 'SHIPPED',  '2025-10-08 11:00:00',  7987.00, 'CNY', '企业采购'),
  (8202, 1001, 6102, 4102, 'SHIPPED',  '2025-10-09 14:20:00',  3180.00, 'CNY', '门店补货')
ON DUPLICATE KEY UPDATE notes=VALUES(notes);

INSERT INTO biz_sales_order_item (id, tenant_id, order_id, product_id, quantity, price_amount, price_currency, warehouse_id)
VALUES
  -- SO 8201 → 上海仓：数据线 30，耳机 10
  (9201, 1001, 8201, 3101, 30,  39.90, 'CNY', 4101),
  (9202, 1001, 8201, 3102, 10, 299.00, 'CNY', 4101),
  -- SO 8202 → 深圳仓：移动电源 20
  (9203, 1001, 8202, 3105, 20, 159.00, 'CNY', 4102)
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity);

/* ========== 出入库流水 Stock Movements ========== */
-- 入库：对应采购到货
INSERT INTO biz_stock_movement (id, tenant_id, product_id, warehouse_id, quantity, type, reason, reference_type, reference_id, occurred_at, created_at)
VALUES
  (7301, 1001, 3101, 4101, 200, 'INBOUND',  'PO 8101 received', 'PURCHASE_ORDER', 8101, '2025-10-02 10:00:00', NOW()),
  (7302, 1001, 3103, 4101, 500, 'INBOUND',  'PO 8101 received', 'PURCHASE_ORDER', 8101, '2025-10-02 10:05:00', NOW()),
  (7303, 1001, 3102, 4101,  50, 'INBOUND',  'PO 8102 received', 'PURCHASE_ORDER', 8102, '2025-10-04 09:30:00', NOW()),
  (7304, 1001, 3105, 4102, 120, 'INBOUND',  'PO 8102 received', 'PURCHASE_ORDER', 8102, '2025-10-04 09:40:00', NOW()),
  (7305, 1001, 3104, 4102, 100, 'INBOUND',  'PO 8103 received', 'PURCHASE_ORDER', 8103, '2025-10-06 16:00:00', NOW()),
  (7306, 1001, 3105, 4102,  60, 'INBOUND',  'PO 8104 received', 'PURCHASE_ORDER', 8104, '2025-10-07 09:10:00', NOW())
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity);

-- 出库：对应销售发货
INSERT INTO biz_stock_movement (id, tenant_id, product_id, warehouse_id, quantity, type, reason, reference_type, reference_id, occurred_at, created_at)
VALUES
  (7311, 1001, 3101, 4101,  30, 'OUTBOUND', 'SO 8201 shipped', 'SALES_ORDER',    8201, '2025-10-08 12:00:00', NOW()),
  (7312, 1001, 3102, 4101,  10, 'OUTBOUND', 'SO 8201 shipped', 'SALES_ORDER',    8201, '2025-10-08 12:05:00', NOW()),
  (7313, 1001, 3105, 4102,  20, 'OUTBOUND', 'SO 8202 shipped', 'SALES_ORDER',    8202, '2025-10-09 15:00:00', NOW())
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity);

/* ========== 初始化库存 Inventory（可与流水核对） ========== */
-- 计算口径：初始为 0，按上面的入库减出库得到快照值
-- 3101@4101: +200 -30 = 170；3103@4101: +500 = 500；3102@4101: +50 -10 = 40；
-- 3105@4102: +120 +60 -20 = 160；3104@4102: +100 = 100。
REPLACE INTO biz_inventory (tenant_id, product_id, warehouse_id, on_hand, reserved)
VALUES
  (1001, 3101, 4101, 170.000, 0.000),
  (1001, 3103, 4101, 500.000, 0.000),
  (1001, 3102, 4101,  40.000, 0.000),
  (1001, 3105, 4102, 160.000, 0.000),
  (1001, 3104, 4102, 100.000, 0.000);

/* 结束 */
