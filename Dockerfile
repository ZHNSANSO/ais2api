# Dockerfile (v5 优化版)
# 1. 基础镜像升级
FROM node:20-slim

WORKDIR /app

# 2. 安装系统依赖
# - 添加 ca-certificates 解决 curl SSL 错误
# - 添加 unzip 用于解压 camoufox.zip
# - 保持构建浏览器所需的基础依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    ca-certificates \
    libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcups2 \
    libdbus-1-3 libdrm2 libgbm1 libgtk-3-0 libnspr4 libnss3 libx11-6 \
    libx11-xcb1 libxcb1 libxcomposite1 libxdamage1 libxext6 libxfixes3 \
    libxrandr2 libxss1 libxtst6 xvfb \
    && rm -rf /var/lib/apt/lists/*

# 3. 拷贝 package.json 并安装依赖
# 利用层缓存，仅在 package.json 变化时重新安装
COPY package*.json ./
RUN npm install --production

# 4. 下载并解压 Camoufox
# - 创建目标目录，因为 zip 包不会自动创建
# - 使用 -d 参数将文件解压到指定目录
ARG CAMOUFOX_URL="https://github.com/coryking/camoufox/releases/download/v142.0.1-fork.26/camoufox-142.0.1-fork.26-lin.x86_64.zip"
RUN mkdir camoufox-linux && \
    curl -sSL ${CAMOUFOX_URL} -o camoufox.zip && \
    unzip -d camoufox-linux camoufox.zip && \
    rm camoufox.zip && \
    chmod +x /app/camoufox-linux/camoufox

# 5. 拷贝应用代码
# 将代码拷贝放在后面，最大化利用缓存
COPY unified-server.js black-browser.js models.json ./

# 6. 创建目录并设置精细化权限
RUN mkdir -p ./auth && chown -R node:node /app/auth
USER node

# 7. 暴露端口
EXPOSE 7860
EXPOSE 9998

# 8. 设置环境变量
ENV CAMOUFOX_EXECUTABLE_PATH=/app/camoufox-linux/camoufox

# 9. 定义启动命令
CMD ["node", "unified-server.js"]
