# IDAP 进销存系统 - 数据模型设计

**版本**: v1.0  
**日期**: 2025-10-25  
**数据库**: PostgreSQL 15+  
**编码**: UTF-8  
**时区**: Asia/Shanghai

---

## 一、设计原则

### 1.1 多租户隔离

- 所有业务表必须包含 `tenant_id` 字段
- 使用 Row-Level Security (RLS) 或 JPA 全局过滤器
- 租户间数据完全隔离，禁止跨租户查询

### 1.2 审计追踪

- 所有业务表包含审计字段：
  - `created_by` (创建人)
  - `created_at` (创建时间)
  - `updated_by` (更新人)
  - `updated_at` (更新时间)
  - `deleted` (软删除标记)

### 1.3 主键策略

- 使用雪花算法生成分布式 ID（bigint）
- 或使用 UUID（uuid 类型）
- 避免使用自增 ID（多租户场景下易泄露信息）

### 1.4 索引策略

- 租户 ID 必须作为联合索引的首列
- 高频查询字段添加索引
- 状态字段使用部分索引（条件索引）

---

## 二、核心表设计

### 2.1 租户域（Tenant Domain）

#### 表：sys_tenant（租户表）

```sql
CREATE TABLE sys_tenant (
    id BIGINT PRIMARY KEY,
    tenant_code VARCHAR(50) UNIQUE NOT NULL,        -- 租户代码（唯一标识）
    tenant_name VARCHAR(100) NOT NULL,              -- 租户名称
    tenant_type VARCHAR(20) NOT NULL,               -- 租户类型：ENTERPRISE/PERSONAL
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',   -- 状态：ACTIVE/SUSPENDED/EXPIRED
    contact_name VARCHAR(50),                       -- 联系人
    contact_phone VARCHAR(20),                      -- 联系电话
    contact_email VARCHAR(100),                     -- 联系邮箱
    logo_url VARCHAR(500),                          -- Logo URL
    domain VARCHAR(100),                            -- 自定义域名
    expired_at TIMESTAMP,                           -- 过期时间
    max_users INT DEFAULT 10,                       -- 最大用户数
    max_storage BIGINT DEFAULT 10737418240,         -- 最大存储空间（字节）10GB
    settings JSONB,                                 -- 租户配置（JSON）
    remark TEXT,                                    -- 备注
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_tenant_code ON sys_tenant(tenant_code) WHERE deleted = FALSE;
CREATE INDEX idx_tenant_status ON sys_tenant(status) WHERE deleted = FALSE;
```

---

### 2.2 组织架构域（Organization Domain）

#### 表：sys_organization（机构/部门表）

```sql
CREATE TABLE sys_organization (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,                      -- 租户 ID
    parent_id BIGINT,                               -- 父机构 ID
    org_code VARCHAR(50) NOT NULL,                  -- 机构代码
    org_name VARCHAR(100) NOT NULL,                 -- 机构名称
    org_type VARCHAR(20) NOT NULL,                  -- 机构类型：COMPANY/DEPARTMENT/TEAM
    sort_order INT DEFAULT 0,                       -- 排序
    leader_id BIGINT,                               -- 负责人 ID
    phone VARCHAR(20),                              -- 联系电话
    email VARCHAR(100),                             -- 联系邮箱
    address TEXT,                                   -- 地址
    status VARCHAR(20) DEFAULT 'ACTIVE',            -- 状态：ACTIVE/INACTIVE
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id)
);

CREATE INDEX idx_org_tenant ON sys_organization(tenant_id, deleted);
CREATE INDEX idx_org_parent ON sys_organization(tenant_id, parent_id);
CREATE INDEX idx_org_code ON sys_organization(tenant_id, org_code) WHERE deleted = FALSE;
```

---

### 2.3 用户域（User Domain）

#### 表：sys_user（用户表）

```sql
CREATE TABLE sys_user (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,                      -- 租户 ID
    username VARCHAR(50) NOT NULL,                  -- 用户名
    password VARCHAR(200) NOT NULL,                 -- 密码（BCrypt）
    real_name VARCHAR(50) NOT NULL,                 -- 真实姓名
    nickname VARCHAR(50),                           -- 昵称
    email VARCHAR(100),                             -- 邮箱
    phone VARCHAR(20),                              -- 手机号
    gender VARCHAR(10),                             -- 性别：MALE/FEMALE/UNKNOWN
    avatar_url VARCHAR(500),                        -- 头像 URL
    org_id BIGINT,                                  -- 所属机构 ID
    status VARCHAR(20) DEFAULT 'ACTIVE',            -- 状态：ACTIVE/LOCKED/DISABLED
    last_login_at TIMESTAMP,                        -- 最后登录时间
    last_login_ip VARCHAR(50),                      -- 最后登录 IP
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (org_id) REFERENCES sys_organization(id)
);

CREATE UNIQUE INDEX idx_user_username ON sys_user(tenant_id, username) WHERE deleted = FALSE;
CREATE INDEX idx_user_tenant ON sys_user(tenant_id, deleted);
CREATE INDEX idx_user_org ON sys_user(tenant_id, org_id);
CREATE INDEX idx_user_email ON sys_user(tenant_id, email) WHERE deleted = FALSE;
CREATE INDEX idx_user_phone ON sys_user(tenant_id, phone) WHERE deleted = FALSE;
```

#### 表：sys_role（角色表）

```sql
CREATE TABLE sys_role (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,                      -- 租户 ID
    role_code VARCHAR(50) NOT NULL,                 -- 角色代码
    role_name VARCHAR(100) NOT NULL,                -- 角色名称
    role_type VARCHAR(20) DEFAULT 'CUSTOM',         -- 角色类型：SYSTEM/CUSTOM
    data_scope VARCHAR(20) DEFAULT 'SELF',          -- 数据权限：ALL/ORG/ORG_CHILD/SELF/CUSTOM
    sort_order INT DEFAULT 0,                       -- 排序
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id)
);

CREATE UNIQUE INDEX idx_role_code ON sys_role(tenant_id, role_code) WHERE deleted = FALSE;
CREATE INDEX idx_role_tenant ON sys_role(tenant_id, deleted);
```

#### 表：sys_user_role（用户角色关联表）

```sql
CREATE TABLE sys_user_role (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,                      -- 租户 ID
    user_id BIGINT NOT NULL,                        -- 用户 ID
    role_id BIGINT NOT NULL,                        -- 角色 ID
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (user_id) REFERENCES sys_user(id),
    FOREIGN KEY (role_id) REFERENCES sys_role(id)
);

CREATE UNIQUE INDEX idx_user_role ON sys_user_role(tenant_id, user_id, role_id);
CREATE INDEX idx_user_role_tenant ON sys_user_role(tenant_id);
```

