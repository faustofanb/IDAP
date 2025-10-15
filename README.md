# IDAP - 智能数据分析平台# IDAP - 智能数据分析平台

**Intelligent Data Analysis Platform\*\***Intelligent Data Analysis Platform\*\*

> 企业级 AI 数据分析平台，支持自然语言查询 (NL2SQL)、RAG 知识检索和智能可视化企业级 AI 数据分析平台，支持自然语言查询 (NL2SQL)、RAG 知识检索和智能可视化。

---

## 🎯 项目概述## 🎯 项目概述

IDAP 是一个混合架构的智能数据分析平台，让业务人员通过**自然语言与数据对话**，无需编写 SQL 即可获取数据洞察。IDAP 是一个混合架构的智能数据分析平台，通过自然语言与数据对话，无需编写 SQL 即可获取数据洞察。

### 核心功能### 核心功能

- 🔍 **NL2SQL**: 自然语言转 SQL，智能查询数据库- 🔍 **NL2SQL**: 自然语言转 SQL，智能查询数据库

- 📊 **智能可视化**: 自动生成 ECharts 图表- 📊 **智能可视化**: 自动生成 ECharts 图表

- 📚 **RAG 知识检索**: 基于向量的企业知识库问答- 📚 **RAG 知识检索**: 基于向量的企业知识库问答

- 🤖 **AI 洞察**: 自动生成数据分析和业务建议- 🤖 **AI 分析**: 自动生成数据洞察和业务建议

### 技术架构---

````## 🏗️ 技术架构

Frontend (Vue 3 + Element Plus)

         ↓ HTTP/SSE### 混合架构设计

Java Gateway (Spring Boot) - Port 8080

         ↓ WebSocket (JSON-RPC)```

Python AI Engine (FastAPI + LangChain) - Port 8001┌─────────────────────────────────────────────────────────┐

         ↓│         前端 (Vue 3 + Element Plus + Vite + Bun)        │

PostgreSQL / Redis / Milvus│                     Port 3000                           │

```└────────────────────┬────────────────────────────────────┘

                     │ HTTP/SSE

**为什么混合架构？**┌────────────────────▼────────────────────────────────────┐

- **Java**: 企业级稳定性、安全性、高并发│           Java Gateway (Spring Boot 3.2+)               │

- **Python**: 最成熟的 AI 生态（LangChain、LLM）│     API Gateway + SQL Executor + Analytics              │

- **清晰分层**: Java 负责数据和安全，Python 负责 AI 推理│                     Port 8080                           │

└────────────────────┬────────────────────────────────────┘

---                     │ WebSocket (JSON-RPC)

┌────────────────────▼────────────────────────────────────┐

## 📚 文档导航│       Python AI Engine (FastAPI + LangChain)            │

│      LLM Service + NL2SQL Agent + RAG Service           │

### 核心文档│                     Port 8001                           │

└─────────────────────────────────────────────────────────┘

| 文档 | 描述 | 适合人群 |         │              │              │

|-----|------|---------|         ▼              ▼              ▼

| **[00-AI提示词指南](docs/00-AI提示词指南.md)** | AI 辅助开发完整指南 | **开发者必读** ⭐ |   PostgreSQL 16+    Redis 7+     Milvus 2.3+

| [01-概要设计](docs/01-概要设计.md) | 系统架构与技术选型 | 架构师、项目经理 |```

| [02-详细设计-数据库](docs/02-详细设计-数据库.md) | 数据库表结构（12 张表） | 后端开发者 |

| [02-详细设计-前端](docs/02-详细设计-前端.md) | Vue 3 + Element Plus | 前端开发者 |### 技术栈

| [02-详细设计-后端](docs/02-详细设计-后端.md) | Java + Python 实现 | 后端开发者 |

| [03-TODO清单](docs/03-TODO清单.md) | 开发任务与里程碑 | 项目管理 |**前端**



### 快速开始- Vue 3.4+ (Composition API)

- Element Plus 2.5+ (UI 组件库)

**第一次接触项目？** 按顺序阅读：- Pinia 2.1+ (状态管理)

- Vite 5 + Bun (构建工具)

1. 📖 **本文档** (README.md) - 了解项目概况- ECharts 5 (数据可视化)

2. 🤖 **[AI提示词指南](docs/00-AI提示词指南.md)** - 掌握 AI 辅助开发方法

3. 🏗️ **[概要设计](docs/01-概要设计.md)** - 理解架构设计**后端**

4. 📋 **[TODO清单](docs/03-TODO清单.md)** - 查看开发任务

- Java 21/25 + Spring Boot 3.2+

---- Python 3.11+ + FastAPI 0.109+

- LangChain + LangGraph (AI 编排)

---

## 🚀 快速开始

### 1. 启动依赖服务

```bash
# 启动 Docker 服务（PostgreSQL + Redis）
./scripts/docker/01-docker-manager.sh start-dev

# 查看服务状态
./scripts/docker/01-docker-manager.sh status

