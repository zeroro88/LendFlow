from app.models.lending import Pool, LoanRequest, LoanResponse
from decimal import Decimal

class LendingService:
    async def get_pools(self) -> dict:
        pool = Pool(
            id="1",
            asset="ETH",
            total_liquidity=Decimal('0'),
            borrow_rate=Decimal('0'),
            lend_rate=Decimal('0')
        )
        return {"pools": [pool.dict()]}

    async def create_loan(self, loan_request: LoanRequest) -> LoanResponse:
        return LoanResponse(
            status="success",
            message="借贷请求已提交",
            transaction_hash="0x..."
        )

lending_service = LendingService()