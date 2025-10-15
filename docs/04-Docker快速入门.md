# IDAP Docker 快速参考

## 🚀 一键启动

```bash
# 1. 确保 Docker Desktop 已启动
open -a Docker  # macOS

# 2. 启动开发环境
./scripts/docker/01-docker-manager.sh start-dev

# 3. 等待服务就绪（约 10 秒）
```

## 📦 已安装服务

| 服务       | 地址           | 用户名/密码                 |
| ---------- | -------------- | --------------------------- |
| PostgreSQL | localhost:5432 | idap / idap123              |
| Redis      | localhost:6379 | 密码: idap123               |
| pgAdmin    | localhost:5050 | admin@idap.local / admin123 |
| Redis UI   | localhost:8081 | -                           |

## 🔗 连接字符串

```bash
# PostgreSQL
postgresql://idap:idap123@localhost:5432/idap

# Redis
redis://:idap123@localhost:6379/0
```

## 💻 常用命令

```bash
./scripts/docker/01-docker-manager.sh start-dev    # 启动
./scripts/docker/01-docker-manager.sh stop         # 停止
./scripts/docker/01-docker-manager.sh restart      # 重启
./scripts/docker/01-docker-manager.sh status       # 状态
./scripts/docker/01-docker-manager.sh logs         # 日志
./scripts/docker/01-docker-manager.sh psql         # 连接数据库
./scripts/docker/01-docker-manager.sh redis-cli    # 连接 Redis
./scripts/docker/01-docker-manager.sh clean        # 清理数据
```

## 📝 配置文件更新

### Java Gateway (application.yml)

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/idap
    username: idap
    password: idap123
  redis:
    host: localhost
    port: 6379
    password: idap123
```

### Python AI Engine (.env)

```bash
DATABASE_URL=postgresql://idap:idap123@localhost:5432/idap
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=idap123
```

## 🐛 故障排查

```bash
# Docker 未启动
open -a Docker

# 查看日志
./scripts/docker/01-docker-manager.sh logs postgres
./scripts/docker/01-docker-manager.sh logs redis

# 重置环境
./scripts/docker/01-docker-manager.sh reset
```

## 📚 完整文档

查看 `docs/07-Docker环境配置.md` 获取详细文档。
