from web3 import Web3

class UserService:
    async def get_user_info(self, address: str):
        return {
            "address": address,
            "total_borrowed": "0",
            "total_lent": "0",
            "active_loans": []
        }

user_service = UserService()