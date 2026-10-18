#!/bin/bash
# 自定义常驻后台任务脚本模版
echo "[$(date)] Task script started. Initial uptime: $(uptime -p)" >> /root/task_status.log

while true; do
    echo "[$(date)] Web Shell daemon is alive | Uptime: $(uptime -p)" >> /root/task_status.log
    sleep 300
done
