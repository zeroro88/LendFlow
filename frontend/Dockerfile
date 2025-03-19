FROM node:16-slim AS builder

WORKDIR /app

# 安装构建依赖
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHON=/usr/bin/python3

# 安装依赖
COPY package*.json ./
RUN npm install

# 构建应用
COPY . .
RUN npm run build

# 生产环境
FROM node:16-slim AS runner
WORKDIR /app

# 复制构建产物（注意这里改为 .next）
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package*.json ./

RUN npm install --production

CMD ["npm", "start"]