# 访问管理界面
# - pgAdmin: http://localhost:5050 (admin@idap.local / admin123)
# - Redis Commander: http://localhost:8081
```

💡 详细说明见 [Docker 快速入门](docs/04-Docker快速入门.md) 和 [Docker 环境配置](docs/07-Docker环境配置.md)

### 2. 启动后端服务

#### Java Gateway (Port 8080)
```bash
cd backend/java-gateway
mvn spring-boot:run
```

#### Python AI Engine (Port 8001)
```bash
cd backend/python-ai-engine
source .venv/bin/activate
python src/main.py
```

### 3. 启动前端

```bash
cd frontend
pnpm install
pnpm dev
# 访问 http://localhost:3000
```

---

## 🚀 技术栈- PostgreSQL 16+ (主数据库)

- Redis 7+ (缓存)

### 前端- Milvus 2.3+ (向量数据库)



- Vue 3.4+ (Composition API)---

- Element Plus 2.5+ (UI 组件库)

- Pinia 2.1+ (状态管理)## 📚 文档结构

- Vite 5 + Bun (构建工具)

- ECharts 5 (数据可视化)```

docs/

### 后端├── 01-概要设计.md           # 系统架构与技术选型

├── 02-详细设计-数据库.md     # 数据库设计（12 张表）

- **Java 21/25** + Spring Boot 3.2+├── 02-详细设计-前端.md       # 前端详细设计

- **Python 3.11+** + FastAPI 0.109+├── 02-详细设计-后端.md       # 后端详细设计

- LangChain + LangGraph (AI 编排)├── 03-TODO清单.md           # 开发任务清单

├── IDAP-Architecture.md     # 详细架构文档

### 数据层├── IDAP-Delivery-Plan.md    # 交付计划

└── DEV_SETUP.md            # 开发环境配置

- PostgreSQL 16+ (主数据库)```

- Redis 7+ (缓存)

- Milvus 2.3+ (向量数据库)**快速导航**:



---- 🏢 **了解系统**: 阅读 `01-概要设计.md`

- 💻 **开始开发**: 查看 `03-TODO清单.md`

## 📁 项目结构- 🗄️ **数据库**: 查看 `02-详细设计-数据库.md`



```---

IDAP/

├── backend/                      # 后端服务（待实现）## 🚀 快速开始

│   ├── java-gateway/             # Spring Boot (Port 8080)

│   └── python-ai-engine/         # FastAPI (Port 8001)### 1. 前置要求

├── frontend/                     # 前端应用（待实现）

├── docs/                         # 设计文档 ⭐- **Node.js**: 18+ (推荐使用 Bun)

│   ├── 00-AI提示词指南.md        # AI 辅助开发指南- **Java**: 21 或 25

│   ├── 01-概要设计.md- **Python**: 3.11+

│   ├── 02-详细设计-数据库.md- **Docker**: 20+ (用于数据库)

│   ├── 02-详细设计-前端.md- **pnpm**: 8+ 或 Bun 1+

│   ├── 02-详细设计-后端.md

│   └── 03-TODO清单.md### 2. 初始化数据库

├── deploy/                       # 部署配置（待实现）

└── README.md                     # 本文档```bash

```# 启动 PostgreSQL

docker run -d --name idap-postgres \

---  -e POSTGRES_DB=idap \

  -e POSTGRES_USER=idap \

## 📊 开发进度  -e POSTGRES_PASSWORD=idap123 \

  -p 5432:5432 \

### 当前阶段：**设计完成，准备开发** 📝  postgres:16



- ✅ **项目架构设计**: 混合架构（Java + Python）# 执行 Schema 初始化

- ✅ **数据库设计**: 12 张表的完整 DDLpsql -h localhost -U idap -d idap -f database/01_schema.sql

- ✅ **API 设计**: REST + WebSocket 通信协议

- ✅ **文档编写**: 6 份完整的设计文档# 导入示例数据

psql -h localhost -U idap -d idap -f database/02_sample_data.sql

### 下一步：**后端核心开发** 🔧```



详见 [03-TODO清单.md](docs/03-TODO清单.md)### 3. 启动前端



