# 文档汇编（全量）

生成日期：2025-10-26

本文件汇集规约与业务专题文档（含 specs 目录），便于一次性阅读与审阅；每个章节均标注来源路径以便追溯。

编排说明：

- 实施计划（plan）、需求规格（spec）、任务清单（tasks）与契约（contracts）等专题文档视为“专题规格”，在信息架构上归属 `.specify/specs/`；本汇编仅做阅读聚合，不替代原文件。
- 根目录 `docs/` 仅存放架构与规约类文档；本汇编为索引/审阅用途，引用之处保持原文件为唯一事实来源（Source of Truth）。
- 本文不对原文做语义改写，仅在排版上做最小的层级优化以提升可读性。

## 目录（当前优先：先业务系统，后智能化）

- [0. 架构综述（采用 Plus-UI & RuoYi-Vue-Plus）](#0-架构综述采用-plus-ui--ruoyi-vue-plus)
- [1. 项目宪章（规约）](#1-项目宪章规约)
- [2. 文档总览](#2-文档总览)
- [3. 功能 001 进销存业务系统——需求规格](#3-功能-001-进销存业务系统需求规格)
- [4. 功能 001 进销存业务系统——实施计划](#4-功能-001-进销存业务系统实施计划)
- [5. 功能 001 进销存业务系统——任务清单](#5-功能-001-进销存业务系统任务清单)
- [6. 功能 001 进销存业务系统——契约说明](#6-功能-001-进销存业务系统契约说明)
- [7. 功能 002 智能分析问询系统——需求规格](#7-功能-002-智能分析问询系统需求规格)
- [8. 功能 002 智能分析问询系统——实施计划](#8-功能-002-智能分析问询系统实施计划)
- [9. 功能 002 智能分析问询系统——任务清单](#9-功能-002-智能分析问询系统任务清单)
- [10. 功能 002 智能分析问询系统——契约说明](#10-功能-002-智能分析问询系统契约说明)

---

## 0. 架构综述（采用 Plus-UI & RuoYi-Vue-Plus）

来源：`docs/01-架构综述.md`

— 本项目采用成熟后台体系：前端使用 Plus-UI（Vue3 + TS + Vite + Pinia + Element Plus），后端使用 RuoYi-Vue-Plus（Java 21 + Spring Boot 3 + Undertow + MyBatis-Plus + Sa-Token + Redis/Redisson + dynamic-datasource + HikariCP + SpringDoc + SnailJob + MinIO + Jackson）；AI 服务独立（FastAPI + LangChain + LangGraph），仅输出结构化请求，不直连数据库。详见架构拓扑、模块映射、集成边界、认证与多租、数据访问、可观测性与升级策略等小节。

## 1. 项目宪章（规约）

来源：`docs/constitution.md`

---

### 项目宪章：智能数据询问平台

## 第一条——规范至上

- 规格、实施计划和任务清单是唯一事实来源。
- 代码生成必须将每个产出追溯到已批准的规范条款。

## 第二条——以用户结果为中心

- 每个功能需记录对分析师和运营人员的可度量价值。
- 模糊需求必须用 `[NEEDS CLARIFICATION: ...]` 标注，并在实施计划批准前解决。

## 第三条——测试驱动与契约优先交付

- 在实现代码之前先编写自动化测试、API/事件契约和握手场景。
- 未具备单元、集成与契约层可演示测试覆盖的实现任务不得关闭。

## 第四条——架构护栏（采用现成后台管理系统）

- 前端：采用 Plus-UI（Vue 3 + TypeScript + Vite + Pinia + Element Plus，支持 ECharts）。通过 WebSocket 为主、REST 为辅与后端交互。
- 后端：采用 RuoYi-Vue-Plus（Java 21 + Spring Boot 3 + Undertow）。数据访问基于 MyBatis-Plus（含多租户、分页、数据权限等插件），认证授权采用 Sa-Token + JWT，缓存选型 Redis（Redisson 客户端），多数据源使用 dynamic-datasource，连接池 HikariCP，接口文档 SpringDoc，任务调度 SnailJob，文件存储 MinIO，序列化 Jackson。
- AI 服务：Python + FastAPI + LangChain + LangGraph；不得直接执行 SQL，仅输出结构化请求。
- 跨服务通信使用结构化 JSON（WS/HTTP），附带 `correlationId` 与遥测。

## 第五条——CQRS 与事件规范

- 读写关注点在规范、计划与代码中保持分离。
- 事件驱动集成必须记录生产者、消费者、模式与投递保证。

## 第六条——安全与合规

- 每个外部交互必须使用基于 JWT 的身份验证。
- 每个功能定义 PII 处理与审计要求，并在规划阶段验证。

## 第七条——性能期望

- 每份规范需声明 API、WebSocket 与 AI 往返的延迟预算（p95）与吞吐需求。
- 计划需记录并发策略（如虚拟线程池或异步流程）以满足预算。

## 第八条——可观测性

- 每个功能需定义日志、追踪与指标要求，包括跨服务的请求关联。
- 计划包含通过自动化测试或工具脚本验证可观测性的步骤。

## 第九条——演进流程

- 对本宪章的修改需获得产品、工程与数据干系人共识，并在变更请求中包含理由与影响分析。
- 每次任务完成后，必须同步更新对应功能目录下的规划与任务文档，至少包含：
  - `specs/<feature>/plan.md`：状态/范围变更、里程碑达成与风险状态；
  - `specs/<feature>/tasks.md`：任务项完成勾选、残余问题与后续动作；
  - 更新需在提交信息与文档“更新记录”中同时体现日期与变更要点。

## 第十条——文档规约（新增）

- 仓库内所有文档需集中存放于 `docs/` 目录下，按主题保留必要的子结构。
- 仓库文档统一采用简体中文撰写；不再保留英文并行版本。
- 对外沟通与文档相关的系统回答一律使用中文。
- 若涉及专业术语，可在中文后括注英文原词以降低歧义（如：虚拟线程（virtual threads））。
- 目录边界：根目录 `docs/` 仅存放架构综述与规约类文档；前端/后端（及 AI）的实现细节、开发手册、运维笔记等“非全局架构”文档应分别放置在 `frontend/docs/`、`backend/docs/`（与 `ai/docs/`）目录中。

## 第十一条——业务域与模块边界（新增）

- 业务定位：本系统为“进销存”的多租户后台管理系统（B2B 管理后台），所有功能均以租户隔离为前提。
- 业务模块（最小可用集）：
  - 租户管理：租户生命周期、配额与计费字段预留、租户级参数配置。
  - 机构管理：组织/部门树、岗位模型与上下级关系维护。
  - 用户管理：用户与角色、与租户/机构的绑定与授权。
  - 菜单与 URL 管理：前端菜单、后端 URL 资源与按钮级资源登记。
  - 权限管理：基于角色的访问控制（RBAC），支持按租户/机构的数据权限（行/列/范围策略）。
  - 报表展示：通用报表与可视化组件，支持导出与订阅。
  - 进销存业务：采购、销售、库存（入库/出库/调拨/盘点/退货等）核心流程与台账。
- 多租户原则：
  - 所有读写必须显式携带租户上下文（tenantId）；无上下文一律拒绝访问。
  - 隔离策略优先采用逻辑隔离（tenant_id 列 + 全局查询约束）；如需演进到 schema 隔离，需保证契约与代码低侵入。
  - 跨租户访问默认禁止；运营侧跨租户能力须通过特权工单审批并全量审计。
- 安全与审计补充：
  - 权限校验以 URL/资源为最小单位；菜单仅用于导航不作为权限来源。
  - 所有管理操作生成不可篡改审计日志，并附带租户、用户与请求链路标识。
- AI 能力范围与约束：
  - 范围：仅支持“进销存的智能数据查询”和“报表分析”。
  - 约束：AI 服务不得直接执行 SQL；只允许生成查询意图/中间表示，由受控查询引擎访问数据；输出的洞察需附带可追溯遥测与来源说明。

## 第十二条——文档命名与排序（新增）

- 除本宪章外，新增加的文档须使用数字前缀进行排序，推荐两位数字（必要时三位），例如：
  - `01-架构综述.md`
  - `02-接口规范.md`
  - `03-数据模型.md`
- 子目录遵循相同规则；同级文档按数字前缀升序呈现。
- 前后端（及 AI）子项目的 `docs/` 目录同样遵循数字前缀命名，如：
  - `frontend/docs/01-开发环境.md`
  - `backend/docs/01-数据迁移策略.md`
  - `ai/docs/01-模型服务接入.md`

---

## 2. 文档总览

来源：`docs/README.md`

---

### 文档总览与规约

本仓库的通用文档集中存放于 `docs/` 目录，需求规格、计划、任务和契约等规格驱动产物则统一放在 `.specify/specs/` 下，并统一使用简体中文撰写；对外回答也使用中文。若出现专业术语，可在中文后括注英文原词以降低歧义（如：虚拟线程（virtual threads））。

## 文档结构

- `docs/constitution.md` — 项目宪章（含文档规约）
- `.specify/specs/001-business-system/plan.md` — 业务系统实施计划（当前优先）
- `.specify/specs/001-business-system/spec.md` — 业务系统需求规格
- `.specify/specs/001-business-system/tasks.md` — 业务系统任务清单
- `.specify/specs/001-business-system/contracts/README.md` — 业务系统契约说明
- `.specify/specs/002-intelligent-querying/plan.md` — 智能问数实施计划（后续阶段）
- `.specify/specs/002-intelligent-querying/spec.md` — 智能问数需求规格
- `.specify/specs/002-intelligent-querying/tasks.md` — 智能问数任务清单
- `.specify/specs/002-intelligent-querying/contracts/README.md` — 智能问数契约说明

## 维护说明

- 通用说明性文档保存在 `docs/` 下；规格驱动产物请在 `.specify/specs/` 下维护，避免重复。
- 所有文档以中文为准；如需保留英文参考，请在中文正文中以括注形式标注关键术语。
- 若未来需要多语言支持，建议使用 i18n 目录结构（例如 `docs/zh-CN/`、`docs/en/`），但当前仅保留中文。

---

## 3. 功能 001 进销存业务系统——需求规格

来源：`.specify/specs/001-business-system/spec.md`

---

（见 `.specify/specs/001-business-system/spec.md`，内容摘要：角色权限、主数据、用例、API 草案、数据模型、审计与合规、非功能与错误码）

## 4. 功能 001 进销存业务系统——实施计划

来源：`.specify/specs/001-business-system/plan.md`

---

（见 `.specify/specs/001-business-system/plan.md`，内容摘要：目标与范围、里程碑（M1~M6）、风险与验收）

## 5. 功能 001 进销存业务系统——任务清单

来源：`.specify/specs/001-business-system/tasks.md`

---

（见 `.specify/specs/001-business-system/tasks.md`，内容摘要：阶段任务与“完成后同步记录”规则）

## 6. 功能 001 进销存业务系统——契约说明

来源：`.specify/specs/001-business-system/contracts/README.md`

---

（见 `.specify/specs/001-business-system/contracts/README.md`，内容摘要：REST/领域对象契约、版本与生成）

## 更新记录

- 2025-10-26：采用 Plus-UI 与 RuoYi-Vue-Plus 作为前后端底座；新增 `docs/01-架构综述.md` 并更新宪章“架构护栏”“安全与合规”等条款以匹配上游技术栈。
- 2025-10-25：同步规约更新，新增“每次任务完成后需更新 plan 与 tasks 文档”的要求；本任务清单将随任务完成情况持续更新并在此记录要点与日期。

## 阶段 0——基础

- [ ] 初始化 monorepo 结构，包含 `frontend/`、`backend/`、`ai/` 包以及共享的 `contracts/` 模块。**[P]**
- [ ] 配置工具链：Bun + Vite + ESLint + Prettier + Vitest（前端），Maven + Spotless + JUnit + Testcontainers（后端），uv + Ruff + Pytest（AI）。**[P]**
- [ ] 定义 `RequestEnvelope`、`BusinessRequest`、`SQLRequest`、`InsightPayload` 的主 JSON Schema；生成 TypeScript、Java、Python 类型。**[P]**

## 阶段 1——会话骨架

- [ ] 实现后端 WebSocket 端点 `/ws/conversation`，使用虚拟线程处理，并返回桩响应。
- [ ] 实现 AI 服务的 FastAPI WebSocket 客户端/服务端处理器，返回预置结构化响应。
- [ ] 构建前端聊天界面（消息列表、输入编辑器、遥测面板占位）及带重连策略的 WebSocket 客户端。
- [ ] 编写集成测试，覆盖各服务间的握手与桩消息交换。

## 阶段 2——意图解析与校验

- [ ] 实现 LangGraph 工作流，用于意图分类与请求合成，并输出置信度分数。
- [ ] 增加 SQL 防护模块（规则白名单、正则过滤、审批状态机），并以 Pytest 覆盖。
- [ ] 实现后端命令/查询处理器，遵循 CQRS 分离并校验入站信封。
- [ ] 扩展集成测试，覆盖业务与 SQL 分支以及防护执行。

## 阶段 3——数据渲染与洞察

- [ ] 创建内存领域数据集（customers、orders、alerts），并使用确定性播种器。
- [ ] 实现后端生成器，产出 `TableDescriptor`、`ChartDescriptor`、`InsightText`、`Telemetry` 负载。
- [ ] 构建前端渲染器：表格（Element Plus）、图表（ECharts）、洞察卡片与延迟指示器。
- [ ] 为 AI 服务增加后处理，以启发式方式丰富洞察摘要。

## 阶段 4——可观测性与安全

- [ ] 在前端、后端与 AI 服务间集成 JWT 认证，并实现令牌刷新流程。
- [ ] 接入 OpenTelemetry 追踪与 Prometheus 指标导出；确保请求 ID 端到端传递。
- [ ] 实现 SQL 审批 UI 流程与审计日志存储。
- [ ] 编写性能测试，验证 p95 延迟预算与日志覆盖率。

## 阶段 5——加固与测试

- [ ] 创建 Playwright 端到端场景，用于双语查询与重连恢复。
- [ ] 对 WebSocket 路径（虚拟线程）进行负载测试并记录结果。
- [ ] 起草运行手册、部署脚本（Docker Compose 内存化服务）与上手指南。
- [ ] 最终审查：确保所有 `[NEEDS CLARIFICATION]` 已解决，并落地成功指标的埋点。

---

## 7. 功能 002 智能分析问询系统——需求规格

来源：`.specify/specs/002-intelligent-querying/spec.md`

---

## 8. 功能 002 智能分析问询系统——实施计划

来源：`.specify/specs/002-intelligent-querying/plan.md`

---

（见 `.specify/specs/002-intelligent-querying/plan.md`）

## 9. 功能 002 智能分析问询系统——任务清单

来源：`.specify/specs/002-intelligent-querying/tasks.md`

---

（见 `.specify/specs/002-intelligent-querying/tasks.md`）

## 10. 功能 002 智能分析问询系统——契约说明

来源：`.specify/specs/002-intelligent-querying/contracts/README.md`

---

（见 `.specify/specs/002-intelligent-querying/contracts/README.md`）

契约使用的 `RequestEnvelope`、`BusinessRequest`、`SQLRequest`、`InsightPayload` 以及 WebSocket 事件负载 JSON Schema 存放在 `.specify/specs/shared/schemas/`。请基于这些规范文档生成各语言的绑定（类型/模型）。
