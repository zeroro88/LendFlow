const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LendFlow", function () {
  let LendFlow;
  let lendFlow;
  let owner;
  let addr1;
  let addr2;
  let mockToken1;
  let mockToken2;

  beforeEach(async function () {
    // 获取测试账户
    [owner, addr1, addr2] = await ethers.getSigners();

    // 部署模拟代币
    const MockToken = await ethers.getContractFactory("MockToken");
    mockToken1 = await MockToken.deploy("Mock Token 1", "MTK1");
    mockToken2 = await MockToken.deploy("Mock Token 2", "MTK2");

    // 部署LendFlow合约
    LendFlow = await ethers.getContractFactory("LendFlow");
    lendFlow = await LendFlow.deploy();
    await lendFlow.deployed();

    // 创建借贷池
    await lendFlow.createPool(await mockToken1.address);
    await lendFlow.createPool(await mockToken2.address);
  });

  describe("创建借贷池", function () {
    it("应该成功创建新的借贷池", async function () {
      const newToken = await (await ethers.getContractFactory("MockToken")).deploy("New Token", "NTK");
      await expect(lendFlow.createPool(await newToken.address))
        .to.emit(lendFlow, "PoolCreated")
        .withArgs(await newToken.address);
    });

    it("不应该允许重复创建同一个代币的借贷池", async function () {
      await expect(lendFlow.createPool(await mockToken1.address))
        .to.be.revertedWith("Pool already exists");
    });
  });

  describe("提供流动性", function () {
    it("应该成功提供流动性", async function () {
      const amount = ethers.utils.parseEther("100");
      await mockToken1.approve(await lendFlow.address, amount);
      
      await expect(lendFlow.provideLiquidity(await mockToken1.address, amount))
        .to.emit(lendFlow, "LiquidityProvided")
        .withArgs(owner.address, await mockToken1.address, amount);
    });

    it("不应该允许提供0数量的流动性", async function () {
      await expect(lendFlow.provideLiquidity(await mockToken1.address, 0))
        .to.be.revertedWith("Amount must be greater than 0");
    });
  });

  describe("创建贷款", function () {
    beforeEach(async function () {
      // 提供流动性
      const amount = ethers.utils.parseEther("1000");
      await mockToken1.approve(await lendFlow.address, amount);
      await lendFlow.provideLiquidity(await mockToken1.address, amount);
    });

    it("应该成功创建贷款", async function () {
      const collateralAmount = ethers.utils.parseEther("100");
      const borrowAmount = ethers.utils.parseEther("50");
      
      await mockToken2.approve(await lendFlow.address, collateralAmount);
      
      await expect(lendFlow.createLoan(
        await mockToken2.address,
        await mockToken1.address,
        collateralAmount,
        borrowAmount
      )).to.emit(lendFlow, "LoanCreated");
    });

    it("不应该允许创建抵押率不足的贷款", async function () {
      const collateralAmount = ethers.utils.parseEther("10");
      const borrowAmount = ethers.utils.parseEther("100");
      
      await mockToken2.approve(await lendFlow.address, collateralAmount);
      
      await expect(lendFlow.createLoan(
        await mockToken2.address,
        await mockToken1.address,
        collateralAmount,
        borrowAmount
      )).to.be.revertedWith("Insufficient collateral");
    });
  });

  describe("还款", function () {
    let loanId;

    beforeEach(async function () {
      // 提供流动性
      const amount = ethers.utils.parseEther("1000");
      await mockToken1.approve(await lendFlow.address, amount);
      await lendFlow.provideLiquidity(await mockToken1.address, amount);

      // 创建贷款
      const collateralAmount = ethers.utils.parseEther("100");
      const borrowAmount = ethers.utils.parseEther("50");
      
      await mockToken2.approve(await lendFlow.address, collateralAmount);
      const tx = await lendFlow.createLoan(
        await mockToken2.address,
        await mockToken1.address,
        collateralAmount,
        borrowAmount
      );
      
      const receipt = await tx.wait();
      loanId = receipt.events.find(e => e.event === "LoanCreated").args.loanId;
    });

    it("应该成功还款", async function () {
      await mockToken1.approve(await lendFlow.address, ethers.utils.parseEther("100"));
      
      await expect(lendFlow.repayLoan(loanId))
        .to.emit(lendFlow, "LoanRepaid")
        .withArgs(loanId);
    });

    it("不应该允许非借款人还款", async function () {
      await expect(lendFlow.connect(addr1).repayLoan(loanId))
        .to.be.revertedWith("Not the borrower");
    });
  });
}); 