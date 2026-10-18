#!/bin/bash
set -e

PORT="${PORT:-10000}"
AUTH_USER="${SHELL_USER:-admin}"
AUTH_PASS="${SHELL_PASS:-RenderShell@2026}"

# 1. 启动后台自定义脚本
if [ -f "/root/my_script.sh" ]; then
    echo "[$(date)] Starting background task..."
    nohup /root/my_script.sh > /root/my_script.log 2>&1 &
fi

# 2. 生成 Nginx 动态路由配置
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen ${PORT};
    server_name _;

    # 外部专属 health 接口：无需鉴权，直接返回 200 OK 与运行状态
    location /health {
        default_type application/json;
        return 200 '{"status":"ok","uptime":"running"}';
    }

    # 根路径：全功能代理到内网 ttyd，并完整支持 WebSocket
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

# 启动 Nginx 反向代理
nginx -g "daemon on;"

# 3. 启动 ttyd 监听本地回路端口 7681
echo "[$(date)] Starting ttyd on 127.0.0.1:7681, Nginx listening on port $PORT..."
exec ttyd -W -p 7681 -c "${AUTH_USER}:${AUTH_PASS}" /bin/bash