| 里程碑 | 目标 | 预计完成 | 状态 |```bash

|--------|------|----------|------|cd frontend

| M1 | 架构与数据库设计 | 2025-01-13 | ✅ 已完成 |

| M2 | 后端框架搭建 | 2025-01-20 | ⏳ 计划中 |# 安装依赖

| M3 | NL2SQL 功能实现 | 2025-01-27 | ⏳ 待开始 |pnpm install  # 或 bun install

| M4 | RAG 功能实现 | 2025-02-03 | ⏳ 待开始 |

| M5 | MVP 演示 | 2025-02-10 | ⏳ 待开始 |# 启动开发服务器

| M6 | 生产部署 | 2025-02-20 | ⏳ 待开始 |pnpm dev      # 或 bun run dev:bun



---# 访问 http://localhost:3000

````

## 🎯 MVP 目标

### 4. 演示账号

| 指标 | 目标值 |

|------|--------|| 用户名 | 密码 | 角色 |

| NL2SQL 生成延迟 | ≤ 3s || --------- | -------------- | ---------- |

| SQL 执行时间 | ≤ 5s || `demo` | `Password123!` | 普通用户 |

| 端到端响应 | ≤ 8s || `admin` | `Password123!` | 管理员 |

| SQL 生成准确率 | ≥ 75% || `analyst` | `Password123!` | 数据分析师 |

| 并发用户数 | 100+ |

---

---

## 📁 项目结构

## 🤝 如何参与开发

````

### 使用 AI 辅助开发（推荐）IDAP/

├── backend/

1. 阅读 **[AI提示词指南](docs/00-AI提示词指南.md)**│   ├── java-gateway/          # Spring Boot (Port 8080)

2. 使用提示词模板与 AI 对话│   └── python-ai-engine/      # FastAPI (Port 8001)

3. 参考设计文档实现功能├── frontend/                  # Vue 3 (Port 3000)

├── database/

**示例提示词**:│   ├── 01_schema.sql          # 数据库初始化

```│   └── 02_sample_data.sql     # 示例数据

我正在开发 IDAP 项目的 Java Gateway 模块。├── docs/                      # 文档

请基于 docs/02-详细设计-后端.md 生成 JWT 认证的代码。├── deploy/                    # 部署配置

要求：│   └── docker-compose.yml

- 使用 Spring Security 6.2+└── README.md

- JWT 有效期 24 小时```

- 包含 /api/v1/auth/login 接口

```---



### 传统开发流程## 🔧 开发进度



1. Fork 本项目- ✅ **阶段 1**: 基础设施准备 (100%)

2. 阅读设计文档（`docs/` 目录）

3. 创建功能分支  - 数据库设计 (12 张表 + 1000+ 条示例数据)

4. 提交 Pull Request  - 前端项目搭建 (Vue 3 + Element Plus)

  - 文档编写 (概要设计 + 详细设计 + TODO)

**Commit 规范**:

```- 🔄 **阶段 2**: 后端核心开发 (0%)

feat: 新功能

fix: 修复 Bug  - Java Gateway 框架

docs: 文档更新  - Python AI Engine 框架

refactor: 代码重构  - NL2SQL Agent

test: 测试相关  - RAG 服务

````

- ⏳ **阶段 3**: 前后端集成 (0%)

---- ⏳ **阶段 4**: 功能完善 (0%)

- ⏳ **阶段 5**: 测试与部署 (0%)

## 📄 许可证

**总体进度**: 15%

MIT License

详见 `docs/03-TODO清单.md`

---

---

## 📮 联系方式

## 🎯 MVP 里程碑

- **项目负责人**: Fausto

- **技术交流**: 欢迎提 Issue 讨论| 里程碑 | 目标 | 预计日期 | 状态 |

| ------ | ------------ | ---------- | --------- |

---| M1 | 基础设施完成 | 2025-01-13 | ✅ 已完成 |

| M2 | 后端框架完成 | 2025-01-20 | 🔄 进行中 |

## 🙏 致谢| M3 | NL2SQL 可用 | 2025-01-27 | ⏳ 待开始 |

| M4 | RAG 可用 | 2025-02-03 | ⏳ 待开始 |

- [Spring Boot](https://spring.io/) - Java 企业级框架| M5 | MVP 完成 | 2025-02-10 | ⏳ 待开始 |

- [FastAPI](https://fastapi.tiangolo.com/) - Python 异步框架| M6 | 生产就绪 | 2025-02-20 | ⏳ 待开始 |

- [LangChain](https://langchain.com/) - LLM 应用框架

- [Vue.js](https://vuejs.org/) - 渐进式前端框架---

- [Element Plus](https://element-plus.org/) - 企业级 UI 组件库

## 📊 核心指标

---

| 指标 | 目标值 | 当前值 |

**⭐ 开始开发前，请务必阅读 [AI 提示词指南](docs/00-AI提示词指南.md)**| --------------- | ------ | ------ |

| NL2SQL 生成延迟 | ≤ 3s | - |
| SQL 执行时间 | ≤ 5s | - |
| 端到端延迟 | ≤ 8s | - |
| NL2SQL 准确率 | ≥ 75% | - |
| 并发用户数 | 100+ | - |

---

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

**Commit 规范**:

```
feat: 新功能
fix: 修复 Bug
docs: 文档更新
style: 代码格式
refactor: 代码重构
test: 测试相关
chore: 构建/工具链
```

---

## 📄 许可证

MIT License

---

## 📮 联系方式

- **项目负责人**: Fausto
- **Email**: (待添加)
- **GitHub**: (待添加)

---

## 🙏 致谢

- [Vue.js](https://vuejs.org/)
- [Element Plus](https://element-plus.org/)
- [LangChain](https://langchain.com/)
- [FastAPI](https://fastapi.tiangolo.com/)
- [Spring Boot](https://spring.io/projects/spring-boot)
- [ECharts](https://echarts.apache.org/)

---

**⭐ 如果觉得项目有帮助，欢迎 Star！**
