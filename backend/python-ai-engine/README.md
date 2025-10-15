# Python AI Engine

IDAP Python AI Engine - AI 能力层，提供 LLM、NL2SQL、RAG 服务。

## 技术栈

- **FastAPI** 0.109+ - 异步 Web 框架
- **LangChain** 0.1+ - LLM 应用框架
- **LangGraph** 0.0.40+ - Agent 编排
- **OpenAI/Anthropic** - LLM 模型
- **FAISS/Milvus** - 向量检索
- **SQLAlchemy** 2.0+ - ORM

## 项目结构

```
python-ai-engine/
├── src/
│   ├── main.py                   # FastAPI 入口
│   ├── config/
│   │   └── settings.py           # 配置管理
│   ├── services/
│   │   ├── llm_service.py        # LLM 服务
│   │   ├── nl2sql/               # NL2SQL 模块
│   │   │   ├── agent.py
│   │   │   ├── schema_retriever.py
│   │   │   └── sql_validator.py
│   │   └── rag/                  # RAG 模块
│   │       ├── rag_service.py
│   │       └── retriever.py
│   ├── prompts/                  # Prompt 模板
│   │   ├── nl2sql_prompts.py
│   │   └── rag_prompts.py
│   ├── models/                   # Pydantic 模型
│   │   ├── request_models.py
│   │   └── response_models.py
│   └── websocket/                # WebSocket 服务
│       └── handler.py
├── pyproject.toml                # Poetry 配置
└── .env.example                  # 环境变量示例
```

## 快速开始

### 1. 安装依赖

```bash
# 使用 uv（推荐）
uv venv                    # 创建虚拟环境
uv pip install -e .        # 安装生产依赖
uv pip install -e ".[dev]" # 安装开发依赖

# 或使用 pip
pip install -e .
```

### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 填入 API Key
```

### 3. 启动服务

```bash
# 使用启动脚本（推荐）
../../scripts/dev/01-run-python-ai.sh

# 或手动启动
source .venv/bin/activate
python src/main.py

# 或使用 uvicorn
uvicorn src.main:app --reload --port 8001
```

### 4. 访问 API 文档

- Swagger UI: http://localhost:8001/docs
- ReDoc: http://localhost:8001/redoc

## API 说明

### 健康检查

```bash
GET /health
```

### WebSocket 连接

```bash
WS ws://localhost:8001/ws
```

支持的 JSON-RPC 方法：

- `nl2sql.generate` - 生成 SQL
- `rag.query` - RAG 查询
- `llm.chat` - LLM 对话

## 开发指南

### 添加新的 LLM 模型

在 `src/services/llm_service.py` 中：

```python
self.models["new-model"] = ChatOpenAI(model="new-model")
```

### 添加 Few-shot 示例

在 `src/prompts/nl2sql_prompts.py` 中添加到 `FEW_SHOT_EXAMPLES`。

### 测试

```bash
# 激活虚拟环境
source .venv/bin/activate

# 运行测试
pytest

# 代码格式化
black src/
ruff check src/
```

## 注意事项

⚠️ **重要**: Python AI Engine **不直接执行 SQL**，SQL 执行由 Java Gateway 控制。

## 架构约束

- ✅ 只负责 AI 推理（NL2SQL、RAG）
- ✅ 通过 WebSocket 与 Java Gateway 通信
- ❌ 不直接访问业务数据库
- ❌ 不执行 SQL 查询
