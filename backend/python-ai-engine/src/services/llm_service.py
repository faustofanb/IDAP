from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic
from typing import AsyncGenerator

class LLMService:
    """LLM 服务 - 管理多个 LLM 模型"""

    def __init__(self):
        self.models = {}
        # TODO: 初始化模型

    async def generate(
        self,
        prompt: str,
        model: str = "gpt-4",
        stream: bool = False
    ):
        """生成文本"""
        # TODO: 实现 LLM 调用
        pass

    async def generate_stream(
        self,
        prompt: str,
        model: str = "gpt-4"
    ) -> AsyncGenerator[str, None]:
        """流式生成"""
        # TODO: 实现流式输出
        yield ""