---

### 2.4 权限域（Permission Domain）

#### 表：sys_menu（菜单表）

```sql
CREATE TABLE sys_menu (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT,                               -- 租户 ID（NULL 为系统菜单）
    parent_id BIGINT,                               -- 父菜单 ID
    menu_name VARCHAR(100) NOT NULL,                -- 菜单名称
    menu_type VARCHAR(20) NOT NULL,                 -- 菜单类型：DIRECTORY/MENU/BUTTON
    path VARCHAR(200),                              -- 路由路径
    component VARCHAR(200),                         -- 组件路径
    permission VARCHAR(200),                        -- 权限标识
    icon VARCHAR(100),                              -- 图标
    sort_order INT DEFAULT 0,                       -- 排序
    visible BOOLEAN DEFAULT TRUE,                   -- 是否可见
    status VARCHAR(20) DEFAULT 'ACTIVE',            -- 状态：ACTIVE/INACTIVE
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_menu_tenant ON sys_menu(tenant_id, deleted);
CREATE INDEX idx_menu_parent ON sys_menu(tenant_id, parent_id);
```

#### 表：sys_resource（资源表 - URL/按钮）

```sql
CREATE TABLE sys_resource (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT,                               -- 租户 ID（NULL 为系统资源）
    resource_code VARCHAR(100) NOT NULL,            -- 资源代码
    resource_name VARCHAR(200) NOT NULL,            -- 资源名称
    resource_type VARCHAR(20) NOT NULL,             -- 资源类型：URL/BUTTON
    resource_url VARCHAR(500),                      -- 资源 URL
    request_method VARCHAR(10),                     -- 请求方法：GET/POST/PUT/DELETE
    permission VARCHAR(200),                        -- 权限标识
    sort_order INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_resource_tenant ON sys_resource(tenant_id, deleted);
CREATE INDEX idx_resource_url ON sys_resource(tenant_id, resource_url);
```

#### 表：sys_role_menu（角色菜单关联表）

```sql
CREATE TABLE sys_role_menu (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    menu_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (role_id) REFERENCES sys_role(id),
    FOREIGN KEY (menu_id) REFERENCES sys_menu(id)
);

CREATE UNIQUE INDEX idx_role_menu ON sys_role_menu(tenant_id, role_id, menu_id);
```

#### 表：sys_role_resource（角色资源关联表）

```sql
CREATE TABLE sys_role_resource (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    resource_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (role_id) REFERENCES sys_role(id),
    FOREIGN KEY (resource_id) REFERENCES sys_resource(id)
);

CREATE UNIQUE INDEX idx_role_resource ON sys_role_resource(tenant_id, role_id, resource_id);
```

---

### 2.5 主数据域（Master Data Domain）

#### 表：biz_warehouse（仓库表）

```sql
CREATE TABLE biz_warehouse (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    warehouse_code VARCHAR(50) NOT NULL,            -- 仓库代码
    warehouse_name VARCHAR(100) NOT NULL,           -- 仓库名称
    warehouse_type VARCHAR(20) NOT NULL,            -- 仓库类型：MAIN/BRANCH/VIRTUAL
    org_id BIGINT,                                  -- 所属机构
    manager_id BIGINT,                              -- 负责人
    address TEXT,                                   -- 地址
    phone VARCHAR(20),
    capacity DECIMAL(15,2),                         -- 容量（立方米）
    status VARCHAR(20) DEFAULT 'ACTIVE',
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (org_id) REFERENCES sys_organization(id)
);

CREATE UNIQUE INDEX idx_warehouse_code ON biz_warehouse(tenant_id, warehouse_code) WHERE deleted = FALSE;
CREATE INDEX idx_warehouse_tenant ON biz_warehouse(tenant_id, deleted);
```

#### 表：biz_supplier（供应商表）

```sql
CREATE TABLE biz_supplier (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    supplier_code VARCHAR(50) NOT NULL,             -- 供应商代码
    supplier_name VARCHAR(200) NOT NULL,            -- 供应商名称
    supplier_type VARCHAR(20),                      -- 供应商类型
    contact_name VARCHAR(50),                       -- 联系人
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    address TEXT,
    bank_name VARCHAR(100),                         -- 开户行
    bank_account VARCHAR(50),                       -- 银行账号
    tax_number VARCHAR(50),                         -- 税号
    credit_level VARCHAR(20),                       -- 信用等级：A/B/C/D
    status VARCHAR(20) DEFAULT 'ACTIVE',
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id)
);

CREATE UNIQUE INDEX idx_supplier_code ON biz_supplier(tenant_id, supplier_code) WHERE deleted = FALSE;
CREATE INDEX idx_supplier_tenant ON biz_supplier(tenant_id, deleted);
```

#### 表：biz_customer（客户表）

```sql
CREATE TABLE biz_customer (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    customer_code VARCHAR(50) NOT NULL,             -- 客户代码
    customer_name VARCHAR(200) NOT NULL,            -- 客户名称
    customer_type VARCHAR(20),                      -- 客户类型
    contact_name VARCHAR(50),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    address TEXT,
    credit_limit DECIMAL(15,2) DEFAULT 0,           -- 信用额度
    credit_level VARCHAR(20),                       -- 信用等级
    status VARCHAR(20) DEFAULT 'ACTIVE',
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id)
);

CREATE UNIQUE INDEX idx_customer_code ON biz_customer(tenant_id, customer_code) WHERE deleted = FALSE;
CREATE INDEX idx_customer_tenant ON biz_customer(tenant_id, deleted);
```

#### 表：biz_product_category（商品分类表）

```sql
CREATE TABLE biz_product_category (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    parent_id BIGINT,
    category_code VARCHAR(50) NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    sort_order INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id)
);

CREATE INDEX idx_category_tenant ON biz_product_category(tenant_id, parent_id, deleted);
```

#### 表：biz_product（商品表 - SPU）

