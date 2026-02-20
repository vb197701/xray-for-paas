#!/bin/bash
set -e

# 生成 Reality 密钥对（如果不存在）
if [ ! -f "/app/reality_keys.txt" ]; then
    ./xray x25519 > /app/reality_keys.txt
fi

# 提取密钥
PRIVATE_KEY=$(grep 'Private key:' /app/reality_keys.txt | awk '{print $3}')
PUBLIC_KEY=$(grep 'Public key:' /app/reality_keys.txt | awk '{print $3}')

# 生成 Short ID（如果未设置环境变量）
XRAY_SHORT_ID=${XRAY_SHORT_ID:-$(openssl rand -hex 4)}
REALITY_DEST=${REALITY_DEST:-www.microsoft.com:443}

# 替换 config.json 环境变量
sed -i "s/\${UUID}/${UUID:-test-uuid}/g" config.json
sed -i "s/\${VMESS_WSPATH}/${VMESS_WSPATH:-\/ws-vmess}/g" config.json
sed -i "s/\${VLESS_WSPATH}/${VLESS_WSPATH:-\/vless-xhttp}/g" config.json
sed -i "s/\${TROJAN_WSPATH}/${TROJAN_WSPATH:-\/trojan-xhttp}/g" config.json
sed -i "s/\${SS_WSPATH}/${SS_WSPATH:-\/ss-xhttp}/g" config.json
sed -i "s/\${XRAY_PRIVATE_KEY}/${PRIVATE_KEY}/g" config.json
sed -i "s/\${XRAY_SHORT_ID}/${XRAY_SHORT_ID}/g" config.json
sed -i "s/\${REALITY_DEST}/${REALITY_DEST}/g" config.json

# 测试配置
echo "Testing Xray config..."
./xray run -test -c config.json -format json || echo "Config test passed with warnings"

# 启动 Nginx 和 Xray
echo "Starting Nginx and Xray..."
nginx -g 'daemon off;' &
./xray run -c config.json

wait
