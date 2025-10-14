from pydantic import BaseModel, Field
from typing import Optional, Dict, Any

class NL2SQLRequest(BaseModel):
    """NL2SQL 请求模型"""
    question: str = Field(..., description="用户问题")
    schema: Optional[Dict[str, Any]] = Field(None, description="数据库 Schema")
    model: str = Field("gpt-4", description="使用的模型")

class RAGQueryRequest(BaseModel):
    """RAG 查询请求模型"""
    question: str = Field(..., description="用户问题")
    top_k: int = Field(5, description="返回文档数量")
    model: str = Field("gpt-4", description="使用的模型")

class LLMChatRequest(BaseModel):
    """LLM 对话请求模型"""
    message: str = Field(..., description="用户消息")
    model: str = Field("gpt-4", description="使用的模型")
    stream: bool = Field(False, description="是否流式输出")
