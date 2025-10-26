/*
  IDAP 进销存业务系统 — 批量示例数据 SEED（每表≥100条） MySQL 8
  version: 0.1.0
  说明：
  - 统一 tenant_id = 1001。
  - 使用递归 CTE 生成 1..100 的序列，批量插入。
  - ID 范围避免与 005 脚本冲突：
    * UOM: 11101..11200
    * Category: 22001..22100（父：2101）
    * Warehouse: 42001..42100
    * Supplier: 52001..52100
    * Customer: 62001..62100
    * Product: 33001..33100（关联上面的 UOM/Category）
    * PurchaseOrder: 84001..84100
    * PurchaseOrderItem: 94001..94100
    * SalesOrder: 85001..85100
    * SalesOrderItem: 95001..95100
    * StockMovement: 77001..77100（入）/ 78001..78100（出）
    * Inventory: 100 条组合
*/

USE idap;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

/* 确保根分类存在（供批量分类的 parent 引用） */
INSERT IGNORE INTO biz_category (id, tenant_id, parent_id, name, status)
VALUES (2101, 1001, NULL, 'Root', 'ENABLED');

/* ========== 序列 1..100：使用临时表避免对部分 MySQL 8 小版本的 CTE 兼容性问题 ========== */
DROP TEMPORARY TABLE IF EXISTS tmp_seq_100;
CREATE TEMPORARY TABLE tmp_seq_100 (n INT NOT NULL PRIMARY KEY) ENGINE=Memory;
INSERT INTO tmp_seq_100(n)
SELECT (a.d + b.d*10) + 1 AS n
FROM (
  SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
  UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
) a
CROSS JOIN (
  SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
  UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
) b;

/* ========== UOM 100 条 ========== */
INSERT INTO biz_uom (id, tenant_id, code, name, description, status)
SELECT 11100 + t.n, 1001,
       CONCAT('UOM', LPAD(n, 3, '0')),
       CONCAT('单位', n),
       CONCAT('自动生成的计量单位 #', n),
       'ENABLED'
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE name=VALUES(name);

/* ========== Category 100 条（父=2101） ========== */
INSERT INTO biz_category (id, tenant_id, parent_id, name, status)
SELECT 22000 + t.n, 1001, 2101,
       CONCAT('分类-', LPAD(n, 3, '0')),
       'ENABLED'
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE name=VALUES(name);

/* ========== Warehouse 100 条 ========== */
INSERT INTO biz_warehouse (id, tenant_id, code, name, country, province, city, district, street, postal_code, status)
SELECT 42000 + t.n, 1001,
       CONCAT('WH', LPAD(n, 3, '0')),
       CONCAT('示例仓库 ', n),
       'CN', '示例省', CONCAT('示例市', MOD(n,10)), CONCAT('示例区', MOD(n,20)), CONCAT('示例路 ', n, ' 号'), CONCAT('PC', LPAD(n, 5, '0')),
       'ENABLED'
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE name=VALUES(name);

/* ========== Supplier 100 条 ========== */
INSERT INTO biz_supplier (id, tenant_id, name, contact, phone, email, country, province, city, district, street, postal_code, status)
SELECT 52000 + t.n, 1001,
       CONCAT('供应商 ', LPAD(n,3,'0')),
       CONCAT('联系人', n),
       CONCAT('139', LPAD(n,8,'0')),
       CONCAT('supplier', n, '@demo.test'),
       'CN','示例省', CONCAT('示例市', MOD(n,10)), CONCAT('示例区', MOD(n,20)), CONCAT('示例街', n, '号'), CONCAT('PC', LPAD(n,5,'0')),
       'ENABLED'
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE contact=VALUES(contact);

/* ========== Customer 100 条 ========== */
INSERT INTO biz_customer (id, tenant_id, name, contact, phone, email, country, province, city, district, street, postal_code, status)
SELECT 62000 + t.n, 1001,
       CONCAT('客户 ', LPAD(n,3,'0')),
       CONCAT('联系人', n),
       CONCAT('138', LPAD(n,8,'0')),
       CONCAT('customer', n, '@demo.test'),
       'CN','示例省', CONCAT('示例市', MOD(n,10)), CONCAT('示例区', MOD(n,20)), CONCAT('示例街', n, '号'), CONCAT('PC', LPAD(n,5,'0')),
       'ENABLED'
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE contact=VALUES(contact);