```sql
CREATE TABLE biz_product (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    product_code VARCHAR(50) NOT NULL,              -- 商品代码
    product_name VARCHAR(200) NOT NULL,             -- 商品名称
    category_id BIGINT,                             -- 分类 ID
    unit VARCHAR(20) NOT NULL,                      -- 单位：个/件/箱/kg
    spec TEXT,                                      -- 规格
    brand VARCHAR(100),                             -- 品牌
    barcode VARCHAR(100),                           -- 条形码
    image_url VARCHAR(500),                         -- 图片 URL
    purchase_price DECIMAL(15,2),                   -- 采购价
    sale_price DECIMAL(15,2),                       -- 销售价
    cost_price DECIMAL(15,2),                       -- 成本价
    min_stock DECIMAL(15,2) DEFAULT 0,              -- 最低库存
    max_stock DECIMAL(15,2),                        -- 最高库存
    status VARCHAR(20) DEFAULT 'ACTIVE',
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (category_id) REFERENCES biz_product_category(id)
);

CREATE UNIQUE INDEX idx_product_code ON biz_product(tenant_id, product_code) WHERE deleted = FALSE;
CREATE INDEX idx_product_tenant ON biz_product(tenant_id, deleted);
CREATE INDEX idx_product_category ON biz_product(tenant_id, category_id);
```

---

### 2.6 库存域（Inventory Domain）

#### 表：biz_stock（库存表）

```sql
CREATE TABLE biz_stock (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,                   -- 仓库 ID
    product_id BIGINT NOT NULL,                     -- 商品 ID
    quantity DECIMAL(15,2) NOT NULL DEFAULT 0,      -- 当前库存
    locked_quantity DECIMAL(15,2) DEFAULT 0,        -- 锁定库存
    available_quantity DECIMAL(15,2) DEFAULT 0,     -- 可用库存
    cost_price DECIMAL(15,2),                       -- 成本价
    last_in_at TIMESTAMP,                           -- 最后入库时间
    last_out_at TIMESTAMP,                          -- 最后出库时间
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (warehouse_id) REFERENCES biz_warehouse(id),
    FOREIGN KEY (product_id) REFERENCES biz_product(id)
);

CREATE UNIQUE INDEX idx_stock_unique ON biz_stock(tenant_id, warehouse_id, product_id);
CREATE INDEX idx_stock_tenant ON biz_stock(tenant_id);
CREATE INDEX idx_stock_warehouse ON biz_stock(tenant_id, warehouse_id);
```

#### 表：biz_stock_log（库存流水表）

```sql
CREATE TABLE biz_stock_log (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    log_type VARCHAR(20) NOT NULL,                  -- 流水类型：IN/OUT/TRANSFER/ADJUST
    quantity DECIMAL(15,2) NOT NULL,                -- 数量（正数入库，负数出库）
    before_quantity DECIMAL(15,2),                  -- 变化前库存
    after_quantity DECIMAL(15,2),                   -- 变化后库存
    bill_type VARCHAR(50),                          -- 单据类型：PURCHASE/SALE/TRANSFER
    bill_id BIGINT,                                 -- 单据 ID
    bill_no VARCHAR(100),                           -- 单据编号
    operator_id BIGINT,                             -- 操作人
    operated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remark TEXT,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (warehouse_id) REFERENCES biz_warehouse(id),
    FOREIGN KEY (product_id) REFERENCES biz_product(id)
);

CREATE INDEX idx_stock_log_tenant ON biz_stock_log(tenant_id);
CREATE INDEX idx_stock_log_warehouse ON biz_stock_log(tenant_id, warehouse_id);
CREATE INDEX idx_stock_log_product ON biz_stock_log(tenant_id, product_id);
CREATE INDEX idx_stock_log_bill ON biz_stock_log(tenant_id, bill_type, bill_id);
CREATE INDEX idx_stock_log_time ON biz_stock_log(tenant_id, operated_at);
```

---

### 2.7 采购域（Purchase Domain）

#### 表：biz_purchase_order（采购订单表）

```sql
CREATE TABLE biz_purchase_order (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    order_no VARCHAR(100) NOT NULL,                 -- 订单编号
    supplier_id BIGINT NOT NULL,                    -- 供应商 ID
    warehouse_id BIGINT NOT NULL,                   -- 收货仓库 ID
    order_date DATE NOT NULL,                       -- 订单日期
    expected_date DATE,                             -- 期望到货日期
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,  -- 订单总额
    discount_amount DECIMAL(15,2) DEFAULT 0,        -- 优惠金额
    actual_amount DECIMAL(15,2) NOT NULL DEFAULT 0, -- 实际金额
    paid_amount DECIMAL(15,2) DEFAULT 0,            -- 已付金额
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',    -- 状态：DRAFT/PENDING/APPROVED/IN_TRANSIT/COMPLETED/CANCELLED
    approver_id BIGINT,                             -- 审批人 ID
    approved_at TIMESTAMP,                          -- 审批时间
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (supplier_id) REFERENCES biz_supplier(id),
    FOREIGN KEY (warehouse_id) REFERENCES biz_warehouse(id)
);

CREATE UNIQUE INDEX idx_purchase_order_no ON biz_purchase_order(tenant_id, order_no) WHERE deleted = FALSE;
CREATE INDEX idx_purchase_tenant ON biz_purchase_order(tenant_id, deleted);
CREATE INDEX idx_purchase_supplier ON biz_purchase_order(tenant_id, supplier_id);
CREATE INDEX idx_purchase_status ON biz_purchase_order(tenant_id, status) WHERE deleted = FALSE;
CREATE INDEX idx_purchase_date ON biz_purchase_order(tenant_id, order_date);
```

#### 表：biz_purchase_order_item（采购订单明细表）

```sql
CREATE TABLE biz_purchase_order_item (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,                       -- 订单 ID
    product_id BIGINT NOT NULL,                     -- 商品 ID
    quantity DECIMAL(15,2) NOT NULL,                -- 采购数量
    received_quantity DECIMAL(15,2) DEFAULT 0,      -- 已收货数量
    price DECIMAL(15,2) NOT NULL,                   -- 单价
    amount DECIMAL(15,2) NOT NULL,                  -- 金额
    tax_rate DECIMAL(5,2) DEFAULT 0,                -- 税率
    tax_amount DECIMAL(15,2) DEFAULT 0,             -- 税额
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (order_id) REFERENCES biz_purchase_order(id),
    FOREIGN KEY (product_id) REFERENCES biz_product(id)
);

CREATE INDEX idx_purchase_item_order ON biz_purchase_order_item(tenant_id, order_id);
CREATE INDEX idx_purchase_item_product ON biz_purchase_order_item(tenant_id, product_id);
```

#### 表：biz_purchase_receive（采购入库单表）

