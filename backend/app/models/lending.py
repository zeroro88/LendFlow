from pydantic import BaseModel, Field
from typing import Optional
from decimal import Decimal
from datetime import datetime

class Pool(BaseModel):
    id: str
    asset: str
    total_liquidity: Decimal = Field(default=Decimal('0'))
    borrow_rate: Decimal = Field(default=Decimal('0'))
    lend_rate: Decimal = Field(default=Decimal('0'))

class LoanRequest(BaseModel):
    collateral_amount: Decimal
    borrow_amount: Decimal
    collateral_asset: str
    borrow_asset: str
    user_address: str

class LoanResponse(BaseModel):
    status: str
    message: str
    transaction_hash: str