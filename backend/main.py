from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from web3 import Web3
import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

app = FastAPI(
    title="LendFlow API",
    description="DeFi借贷平台的后端API",
    version="1.0.0"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生产环境中应该设置具体的域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 初始化Web3连接
w3 = Web3(Web3.HTTPProvider(os.getenv("ETH_NODE_URL", "http://localhost:8545")))

@app.get("/")
async def root():
    return {"message": "欢迎使用LendFlow API"}

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "web3_connected": w3.is_connected()
    }

# 用户相关路由
@app.get("/api/user/{address}")
async def get_user_info(address: str):
    try:
        # 验证地址格式
        if not w3.is_address(address):
            raise HTTPException(status_code=400, detail="无效的以太坊地址")
        
        # TODO: 从数据库获取用户信息
        return {
            "address": address,
            "total_borrowed": "0",
            "total_lent": "0",
            "active_loans": []
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 借贷池相关路由
@app.get("/api/pools")
async def get_lending_pools():
    # TODO: 从智能合约获取借贷池信息
    return {
        "pools": [
            {
                "id": "1",
                "asset": "ETH",
                "total_liquidity": "0",
                "borrow_rate": "0",
                "lend_rate": "0"
            }
        ]
    }

# 借贷相关路由
@app.post("/api/borrow")
async def create_loan(
    collateral_amount: float,
    borrow_amount: float,
    collateral_asset: str,
    borrow_asset: str,
    user_address: str
):
    # TODO: 实现借贷逻辑
    return {
        "status": "success",
        "message": "借贷请求已提交",
        "transaction_hash": "0x..."
    }

@app.post("/api/repay")
async def repay_loan(
    loan_id: str,
    amount: float,
    user_address: str
):
    # TODO: 实现还款逻辑
    return {
        "status": "success",
        "message": "还款请求已提交",
        "transaction_hash": "0x..."
    }

# 流动性提供相关路由
@app.post("/api/provide-liquidity")
async def provide_liquidity(
    amount: float,
    asset: str,
    user_address: str
):
    # TODO: 实现提供流动性逻辑
    return {
        "status": "success",
        "message": "流动性提供请求已提交",
        "transaction_hash": "0x..."
    }

@app.post("/api/withdraw-liquidity")
async def withdraw_liquidity(
    amount: float,
    asset: str,
    user_address: str
):
    # TODO: 实现提取流动性逻辑
    return {
        "status": "success",
        "message": "提取流动性请求已提交",
        "transaction_hash": "0x..."
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 