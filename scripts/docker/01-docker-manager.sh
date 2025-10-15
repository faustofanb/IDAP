#!/bin/bash

# IDAP Docker 环境管理脚本

set -e

# 获取脚本所在目录（scripts/docker/）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
IDAP Docker 环境管理脚本

用法: ./docker.sh [命令]

命令:
  start-dev       启动开发环境（PostgreSQL + Redis）
  start-full      启动完整环境（包含 Milvus）
  stop            停止所有服务
  restart         重启所有服务
  logs            查看服务日志
  status          查看服务状态
  clean           清理所有数据卷（危险操作！）
  reset           重置环境（停止 + 清理 + 启动）
  psql            连接到 PostgreSQL
  redis-cli       连接到 Redis
  help            显示此帮助信息

示例:
  ./docker.sh start-dev          # 启动开发环境
  ./docker.sh logs postgres      # 查看 PostgreSQL 日志
  ./docker.sh psql               # 连接数据库

EOF
}

# 启动开发环境
start_dev() {
    print_info "启动开发环境（PostgreSQL + Redis）..."
    docker-compose -f 04-docker-compose-dev.yml up -d
    print_info "等待服务就绪..."
    sleep 5
    docker-compose -f 04-docker-compose-dev.yml ps
    print_info "✅ 开发环境已启动"
    print_info "PostgreSQL: localhost:5432 (idap/idap123)"
    print_info "Redis:      localhost:6379 (密码: idap123)"
    print_info "pgAdmin:    http://localhost:5050 (admin@idap.local/admin123)"
    print_info "Redis UI:   http://localhost:8081"
}

# 启动完整环境
start_full() {
    print_info "启动完整环境（PostgreSQL + Redis + Milvus）..."
    docker-compose -f 03-docker-compose-full.yml up -d
    print_info "等待服务就绪..."
    sleep 10
    docker-compose -f 03-docker-compose-full.yml ps
    print_info "✅ 完整环境已启动"
    print_info "PostgreSQL: localhost:5432 (idap/idap123)"
    print_info "Redis:      localhost:6379 (密码: idap123)"
    print_info "Milvus:     localhost:19530"
    print_info "pgAdmin:    http://localhost:5050 (admin@idap.local/admin123)"
    print_info "Redis UI:   http://localhost:8081"
    print_info "Milvus UI:  http://localhost:8000"
}

# 停止服务
stop_services() {
    print_info "停止所有服务..."
    docker-compose -f 04-docker-compose-dev.yml down 2>/dev/null || true
    docker-compose -f 03-docker-compose-full.yml down 2>/dev/null || true
    print_info "✅ 服务已停止"
}

# 重启服务
restart_services() {
    print_info "重启服务..."
    stop_services
    sleep 2
    start_dev
}

# 查看日志
view_logs() {
    if [ -z "$1" ]; then
        docker-compose -f 04-docker-compose-dev.yml logs -f
    else
        docker-compose -f 04-docker-compose-dev.yml logs -f "$1"
    fi
}

# 查看状态
show_status() {
    print_info "服务状态:"
    docker-compose -f 04-docker-compose-dev.yml ps
    echo ""
    docker-compose -f 03-docker-compose-full.yml ps 2>/dev/null || true
}

# 清理数据
clean_data() {
    print_warning "⚠️  这将删除所有数据卷，数据将无法恢复！"
    read -p "确认清理所有数据？(yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        print_info "停止服务..."
        docker-compose -f 04-docker-compose-dev.yml down -v 2>/dev/null || true
        docker-compose -f 03-docker-compose-full.yml down -v 2>/dev/null || true
        print_info "✅ 数据已清理"
    else
        print_info "已取消"
    fi
}

# 重置环境
reset_env() {
    print_warning "⚠️  这将重置整个环境（停止 + 清理 + 启动）"
    read -p "确认重置环境？(yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        clean_data
        sleep 2
        start_dev
    else
        print_info "已取消"
    fi
}

# 连接 PostgreSQL
connect_psql() {
    print_info "连接到 PostgreSQL..."
    docker exec -it idap-postgres-dev psql -U idap -d idap
}

# 连接 Redis
connect_redis() {
    print_info "连接到 Redis..."
    docker exec -it idap-redis-dev redis-cli -a idap123
}

# 主逻辑
case "${1:-help}" in
    start-dev)
        start_dev
        ;;
    start-full)
        start_full
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    logs)
        view_logs "${2}"
        ;;
    status)
        show_status
        ;;
    clean)
        clean_data
        ;;
    reset)
        reset_env
        ;;
    psql)
        connect_psql
        ;;
    redis-cli)
        connect_redis
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "未知命令: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
