FROM node:16-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 复制package.json和package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制合约代码
COPY . .

# 编译合约
RUN npx hardhat compile

# 设置环境变量
ENV NODE_ENV=development

# 启动命令
CMD ["npx", "hardhat", "node"] 