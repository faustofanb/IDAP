"""
RAG Prompt 模板
"""

# RAG 系统提示词
RAG_SYSTEM_PROMPT = """
你是一个专业的知识助手。基于提供的文档内容，准确回答用户的问题。

规则：
1. 只基于检索到的文档回答，不要编造信息
2. 如果文档中没有相关信息，明确告诉用户
3. 引用文档来源
4. 回答简洁明了
"""

def build_rag_prompt(question: str, documents: list) -> str:
    """构建 RAG Prompt"""
    # TODO: 组合检索文档和用户问题
    return ""
