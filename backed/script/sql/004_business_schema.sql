/*
  IDAP 进销存业务系统 — MySQL 8 数据建模 DDL
  version: 0.1.0
  说明：
  - 所有业务表均包含 tenant_id 实现多租户隔离；子表外键使用 (tenant_id, id) 复合键以保证同租户引用。
  - 金额使用 DECIMAL(18,2)，数量使用 DECIMAL(18,3)。
  - 审计字段：created_at/created_by/updated_at/updated_by/is_deleted/version。
  - 字符集/排序规则：utf8mb4 / utf8mb4_general_ci。
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 公共枚举说明：
-- 状态：ENABLED/DISABLED；商品：ACTIVE/INACTIVE；
-- 采购单：DRAFT/SUBMITTED/APPROVED/RECEIVED/CANCELLED；
-- 销售单：DRAFT/CONFIRMED/ALLOCATED/SHIPPED/COMPLETED/CANCELLED；
-- 出入库类型：INBOUND/OUTBOUND/ADJUSTMENT；引用来源：PURCHASE_ORDER/SALES_ORDER/MANUAL_ADJUST。

CREATE DATABASE IF NOT EXISTS idap DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE idap;

/* ========== 通用基础表（如需）可在此处扩展 ========== */

/* ========== 主数据 ========== */
-- 表：biz_uom（计量单位）- 多租户隔离，供商品引用；(tenant_id, code) 保证同租户唯一
DROP TABLE IF EXISTS biz_uom;
CREATE TABLE biz_uom (
  id           BIGINT       NOT NULL COMMENT '主键ID',
  tenant_id    BIGINT       NOT NULL COMMENT '租户ID',
  code         VARCHAR(64)  NOT NULL COMMENT '计量单位编码',
  name         VARCHAR(128) NOT NULL COMMENT '计量单位名称',
  description  VARCHAR(255) NULL COMMENT '描述',
  status       ENUM('ENABLED','DISABLED') NOT NULL DEFAULT 'ENABLED' COMMENT '状态：ENABLED/DISABLED',
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  created_by   VARCHAR(64)  NULL COMMENT '创建人',
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  updated_by   VARCHAR(64)  NULL COMMENT '更新人',
  is_deleted   TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '逻辑删除标记(0-否,1-是)',
  version      INT          NOT NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  PRIMARY KEY (id),
  UNIQUE KEY uk_uom_tenant_id (tenant_id, id),
  UNIQUE KEY uk_uom_tenant_code (tenant_id, code),
  KEY          idx_uom_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='计量单位';

-- 表：biz_category（商品分类）- 自引用父子关系，限定同租户；不允许删除存在子类/被引用的分类
DROP TABLE IF EXISTS biz_category;
CREATE TABLE biz_category (
  id           BIGINT       NOT NULL COMMENT '主键ID',
  tenant_id    BIGINT       NOT NULL COMMENT '租户ID',
  parent_id    BIGINT       NULL COMMENT '父分类ID',
  name         VARCHAR(128) NOT NULL COMMENT '分类名称',
  status       ENUM('ENABLED','DISABLED') NOT NULL DEFAULT 'ENABLED' COMMENT '状态：ENABLED/DISABLED',
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  created_by   VARCHAR(64)  NULL COMMENT '创建人',
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  updated_by   VARCHAR(64)  NULL COMMENT '更新人',
  is_deleted   TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '逻辑删除标记(0-否,1-是)',
  version      INT          NOT NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  PRIMARY KEY (id),
  UNIQUE KEY uk_category_tenant_id (tenant_id, id),
  KEY          idx_category_tenant (tenant_id),
  KEY          idx_category_parent (tenant_id, parent_id),
  -- 自引用：同一租户内 parent_id → id；RESTRICT 防止误删父类导致孤儿数据
  CONSTRAINT fk_category_parent FOREIGN KEY (tenant_id, parent_id)
    REFERENCES biz_category (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类';

-- 表：biz_product（商品）- 通过 (tenant_id, id) 复合键与分类/计量单位关联；SKU 在租户内唯一
DROP TABLE IF EXISTS biz_product;
CREATE TABLE biz_product (
  id            BIGINT        NOT NULL COMMENT '主键ID',
  tenant_id     BIGINT        NOT NULL COMMENT '租户ID',
  sku           VARCHAR(64)   NOT NULL COMMENT '商品编码(SKU)',
  name          VARCHAR(256)  NOT NULL COMMENT '商品名称',
  category_id   BIGINT        NULL COMMENT '分类ID',
  uom_id        BIGINT        NOT NULL COMMENT '计量单位ID',
  price_amount  DECIMAL(18,2) NULL COMMENT '标价金额',
  price_currency VARCHAR(8)   NULL COMMENT '标价币种',
  status        ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE' COMMENT '商品状态：ACTIVE/INACTIVE',
  attributes    JSON          NULL COMMENT '扩展属性(JSON)',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  created_by    VARCHAR(64)   NULL COMMENT '创建人',
  updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  updated_by    VARCHAR(64)   NULL COMMENT '更新人',
  is_deleted    TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '逻辑删除标记(0-否,1-是)',
  version       INT           NOT NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  PRIMARY KEY (id),
  UNIQUE KEY uk_product_tenant_id (tenant_id, id),
  UNIQUE KEY uk_product_tenant_sku (tenant_id, sku),
  KEY          idx_product_tenant (tenant_id),
  KEY          idx_product_category (tenant_id, category_id),
  KEY          idx_product_uom (tenant_id, uom_id),
  -- 关联分类（同租户）
  CONSTRAINT fk_product_category FOREIGN KEY (tenant_id, category_id)
    REFERENCES biz_category (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  -- 关联计量单位（同租户）
  CONSTRAINT fk_product_uom FOREIGN KEY (tenant_id, uom_id)
    REFERENCES biz_uom (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品';

-- 表：biz_warehouse（仓库）- 租户内 code 唯一；供库存与流水引用
DROP TABLE IF EXISTS biz_warehouse;
CREATE TABLE biz_warehouse (
  id           BIGINT        NOT NULL COMMENT '主键ID',
  tenant_id    BIGINT        NOT NULL COMMENT '租户ID',
  code         VARCHAR(64)   NOT NULL COMMENT '仓库编码',
  name         VARCHAR(256)  NOT NULL COMMENT '仓库名称',
  country      VARCHAR(64)   NULL COMMENT '国家',
  province     VARCHAR(64)   NULL COMMENT '省份',
  city         VARCHAR(64)   NULL COMMENT '城市',
  district     VARCHAR(64)   NULL COMMENT '区县',
  street       VARCHAR(128)  NULL COMMENT '街道地址',
  postal_code  VARCHAR(32)   NULL COMMENT '邮编',
  status       ENUM('ENABLED','DISABLED') NOT NULL DEFAULT 'ENABLED' COMMENT '状态：ENABLED/DISABLED',
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  created_by   VARCHAR(64)   NULL COMMENT '创建人',
  updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  updated_by   VARCHAR(64)   NULL COMMENT '更新人',
  is_deleted   TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '逻辑删除标记(0-否,1-是)',
  version      INT           NOT NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  PRIMARY KEY (id),
  UNIQUE KEY uk_warehouse_tenant_id (tenant_id, id),
  UNIQUE KEY uk_warehouse_tenant_code (tenant_id, code),
  KEY          idx_warehouse_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库';

-- 表：biz_supplier（供应商）- 供采购单引用
DROP TABLE IF EXISTS biz_supplier;
CREATE TABLE biz_supplier (
  id           BIGINT        NOT NULL COMMENT '主键ID',
  tenant_id    BIGINT        NOT NULL COMMENT '租户ID',
  name         VARCHAR(256)  NOT NULL COMMENT '供应商名称',
  contact      VARCHAR(128)  NULL COMMENT '联系人',
  phone        VARCHAR(64)   NULL COMMENT '联系电话',
  email        VARCHAR(128)  NULL COMMENT '联系邮箱',
  country      VARCHAR(64)   NULL COMMENT '国家',
  province     VARCHAR(64)   NULL COMMENT '省份',
  city         VARCHAR(64)   NULL COMMENT '城市',
  district     VARCHAR(64)   NULL COMMENT '区县',
  street       VARCHAR(128)  NULL COMMENT '街道地址',
  postal_code  VARCHAR(32)   NULL COMMENT '邮编',
  status       ENUM('ENABLED','DISABLED') NOT NULL DEFAULT 'ENABLED' COMMENT '状态：ENABLED/DISABLED',
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  created_by   VARCHAR(64)   NULL COMMENT '创建人',
  updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  updated_by   VARCHAR(64)   NULL COMMENT '更新人',
  is_deleted   TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '逻辑删除标记(0-否,1-是)',
  version      INT           NOT NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  PRIMARY KEY (id),
  UNIQUE KEY uk_supplier_tenant_id (tenant_id, id),
  KEY          idx_supplier_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商';

-- 表：biz_customer（客户）- 供销售单引用
DROP TABLE IF EXISTS biz_customer;
CREATE TABLE biz_customer (
  id           BIGINT        NOT NULL COMMENT '主键ID',
  tenant_id    BIGINT        NOT NULL COMMENT '租户ID',
  name         VARCHAR(256)  NOT NULL COMMENT '客户名称',
  contact      VARCHAR(128)  NULL COMMENT '联系人',
  phone        VARCHAR(64)   NULL COMMENT '联系电话',
  email        VARCHAR(128)  NULL COMMENT '联系邮箱',
  country      VARCHAR(64)   NULL COMMENT '国家',
  province     VARCHAR(64)   NULL COMMENT '省份',
  city         VARCHAR(64)   NULL COMMENT '城市',
  district     VARCHAR(64)   NULL COMMENT '区县',
  street       VARCHAR(128)  NULL COMMENT '街道地址',
  postal_code  VARCHAR(32)   NULL COMMENT '邮编',
  status       ENUM('ENABLED','DISABLED') NOT NULL DEFAULT 'ENABLED' COMMENT '状态：ENABLED/DISABLED',
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  created_by   VARCHAR(64)   NULL COMMENT '创建人',
  updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  updated_by   VARCHAR(64)   NULL COMMENT '更新人',
  is_deleted   TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '逻辑删除标记(0-否,1-是)',
  version      INT           NOT NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  PRIMARY KEY (id),
  UNIQUE KEY uk_customer_tenant_id (tenant_id, id),
  KEY          idx_customer_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户';

/* ========== 库存与流水 ========== */
-- 表：biz_inventory（库存快照）- 主键为 (tenant_id, product_id, warehouse_id)；available 为虚拟列
DROP TABLE IF EXISTS biz_inventory;
CREATE TABLE biz_inventory (
  tenant_id    BIGINT        NOT NULL COMMENT '租户ID',
  product_id   BIGINT        NOT NULL COMMENT '商品ID',
  warehouse_id BIGINT        NOT NULL COMMENT '仓库ID',
  on_hand      DECIMAL(18,3) NOT NULL DEFAULT 0 COMMENT '在库数量',
  reserved     DECIMAL(18,3) NOT NULL DEFAULT 0 COMMENT '预留数量',
  -- 虚拟列：可用库存 = 在库 - 预留；只读、自动计算
  available    DECIMAL(18,3) GENERATED ALWAYS AS (on_hand - reserved) VIRTUAL COMMENT '可用数量(虚拟列=在库-预留)',
  updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (tenant_id, product_id, warehouse_id),
  KEY          idx_inventory_product (tenant_id, product_id),
  KEY          idx_inventory_warehouse (tenant_id, warehouse_id),
  -- 同租户的商品引用；RESTRICT 防止删除已被库存引用的商品
  CONSTRAINT fk_inventory_product FOREIGN KEY (tenant_id, product_id)
    REFERENCES biz_product (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  -- 同租户的仓库引用；RESTRICT 防止删除已被库存引用的仓库
  CONSTRAINT fk_inventory_warehouse FOREIGN KEY (tenant_id, warehouse_id)
    REFERENCES biz_warehouse (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存快照';

-- 表：biz_stock_movement（出入库流水）- 记录库存变动；常按时间、商品、仓库、租户查询
DROP TABLE IF EXISTS biz_stock_movement;
CREATE TABLE biz_stock_movement (
  id            BIGINT        NOT NULL COMMENT '主键ID',
  tenant_id     BIGINT        NOT NULL COMMENT '租户ID',
  product_id    BIGINT        NOT NULL COMMENT '商品ID',
  warehouse_id  BIGINT        NOT NULL COMMENT '仓库ID',
  quantity      DECIMAL(18,3) NOT NULL COMMENT '变动数量',
  type          ENUM('INBOUND','OUTBOUND','ADJUSTMENT') NOT NULL COMMENT '出入库类型',
  reason        VARCHAR(255)  NULL COMMENT '原因说明',
  reference_type ENUM('PURCHASE_ORDER','SALES_ORDER','MANUAL_ADJUST') NULL COMMENT '关联来源类型',
  reference_id  BIGINT        NULL COMMENT '关联来源ID',
  occurred_at   DATETIME      NOT NULL COMMENT '发生时间',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  created_by    VARCHAR(64)   NULL COMMENT '创建人',
  PRIMARY KEY (id),
  UNIQUE KEY uk_stockmv_tenant_id (tenant_id, id),
  KEY          idx_stockmv_tenant (tenant_id),
  KEY          idx_stockmv_prod (tenant_id, product_id),
  KEY          idx_stockmv_wh (tenant_id, warehouse_id),
  KEY          idx_stockmv_time (tenant_id, occurred_at),
  -- 同租户商品引用
  CONSTRAINT fk_stockmv_product FOREIGN KEY (tenant_id, product_id)
    REFERENCES biz_product (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  -- 同租户仓库引用
  CONSTRAINT fk_stockmv_warehouse FOREIGN KEY (tenant_id, warehouse_id)
    REFERENCES biz_warehouse (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='出入库流水';

/* ========== 采购 ========== */
-- 表：biz_purchase_order（采购单）- 与供应商/仓库关联；删除供应商/仓库将被限制
DROP TABLE IF EXISTS biz_purchase_order;
CREATE TABLE biz_purchase_order (
  id            BIGINT        NOT NULL COMMENT '主键ID',
  tenant_id     BIGINT        NOT NULL COMMENT '租户ID',
  supplier_id   BIGINT        NOT NULL COMMENT '供应商ID',
  warehouse_id  BIGINT        NULL COMMENT '入库仓ID',
  status        ENUM('DRAFT','SUBMITTED','APPROVED','RECEIVED','CANCELLED') NOT NULL DEFAULT 'DRAFT' COMMENT '采购状态',
  order_date    DATETIME      NOT NULL COMMENT '下单日期',
  total_amount  DECIMAL(18,2) NULL COMMENT '订单金额',
  total_currency VARCHAR(8)   NULL COMMENT '订单币种',
  notes         TEXT          NULL COMMENT '备注',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  created_by    VARCHAR(64)   NULL COMMENT '创建人',
  updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  updated_by    VARCHAR(64)   NULL COMMENT '更新人',
  is_deleted    TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '逻辑删除标记(0-否,1-是)',
  version       INT           NOT NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  PRIMARY KEY (id),
  UNIQUE KEY uk_po_tenant_id (tenant_id, id),
  KEY          idx_po_tenant (tenant_id),
  KEY          idx_po_supplier (tenant_id, supplier_id),
  KEY          idx_po_warehouse (tenant_id, warehouse_id),
  -- 同租户供应商引用
  CONSTRAINT fk_po_supplier FOREIGN KEY (tenant_id, supplier_id)
    REFERENCES biz_supplier (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  -- 同租户仓库引用
  CONSTRAINT fk_po_warehouse FOREIGN KEY (tenant_id, warehouse_id)
    REFERENCES biz_warehouse (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购单';

-- 表：biz_purchase_order_item（采购明细）- 依赖采购单；删除订单级联删除明细
DROP TABLE IF EXISTS biz_purchase_order_item;
CREATE TABLE biz_purchase_order_item (
  id            BIGINT        NOT NULL COMMENT '主键ID',
  tenant_id     BIGINT        NOT NULL COMMENT '租户ID',
  order_id      BIGINT        NOT NULL COMMENT '采购单ID',
  product_id    BIGINT        NOT NULL COMMENT '商品ID',
  quantity      DECIMAL(18,3) NOT NULL COMMENT '采购数量',
  price_amount  DECIMAL(18,2) NULL COMMENT '采购单价',
  price_currency VARCHAR(8)   NULL COMMENT '币种',
  warehouse_id  BIGINT        NULL COMMENT '收货仓ID',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_poi_tenant_id (tenant_id, id),
  KEY          idx_poi_tenant (tenant_id),
  KEY          idx_poi_order (tenant_id, order_id),
  KEY          idx_poi_product (tenant_id, product_id),
  -- 依赖采购单：删除采购单时 CASCADE 级联删除明细
  CONSTRAINT fk_poi_order FOREIGN KEY (tenant_id, order_id)
    REFERENCES biz_purchase_order (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  -- 引用商品与仓库：RESTRICT 防止被引用对象被误删
  CONSTRAINT fk_poi_product FOREIGN KEY (tenant_id, product_id)
    REFERENCES biz_product (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_poi_warehouse FOREIGN KEY (tenant_id, warehouse_id)
    REFERENCES biz_warehouse (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购单明细';

/* ========== 销售 ========== */
-- 表：biz_sales_order（销售单）- 与客户/仓库关联；删除客户/仓库将被限制
DROP TABLE IF EXISTS biz_sales_order;
CREATE TABLE biz_sales_order (
  id            BIGINT        NOT NULL COMMENT '主键ID',
  tenant_id     BIGINT        NOT NULL COMMENT '租户ID',
  customer_id   BIGINT        NOT NULL COMMENT '客户ID',
  warehouse_id  BIGINT        NULL COMMENT '出库仓ID',
  status        ENUM('DRAFT','CONFIRMED','ALLOCATED','SHIPPED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'DRAFT' COMMENT '销售状态',
  order_date    DATETIME      NOT NULL COMMENT '下单日期',
  total_amount  DECIMAL(18,2) NULL COMMENT '订单金额',
  total_currency VARCHAR(8)   NULL COMMENT '订单币种',
  notes         TEXT          NULL COMMENT '备注',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  created_by    VARCHAR(64)   NULL COMMENT '创建人',
  updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  updated_by    VARCHAR(64)   NULL COMMENT '更新人',
  is_deleted    TINYINT(1)    NOT NULL DEFAULT 0 COMMENT '逻辑删除标记(0-否,1-是)',
  version       INT           NOT NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  PRIMARY KEY (id),
  UNIQUE KEY uk_so_tenant_id (tenant_id, id),
  KEY          idx_so_tenant (tenant_id),
  KEY          idx_so_customer (tenant_id, customer_id),
  KEY          idx_so_warehouse (tenant_id, warehouse_id),
  -- 同租户客户引用
  CONSTRAINT fk_so_customer FOREIGN KEY (tenant_id, customer_id)
    REFERENCES biz_customer (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  -- 同租户仓库引用
  CONSTRAINT fk_so_warehouse FOREIGN KEY (tenant_id, warehouse_id)
    REFERENCES biz_warehouse (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售单';

-- 表：biz_sales_order_item（销售明细）- 依赖销售单；删除订单级联删除明细
DROP TABLE IF EXISTS biz_sales_order_item;
CREATE TABLE biz_sales_order_item (
  id            BIGINT        NOT NULL COMMENT '主键ID',
  tenant_id     BIGINT        NOT NULL COMMENT '租户ID',
  order_id      BIGINT        NOT NULL COMMENT '销售单ID',
  product_id    BIGINT        NOT NULL COMMENT '商品ID',
  quantity      DECIMAL(18,3) NOT NULL COMMENT '销售数量',
  price_amount  DECIMAL(18,2) NULL COMMENT '销售单价',
  price_currency VARCHAR(8)   NULL COMMENT '币种',
  warehouse_id  BIGINT        NULL COMMENT '出库仓ID',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_soi_tenant_id (tenant_id, id),
  KEY          idx_soi_tenant (tenant_id),
  KEY          idx_soi_order (tenant_id, order_id),
  KEY          idx_soi_product (tenant_id, product_id),
  -- 依赖销售单：删除销售单时 CASCADE 级联删除明细
  CONSTRAINT fk_soi_order FOREIGN KEY (tenant_id, order_id)
    REFERENCES biz_sales_order (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  -- 引用商品与仓库：RESTRICT 防止被引用对象被误删
  CONSTRAINT fk_soi_product FOREIGN KEY (tenant_id, product_id)
    REFERENCES biz_product (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_soi_warehouse FOREIGN KEY (tenant_id, warehouse_id)
    REFERENCES biz_warehouse (tenant_id, id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售单明细';

SET FOREIGN_KEY_CHECKS = 1;
