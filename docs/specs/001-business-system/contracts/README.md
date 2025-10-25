# Contracts（JSON Schema）

本目录用于业务系统契约（非 AI）：如 REST 请求/响应模式、领域对象（Item、Order、Ledger）等。

## 命名与版本

- 文件名使用 kebab-case，如 `purchase-order.schema.json`、`inventory-ledger.schema.json`。
- 使用 `$id` 与 `$schema` 指明版本；破坏性变更需 bump 主版本。

## 代码生成

- 目标语言：TypeScript / Java / Python
- 用途：生成 DTO/校验模型；在 CI 中执行一致性检查。

## 注意

- 契约中不得出现敏感实现细节（如内部表名/SQL）。
- 与权限/审计相关字段（tenantId、userId、correlationId）需保留。
