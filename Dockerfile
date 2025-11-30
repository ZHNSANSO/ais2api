# Dockerfile (v8 最终修复版)
# 1. 基础镜像升级
FROM node:20-slim

WORKDIR /app

# 2. 安装系统依赖
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
COPY package*.json ./
RUN npm install --production

# 4. 下载并解压 Camoufox 资源文件
# 根据日志，此 zip 包不包含 camoufox 可执行文件，只包含字体和配置文件。
# 因此，我们只解压文件，不再尝试执行 chmod 或设置相关路径。
ARG CAMOUFOX_URL="https://github.com/coryking/camoufox/releases/download/v142.0.1-fork.26/camoufox-142.0.1-fork.26-lin.x86_64.zip"
RUN curl -sSL ${CAMOUFOX_URL} -o camoufox.zip && \
    unzip camoufox.zip && \
    rm camoufox.zip

# 5. 拷贝应用代码
COPY unified-server.js black-browser.js models.json ./

# 6. 创建目录并设置精细化权限
RUN mkdir -p ./auth && chown -R node:node /app/auth
USER node

# 7. 暴露端口
EXPOSE 7860
EXPOSE 9998

# 8. 定义启动命令
# 移除了 CAMOUFOX_EXECUTABLE_PATH 环境变量，因为它指向的文件不存在。
CMD ["node", "unified-server.js"]
