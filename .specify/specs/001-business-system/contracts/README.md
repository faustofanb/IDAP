# 功能 001：进销存业务系统 — 契约说明

## 1. 范围

本目录存放功能 001 的接口契约、JSON Schema 与事件定义，涵盖前后端、后端与 AI 服务之间的交互。所有契约需保持与 `spec.md`、`plan.md` 同步，并作为自动化测试的输入。

## 2. 契约清单

| 契约 | 文件 | 说明 |
| ---- | ---- | ---- |
| `RequestEnvelope` | `../../shared/schemas/request-envelope.json` | WebSocket/REST 通用封包，包含 `tenantId`、`correlationId`、安全签名与遥测。 |
| `BusinessRequest` | `../../shared/schemas/business-request.json` | AI 服务返回的业务意图描述，供后端命令处理。 |
| `SQLRequest` | `../../shared/schemas/sql-request.json` | AI 服务建议的受托 SQL 意图，满足审批后才可执行。 |
| `InsightPayload` | `../../shared/schemas/insight-payload.json` | AI 洞察消息结构，包含洞察文本、可视化描述与来源说明。 |
| 表格描述 | `../../shared/schemas/table-descriptor.json` | 前端表格渲染描述 Schema。 |
| 图表描述 | `../../shared/schemas/chart-descriptor.json` | 前端图表渲染描述 Schema。 |
| 领域对象 | `schemas/domain/*.json` | Product、Warehouse、Supplier、Customer、Inventory、StockMovement、PurchaseOrder、SalesOrder、Uom、Category。 |
| OpenAPI 契约 | `openapi.yaml` | v1 接口（主数据、单据、库存）定义，含多租户与 JWT。 |

> 提示：如需新增领域对象，请在 `schemas/domain/` 下添加 Schema，并在 `openapi.yaml` 的 components.schemas 中引用。

## 3. 版本管理

- 契约文件使用语义化版本（`x.y.z`），变更时在同目录 `CHANGELOG.md` 中记录。
- 重大变更需更新影响评估，并通知前端与 AI 团队。

## 4. 生成与验证

- **生成工具**：
  - TypeScript：`pnpm run generate:types`（待实现，调用 `json-schema-to-typescript`）。
  - Java：`mvn -pl ruoyi-common-core exec:java@jsonschema2pojo`（待实现）。
  - Python：`uv run datamodel-codegen`（待实现）。
- **验证策略**：
  - 在 CI 中引入 `ajv`、`schemathesis` 等工具对 JSON Schema 与 OpenAPI 进行校验。
  - WebSocket 契约通过契约测试（Spring + Playwright）验证。

## 5. 更新记录

- 2025-10-26：创建契约目录结构与约定，列出待交付的 Schema 与 OpenAPI 文件。
