# 功能 002：智能分析问询系统 — 契约说明

## 1. 范围

本目录定义 AI 问询流程的消息、契约与事件，重点关注 WebSocket 交互与 SQL 审批工作流，需与功能 001 的共享 Schema 对齐。

## 2. 契约清单

| 契约 | 文件 | 说明 |
| ---- | ---- | ---- |
| `RequestEnvelope` 扩展 | `schemas/request-envelope-extended.json` | 在基础封包上增加 `sessionId`、`messageType`、`tenantContext`、`telemetry`。 |
| `InsightPayload` 扩展 | `schemas/insight-payload-extended.json` | 增加置信度、推荐动作、数据快照版本与 `traceId`。 |
| `SqlApprovalRequest` | `schemas/sql-approval-request.json` | SQL 审批任务描述，含意图、理由、风险评级。 |
| `SqlApprovalDecision` | `schemas/sql-approval-decision.json` | 审批结果消息，供 AI 与前端同步状态。 |
| `TableDescriptor` | `schemas/table-descriptor.json` | 表格数据结构（列描述、分页、排序、合计）。 |
| `ChartDescriptor` | `schemas/chart-descriptor.json` | 图表渲染所需信息（类型、数据点、配色、交互）。 |
| WebSocket 协议 | `ws/protocol.md` | 消息流转、心跳、错误码、重连策略。 |
| 审批 API | `rest/sql-approval.yaml` | 审批列表、详情、操作接口 OpenAPI 契约。 |

## 3. 版本策略

- 共用 Schema 的扩展字段需向下兼容；新增字段应标记为可选并更新 JSON Schema 版本。
- 契约变更需同步更新 `.specify/specs/001-business-system/contracts/README.md` 以维持一致性。

## 4. 生成与验证

- 使用 `json-schema-to-typescript`、`jsonschema2pojo`、`datamodel-codegen` 生成多语言类型。
- 通过 Schemathesis 针对 `rest/sql-approval.yaml` 执行契约测试。
- WebSocket 协议由 Playwright + Pact（可选）验证。

## 5. 更新记录

- 2025-10-26：创建契约结构与待交付文件清单。
