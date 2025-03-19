from web3 import Web3
from app.core.config import settings

class Web3Service:
    def __init__(self):
        self.w3 = Web3(Web3.HTTPProvider(settings.ETH_NODE_URL))

    def is_connected(self) -> bool:
        return self.w3.is_connected()

    def validate_address(self, address: str) -> bool:
        return self.w3.is_address(address)

web3_service = Web3Service()