```sql
CREATE TABLE biz_purchase_receive (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    receive_no VARCHAR(100) NOT NULL,               -- 入库单编号
    order_id BIGINT NOT NULL,                       -- 采购订单 ID
    warehouse_id BIGINT NOT NULL,                   -- 入库仓库 ID
    receive_date DATE NOT NULL,                     -- 入库日期
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,  -- 入库总额
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',    -- 状态：DRAFT/CONFIRMED/CANCELLED
    receiver_id BIGINT,                             -- 收货人 ID
    received_at TIMESTAMP,                          -- 收货时间
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (order_id) REFERENCES biz_purchase_order(id),
    FOREIGN KEY (warehouse_id) REFERENCES biz_warehouse(id)
);

CREATE UNIQUE INDEX idx_receive_no ON biz_purchase_receive(tenant_id, receive_no) WHERE deleted = FALSE;
CREATE INDEX idx_receive_tenant ON biz_purchase_receive(tenant_id, deleted);
CREATE INDEX idx_receive_order ON biz_purchase_receive(tenant_id, order_id);
```

#### 表：biz_purchase_receive_item（采购入库明细表）

```sql
CREATE TABLE biz_purchase_receive_item (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    receive_id BIGINT NOT NULL,                     -- 入库单 ID
    order_item_id BIGINT NOT NULL,                  -- 订单明细 ID
    product_id BIGINT NOT NULL,                     -- 商品 ID
    quantity DECIMAL(15,2) NOT NULL,                -- 入库数量
    price DECIMAL(15,2) NOT NULL,                   -- 单价
    amount DECIMAL(15,2) NOT NULL,                  -- 金额
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (receive_id) REFERENCES biz_purchase_receive(id),
    FOREIGN KEY (order_item_id) REFERENCES biz_purchase_order_item(id),
    FOREIGN KEY (product_id) REFERENCES biz_product(id)
);

CREATE INDEX idx_receive_item_receive ON biz_purchase_receive_item(tenant_id, receive_id);
```

#### 表：biz_purchase_return（采购退货单表）

```sql
CREATE TABLE biz_purchase_return (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    return_no VARCHAR(100) NOT NULL,                -- 退货单编号
    order_id BIGINT NOT NULL,                       -- 采购订单 ID
    warehouse_id BIGINT NOT NULL,                   -- 退货仓库 ID
    return_date DATE NOT NULL,                      -- 退货日期
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,  -- 退货总额
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',    -- 状态：DRAFT/CONFIRMED/CANCELLED
    return_reason TEXT,                             -- 退货原因
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (order_id) REFERENCES biz_purchase_order(id),
    FOREIGN KEY (warehouse_id) REFERENCES biz_warehouse(id)
);

CREATE UNIQUE INDEX idx_return_no ON biz_purchase_return(tenant_id, return_no) WHERE deleted = FALSE;
CREATE INDEX idx_return_tenant ON biz_purchase_return(tenant_id, deleted);
```

#### 表：biz_purchase_return_item（采购退货明细表）

```sql
CREATE TABLE biz_purchase_return_item (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    return_id BIGINT NOT NULL,                      -- 退货单 ID
    product_id BIGINT NOT NULL,                     -- 商品 ID
    quantity DECIMAL(15,2) NOT NULL,                -- 退货数量
    price DECIMAL(15,2) NOT NULL,                   -- 单价
    amount DECIMAL(15,2) NOT NULL,                  -- 金额
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (return_id) REFERENCES biz_purchase_return(id),
    FOREIGN KEY (product_id) REFERENCES biz_product(id)
);

CREATE INDEX idx_return_item_return ON biz_purchase_return_item(tenant_id, return_id);
```

---

### 2.8 销售域（Sales Domain）

#### 表：biz_sales_order（销售订单表）

```sql
CREATE TABLE biz_sales_order (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    order_no VARCHAR(100) NOT NULL,                 -- 订单编号
    customer_id BIGINT NOT NULL,                    -- 客户 ID
    warehouse_id BIGINT NOT NULL,                   -- 发货仓库 ID
    order_date DATE NOT NULL,                       -- 订单日期
    delivery_date DATE,                             -- 交货日期
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,  -- 订单总额
    discount_amount DECIMAL(15,2) DEFAULT 0,        -- 优惠金额
    actual_amount DECIMAL(15,2) NOT NULL DEFAULT 0, -- 实际金额
    received_amount DECIMAL(15,2) DEFAULT 0,        -- 已收款金额
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',    -- 状态：DRAFT/PENDING/APPROVED/SHIPPED/COMPLETED/CANCELLED
    approver_id BIGINT,                             -- 审批人 ID
    approved_at TIMESTAMP,                          -- 审批时间
    shipping_address TEXT,                          -- 收货地址
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (customer_id) REFERENCES biz_customer(id),
    FOREIGN KEY (warehouse_id) REFERENCES biz_warehouse(id)
);

CREATE UNIQUE INDEX idx_sales_order_no ON biz_sales_order(tenant_id, order_no) WHERE deleted = FALSE;
CREATE INDEX idx_sales_tenant ON biz_sales_order(tenant_id, deleted);
CREATE INDEX idx_sales_customer ON biz_sales_order(tenant_id, customer_id);
CREATE INDEX idx_sales_status ON biz_sales_order(tenant_id, status) WHERE deleted = FALSE;
CREATE INDEX idx_sales_date ON biz_sales_order(tenant_id, order_date);
```

#### 表：biz_sales_order_item（销售订单明细表）

```sql
CREATE TABLE biz_sales_order_item (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,                       -- 订单 ID
    product_id BIGINT NOT NULL,                     -- 商品 ID
    quantity DECIMAL(15,2) NOT NULL,                -- 销售数量
    shipped_quantity DECIMAL(15,2) DEFAULT 0,       -- 已发货数量
    price DECIMAL(15,2) NOT NULL,                   -- 单价
    amount DECIMAL(15,2) NOT NULL,                  -- 金额
    tax_rate DECIMAL(5,2) DEFAULT 0,                -- 税率
    tax_amount DECIMAL(15,2) DEFAULT 0,             -- 税额
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (order_id) REFERENCES biz_sales_order(id),
    FOREIGN KEY (product_id) REFERENCES biz_product(id)
);

CREATE INDEX idx_sales_item_order ON biz_sales_order_item(tenant_id, order_id);
CREATE INDEX idx_sales_item_product ON biz_sales_order_item(tenant_id, product_id);
```

#### 表：biz_sales_shipment（销售出库单表）

