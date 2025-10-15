# Docker 环境配置文档

## 📦 服务清单

### 开发环境 (scripts/docker/04-docker-compose-dev.yml)

- **PostgreSQL 16** - 主数据库 (端口 5432)
- **Redis 7** - 缓存与会话存储 (端口 6379)
- **pgAdmin** - PostgreSQL 管理界面 (端口 5050)
- **Redis Commander** - Redis 管理界面 (端口 8081)

### 完整环境 (scripts/docker/03-docker-compose-full.yml)

包含开发环境的所有服务，另外增加：

- **Milvus 2.3** - 向量数据库 (端口 19530)
- **Attu** - Milvus 管理界面 (端口 8000)
- **etcd** - Milvus 元数据存储
- **MinIO** - Milvus 对象存储

---

## 🚀 快速开始

### 方式 1: 使用管理脚本（推荐）

```bash
# 启动开发环境
./scripts/docker/01-docker-manager.sh start-dev

# 查看服务状态
./scripts/docker/01-docker-manager.sh status

# 查看日志
./scripts/docker/01-docker-manager.sh logs

# 停止服务
./scripts/docker/01-docker-manager.sh stop
```

### 方式 2: 直接使用 Docker Compose

```bash
# 启动开发环境
docker-compose -f scripts/docker/04-docker-compose-dev.yml up -d

# 启动完整环境（包含 Milvus）
docker-compose up -d

# 停止服务
docker-compose -f scripts/docker/04-docker-compose-dev.yml down
```

---

## 📋 管理脚本命令

```bash
./scripts/docker/01-docker-manager.sh start-dev       # 启动开发环境
./scripts/docker/01-docker-manager.sh start-full      # 启动完整环境（包含 Milvus）
./scripts/docker/01-docker-manager.sh stop            # 停止所有服务
./scripts/docker/01-docker-manager.sh restart         # 重启服务
./scripts/docker/01-docker-manager.sh logs [服务名]   # 查看日志
./scripts/docker/01-docker-manager.sh status          # 查看服务状态
./scripts/docker/01-docker-manager.sh clean           # 清理所有数据卷
./scripts/docker/01-docker-manager.sh reset           # 重置环境
./scripts/docker/01-docker-manager.sh psql            # 连接 PostgreSQL
./scripts/docker/01-docker-manager.sh redis-cli       # 连接 Redis
./scripts/docker/01-docker-manager.sh help            # 显示帮助
```

---

## 🔌 服务访问信息

### PostgreSQL

- **地址**: `localhost:5432`
- **数据库**: `idap`
- **用户名**: `idap`
- **密码**: `idap123`
- **连接字符串**: `postgresql://idap:idap123@localhost:5432/idap`

**连接方式**:

```bash
# 使用脚本连接
./scripts/docker/01-docker-manager.sh psql

# 使用 psql 客户端
psql -h localhost -p 5432 -U idap -d idap

# 使用连接字符串
psql postgresql://idap:idap123@localhost:5432/idap
```

### Redis

- **地址**: `localhost:6379`
- **密码**: `idap123`
- **连接字符串**: `redis://:idap123@localhost:6379/0`

**连接方式**:

```bash
# 使用脚本连接
./scripts/docker/01-docker-manager.sh redis-cli

# 使用 redis-cli
redis-cli -h localhost -p 6379 -a idap123

# Python 连接
import redis
r = redis.Redis(host='localhost', port=6379, password='idap123', db=0)
```

### Milvus

- **地址**: `localhost:19530`
- **连接方式**:

```python
from pymilvus import connections
connections.connect(
    alias="default",
    host='localhost',
    port='19530'
)
```

### 管理界面

| 服务            | 访问地址              | 用户名           | 密码     |
| --------------- | --------------------- | ---------------- | -------- |
| pgAdmin         | http://localhost:5050 | admin@idap.local | admin123 |
| Redis Commander | http://localhost:8081 | -                | -        |
| Attu (Milvus)   | http://localhost:8000 | -                | -        |

---

## 📝 应用配置

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
MILVUS_HOST=localhost
MILVUS_PORT=19530
```

### Vue Frontend (.env)

```bash
VITE_API_BASE_URL=http://localhost:8080/api/v1
```

---

## 🔧 常用操作

### 查看日志

```bash
# 查看所有服务日志
./scripts/docker/01-docker-manager.sh logs

