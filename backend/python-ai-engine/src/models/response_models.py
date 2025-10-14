from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any

class NL2SQLResponse(BaseModel):
    """NL2SQL 响应模型"""
    sql: str = Field(..., description="生成的 SQL")
    confidence: float = Field(..., description="置信度")
    explanation: Optional[str] = Field(None, description="解释")
    tables_used: List[str] = Field(default_factory=list, description="使用的表")

class RAGQueryResponse(BaseModel):
    """RAG 查询响应模型"""
    answer: str = Field(..., description="答案")
    sources: List[Dict[str, Any]] = Field(default_factory=list, description="来源文档")

class LLMChatResponse(BaseModel):
    """LLM 对话响应模型"""
    message: str = Field(..., description="回复消息")
    model: str = Field(..., description="使用的模型")
    tokens: int = Field(..., description="Token 消耗")
