# 功能 002：智能分析问询系统 — 任务清单

> 版本：v0.1（2025-10-26）

## 阶段 0：准备

- [ ] 补齐 `.specify/` 中 Feature 002 的 `spec.md`、`plan.md`、`tasks.md`，对齐本地文档。
- [ ] 在 `backend/ruoyi-admin` 中预留 WebSocket 控制器与配置占位，支持租户上下文与 JWT 校验。
- [ ] 在 `frontend/apps/web-antd` 中创建 `modules/ai-assistant` 模块与路由。

## 阶段 1：会话骨架（Q1）

- [ ] 定义 WebSocket 消息类型与 `RequestEnvelope` 扩展字段，更新契约文档。
- [ ] 实现 FastAPI WebSocket 服务器桩，返回固定 `InsightPayload`。
- [ ] 后端实现 WebSocket 网关（Spring），处理心跳、错误、租户验证。[P]
- [ ] 前端实现聊天界面、消息流与错误提示；引入重连策略。[P]
- [ ] 为会话消息编写集成测试（Spring Boot Test + Playwright）。

## 阶段 2：意图解析与 SQL 防护（Q2）

- [ ] 使用 LangGraph 定义节点：输入解析、意图分类、策略守卫、动作执行。
- [ ] 构建 SQL 防护模块：白名单、正则过滤、AST 校验、审批状态机。
- [ ] 实现审批 REST API（查询、审批、驳回），并写入审计日志。[P]
- [ ] 前端实现审批面板（Ant Design），支持批量审批/驳回。[P]
- [ ] 编写 Pytest 测试覆盖 LangGraph 节点、SQL 防护规则。
- [ ] Playwright 场景：提交 SQL 请求 → 审批 → 执行 → AI 回复。

## 阶段 3：洞察渲染与订阅（Q3）

- [ ] 实现 `TableDescriptor`、`ChartDescriptor`、`InsightText` 到前端组件的映射。
- [ ] 后端生成洞察数据，补充置信度、数据快照、延迟信息。
- [ ] 构建订阅任务（SnailJob + Redis Stream），推送 KPI 异常提醒。
- [ ] 前端实现订阅管理 UI、通知中心（Ant Design `Statistic` + ECharts）。
- [ ] 引入 Prometheus 指标：模型耗时、审批队列、订阅触发次数。
- [ ] 编写性能测试：并发 200 WebSocket 连接、SQL 审批峰值。

## 阶段 4：交付闭环

- [ ] 更新任务勾选状态，确保无 `[NEEDS CLARIFICATION]`。
- [ ] 导出会话历史、审批记录与洞察日志，验证审计可追溯性。
- [ ] 生成使用手册（前端操作、审批流程、运维 FAQ）。
- [ ] 复核与功能 001 的契约兼容性（JSON Schema、OpenAPI）。

## 更新记录

- 2025-10-26：创建任务清单，覆盖会话、意图解析、洞察渲染与交付步骤。
