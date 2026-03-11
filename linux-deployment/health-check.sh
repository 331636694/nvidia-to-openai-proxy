#!/bin/bash
# 健康检查脚本

URL="http://localhost:3000/health"
LOG_FILE="/var/log/nvidia-proxy-health-check.log"
NVIDIA_PROXY_USER="nvidia-proxy"  # PM2 使用当前用户，systemd 使用 nvidia-proxy

# 创建日志目录
mkdir -p $(dirname $LOG_FILE)
touch $LOG_FILE

# 检查 URL 是否可访问
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null) || RESPONSE="000"

# 获取当前时间
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$RESPONSE" = "200" ]; then
    # 服务正常
    echo "[$TIMESTAMP] ✅ 服务正常 (HTTP 200)" >> $LOG_FILE
    exit 0
else
    # 服务异常
    echo "[$TIMESTAMP] ❌ 服务异常 (HTTP $RESPONSE)" >> $LOG_FILE

    # 尝试重启服务
    echo "[$TIMESTAMP] 尝试重启服务..." >> $LOG_FILE

    # PM2 方式
    if command -v pm2 &> /dev/null && pm2 ls | grep -q "nvidia-proxy"; then
        pm2 restart nvidia-proxy >> $LOG_FILE 2>&1
        echo "[$TIMESTAMP] 使用 PM2 重启" >> $LOG_FILE
    # Systemd 方式
    elif systemctl is-active --quiet nvidia-proxy; then
        systemctl restart nvidia-proxy >> $LOG_FILE 2>&1
        echo "[$TIMESTAMP] 使用 Systemd 重启" >> $LOG_FILE
    # Supervisord 方式
    elif command -v supervisorctl &> /dev/null; then
        supervisorctl restart nvidia-proxy >> $LOG_FILE 2>&1
        echo "[$TIMESTAMP] 使用 Supervisord 重启" >> $LOG_FILE
    else
        echo "[$TIMESTAMP] 未找到有效的进程管理器" >> $LOG_FILE
    fi

    exit 1
fi
