#!/bin/bash
# IDAP 数据库初始化脚本
# 描述: 按顺序执行所有数据库迁移脚本
# 日期: 2025-01-15

set -e

echo "=================================================="
echo "IDAP Database Initialization"
echo "=================================================="
echo ""

# 数据库连接信息
DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-idap}"
DB_USER="${POSTGRES_USER:-idap}"
DB_PASSWORD="${POSTGRES_PASSWORD:-idap123}"

export PGPASSWORD="$DB_PASSWORD"

MIGRATIONS_DIR="/docker-entrypoint-initdb.d/migrations"

echo "📊 Database: $DB_NAME"
echo "🔗 Host: $DB_HOST:$DB_PORT"
echo "👤 User: $DB_USER"
echo ""

# 执行 Schema 迁移
echo "🏗️  Executing Schema Migrations..."
echo "=================================================="
for sql_file in "$MIGRATIONS_DIR/schema"/V*.sql; do
    if [ -f "$sql_file" ]; then
        filename=$(basename "$sql_file")
        echo "▶️  Executing: $filename"
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$sql_file"
        echo "✅ Completed: $filename"
        echo ""
    fi
done

# 执行 Data 迁移
echo "📝 Executing Data Migrations..."
echo "=================================================="
for sql_file in "$MIGRATIONS_DIR/data"/D*.sql; do
    if [ -f "$sql_file" ]; then
        filename=$(basename "$sql_file")
        echo "▶️  Executing: $filename"
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$sql_file"
        echo "✅ Completed: $filename"
        echo ""
    fi
done

# 执行存储过程迁移（如果有）
if [ -d "$MIGRATIONS_DIR/procedures" ] && [ "$(ls -A $MIGRATIONS_DIR/procedures/*.sql 2>/dev/null)" ]; then
    echo "⚙️  Executing Procedure Migrations..."
    echo "=================================================="
    for sql_file in "$MIGRATIONS_DIR/procedures"/P*.sql; do
        if [ -f "$sql_file" ]; then
            filename=$(basename "$sql_file")
            echo "▶️  Executing: $filename"
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$sql_file"
            echo "✅ Completed: $filename"
            echo ""
        fi
    done
fi

# 显示数据库统计信息
echo "📊 Database Statistics"
echo "=================================================="
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << 'EOF'
SELECT 
    'Tables' as type, 
    COUNT(*) as count 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
UNION ALL
SELECT 
    'Views' as type, 
    COUNT(*) as count 
FROM information_schema.views 
WHERE table_schema = 'public'
UNION ALL
SELECT 
    'Users' as type, 
    COUNT(*)::TEXT as count 
FROM users
UNION ALL
SELECT 
    'Products' as type, 
    COUNT(*)::TEXT as count 
FROM products
UNION ALL
SELECT 
    'Customers' as type, 
    COUNT(*)::TEXT as count 
FROM customers
UNION ALL
SELECT 
    'Sales' as type, 
    COUNT(*)::TEXT as count 
FROM sales
UNION ALL
SELECT 
    'RAG Documents' as type, 
    COUNT(*)::TEXT as count 
FROM rag_documents;
EOF

echo ""
echo "=================================================="
echo "✅ Database initialization completed successfully!"
echo "=================================================="
echo ""
echo "🎉 You can now:"
echo "  - Login with: demo / Password123!"
echo "  - Query products, customers, and sales data"
echo "  - Test NL2SQL with questions like:"
echo "    '本月销售额是多少？'"
echo "    '销售额TOP10的商品'"
echo "    '上海地区的金卡会员有多少人？'"
echo ""