```sql
CREATE TABLE biz_sales_shipment (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    shipment_no VARCHAR(100) NOT NULL,              -- 出库单编号
    order_id BIGINT NOT NULL,                       -- 销售订单 ID
    warehouse_id BIGINT NOT NULL,                   -- 出库仓库 ID
    shipment_date DATE NOT NULL,                    -- 出库日期
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,  -- 出库总额
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',    -- 状态：DRAFT/CONFIRMED/CANCELLED
    shipper_id BIGINT,                              -- 发货人 ID
    shipped_at TIMESTAMP,                           -- 发货时间
    tracking_no VARCHAR(100),                       -- 物流单号
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (order_id) REFERENCES biz_sales_order(id),
    FOREIGN KEY (warehouse_id) REFERENCES biz_warehouse(id)
);

CREATE UNIQUE INDEX idx_shipment_no ON biz_sales_shipment(tenant_id, shipment_no) WHERE deleted = FALSE;
CREATE INDEX idx_shipment_tenant ON biz_sales_shipment(tenant_id, deleted);
CREATE INDEX idx_shipment_order ON biz_sales_shipment(tenant_id, order_id);
```

#### 表：biz_sales_shipment_item（销售出库明细表）

```sql
CREATE TABLE biz_sales_shipment_item (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    shipment_id BIGINT NOT NULL,                    -- 出库单 ID
    order_item_id BIGINT NOT NULL,                  -- 订单明细 ID
    product_id BIGINT NOT NULL,                     -- 商品 ID
    quantity DECIMAL(15,2) NOT NULL,                -- 出库数量
    price DECIMAL(15,2) NOT NULL,                   -- 单价
    amount DECIMAL(15,2) NOT NULL,                  -- 金额
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (shipment_id) REFERENCES biz_sales_shipment(id),
    FOREIGN KEY (order_item_id) REFERENCES biz_sales_order_item(id),
    FOREIGN KEY (product_id) REFERENCES biz_product(id)
);

CREATE INDEX idx_shipment_item_shipment ON biz_sales_shipment_item(tenant_id, shipment_id);
```

#### 表：biz_sales_return（销售退货单表）

```sql
CREATE TABLE biz_sales_return (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    return_no VARCHAR(100) NOT NULL,                -- 退货单编号
    order_id BIGINT NOT NULL,                       -- 销售订单 ID
    warehouse_id BIGINT NOT NULL,                   -- 退货仓库 ID
    return_date DATE NOT NULL,                      -- 退货日期
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,  -- 退货总额
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',    -- 状态：DRAFT/CONFIRMED/CANCELLED
    return_reason TEXT,                             -- 退货原因
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (order_id) REFERENCES biz_sales_order(id),
    FOREIGN KEY (warehouse_id) REFERENCES biz_warehouse(id)
);

CREATE UNIQUE INDEX idx_sales_return_no ON biz_sales_return(tenant_id, return_no) WHERE deleted = FALSE;
CREATE INDEX idx_sales_return_tenant ON biz_sales_return(tenant_id, deleted);
```

#### 表：biz_sales_return_item（销售退货明细表）

```sql
CREATE TABLE biz_sales_return_item (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    return_id BIGINT NOT NULL,                      -- 退货单 ID
    product_id BIGINT NOT NULL,                     -- 商品 ID
    quantity DECIMAL(15,2) NOT NULL,                -- 退货数量
    price DECIMAL(15,2) NOT NULL,                   -- 单价
    amount DECIMAL(15,2) NOT NULL,                  -- 金额
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id),
    FOREIGN KEY (return_id) REFERENCES biz_sales_return(id),
    FOREIGN KEY (product_id) REFERENCES biz_product(id)
);

CREATE INDEX idx_sales_return_item_return ON biz_sales_return_item(tenant_id, return_id);
```

---

### 2.9 审计域（Audit Domain）

#### 表：sys_audit_log（审计日志表）

```sql
CREATE TABLE sys_audit_log (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    user_id BIGINT,                                 -- 操作用户 ID
    username VARCHAR(50),                           -- 用户名
    operation VARCHAR(50) NOT NULL,                 -- 操作类型：CREATE/UPDATE/DELETE/LOGIN/LOGOUT
    module VARCHAR(50) NOT NULL,                    -- 模块名称
    business_type VARCHAR(50),                      -- 业务类型
    business_id BIGINT,                             -- 业务 ID
    method VARCHAR(200),                            -- 请求方法
    request_url VARCHAR(500),                       -- 请求 URL
    request_method VARCHAR(10),                     -- HTTP 方法
    request_params TEXT,                            -- 请求参数（JSON）
    response_result TEXT,                           -- 响应结果（JSON）
    ip_address VARCHAR(50),                         -- IP 地址
    user_agent TEXT,                                -- User Agent
    status VARCHAR(20) NOT NULL,                    -- 状态：SUCCESS/FAILURE
    error_msg TEXT,                                 -- 错误信息
    duration_ms INT,                                -- 执行时长（毫秒）
    request_id VARCHAR(100),                        -- 请求追踪 ID
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(id)
);

CREATE INDEX idx_audit_tenant ON sys_audit_log(tenant_id);
CREATE INDEX idx_audit_user ON sys_audit_log(tenant_id, user_id);
CREATE INDEX idx_audit_time ON sys_audit_log(tenant_id, created_at);
CREATE INDEX idx_audit_operation ON sys_audit_log(tenant_id, operation);
CREATE INDEX idx_audit_request_id ON sys_audit_log(request_id);
```

---

### 2.10 数据字典域（Dictionary Domain）

#### 表：sys_dict_type（字典类型表）

```sql
CREATE TABLE sys_dict_type (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT,                               -- 租户 ID（NULL 为系统字典）
    dict_code VARCHAR(50) NOT NULL,                 -- 字典编码（唯一标识）
    dict_name VARCHAR(100) NOT NULL,                -- 字典名称
    dict_type VARCHAR(20) DEFAULT 'SYSTEM',         -- 字典类型：SYSTEM/CUSTOM
    description TEXT,                               -- 描述
    sort_order INT DEFAULT 0,                       -- 排序
    status VARCHAR(20) DEFAULT 'ACTIVE',            -- 状态：ACTIVE/INACTIVE
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE
);

CREATE UNIQUE INDEX idx_dict_type_code ON sys_dict_type(COALESCE(tenant_id, 0), dict_code) WHERE deleted = FALSE;
CREATE INDEX idx_dict_type_tenant ON sys_dict_type(tenant_id, deleted);
CREATE INDEX idx_dict_type_status ON sys_dict_type(tenant_id, status) WHERE deleted = FALSE;

COMMENT ON TABLE sys_dict_type IS '字典类型表：定义数据字典的分类，如"用户状态"、"订单状态"等';
COMMENT ON COLUMN sys_dict_type.dict_code IS '字典编码：如 user_status, order_status，用于代码中引用';
COMMENT ON COLUMN sys_dict_type.dict_type IS '字典类型：SYSTEM-系统内置（不可删除），CUSTOM-租户自定义';
```

