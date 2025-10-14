from typing import Dict, Any

class NL2SQLAgent:
    """NL2SQL Agent - 自然语言转 SQL"""

    def __init__(self, llm_service):
        self.llm_service = llm_service
        # TODO: 初始化 Agent

    async def generate_sql(
        self,
        question: str,
        schema: Dict[str, Any]
    ) -> Dict[str, Any]:
        """生成 SQL"""
        # TODO: 1. 检索相关表 Schema
        # TODO: 2. 构建 Few-shot Prompt
        # TODO: 3. 调用 LLM 生成 SQL
        # TODO: 4. 验证 SQL 语法
        return {
            "sql": "",
            "confidence": 0.0,
            "explanation": ""
        }

    async def retrieve_schema(self, question: str):
        """检索相关表 Schema"""
        # TODO: 向量检索相关表
        pass
