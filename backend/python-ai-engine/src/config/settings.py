from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """应用配置"""

    # OpenAI
    openai_api_key: str
    anthropic_api_key: str = ""

    # LLM
    default_model: str = "gpt-4-turbo-preview"
    default_temperature: float = 0.7

    # Database (只读 Schema)
    database_url: str

    # Vector Store
    vector_store_type: str = "faiss"
    milvus_host: str = "localhost"
    milvus_port: int = 19530

    # Server
    host: str = "0.0.0.0"
    port: int = 8001

    # Redis
    redis_host: str = "localhost"
    redis_port: int = 6379

    class Config:
        env_file = ".env"

settings = Settings()