#### 表：sys_dict_data（字典数据表）

```sql
CREATE TABLE sys_dict_data (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT,                               -- 租户 ID（NULL 为系统字典）
    dict_type_id BIGINT NOT NULL,                   -- 字典类型 ID
    dict_label VARCHAR(100) NOT NULL,               -- 字典标签（显示值）
    dict_value VARCHAR(100) NOT NULL,               -- 字典键值（实际值）
    dict_sort INT DEFAULT 0,                        -- 显示排序
    tag_type VARCHAR(20),                           -- 标签样式：default/primary/success/info/warning/danger
    css_class VARCHAR(100),                         -- CSS 类名
    is_default BOOLEAN DEFAULT FALSE,               -- 是否默认选项
    status VARCHAR(20) DEFAULT 'ACTIVE',            -- 状态：ACTIVE/INACTIVE
    remark TEXT,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (dict_type_id) REFERENCES sys_dict_type(id)
);

CREATE INDEX idx_dict_data_type ON sys_dict_data(tenant_id, dict_type_id, deleted);
CREATE INDEX idx_dict_data_value ON sys_dict_data(tenant_id, dict_type_id, dict_value) WHERE deleted = FALSE;
CREATE INDEX idx_dict_data_status ON sys_dict_data(tenant_id, status) WHERE deleted = FALSE;
CREATE INDEX idx_dict_data_sort ON sys_dict_data(tenant_id, dict_type_id, dict_sort);

COMMENT ON TABLE sys_dict_data IS '字典数据表：存储字典类型下的具体选项值';
COMMENT ON COLUMN sys_dict_data.dict_label IS '字典标签：前端显示的文本，如"正常"、"锁定"';
COMMENT ON COLUMN sys_dict_data.dict_value IS '字典键值：后端存储的值，如"ACTIVE"、"LOCKED"';
COMMENT ON COLUMN sys_dict_data.tag_type IS '标签样式：用于前端显示不同颜色的标签';
COMMENT ON COLUMN sys_dict_data.is_default IS '是否默认：新增数据时的默认选项';
```

#### 数据字典使用示例

```sql
-- 示例1：用户状态字典
INSERT INTO sys_dict_type (id, tenant_id, dict_code, dict_name, dict_type, description)
VALUES (1, NULL, 'user_status', '用户状态', 'SYSTEM', '用户账号状态枚举');

INSERT INTO sys_dict_data (id, tenant_id, dict_type_id, dict_label, dict_value, dict_sort, tag_type, is_default)
VALUES
    (101, NULL, 1, '正常', 'ACTIVE', 1, 'success', TRUE),
    (102, NULL, 1, '停用', 'INACTIVE', 2, 'info', FALSE),
    (103, NULL, 1, '锁定', 'LOCKED', 3, 'warning', FALSE),
    (104, NULL, 1, '已删除', 'DELETED', 4, 'danger', FALSE);

-- 示例2：订单状态字典
INSERT INTO sys_dict_type (id, tenant_id, dict_code, dict_name, dict_type, description)
VALUES (2, NULL, 'order_status', '订单状态', 'SYSTEM', '采购/销售订单状态枚举');

INSERT INTO sys_dict_data (id, tenant_id, dict_type_id, dict_label, dict_value, dict_sort, tag_type)
VALUES
    (201, NULL, 2, '草稿', 'DRAFT', 1, 'info'),
    (202, NULL, 2, '待审核', 'PENDING', 2, 'warning'),
    (203, NULL, 2, '已审核', 'APPROVED', 3, 'success'),
    (204, NULL, 2, '已驳回', 'REJECTED', 4, 'danger'),
    (205, NULL, 2, '已完成', 'COMPLETED', 5, 'success'),
    (206, NULL, 2, '已取消', 'CANCELLED', 6, 'info');

-- 示例3：商品单位字典（租户自定义）
INSERT INTO sys_dict_type (id, tenant_id, dict_code, dict_name, dict_type, description)
VALUES (100, 1, 'product_unit', '商品单位', 'CUSTOM', '租户自定义的商品单位');

INSERT INTO sys_dict_data (id, tenant_id, dict_type_id, dict_label, dict_value, dict_sort)
VALUES
    (1001, 1, 100, '个', 'PCS', 1),
    (1002, 1, 100, '箱', 'BOX', 2),
    (1003, 1, 100, '公斤', 'KG', 3),
    (1004, 1, 100, '吨', 'TON', 4),
    (1005, 1, 100, '米', 'METER', 5);
```

#### 数据字典 API 使用场景

```typescript
// 前端获取字典数据
interface DictData {
  label: string      // 显示标签
  value: string      // 实际值
  tagType?: string   // 标签类型
  cssClass?: string  // CSS 类名
}

// 1. 下拉框选项
GET /api/dict/data/{dictCode}
Response: DictData[]

// 2. 标签显示（根据值获取标签）
GET /api/dict/label/{dictCode}/{dictValue}
Response: { label: string, tagType: string }

// 3. 批量翻译（列表数据）
POST /api/dict/translate
Request: {
  dictCode: 'user_status',
  values: ['ACTIVE', 'LOCKED']
}
Response: {
  'ACTIVE': { label: '正常', tagType: 'success' },
  'LOCKED': { label: '锁定', tagType: 'warning' }
}
```

#### 数据字典缓存策略

```java
/**
 * 字典缓存策略
 * - 系统字典（tenant_id = NULL）：启动时加载，Redis 永久缓存
 * - 租户字典：按需加载，Redis 缓存 24 小时
 * - 缓存 Key 格式：dict:{tenant_id}:{dict_code}
 */
@Cacheable(value = "dict", key = "#tenantId + ':' + #dictCode")
public List<DictData> getDictData(Long tenantId, String dictCode) {
    // 查询逻辑
}

// 缓存失效策略
@CacheEvict(value = "dict", key = "#tenantId + ':' + #dictCode")
public void updateDictData(Long tenantId, String dictCode) {
    // 更新逻辑
}
```

---

_（未完待续 - 继续添加完整的 DDL 脚本和枚举定义）_

---

## 三、枚举定义

### 3.1 通用枚举

