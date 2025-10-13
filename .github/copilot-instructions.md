# IDAP GitHub Copilot Instructions

## 项目概述

IDAP (Intelligent Data Analysis Platform) 是一个企业级智能数据分析平台，支持自然语言查询（NL2SQL）、RAG 知识检索和可视化分析。

**当前状态**: 设计阶段完成，准备开始实现

---

## 核心架构

### 混合架构设计

```
Frontend (Vue 3 + Element Plus) - Port 3000
    ↓ HTTP/SSE
Java Gateway (Spring Boot 3.2+) - Port 8080
    ↓ WebSocket (JSON-RPC 2.0)
Python AI Engine (FastAPI 0.109+) - Port 8001
    ↓
PostgreSQL 16+ / Redis 7+ / Milvus 2.3+
```

### 职责分层

| 层次       | 技术                        | 职责                                  |
| ---------- | --------------------------- | ------------------------------------- |
| **前端**   | Vue 3 + Element Plus        | UI 交互、图表展示                     |
| **业务层** | Java (Spring Boot)          | API Gateway、JWT 认证、SQL 执行、缓存 |
| **AI 层**  | Python (FastAPI)            | LLM 调用、NL2SQL、RAG、Agent 编排     |
| **数据层** | PostgreSQL / Redis / Milvus | 业务数据、缓存、向量存储              |

**关键原则**:

- ✅ Java 负责安全和数据，Python 负责 AI 推理
- ✅ Python **不直接访问数据库**，SQL 执行由 Java 控制
- ✅ 服务间通过 WebSocket (JSON-RPC 2.0) 通信

---

## 技术栈

### 前端 (Port 3000)

- Vue 3.4+ (Composition API)
- Element Plus 2.5+
- Pinia 2.1+
- Vite 5 + Bun
- ECharts 5

### Java Gateway (Port 8080)

- Spring Boot 3.2+ (JDK 21/25)
- Spring Security 6.2+ (JWT)
- Spring WebSocket 6.1+
- HikariCP 5.1+
- Resilience4j 2.1+

### Python AI Engine (Port 8001)

- FastAPI 0.109+
- LangChain 0.1+
- LangGraph 0.0.20+
- FAISS 1.7+ (开发) / Milvus 2.3+ (生产)

---

## 项目结构

```
IDAP/
├── backend/
│   ├── java-gateway/              # Spring Boot (Port 8080)
│   │   └── src/main/java/com/idap/
│   │       ├── gateway/           # API Gateway
│   │       ├── security/          # JWT 认证
│   │       ├── service/           # 业务服务
│   │       ├── data/              # SQL 执行器
│   │       ├── analytics/         # 图表生成
│   │       └── client/            # WebSocket 客户端
│   │
│   └── python-ai-engine/          # FastAPI (Port 8001)
│       └── src/
│           ├── main.py
│           ├── services/
│           │   ├── llm_service.py
│           │   ├── nl2sql/
│           │   └── rag/
│           ├── agents/            # LangGraph Agents
│           ├── prompts/           # Prompt 模板
│           └── websocket/         # WebSocket 服务器
│
├── frontend/                      # Vue 3
│   └── src/
│       ├── views/
│       ├── components/
│       ├── stores/                # Pinia
│       └── api/
│
└── docs/                          # 设计文档
    ├── 00-AI提示词指南.md         # ⭐ AI 辅助开发指南
    ├── 01-概要设计.md
    ├── 02-详细设计-数据库.md
    ├── 02-详细设计-前端.md
    ├── 02-详细设计-后端.md
    └── 03-TODO清单.md
```

---

## 编码规范

### Java

- **包命名**: `com.idap.<module>`
- **缩进**: 4 空格
- **编码**: UTF-8
- **行尾**: LF
- **JDK**: 21/25 (使用虚拟线程)

```java
package com.idap.gateway;

@RestController
@RequestMapping("/api/v1")
public class QueryController {
    // 4 空格缩进
}
```

### Python

- **包命名**: `src.<module>`
- **缩进**: 4 空格
- **类型注解**: 必须使用
- **格式化**: Black (行长 100)
- **Linting**: Ruff

```python
from fastapi import FastAPI

class LLMService:
    def generate(self, prompt: str) -> str:
        # 4 空格缩进 + 类型注解
        pass
```

### Vue 3

- **组件命名**: PascalCase
- **缩进**: 2 空格
- **API**: Composition API
- **样式**: SCSS + scoped

```vue
<script setup>
// Composition API
// 2 空格缩进
</script>

<style scoped lang="scss">
// SCSS
</style>
```

---

## 关键设计文档

在生成代码前，请务必参考以下文档：

1. **[00-AI 提示词指南.md](../docs/00-AI提示词指南.md)** ⭐

   - 完整的项目上下文
   - AI 辅助开发提示词模板
   - 架构设计详解

2. **[01-概要设计.md](../docs/01-概要设计.md)**

   - 系统架构图
   - 技术选型理由
   - 核心模块划分

