# 功能 001：进销存业务系统 — 实施计划

> 版本：v0.1（2025-10-26）

## 1. 目标与范围

- 实现多租户进销存后台的最小可用能力：采购、销售、库存、主数据、报表与权限。
- 以 Plus-Vben5 + Ant Design Vue 作为前端基座，RuoYi-Vue-Plus 作为后端基座，确保 AI 服务能够通过标准契约对接。
- 完成从规格、计划到任务的闭环，并输出契约与测试脚手架。

## 2. 里程碑

| 里程碑 | 目标 | 预计完成 |
| ------ | ---- | -------- |
| M1：租户骨架 | 完成租户/机构/用户模块迁移，打通 Sa-Token/Redis/JWT 流程；初始化前端工作台与登录流程。 | 2025-11-08 |
| M2：业务闭环 | 完成采购、销售、库存核心用例、WebSocket 框架、报表初版；提供契约测试覆盖。 | 2025-12-05 |
| M3：可观测性强化 | 接入 OpenTelemetry、Prometheus、审计日志看板；交付 RSA 密钥轮换方案与性能测试报告。 | 2026-01-10 |

## 3. 架构决策

- **通信协议**：WebSocket 优先，REST API 为补充。所有消息封装在 `RequestEnvelope` 中，包含 `tenantId`、`correlationId`、安全签名与遥测字段。
- **多租户策略**：使用 MyBatis-Plus 多租户插件 + 数据权限（DataScope）组合；将租户上下文绑定到 Sa-Token `LoginUser` 并在虚拟线程上下文中传递。
- **安全策略**：
  - 前端启用 RSA 请求加密；后端在 `OncePerRequestFilter` 中解密并注入上下文。
  - JWT 刷新通过后台 `/auth/token/refresh`，支持虚拟线程。
- **数据同步**：短期内采用本地事务（事务脚本 + 事件表），后续与外部 ERP 同步通过事件队列扩展。
- **可观测性**：统一使用 OpenTelemetry SDK，导出到 Prometheus + Grafana；日志使用 Logback JSON + traceId。

## 4. 关键任务概览

1. **基础设施（M1）**
	- 迁移/创建租户、机构、用户、角色、菜单表及前端路由定义。
	- 集成 Sa-Token、Redis、JWT 加解密，补齐 RSA 密钥配置。
	- 搭建前端登录、首页仪表板骨架，接入 Ant Design Vue 布局。
2. **业务流程（M2）**
	- 设计采购/销售/库存领域模型与 Mapper，确保 `tenantId` 过滤。
	- 实现采购/销售单的单据生命周期（草稿→审核→执行）。
	- 构建库存计算服务，支持盘点、调拨、退货及库存预警。
	- 开发报表 API + 前端 ECharts/Olap 展示，提供 KPI 指标组件。
	- 实现 WebSocket `/ws/conversation` 桩服务，并与前端消息流对接。
3. **可观测性与安全（M3）**
	- 接入 OpenTelemetry Trace，配置 Prometheus Exporter。
	- 完成 SQL 审批流程与日志审计落库。
	- 建立性能测试脚本（Gatling/JMeter）与密钥轮换脚本。

## 5. 测试策略

| 层级 | 工具 | 范围 |
| ---- | ---- | ---- |
| 单元测试 | JUnit 5 + Mockito，Vitest，Pytest | 服务实现、Pinia Store、LangChain 节点。 |
| 集成测试 | Spring Boot Test + Testcontainers，Playwright | API + DB 行为、前后端交互。 |
| 契约测试 | OpenAPI + JSON Schema 校验 | `RequestEnvelope`、WebSocket 消息、报表接口。 |
| 性能测试 | Gatling/JMeter、pnpm script | WebSocket 并发、单据批处理、导出任务。 |

## 6. 风险与缓解

| 风险 | 等级 | 缓解措施 |
| ---- | ---- | -------- |
| MyBatis 多租户规则遗漏 | 高 | 建立自动化测试断言 `tenantId`；审核 Mapper 配置。
| WebSocket 与 RSA 加密兼容性 | 中 | 先实现 REST 通路回退；对 WebSocket 消息采用对称密钥协商。
| 报表性能不足 | 中 | 使用分页/流式导出；提前验证索引与物化视图需求。
| SnailJob 调度延迟 | 低 | 定期巡检任务堆积，提供手动触发脚本。

## 7. 交付物

- `.specify/specs/001-business-system/spec.md`（需求规格）。
- `.specify/specs/001-business-system/tasks.md`（任务清单）。
- `.specify/specs/001-business-system/contracts/README.md` + JSON Schema。
- 前后端代码、测试、CI/CD 管道更新。
- 性能与安全测试报告。

## 8. 更新记录

- 2025-10-26：创建实施计划，定义里程碑、架构决策、测试策略与风险清单。
