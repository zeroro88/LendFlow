from fastapi import APIRouter, HTTPException
from app.services.user_service import user_service
from app.services.web3_service import web3_service

router = APIRouter(prefix="/api/user")

@router.get("/{address}")
async def get_user_info(address: str):
    try:
        if not web3_service.validate_address(address):
            raise HTTPException(status_code=400, detail="无效的以太坊地址")
        return await user_service.get_user_info(address)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))