```typescript
// 状态枚举
enum Status {
  ACTIVE = "ACTIVE", // 激活
  INACTIVE = "INACTIVE", // 停用
  LOCKED = "LOCKED", // 锁定
  EXPIRED = "EXPIRED", // 过期
}

// 性别枚举
enum Gender {
  MALE = "MALE",
  FEMALE = "FEMALE",
  UNKNOWN = "UNKNOWN",
}

// 数据权限范围
enum DataScope {
  ALL = "ALL", // 全部数据
  ORG = "ORG", // 本机构
  ORG_CHILD = "ORG_CHILD", // 本机构及下级
  SELF = "SELF", // 仅自己
  CUSTOM = "CUSTOM", // 自定义
}
```

### 3.2 业务枚举

```typescript
// 库存流水类型
enum StockLogType {
  IN = "IN", // 入库
  OUT = "OUT", // 出库
  TRANSFER = "TRANSFER", // 调拨
  ADJUST = "ADJUST", // 调整
}

// 单据状态
enum BillStatus {
  DRAFT = "DRAFT", // 草稿
  PENDING = "PENDING", // 待审核
  APPROVED = "APPROVED", // 已审核
  REJECTED = "REJECTED", // 已驳回
  COMPLETED = "COMPLETED", // 已完成
  CANCELLED = "CANCELLED", // 已取消
}

// 字典类型
enum DictType {
  SYSTEM = "SYSTEM", // 系统字典（不可删除）
  CUSTOM = "CUSTOM", // 租户自定义字典
}

// 标签样式（用于前端显示）
enum TagType {
  DEFAULT = "default", // 默认灰色
  PRIMARY = "primary", // 主色蓝色
  SUCCESS = "success", // 成功绿色
  INFO = "info", // 信息蓝色
  WARNING = "warning", // 警告橙色
  DANGER = "danger", // 危险红色
}
```

### 3.3 系统预置字典清单

| 字典编码         | 字典名称     | 应用场景      |
| ---------------- | ------------ | ------------- |
| `user_status`    | 用户状态     | 用户管理      |
| `user_gender`    | 性别         | 用户信息      |
| `org_type`       | 机构类型     | 组织架构      |
| `tenant_type`    | 租户类型     | 租户管理      |
| `menu_type`      | 菜单类型     | 菜单管理      |
| `resource_type`  | 资源类型     | 权限管理      |
| `data_scope`     | 数据权限范围 | 角色管理      |
| `warehouse_type` | 仓库类型     | 仓库管理      |
| `supplier_level` | 供应商等级   | 供应商管理    |
| `customer_level` | 客户等级     | 客户管理      |
| `product_unit`   | 商品单位     | 商品管理      |
| `order_status`   | 订单状态     | 采购/销售订单 |
| `bill_status`    | 单据状态     | 所有单据      |
| `audit_result`   | 审核结果     | 审批流程      |
| `payment_method` | 付款方式     | 财务管理      |
| `invoice_type`   | 发票类型     | 财务管理      |

````

---

## 四、数据字典最佳实践

### 4.1 字典命名规范

```typescript
// 字典编码命名：{模块}_{业务}_{类型}
// 示例：
- sys_user_status        // 系统-用户-状态
- biz_order_status       // 业务-订单-状态
- biz_product_unit       // 业务-商品-单位
- finance_payment_method // 财务-支付-方式
````

### 4.2 前端使用示例

```vue
<!-- 1. 下拉选择器 -->
<template>
  <el-select v-model="form.status" placeholder="请选择状态">
    <el-option
      v-for="item in statusDict"
      :key="item.value"
      :label="item.label"
      :value="item.value"
    />
  </el-select>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { getDictData } from "@/api/dict";

const statusDict = ref<DictData[]>([]);

onMounted(async () => {
  statusDict.value = await getDictData("user_status");
});
</script>

<!-- 2. 标签显示 -->
<template>
  <el-tag :type="getStatusTagType(row.status)">
    {{ getStatusLabel(row.status) }}
  </el-tag>
</template>

<script setup lang="ts">
import { useDictStore } from "@/stores/dict";

const dictStore = useDictStore();

const getStatusLabel = (value: string) => {
  return dictStore.getLabel("user_status", value);
};

const getStatusTagType = (value: string) => {
  return dictStore.getTagType("user_status", value);
};
</script>
```

### 4.3 后端使用示例

```java
// 1. 服务层：字典数据查询
@Service
public class DictService {

    @Cacheable(value = "dict", key = "#tenantId + ':' + #dictCode")
    public List<DictDataVO> getDictData(Long tenantId, String dictCode) {
        // 查询字典类型
        DictType dictType = dictTypeRepository.findByCode(dictCode, tenantId);

        // 查询字典数据
        return dictDataRepository.findByTypeId(dictType.getId(), tenantId)
            .stream()
            .filter(d -> "ACTIVE".equals(d.getStatus()))
            .sorted(Comparator.comparing(DictData::getDictSort))
            .map(this::toVO)
            .collect(Collectors.toList());
    }

    // 2. 字典值翻译
    public String translateLabel(Long tenantId, String dictCode, String value) {
        String cacheKey = String.format("dict:%d:%s:%s", tenantId, dictCode, value);
        return redisTemplate.opsForValue().get(cacheKey);
    }
}

// 3. 控制器：字典 API
@RestController
@RequestMapping("/api/dict")
public class DictController {

    @Autowired
    private DictService dictService;

    /**
     * 获取字典数据
     */
    @GetMapping("/data/{dictCode}")
    public Result<List<DictDataVO>> getDictData(@PathVariable String dictCode) {
        Long tenantId = TenantContextHolder.getTenantId();
        return Result.success(dictService.getDictData(tenantId, dictCode));
    }

    /**
     * 批量翻译字典值
     */
    @PostMapping("/translate")
    public Result<Map<String, DictLabelVO>> translateBatch(@RequestBody DictTranslateRequest request) {
        Long tenantId = TenantContextHolder.getTenantId();
        return Result.success(dictService.translateBatch(tenantId, request));
    }
}
```

### 4.4 字典数据初始化脚本

```sql
-- ============================================
-- 数据字典初始化脚本
-- 用途：系统启动时加载预置字典数据
-- ============================================

-- 1. 用户状态字典
INSERT INTO sys_dict_type (id, dict_code, dict_name, dict_type, description, sort_order, status)
VALUES (1, 'user_status', '用户状态', 'SYSTEM', '用户账号状态', 1, 'ACTIVE');

