# 001-进销存业务系统：需求规格（Spec）

## 角色与权限

- 租户管理员、采购员、销售员、库管、审计员。
- 最小授权单元为 URL/资源；菜单仅用于导航。
- 数据权限：按租户/机构/仓库维度的行/范围策略；字段脱敏（如价格、电话）。

## 主数据

- 商品（SPU/SKU 简化版）、供应商、客户、仓库、库位（可后置）。

## 用例

- 采购：新建采购单 → 审核 → 入库 →（可选）退货；更新应付台账。
- 销售：新建销售单 → 审核 → 出库 →（可选）退货；更新应收台账。
- 库存：入库/出库/调拨/盘点；库存结存与快照查询。
- 报表：库存余额、周转率、采销额按日/周/月聚合；导出/订阅。

## API（草案）

- 认证与上下文
  - POST /auth/login → JWT
  - 所有 API 需 Header: X-Tenant-Id
- 主数据
  - GET/POST/PUT/DELETE /items
  - GET/POST/PUT/DELETE /suppliers
  - GET/POST/PUT/DELETE /customers
  - GET/POST/PUT/DELETE /warehouses
- 采购
  - GET/POST /purchase/orders
  - POST /purchase/orders/{id}/approve
  - POST /purchase/orders/{id}/receive
  - POST /purchase/orders/{id}/return
- 销售
  - GET/POST /sales/orders
  - POST /sales/orders/{id}/approve
  - POST /sales/orders/{id}/ship
  - POST /sales/orders/{id}/return
- 库存
  - GET /inventory/ledger（按 item/warehouse 过滤）
  - POST /inventory/stock-in
  - POST /inventory/stock-out
  - POST /inventory/transfer
  - POST /inventory/stocktake
- 报表
  - GET /reports/inventory/balance?from=...&to=...
  - GET /reports/sales/summary?from=...&to=...
  - GET /reports/purchase/summary?from=...&to=...
  - POST /reports/export

## 数据模型（摘要）

- Item{id, sku, name, unit}
- Supplier{id, name}
- Customer{id, name}
- Warehouse{id, name}
- InventoryLedger{id, itemId, warehouseId, qtyDelta, type, ts}
- PurchaseOrder{id, supplierId, items[], status}
- SalesOrder{id, customerId, items[], status}

## 审计与合规

- 所有变更操作记录审计日志：tenantId、userId、resource、action、before/after、ts、correlationId。

## 非功能

- p95 < 2s；并发目标按单租户 50 RPS 起步。
- 可观测性：日志规范、追踪（correlationId）、指标（请求数/延迟/错误率）。

## 错误码

- 401 未认证；403 越权；422 参数/状态不合法；409 版本冲突；500 内部错误。
