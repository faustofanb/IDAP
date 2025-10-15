#!/bin/bash

# IDAP 服务健康检查脚本

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 IDAP 服务健康检查"
echo "===================="
echo ""

# 检查 Docker
echo -n "Docker: "
if docker info &>/dev/null; then
    echo -e "${GREEN}✓ 运行中${NC}"
else
    echo -e "${RED}✗ 未运行${NC}"
    echo "请启动 Docker Desktop: open -a Docker"
    exit 1
fi

# 检查 PostgreSQL
echo -n "PostgreSQL: "
if docker ps | grep -q "idap-postgres"; then
    if docker exec idap-postgres-dev pg_isready -U idap &>/dev/null; then
        echo -e "${GREEN}✓ 健康${NC}"
    else
        echo -e "${YELLOW}⚠ 运行中但未就绪${NC}"
    fi
else
    echo -e "${RED}✗ 未运行${NC}"
fi

# 检查 Redis
echo -n "Redis: "
if docker ps | grep -q "idap-redis"; then
    if docker exec idap-redis-dev redis-cli -a idap123 ping 2>/dev/null | grep -q "PONG"; then
        echo -e "${GREEN}✓ 健康${NC}"
    else
        echo -e "${YELLOW}⚠ 运行中但未就绪${NC}"
    fi
else
    echo -e "${RED}✗ 未运行${NC}"
fi

# 检查 pgAdmin
echo -n "pgAdmin: "
if docker ps | grep -q "idap-pgadmin"; then
    echo -e "${GREEN}✓ 运行中${NC} (http://localhost:5050)"
else
    echo -e "${RED}✗ 未运行${NC}"
fi

# 检查 Redis Commander
echo -n "Redis Commander: "
if docker ps | grep -q "idap-redis-commander"; then
    echo -e "${GREEN}✓ 运行中${NC} (http://localhost:8081)"
else
    echo -e "${RED}✗ 未运行${NC}"
fi

echo ""
echo "===================="

# 检查端口占用
echo ""
echo "📡 端口状态检查"
echo "===================="

check_port() {
    local port=$1
    local service=$2
    if lsof -i :$port &>/dev/null; then
        echo -e "${GREEN}✓${NC} $service (Port $port)"
    else
        echo -e "${RED}✗${NC} $service (Port $port) - 未监听"
    fi
}

check_port 5432 "PostgreSQL"
check_port 6379 "Redis"
check_port 5050 "pgAdmin"
check_port 8081 "Redis Commander"

echo ""
echo "===================="
echo "💡 提示:"
echo "  启动服务: ./scripts/docker/01-docker-manager.sh start-dev"
echo "  查看日志: ./scripts/docker/01-docker-manager.sh logs"
echo "  查看状态: ./scripts/docker/01-docker-manager.sh status"
