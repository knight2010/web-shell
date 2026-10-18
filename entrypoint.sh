#!/bin/bash
set -e

# 获取平台端口，未指定时兜底为 10000
APP_PORT="${PORT:-10000}"
AUTH_USER="${SHELL_USER:-admin}"
AUTH_PASS="${SHELL_PASS:-RenderShell@2026}"

# 1. 启动后台自定义脚本
if [ -f "/root/my_script.sh" ]; then
    echo "[$(date)] Starting background task..."
    nohup /root/my_script.sh > /root/my_script.log 2>&1 &
fi

# 2. 动态生成监听端口列表（自动去重，避免 duplicate listen 报错）
LISTEN_DIRECTIVES="listen ${APP_PORT} default_server;"
for p in 80 8080 10000; do
    if [ "$p" != "$APP_PORT" ]; then
        LISTEN_DIRECTIVES="${LISTEN_DIRECTIVES}
    listen ${p};"
    fi
done

# 3. 写入 Nginx 配置文件
cat <<EOF > /etc/nginx/sites-available/default
server {
    ${LISTEN_DIRECTIVES}
    server_name _;

    # 外部专属 health 接口：无需鉴权，直接返回 200 OK
    location /health {
        default_type application/json;
        return 200 '{"status":"ok","uptime":"running"}';
    }

    # 根路径：代理到内网 ttyd，并完整支持 WebSocket
    location / {
        proxy_pass http://127.0.0.1:7681;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}
EOF

# 4. 确保 sites-enabled 软链接存在
mkdir -p /etc/nginx/sites-enabled
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# 5. 校验并启动 Nginx
nginx -t
nginx -g "daemon on;"

# 6. 前台拉起 ttyd 终端
echo "[$(date)] Starting ttyd on 127.0.0.1:7681..."
exec ttyd -W -p 7681 -c "${AUTH_USER}:${AUTH_PASS}" /bin/bash