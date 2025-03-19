const hre = require("hardhat");

async function main() {
  console.log("开始部署LendFlow合约...");

  // 部署LendFlow合约
  const LendFlow = await hre.ethers.getContractFactory("LendFlow");
  const lendFlow = await LendFlow.deploy();
  await lendFlow.deployed();

  console.log("LendFlow合约已部署到:", lendFlow.address);

  // 等待几个区块确认
  await lendFlow.deployTransaction.wait(5);
  console.log("部署交易已确认");

  // 验证合约
  if (process.env.ETHERSCAN_API_KEY) {
    console.log("正在验证合约...");
    await hre.run("verify:verify", {
      address: lendFlow.address,
      constructorArguments: [],
    });
    console.log("合约验证完成");
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 