# 查看特定服务日志
./scripts/docker/01-docker-manager.sh logs postgres
./scripts/docker/01-docker-manager.sh logs redis

# 实时跟踪日志
docker-compose -f scripts/docker/04-docker-compose-dev.yml logs -f postgres
```

### 重启服务

```bash
# 重启所有服务
./scripts/docker/01-docker-manager.sh restart

# 重启特定服务
docker-compose -f scripts/docker/04-docker-compose-dev.yml restart postgres
```

### 备份数据

```bash
# 备份 PostgreSQL
docker exec idap-postgres-dev pg_dump -U idap idap > backup_$(date +%Y%m%d_%H%M%S).sql

# 恢复 PostgreSQL
docker exec -i idap-postgres-dev psql -U idap idap < backup.sql
```

### 清理数据

```bash
# 清理所有数据（会删除数据卷）
./scripts/docker/01-docker-manager.sh clean

# 只停止服务，保留数据
./scripts/docker/01-docker-manager.sh stop
```

---

## 🐛 故障排查

### 端口冲突

如果端口已被占用，可以修改 `scripts/docker/04-docker-compose-dev.yml` 中的端口映射：

```yaml
ports:
  - "15432:5432" # 修改为其他端口
```

### 服务无法启动

```bash
# 查看详细日志
./scripts/docker/01-docker-manager.sh logs [服务名]

# 检查服务健康状态
docker-compose -f scripts/docker/04-docker-compose-dev.yml ps

# 重新创建服务
docker-compose -f scripts/docker/04-docker-compose-dev.yml up -d --force-recreate
```

### 数据库连接失败

```bash
# 检查 PostgreSQL 是否就绪
docker exec idap-postgres-dev pg_isready -U idap

# 检查网络连接
docker network ls
docker network inspect idap-dev-network
```

### 清理残留容器

```bash
# 停止所有相关容器
docker ps -a | grep idap | awk '{print $1}' | xargs docker stop
docker ps -a | grep idap | awk '{print $1}' | xargs docker rm

# 清理孤立卷
docker volume prune
```

---

## 📊 资源占用

### 开发环境（最小配置）

- **PostgreSQL**: ~50MB RAM, ~500MB 磁盘
- **Redis**: ~10MB RAM, ~100MB 磁盘
- **pgAdmin**: ~100MB RAM
- **Redis Commander**: ~50MB RAM
- **总计**: ~210MB RAM, ~600MB 磁盘

### 完整环境（包含 Milvus）

- **开发环境**: ~210MB RAM
- **Milvus + etcd + MinIO**: ~1GB RAM, ~2GB 磁盘
- **总计**: ~1.2GB RAM, ~2.6GB 磁盘

---

## 🔒 安全建议

### 生产环境注意事项

1. **修改默认密码**: 修改 `.env.docker` 中的密码
2. **使用加密连接**: 配置 SSL/TLS
3. **限制网络访问**: 使用防火墙规则
4. **定期备份**: 设置自动备份任务
5. **监控日志**: 配置日志收集和告警

### 密码管理

```bash
# 生成强密码
openssl rand -base64 32

# 修改 .env.docker
POSTGRES_PASSWORD=your_strong_password
REDIS_PASSWORD=your_strong_password
```

---

## 📚 参考文档

- [PostgreSQL 官方文档](https://www.postgresql.org/docs/16/)
- [Redis 官方文档](https://redis.io/docs/)
- [Milvus 官方文档](https://milvus.io/docs)
- [Docker Compose 文档](https://docs.docker.com/compose/)

---

## 🆘 常见问题

**Q: 如何重置数据库？**

```bash
./scripts/docker/01-docker-manager.sh reset
```

**Q: 如何修改数据库密码？**

1. 修改 `.env.docker` 中的密码
2. 运行 `./scripts/docker/01-docker-manager.sh clean`
3. 运行 `./scripts/docker/01-docker-manager.sh start-dev`

**Q: 如何在容器间访问服务？**
使用服务名作为主机名，例如：

- PostgreSQL: `postgres:5432`
- Redis: `redis:6379`

**Q: 如何导入初始数据？**
将 SQL 文件放入 `database/init/` 目录，重启容器即可自动执行。