3. **[02-详细设计-数据库.md](../docs/02-详细设计-数据库.md)**

   - 12 张表的完整 DDL
   - 索引策略
   - 数据安全设计

4. **[02-详细设计-后端.md](../docs/02-详细设计-后端.md)**

   - Java Gateway 实现细节
   - Python AI Engine 实现细节
   - WebSocket 通信协议

5. **[02-详细设计-前端.md](../docs/02-详细设计-前端.md)**

   - Vue 3 组件设计
   - Pinia 状态管理
   - 路由与 API 封装

6. **[03-TODO 清单.md](../docs/03-TODO清单.md)**
   - 开发任务列表
   - 里程碑规划

---

## WebSocket 通信协议

### 端点

- **URL**: `ws://localhost:8001/ws`
- **协议**: JSON-RPC 2.0

### 消息格式

**请求 (Java → Python)**:

```json
{
  "id": "req_abc123",
  "type": "request",
  "method": "nl2sql.generate",
  "params": {
    "question": "本月销售额前10的商品",
    "schema": {...}
  }
}
```

**响应 (Python → Java)**:

```json
{
  "id": "req_abc123",
  "type": "response",
  "result": {
    "sql": "SELECT ... LIMIT 10",
    "confidence": 0.95
  }
}
```

### 支持的 RPC 方法

| 方向          | 方法              | 描述       |
| ------------- | ----------------- | ---------- |
| Java → Python | `nl2sql.generate` | 生成 SQL   |
| Java → Python | `rag.query`       | RAG 检索   |
| Java → Python | `llm.chat`        | LLM 对话   |
| Python → Java | `db.execute`      | 执行 SQL   |
| Python → Java | `db.get_schema`   | 获取表结构 |

---

## 安全设计

### SQL 安全

```java
// Java Gateway 实现
public class SqlValidator {
    // 1. 白名单校验
    validateTableWhitelist(sql);

    // 2. 黑名单检测
    if (sql.contains("DROP") || sql.contains("DELETE")) {
        throw new SecurityException("Prohibited SQL");
    }

    // 3. 只读强制
    executeQuery(sql); // 使用 executeQuery
}
```

### JWT 认证

- 有效期: 24 小时
- 角色: `user`, `analyst`, `admin`
- 所有 `/api/v1/*` 接口需验证

---

## MVP 目标

| 指标            | 目标值 |
| --------------- | ------ |
| NL2SQL 生成延迟 | ≤ 3s   |
| SQL 执行时间    | ≤ 5s   |
| 端到端响应      | ≤ 8s   |
| SQL 生成准确率  | ≥ 75%  |
| 并发用户数      | 100+   |

---

## 开发指导原则

### 生成代码时

1. **先查阅文档**: 优先参考 `docs/00-AI提示词指南.md` 和相关设计文档
2. **遵循架构**: 严格遵守混合架构设计，不得跨层调用
3. **安全第一**: Python 不得直接访问数据库
4. **完整实现**: 生成的代码应包含注释、错误处理、日志
5. **包含测试**: 关键代码应附带单元测试

### 回答问题时

1. **基于设计**: 答案应基于现有设计文档
2. **给出理由**: 解释为什么这样设计/实现
3. **提供示例**: 包含可运行的代码示例
4. **引用文档**: 说明参考了哪份文档

### 常见场景

**场景 1: 用户要求生成 NL2SQL 代码**
→ 参考 `02-详细设计-后端.md` 中的 Python AI Engine 部分
→ 使用 LangChain SQL Agent
→ 返回 SQL 给 Java 执行（不自己执行）

**场景 2: 用户要求实现 JWT 认证**
→ 参考 `02-详细设计-后端.md` 中的 Java Gateway 部分
→ 使用 Spring Security 6.2+
→ Token 有效期 24 小时

**场景 3: 用户要求实现前端组件**
→ 参考 `02-详细设计-前端.md`
→ 使用 Vue 3 Composition API
→ 使用 Element Plus 组件

---

## 常见问题

**Q: 为什么使用混合架构？**
A: Java 提供企业级稳定性，Python 提供最成熟的 AI 生态。各取所长。

**Q: Python 为什么不直接执行 SQL？**
A: 安全隔离。Java 层实现白名单校验、SQL 沙箱、审计日志等安全机制。

**Q: 服务间如何通信？**
A: WebSocket (JSON-RPC 2.0)，支持双向实时通信和流式推送。

**Q: 为什么使用 JDK 21/25？**
A: 利用虚拟线程 (Virtual Threads) 提供高并发性能。

---

## 下一步任务

当前项目处于 **M1 阶段完成** (架构设计)，下一步是 **M2 阶段** (后端框架搭建)。

详细任务见 `docs/03-TODO清单.md`。

---

**重要提示**: 在生成任何代码之前，请先阅读 `docs/00-AI提示词指南.md` 以获取完整的项目上下文。
