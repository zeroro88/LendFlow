from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.routers import user, lending, liquidity

def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.PROJECT_NAME,
        description="DeFi借贷平台的后端API",
        version=settings.VERSION
    )

    # 配置CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # 注册路由
    app.include_router(user.router)
    app.include_router(lending.router)
    app.include_router(liquidity.router)

    @app.get("/health")
    async def health_check():
        from app.services.web3_service import web3_service
        return {
            "status": "healthy",
            "web3_connected": web3_service.is_connected()
        }

    return app