FROM nginx:latest
EXPOSE 80 443
WORKDIR /app
USER root

COPY nginx.conf /etc/nginx/nginx.conf
COPY config.json ./
COPY entrypoint.sh ./

# 安装依赖并下载最新 Xray-core（支持 xhttp+reality）
RUN apt-get update && apt-get install -y wget unzip iproute2 curl && \
    # 使用官方 Docker 镜像或直接下载最新版
    wget -O temp.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip temp.zip xray && \
    rm -f temp.zip && \
    chmod +x xray && \
    # 生成 x25519 密钥对（用于 reality）
    ./xray x25519 > /app/reality_keys.txt && \
    chmod 755 xray entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
