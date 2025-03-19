from pydantic_settings import BaseSettings
from dotenv import load_dotenv
import os

load_dotenv()

class Settings(BaseSettings):
    PROJECT_NAME: str = "LendFlow API"
    VERSION: str = "1.0.0"
    API_PREFIX: str = "/api"
    ETH_NODE_URL: str = os.getenv("ETH_NODE_URL", "http://localhost:8545")

settings = Settings()