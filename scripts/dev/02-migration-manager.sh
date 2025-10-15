#!/bin/bash
# 数据库迁移管理脚本
# 用于创建和执行数据库迁移

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MIGRATIONS_DIR="$PROJECT_ROOT/database/migrations"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_title() {
    echo -e "${BLUE}$1${NC}"
}

# 获取下一个版本号
get_next_version() {
    local type=$1
    local prefix=""
    local dir=""

    case $type in
        schema)
            prefix="V"
            dir="$MIGRATIONS_DIR/schema"
            ;;
        data)
            prefix="D"
            dir="$MIGRATIONS_DIR/data"
            ;;
        procedure)
            prefix="P"
            dir="$MIGRATIONS_DIR/procedures"
            ;;
        *)
            print_error "Unknown migration type: $type"
            exit 1
            ;;
    esac

    # 查找最大版本号
    local max_version=$(ls "$dir"/${prefix}*.sql 2>/dev/null | \
                       sed "s/.*\/${prefix}\([0-9]*\)__.*/\1/" | \
                       sort -n | tail -1)

    if [ -z "$max_version" ]; then
        max_version=0
    fi

    local next_version=$((max_version + 1))
    printf "%s%03d" "$prefix" "$next_version"
}

# 创建新的迁移文件
create_migration() {
    local type=$1
    local description=$2

    if [ -z "$description" ]; then
        print_error "Description is required"
        echo "Usage: $0 create <schema|data|procedure> \"description\""
        exit 1
    fi

    local version=$(get_next_version "$type")
    local dir=""
    local comment_prefix=""

    case $type in
        schema)
            dir="$MIGRATIONS_DIR/schema"
            comment_prefix="DDL"
            ;;
        data)
            dir="$MIGRATIONS_DIR/data"
            comment_prefix="DML"
            ;;
        procedure)
            dir="$MIGRATIONS_DIR/procedures"
            comment_prefix="Procedure"
            ;;
    esac

    # 将描述转换为文件名（空格替换为下划线）
    local filename="${version}__$(echo "$description" | tr ' ' '_' | tr '[:upper:]' '[:lower:]').sql"
    local filepath="$dir/$filename"

    # 创建迁移文件
    cat > "$filepath" << EOF
-- ${version}: ${description}
-- 描述: ${description}
-- 类型: ${comment_prefix}
-- 日期: $(date +%Y-%m-%d)
-- 作者: $(git config user.name 2>/dev/null || echo "Unknown")

-- TODO: 在此编写你的 SQL 语句



-- 验证（可选）
-- SELECT 'Migration ${version} completed' as result;
EOF

    print_info "Created migration file: $filepath"
    echo ""
    print_title "Next steps:"
    echo "1. Edit the file: $filepath"
    echo "2. Add your SQL statements"
    echo "3. Test locally: $0 apply"
    echo "4. Commit to git"
}

# 应用迁移到本地数据库
apply_migrations() {
    print_title "Applying migrations to local database..."
    echo ""

    # 数据库连接信息
    DB_HOST="${POSTGRES_HOST:-localhost}"
    DB_PORT="${POSTGRES_PORT:-5432}"
    DB_NAME="${POSTGRES_DB:-idap}"
    DB_USER="${POSTGRES_USER:-idap}"
    DB_PASSWORD="${POSTGRES_PASSWORD:-idap123}"

    export PGPASSWORD="$DB_PASSWORD"

    # 检查数据库连接
    if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" > /dev/null 2>&1; then
        print_error "Cannot connect to database. Is it running?"
        print_info "Start database: cd scripts/docker && ./01-docker-manager.sh start-dev"
        exit 1
    fi

    # 执行 Schema 迁移
    print_info "Executing Schema migrations..."
    for sql_file in "$MIGRATIONS_DIR/schema"/V*.sql; do
        if [ -f "$sql_file" ]; then
            filename=$(basename "$sql_file")
            echo "  ▶️  $filename"
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$sql_file" -q
        fi
    done

    # 执行 Data 迁移
    print_info "Executing Data migrations..."
    for sql_file in "$MIGRATIONS_DIR/data"/D*.sql; do
        if [ -f "$sql_file" ]; then
            filename=$(basename "$sql_file")
            echo "  ▶️  $filename"
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$sql_file" -q
        fi
    done

    # 执行 Procedure 迁移
    if [ -d "$MIGRATIONS_DIR/procedures" ]; then
        print_info "Executing Procedure migrations..."
        for sql_file in "$MIGRATIONS_DIR/procedures"/P*.sql; do
            if [ -f "$sql_file" ]; then
                filename=$(basename "$sql_file")
                echo "  ▶️  $filename"
                psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$sql_file" -q
            fi
        done
    fi

    echo ""
    print_info "✅ All migrations applied successfully!"
}

# 列出所有迁移
list_migrations() {
    print_title "📋 Migration Files"
    echo ""

    print_info "Schema Migrations (DDL):"
    ls -1 "$MIGRATIONS_DIR/schema"/*.sql 2>/dev/null | sed 's/.*\//  /' || echo "  (none)"
    echo ""

    print_info "Data Migrations (DML):"
    ls -1 "$MIGRATIONS_DIR/data"/*.sql 2>/dev/null | sed 's/.*\//  /' || echo "  (none)"
    echo ""

    print_info "Procedure Migrations:"
    ls -1 "$MIGRATIONS_DIR/procedures"/*.sql 2>/dev/null | sed 's/.*\//  /' || echo "  (none)"
    echo ""
}

# 显示帮助
show_help() {
    cat << EOF
IDAP 数据库迁移管理工具

用法:
  $0 <command> [arguments]

命令:
  create <type> <description>    创建新的迁移文件
    类型: schema, data, procedure
    示例: $0 create schema "add user email index"
         $0 create data "insert sample products"

  apply                          应用所有迁移到本地数据库

  list                           列出所有迁移文件

  help                           显示此帮助信息

迁移文件命名规范:
  - Schema (DDL): V001__create_users_table.sql
  - Data (DML):   D001__insert_sample_users.sql
  - Procedure:    P001__calculate_revenue.sql

最佳实践:
  1. Schema 变更和 Data 变更分开
  2. 每个迁移文件只做一件事
  3. 迁移文件创建后不要修改（创建新的回滚迁移）
  4. 在提交前先测试: $0 apply

EOF
}

# 主逻辑
case "${1:-help}" in
    create)
        if [ -z "$2" ] || [ -z "$3" ]; then
            print_error "Missing arguments"
            echo ""
            show_help
            exit 1
        fi
        create_migration "$2" "$3"
        ;;
    apply)
        apply_migrations
        ;;
    list)
        list_migrations
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
