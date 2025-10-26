# 功能 001：进销存业务系统 — 任务清单

> 版本：v0.1（2025-10-26）

勾选顺序建议遵循里程碑阶段，标记 `[P]` 的任务可并行执行。

## 阶段 0：基础准备

- [ ] `backend/` 引入 Spotless、Checkstyle、Testcontainers 依赖，配置 Maven Profile。
- [ ] `frontend/` 更新 `pnpm-workspace.yaml` 与 `turbo.json`，增加 `web-antd` 构建与测试脚本。
- [ ] 建立 `.specify/` 目录并执行 `specify init --here --ai copilot --ignore-agent-tools`，确认 `/speckit.*` 命令可用。
- [ ] 生成 `RequestEnvelope`、`BusinessRequest`、`SQLRequest`、`InsightPayload` 的 JSON Schema（详见契约章节）并分别生成 TypeScript/Java/Python 类型。

## 阶段 1：租户与安全（对应计划 M1）

- [ ] 在 `ruoyi-common-security` 中实现租户上下文解析、RSA 解密 Filter、`correlationId` 注入。
- [ ] 迁移/编写租户、机构、用户、角色、菜单的 Mapper 与 Service，补充多租户规则测试。
- [ ] 更新 `ruoyi-admin` 登录、令牌刷新、菜单加载接口，并写入契约文档。
- [ ] 前端 `web-antd`：完成登录页、仪表盘骨架、租户切换控件，接入 RSA 公钥配置校验。[P]
- [ ] 配置 Redis、MinIO、SnailJob 在本地开发环境的 Docker 组合，完善启动脚本。[P]

## 阶段 2：业务流程（对应计划 M2）

- [ ] 设计采购/销售/库存领域模型（实体、枚举、DTO、Mapper），编写数据库迁移脚本。
- [ ] 实现采购单生命周期 API（创建、编辑、审核、执行、撤销），编写单元/集成测试。
- [ ] 实现销售单生命周期 API，同步更新前端表单、列表、详情页面。
- [ ] 开发库存服务：入库、出库、调拨、盘点、退货、库存预警；同步报表更新逻辑。
- [ ] 建立 WebSocket `/ws/conversation` 控制器（桩实现），支持租户上下文与心跳机制。[P]
- [ ] 前端：构建采购/销售单表单、列表、自定义列、批量导出、ECharts 报表；实现 Ant Design `Statistic` KPI 卡片。[P]
- [ ] AI 服务：定义 LangGraph 流程，输出 `BusinessRequest`、`SQLRequest`，配合 SQL 防护策略及 Pytest 覆盖。[P]

## 阶段 3：可观测性与加固（对应计划 M3）

- [ ] 引入 OpenTelemetry（后端），配置 Trace ID 透传、Prometheus Exporter、慢查询指标。
- [ ] 构建审计日志管道（数据库表、Service、查询 API），前端提供审计检索 UI。
- [ ] 实现 RSA 密钥轮换脚本与配置热更新机制，添加运维文档。
- [ ] 编写性能测试脚本（Gatling/JMeter）模拟 WebSocket 并发与批量导出。
- [ ] 执行 Playwright 端到端测试覆盖租户切换、单据流程、WebSocket 洞察展示。

## 阶段 4：交付前检查

- [ ] 更新 `plan.md` 与 `tasks.md` 完成状态，确保无 `[NEEDS CLARIFICATION]` 残留。
- [ ] 整理契约文件，导出最新 JSON Schema 与 OpenAPI 文档。
- [ ] 生成性能/安全/测试报告，纳入发布包。
- [ ] 更新仓库 `readme.md`，确认文档结构与索引一致。

## 更新记录

- 2025-10-26：创建任务清单，覆盖基础设施、业务流程、可观测性与交付检查。
