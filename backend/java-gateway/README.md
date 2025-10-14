# IDAP Java Gateway

企业级 API Gateway - 负责认证、SQL 执行、数据分析

## 技术栈

- Spring Boot 3.2+
- JDK 21
- PostgreSQL 16+
- Redis 7+
- WebSocket (JSON-RPC 2.0)

## 项目结构

```
src/main/java/com/idap/
├── GatewayApplication.java       # 启动类
├── config/                       # 配置类
│   ├── SecurityConfig.java       # Spring Security + JWT
│   ├── WebSocketConfig.java      # WebSocket 配置
│   └── RedisConfig.java          # Redis 配置
├── controller/                   # 控制器
│   ├── AuthController.java       # 认证接口
│   ├── QueryController.java      # 查询接口
│   └── SessionController.java    # 会话接口
├── service/                      # 服务层
│   ├── SqlExecutorService.java   # SQL 执行
│   ├── AnalyticsService.java     # 数据分析
│   └── AuditService.java         # 审计日志
├── client/                       # 客户端
│   └── PythonAIClient.java       # Python AI 客户端
├── security/                     # 安全
│   └── JwtTokenProvider.java     # JWT 工具
├── entity/                       # 实体类
│   ├── User.java
│   ├── Session.java
│   └── Query.java
└── repository/                   # 数据访问
    ├── UserRepository.java
    ├── SessionRepository.java
    └── QueryRepository.java
```

## 快速开始

### 1. 配置环境变量

```bash
export DB_PASSWORD=your_db_password
export REDIS_PASSWORD=your_redis_password
export JWT_SECRET=your_jwt_secret
```

### 2. 启动数据库

```bash
docker run -d -p 5432:5432 \
  -e POSTGRES_DB=idap \
  -e POSTGRES_USER=idap \
  -e POSTGRES_PASSWORD=idap123 \
  postgres:16

docker run -d -p 6379:6379 redis:7-alpine
```

### 3. 构建项目

```bash
mvn clean package -DskipTests
```

### 4. 运行

```bash
java -jar target/idap-gateway.jar
```

访问: http://localhost:8080/api/v1

## 配置说明

配置文件: `src/main/resources/application.yml`

关键配置项:

- `spring.datasource.*` - 数据库连接
- `spring.redis.*` - Redis 连接
- `jwt.*` - JWT 配置
- `python-ai.*` - Python AI Engine 连接

## API 文档

### 认证接口

```
POST   /auth/login   # 用户登录
POST   /auth/logout  # 用户登出
GET    /auth/me      # 获取当前用户信息
```

### 查询接口

```
POST   /query        # 提交查询
GET    /query/stream # 流式查询 (SSE)
GET    /query/history # 查询历史
```

### 会话接口

```
POST   /sessions           # 创建会话
GET    /sessions           # 获取会话列表
GET    /sessions/{id}      # 获取会话详情
DELETE /sessions/{id}      # 删除会话
```

## 开发指南

1. 所有代码使用 4 空格缩进
2. 遵循 Java 命名规范
3. 使用 Lombok 简化代码
4. 添加必要的注释和文档
5. 编写单元测试

## 注意事项

⚠️ **安全约束**:

- 所有 SQL 必须经过白名单校验
- 使用 HikariCP 连接池
- 强制使用 executeQuery (只读)
- 记录所有操作到审计日志

⚠️ **架构约束**:

- Python AI Engine 不直接访问数据库
- 所有 AI 请求通过 WebSocket 转发
- 使用 JSON-RPC 2.0 协议通信
