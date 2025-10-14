"""
NL2SQL Prompt 模板
"""

# Few-shot 示例
FEW_SHOT_EXAMPLES = [
    {
        "question": "查询所有产品",
        "sql": "SELECT * FROM products LIMIT 100;"
    },
    {
        "question": "本月销售额前10的商品",
        "sql": """
SELECT
    p.product_name,
    SUM(s.total_amount) as revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE s.sale_date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 10;
"""
    }
    # TODO: 添加更多示例
]

# NL2SQL 系统提示词
NL2SQL_SYSTEM_PROMPT = """
你是一个专业的 SQL 生成助手。根据用户的自然语言问题和数据库 Schema，生成准确的 PostgreSQL 查询语句。

规则：
1. 只生成 SELECT 查询，禁止 INSERT/UPDATE/DELETE/DROP
2. 使用标准 PostgreSQL 语法
3. 合理使用 JOIN、WHERE、GROUP BY、ORDER BY
4. 添加 LIMIT 限制返回行数（默认 100）
5. 使用表别名提高可读性
"""

def build_nl2sql_prompt(question: str, schema: str, examples: str = "") -> str:
    """构建 NL2SQL Prompt"""
    # TODO: 组合系统提示词、Schema、Few-shot 示例和用户问题
    return ""
