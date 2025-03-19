// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract LendFlow is ReentrancyGuard, Pausable, Ownable {
    using SafeERC20 for IERC20;

    // 结构体定义
    struct Loan {
        address borrower;
        address collateralToken;
        address borrowToken;
        uint256 collateralAmount;
        uint256 borrowAmount;
        uint256 startTime;
        uint256 endTime;
        uint256 interestRate;
        bool isActive;
    }

    struct Pool {
        address token;
        uint256 totalLiquidity;
        uint256 totalBorrowed;
        uint256 borrowRate;
        uint256 lendRate;
        uint256 lastUpdateTime;
        uint256 reserveFactor;
    }

    // 状态变量
    mapping(address => Pool) public pools;
    mapping(uint256 => Loan) public loans;
    mapping(address => mapping(address => uint256)) public userDeposits;
    mapping(address => mapping(address => uint256)) public userBorrows;
    
    uint256 public loanCount;
    uint256 public constant COLLATERAL_RATIO = 150; // 150%
    uint256 public constant LIQUIDATION_THRESHOLD = 130; // 130%
    uint256 public constant PRECISION = 10000;

    // 事件定义
    event PoolCreated(address indexed token);
    event LoanCreated(uint256 indexed loanId, address indexed borrower);
    event LoanRepaid(uint256 indexed loanId);
    event LiquidityProvided(address indexed user, address indexed token, uint256 amount);
    event LiquidityWithdrawn(address indexed user, address indexed token, uint256 amount);
    event LoanLiquidated(uint256 indexed loanId);

    constructor() {
        // 初始化合约
    }

    // 创建新的借贷池
    function createPool(address token) external onlyOwner {
        require(token != address(0), "Invalid token address");
        require(pools[token].token == address(0), "Pool already exists");

        pools[token] = Pool({
            token: token,
            totalLiquidity: 0,
            totalBorrowed: 0,
            borrowRate: 0,
            lendRate: 0,
            lastUpdateTime: block.timestamp,
            reserveFactor: 1000 // 10%
        });

        emit PoolCreated(token);
    }

    // 提供流动性
    function provideLiquidity(address token, uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "Amount must be greater than 0");
        require(pools[token].token != address(0), "Pool does not exist");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        
        pools[token].totalLiquidity += amount;
        userDeposits[msg.sender][token] += amount;

        emit LiquidityProvided(msg.sender, token, amount);
    }

    // 提取流动性
    function withdrawLiquidity(address token, uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "Amount must be greater than 0");
        require(userDeposits[msg.sender][token] >= amount, "Insufficient balance");

        pools[token].totalLiquidity -= amount;
        userDeposits[msg.sender][token] -= amount;

        IERC20(token).safeTransfer(msg.sender, amount);

        emit LiquidityWithdrawn(msg.sender, token, amount);
    }

    // 创建贷款
    function createLoan(
        address collateralToken,
        address borrowToken,
        uint256 collateralAmount,
        uint256 borrowAmount
    ) external nonReentrant whenNotPaused {
        require(collateralAmount > 0 && borrowAmount > 0, "Amounts must be greater than 0");
        require(pools[borrowToken].token != address(0), "Borrow pool does not exist");

        // 检查抵押率
        uint256 collateralValue = getTokenValue(collateralToken, collateralAmount);
        uint256 borrowValue = getTokenValue(borrowToken, borrowAmount);
        require(collateralValue * 100 >= borrowValue * COLLATERAL_RATIO, "Insufficient collateral");

        // 转移抵押物
        IERC20(collateralToken).safeTransferFrom(msg.sender, address(this), collateralAmount);

        // 创建贷款记录
        uint256 loanId = loanCount++;
        loans[loanId] = Loan({
            borrower: msg.sender,
            collateralToken: collateralToken,
            borrowToken: borrowToken,
            collateralAmount: collateralAmount,
            borrowAmount: borrowAmount,
            startTime: block.timestamp,
            endTime: block.timestamp + 30 days,
            interestRate: pools[borrowToken].borrowRate,
            isActive: true
        });

        // 更新池子状态
        pools[borrowToken].totalBorrowed += borrowAmount;
        userBorrows[msg.sender][borrowToken] += borrowAmount;

        // 转移借入的资产
        IERC20(borrowToken).safeTransfer(msg.sender, borrowAmount);

        emit LoanCreated(loanId, msg.sender);
    }

    // 还款
    function repayLoan(uint256 loanId) external nonReentrant whenNotPaused {
        Loan storage loan = loans[loanId];
        require(loan.isActive, "Loan is not active");
        require(loan.borrower == msg.sender, "Not the borrower");

        uint256 repayAmount = calculateRepayAmount(loanId);
        require(IERC20(loan.borrowToken).balanceOf(msg.sender) >= repayAmount, "Insufficient balance");

        // 转移还款金额
        IERC20(loan.borrowToken).safeTransferFrom(msg.sender, address(this), repayAmount);

        // 更新池子状态
        pools[loan.borrowToken].totalBorrowed -= loan.borrowAmount;
        userBorrows[msg.sender][loan.borrowToken] -= loan.borrowAmount;

        // 返还抵押物
        IERC20(loan.collateralToken).safeTransfer(msg.sender, loan.collateralAmount);

        // 更新贷款状态
        loan.isActive = false;

        emit LoanRepaid(loanId);
    }

    // 清算贷款
    function liquidateLoan(uint256 loanId) external nonReentrant whenNotPaused {
        Loan storage loan = loans[loanId];
        require(loan.isActive, "Loan is not active");

        uint256 collateralValue = getTokenValue(loan.collateralToken, loan.collateralAmount);
        uint256 borrowValue = getTokenValue(loan.borrowToken, loan.borrowAmount);
        require(collateralValue * 100 < borrowValue * LIQUIDATION_THRESHOLD, "Loan is healthy");

        // 计算清算奖励
        uint256 liquidationReward = (loan.collateralAmount * 5) / 100; // 5% 清算奖励

        // 转移抵押物给清算人
        IERC20(loan.collateralToken).safeTransfer(msg.sender, liquidationReward);

        // 更新池子状态
        pools[loan.borrowToken].totalBorrowed -= loan.borrowAmount;
        userBorrows[loan.borrower][loan.borrowToken] -= loan.borrowAmount;

        // 更新贷款状态
        loan.isActive = false;

        emit LoanLiquidated(loanId);
    }

    // 获取代币价值（使用Chainlink价格预言机）
    function getTokenValue(address token, uint256 amount) public view returns (uint256) {
        // TODO: 实现价格预言机集成
        return amount;
    }

    // 计算还款金额（包含利息）
    function calculateRepayAmount(uint256 loanId) public view returns (uint256) {
        Loan storage loan = loans[loanId];
        uint256 timeElapsed = block.timestamp - loan.startTime;
        uint256 interest = (loan.borrowAmount * loan.interestRate * timeElapsed) / (365 days * PRECISION);
        return loan.borrowAmount + interest;
    }

    // 紧急暂停
    function pause() external onlyOwner {
        _pause();
    }

    // 解除暂停
    function unpause() external onlyOwner {
        _unpause();
    }
} 