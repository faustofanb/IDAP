from typing import List, Dict, Any, AsyncGenerator

class RAGService:
    """RAG 服务 - 知识库检索与问答"""

    def __init__(self, llm_service):
        self.llm_service = llm_service
        # TODO: 初始化向量存储

    async def query(
        self,
        question: str,
        top_k: int = 5
    ) -> Dict[str, Any]:
        """RAG 查询"""
        # TODO: 1. 向量检索
        # TODO: 2. 重排序
        # TODO: 3. 生成答案
        return {
            "answer": "",
            "sources": []
        }

    async def query_stream(
        self,
        question: str
    ) -> AsyncGenerator[str, None]:
        """流式 RAG 查询"""
        # TODO: 流式返回答案
        yield ""
