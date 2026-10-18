#!/bin/bash
set -e

# Render 或其他 PaaS 会自动注入 PORT 环境变量，默认兜底 10000
PORT="${PORT:-10000}"

# Web 终端认证凭据（优先读取环境变量，避免硬编码泄露）
AUTH_USER="${SHELL_USER:-admin}"
AUTH_PASS="${SHELL_PASS:-RenderShell@2026}"

echo "=========================================="
echo " Starting Web Shell Container "
echo " Listening on Port: $PORT"
echo " Auth User: $AUTH_USER"
echo "=========================================="

# 1. 后台拉起自定义常驻自动化脚本（日志重定向至文件，防止阻塞主进程）
if [ -f "/root/my_script.sh" ]; then
    echo "[Init] Launching /root/my_script.sh in background..."
    nohup /root/my_script.sh > /root/my_script.log 2>&1 &
fi

# 2. 前台启动 ttyd，绑定 Render 端口并启用 HTTP 账号密码鉴权
echo "[Init] Launching ttyd Web Shell interface..."
exec ttyd -W -p "$PORT" -c "${AUTH_USER}:${AUTH_PASS}" /bin/bash
