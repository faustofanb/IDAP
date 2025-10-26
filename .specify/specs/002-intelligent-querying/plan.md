# 功能 002：智能分析问询系统 — 实施计划

> 版本：v0.1（2025-10-26）

## 1. 目标与范围

- 构建自然语言问询、意图解析、SQL 审批与洞察输送能力。
- 复用功能 001 的数据模型、WebSocket 通道与安全架构。
- 提供端到端可观测性、审计与 fallback 方案。

## 2. 里程碑

| 里程碑 | 内容 | 预计完成 |
| ------ | ---- | -------- |
| Q1：会话骨架 | WebSocket 会话、消息类型、会话存储、前端聊天 UI。 | 2026-02-07 |
| Q2：意图解析 & SQL 防护 | LangGraph 工作流、SQL 防护模块、审批 UI & API。 | 2026-03-15 |
| Q3：洞察渲染 & 订阅 | Table/Chart/Insight 生成、订阅机制、遥测看板、性能优化。 | 2026-04-20 |

## 3. 架构决策

- **LangGraph 拓扑**：`query_ingest` → `intent_classifier` → `guardrail` → `business_router` → `renderer`。
- **模型与提示**：
  - 主模型：OpenAI/GPT-4o-mini 或同级别模型（可替换）。
  - 使用结构化输出模式（JSON Schema + function calling / tool calling）。
  - 对于 SQL 提供内置 few-shot 示例，强调只输出受控中间表示。
- **SQL 防护**：
  - 决策引擎使用 pydantic + 正则 + AST 简析。
  - 审批请求写入 `sql_approval` 表，后端提供 REST API 和 WebSocket 推送。
- **缓存策略**：
  - 最近查询结果缓存 5 分钟（Redis Hash），缓存键包含 `tenantId`、查询指纹、数据快照版本。
  - 订阅通知通过 SnailJob 定时触发，结合 Prometheus Alertmanager。
- **可观测性**：
  - AI 服务接入 OpenTelemetry Python SDK，记录每个节点耗时与置信度。
  - 后端记录审批队列长度、执行成功率；前端埋点记录用户满意度反馈。

## 4. 核心任务

1. **会话层**
	- 设计 WebSocket 消息协议，扩展 `RequestEnvelope` 支持 AI 特有字段（模型版本、置信度）。
	- 实现会话存储（PostgreSQL/Redis），提供 REST 查询、导出。
	- 前端构建聊天界面、消息流、延迟指示器、错误恢复机制。
2. **AI 工作流**
	- 使用 LangGraph 定义节点与边，完成意图分类与回应合成。
	- 集成 SQL 防护策略、审批请求生成。
	- 引入回滚机制：若请求失败，生成纠错提示并记录。
3. **审批与执行**
	- 后端实现 SQL 审批 API、状态迁移、审计日志。
	- 前端提供审批面板、通知与操作历史。
4. **洞察渲染**
	- 后端根据 AI 输出构造 `TableDescriptor`、`ChartDescriptor`。
	- 前端解析并渲染表格、图表、洞察卡片（含 Ant Design `Statistic` 与 ECharts）。
5. **可观测性与订阅**
	- 将 AI 服务指标导出到 Prometheus（推送模型响应时间、置信度分布）。
	- 建立订阅任务（SnailJob + Redis Stream），向 WebSocket 推送提醒。

## 5. 测试策略

| 层级 | 工具 | 样例 |
| ---- | ---- | ---- |
| 单元测试 | Pytest、Vitest、JUnit | LangChain 节点、前端状态管理、审批 Service。 |
| 集成测试 | FastAPI TestClient、Spring Boot Test + Testcontainers | 会话生命周期、审批状态机、缓存策略。 |
| 契约测试 | Schemathesis、Playwright | WebSocket 消息结构、AI → 后端契约、前端渲染。 |
| 性能测试 | Locust/JMeter、pnpm script | WebSocket 并发、模型响应延迟、订阅推送。 |

## 6. 风险与缓解

| 风险 | 等级 | 缓解措施 |
| ---- | ---- | -------- |
| AI 模型响应慢或不稳定 | 高 | 支持模型切换、结果缓存、异步重试；提供 fallback 报表。 |
| SQL 防护误判 | 中 | 引入白名单维护工具与人工审核；记录误判案例进行调优。 |
| 洞察解释不足 | 中 | 增加 `justification` 字段与原始数据链接；引入用户反馈模块。 |
| 审批流复杂度上升 | 低 | 采用状态机实现 + 自动提醒，提供 SLA 仪表板。 |

## 7. 交付物

- WebSocket/REST 协议文档与 JSON Schema 更新。
- LangGraph 流程定义、测试用例与提示配置。
- SQL 防护规则库与审批工作流实现。
- 前端聊天界面、审批面板、洞察渲染组件。
- 可观测性仪表板、订阅与告警配置。

## 8. 更新记录

- 2025-10-26：创建实施计划，定义里程碑、架构决策、任务、测试与风险。
