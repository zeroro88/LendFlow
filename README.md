# LendFlow - DeFi借贷平台

LendFlow是一个去中心化金融（DeFi）借贷平台，允许用户通过智能合约进行加密资产的借贷和质押。

## 项目结构

```
lendflow/
├── contracts/           # 智能合约
├── backend/            # Python后端
├── frontend/           # React前端
├── tests/              # 测试文件
└── docs/               # 文档
```

## 技术栈

- 智能合约：Solidity
- 后端：Python + FastAPI
- 前端：React + Web3.js
- 区块链网络：以太坊（Goerli测试网）
- 数据库：SQLite
- 容器化：Docker + Docker Compose

## 快速开始

### 使用Docker部署（推荐）

1. 克隆项目
```bash
git clone https://github.com/yourusername/lendflow.git
cd lendflow
```

2. 启动所有服务
```bash
docker-compose up -d
```

3. 访问应用
- 前端界面：http://localhost:3000
- 后端API：http://localhost:8000
- Ganache测试网络：http://localhost:8545

4. 查看日志
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f contracts
```

5. 停止服务
```bash
docker-compose down
```

### 手动部署

如果您想手动部署各个组件，请参考以下步骤：

#### 前置要求

- Node.js >= 14.0.0
- Python >= 3.8
- MetaMask钱包

#### 安装步骤

1. 克隆项目
```bash
git clone https://github.com/yourusername/lendflow.git
cd lendflow
```

2. 安装后端依赖
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
.\venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

3. 安装前端依赖
```bash
cd frontend
npm install
```

4. 安装智能合约依赖
```bash
cd contracts
npm install
```

## 运行项目

### 使用Docker

1. 启动所有服务
```bash
docker-compose up -d
```

2. 部署智能合约
```bash
docker-compose exec contracts npx hardhat run scripts/deploy.js --network localhost
```

### 手动运行

1. 启动后端服务
```bash
cd backend
uvicorn main:app --reload
```

2. 启动前端服务
```bash
cd frontend
npm start
```

3. 部署智能合约
```bash
cd contracts
npx hardhat run scripts/deploy.js --network localhost
```

## 测试

### 使用Docker运行测试

```bash
# 运行智能合约测试
docker-compose exec contracts npx hardhat test

# 运行后端测试
docker-compose exec backend pytest

# 运行前端测试
docker-compose exec frontend npm test
```

### 手动运行测试

```bash
# 运行智能合约测试
cd contracts
npx hardhat test

# 运行后端测试
cd backend
pytest

# 运行前端测试
cd frontend
npm test
```

## 开发环境配置

### 环境变量

1. 复制环境变量示例文件
```bash
cp contracts/.env.example contracts/.env
cp backend/.env.example backend/.env
```

2. 配置必要的环境变量
- 在`contracts/.env`中设置：
  - `GOERLI_URL`：以太坊节点URL
  - `PRIVATE_KEY`：部署账户私钥
  - `ETHERSCAN_API_KEY`：Etherscan API密钥

- 在`backend/.env`中设置：
  - `DATABASE_URL`：数据库URL（默认：sqlite:///./lendflow.db）
  - `ETH_NODE_URL`：以太坊节点URL

### 数据库迁移

```bash
# 使用Docker
docker-compose exec backend alembic upgrade head

# 手动执行
cd backend
alembic upgrade head
```

## 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

MIT License 