/* ========== Product 100 条 ========== */
INSERT INTO biz_product (id, tenant_id, sku, name, category_id, uom_id, price_amount, price_currency, status, attributes)
SELECT 33000 + t.n, 1001,
       CONCAT('SKU-BULK-', LPAD(n,3,'0')),
       CONCAT('批量商品 ', n),
       22000 + ((n - 1) % 100) + 1,
       11100 + ((n - 1) % 100) + 1,
       ROUND(5 + (n * 1.11), 2),
       'CNY',
       'ACTIVE',
       JSON_OBJECT('seed','bulk','idx', n)
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE name=VALUES(name);

/* 采购单 100 条 */
INSERT INTO biz_purchase_order (id, tenant_id, supplier_id, warehouse_id, status, order_date, total_amount, total_currency, notes)
SELECT 84000 + t.n, 1001,
       52000 + ((n - 1) % 100) + 1,
       42000 + ((n - 1) % 100) + 1,
       ELT(MOD(n,5)+1, 'DRAFT','SUBMITTED','APPROVED','RECEIVED','CANCELLED'),
       DATE_ADD('2025-10-10 10:00:00', INTERVAL n MINUTE),
       ROUND(1000 + n * 23.5, 2),
       'CNY',
       CONCAT('批量采购单 #', n)
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE notes=VALUES(notes);

/* 采购单明细 100 条（每单 1 条） */
INSERT INTO biz_purchase_order_item (id, tenant_id, order_id, product_id, quantity, price_amount, price_currency, warehouse_id, created_at)
SELECT 94000 + t.n, 1001,
       84000 + n,
       33000 + ((n - 1) % 100) + 1,
       5 + (n % 10),
       ROUND(5 + (n * 1.11), 2),
       'CNY',
       42000 + ((n - 1) % 100) + 1,
       NOW()
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity);

/* 销售单 100 条 */
INSERT INTO biz_sales_order (id, tenant_id, customer_id, warehouse_id, status, order_date, total_amount, total_currency, notes)
SELECT 85000 + t.n, 1001,
       62000 + ((n - 1) % 100) + 1,
       42000 + ((n - 1) % 100) + 1,
       ELT(MOD(n,6)+1, 'DRAFT','CONFIRMED','ALLOCATED','SHIPPED','COMPLETED','CANCELLED'),
       DATE_ADD('2025-10-12 09:00:00', INTERVAL n MINUTE),
       ROUND(800 + n * 12.8, 2),
       'CNY',
       CONCAT('批量销售单 #', n)
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE notes=VALUES(notes);

/* 销售单明细 100 条（每单 1 条） */
INSERT INTO biz_sales_order_item (id, tenant_id, order_id, product_id, quantity, price_amount, price_currency, warehouse_id, created_at)
SELECT 95000 + t.n, 1001,
       85000 + n,
       33000 + ((n - 1) % 100) + 1,
       3 + (n % 8),
       ROUND(5 + (n * 1.11), 2),
       'CNY',
       42000 + ((n - 1) % 100) + 1,
       NOW()
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity);

/* 入库流水 100 条（关联采购单） */
INSERT INTO biz_stock_movement (id, tenant_id, product_id, warehouse_id, quantity, type, reason, reference_type, reference_id, occurred_at, created_at)
SELECT 77000 + t.n, 1001,
       33000 + ((n - 1) % 100) + 1,
       42000 + ((n - 1) % 100) + 1,
       5 + (n % 10),
       'INBOUND',
       CONCAT('BULK PO receive #', n),
       'PURCHASE_ORDER', 84000 + n,
       DATE_ADD('2025-10-11 10:00:00', INTERVAL n MINUTE), NOW()
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity);

/* 出库流水 100 条（关联销售单） */
INSERT INTO biz_stock_movement (id, tenant_id, product_id, warehouse_id, quantity, type, reason, reference_type, reference_id, occurred_at, created_at)
SELECT 78000 + t.n, 1001,
       33000 + ((n - 1) % 100) + 1,
       42000 + ((n - 1) % 100) + 1,
       2 + (n % 6),
       'OUTBOUND',
       CONCAT('BULK SO shipped #', n),
       'SALES_ORDER', 85000 + n,
       DATE_ADD('2025-10-13 15:00:00', INTERVAL n MINUTE), NOW()
FROM tmp_seq_100 t
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity);

/* 库存快照 100 条（与产品/仓库一一组合） */
REPLACE INTO biz_inventory (tenant_id, product_id, warehouse_id, on_hand, reserved)
SELECT 1001,
       33000 + t.n,
       42000 + t.n,
       CAST( (10 + (n % 50)) AS DECIMAL(18,3) ),
       CAST( (n % 5) AS DECIMAL(18,3) )
FROM tmp_seq_100 t;

/* END */