INSERT INTO sys_dict_data (id, dict_type_id, dict_label, dict_value, dict_sort, tag_type, is_default, status)
VALUES
    (10101, 1, '正常', 'ACTIVE', 1, 'success', TRUE, 'ACTIVE'),
    (10102, 1, '停用', 'INACTIVE', 2, 'info', FALSE, 'ACTIVE'),
    (10103, 1, '锁定', 'LOCKED', 3, 'warning', FALSE, 'ACTIVE');

-- 2. 性别字典
INSERT INTO sys_dict_type (id, dict_code, dict_name, dict_type, description, sort_order, status)
VALUES (2, 'user_gender', '性别', 'SYSTEM', '用户性别', 2, 'ACTIVE');

INSERT INTO sys_dict_data (id, dict_type_id, dict_label, dict_value, dict_sort, tag_type, status)
VALUES
    (10201, 2, '男', 'MALE', 1, 'primary', 'ACTIVE'),
    (10202, 2, '女', 'FEMALE', 2, 'danger', 'ACTIVE'),
    (10203, 2, '未知', 'UNKNOWN', 3, 'info', 'ACTIVE');

-- 3. 订单状态字典
INSERT INTO sys_dict_type (id, dict_code, dict_name, dict_type, description, sort_order, status)
VALUES (3, 'order_status', '订单状态', 'SYSTEM', '采购/销售订单状态', 3, 'ACTIVE');

INSERT INTO sys_dict_data (id, dict_type_id, dict_label, dict_value, dict_sort, tag_type, status)
VALUES
    (10301, 3, '草稿', 'DRAFT', 1, 'info', 'ACTIVE'),
    (10302, 3, '待审核', 'PENDING', 2, 'warning', 'ACTIVE'),
    (10303, 3, '已审核', 'APPROVED', 3, 'success', 'ACTIVE'),
    (10304, 3, '已驳回', 'REJECTED', 4, 'danger', 'ACTIVE'),
    (10305, 3, '进行中', 'IN_PROGRESS', 5, 'primary', 'ACTIVE'),
    (10306, 3, '已完成', 'COMPLETED', 6, 'success', 'ACTIVE'),
    (10307, 3, '已取消', 'CANCELLED', 7, 'info', 'ACTIVE');

-- 4. 商品单位字典
INSERT INTO sys_dict_type (id, dict_code, dict_name, dict_type, description, sort_order, status)
VALUES (4, 'product_unit', '商品单位', 'SYSTEM', '商品计量单位', 4, 'ACTIVE');

INSERT INTO sys_dict_data (id, dict_type_id, dict_label, dict_value, dict_sort, status)
VALUES
    (10401, 4, '个', 'PCS', 1, 'ACTIVE'),
    (10402, 4, '件', 'PIECE', 2, 'ACTIVE'),
    (10403, 4, '箱', 'BOX', 3, 'ACTIVE'),
    (10404, 4, '公斤', 'KG', 4, 'ACTIVE'),
    (10405, 4, '吨', 'TON', 5, 'ACTIVE'),
    (10406, 4, '米', 'METER', 6, 'ACTIVE'),
    (10407, 4, '升', 'LITER', 7, 'ACTIVE');

-- 5. 数据权限范围字典
INSERT INTO sys_dict_type (id, dict_code, dict_name, dict_type, description, sort_order, status)
VALUES (5, 'data_scope', '数据权限范围', 'SYSTEM', '角色数据权限范围', 5, 'ACTIVE');

INSERT INTO sys_dict_data (id, dict_type_id, dict_label, dict_value, dict_sort, status)
VALUES
    (10501, 5, '全部数据', 'ALL', 1, 'ACTIVE'),
    (10502, 5, '本机构数据', 'ORG', 2, 'ACTIVE'),
    (10503, 5, '本机构及下级', 'ORG_CHILD', 3, 'ACTIVE'),
    (10504, 5, '仅本人数据', 'SELF', 4, 'ACTIVE'),
    (10505, 5, '自定义数据', 'CUSTOM', 5, 'ACTIVE');
```

### 4.5 字典管理界面功能

```typescript
// 字典管理页面功能清单
interface DictManagementFeatures {
  // 字典类型管理
  dictType: {
    list: "字典类型列表";
    add: "新增字典类型";
    edit: "编辑字典类型";
    delete: "删除字典类型（仅自定义）";
    export: "导出字典类型";
  };

  // 字典数据管理
  dictData: {
    list: "字典数据列表";
    add: "新增字典数据";
    edit: "编辑字典数据";
    delete: "删除字典数据";
    sort: "拖拽排序";
    batchImport: "批量导入";
    export: "导出字典数据";
  };

  // 高级功能
  advanced: {
    preview: "字典预览（实时查看效果）";
    cache: "刷新字典缓存";
    version: "字典版本管理";
    sync: "租户间字典同步";
  };
}
```

---

## 五、数据字典与枚举的选择

### 5.1 使用数据字典的场景

✅ **适合使用数据字典**：

1. **频繁变化的选项**

   - 商品单位、支付方式、发票类型等
   - 需要租户自定义的业务枚举

2. **需要多语言支持**

   - 字典标签可以根据语言切换

3. **需要动态管理**

   - 运营人员可通过界面添加/修改选项
   - 无需发布代码

4. **需要扩展属性**
   - 颜色、图标、CSS 类名等

### 5.2 使用代码枚举的场景

✅ **适合使用代码枚举**：

1. **系统核心枚举**

   - 用户状态、订单状态等业务关键字段
   - 与业务逻辑强耦合

2. **不会变化的选项**

   - 性别、布尔值等

3. **需要类型安全**

   - TypeScript/Java 枚举提供编译时检查

4. **性能要求高**
   - 枚举直接在代码中，无需查询数据库

### 5.3 混合使用策略

```java
/**
 * 推荐策略：代码枚举 + 数据字典混合使用
 */

// 1. 核心业务枚举：使用代码枚举
public enum OrderStatus {
    DRAFT("草稿"),
    PENDING("待审核"),
    APPROVED("已审核"),
    COMPLETED("已完成");

    private final String label;
}

// 2. 可扩展枚举：使用数据字典
// 由租户在管理界面自定义，存储在数据库
// 例如：商品单位、支付方式、发票类型等

// 3. 枚举与字典映射：系统启动时同步
@PostConstruct
public void syncEnumToDict() {
    // 将代码枚举同步到数据字典表
    // 保证数据一致性
}
```

---

**下一步**：生成完整的 DDL 脚本和 OpenAPI 文档。
