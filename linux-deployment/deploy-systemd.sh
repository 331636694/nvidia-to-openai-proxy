#!/bin/bash
# 部署脚本 - Systemd 方案

set -e

echo "======================================"
echo "NVIDIA Proxy Server 部署脚本"
echo "======================================"
echo

# 配置
APP_DIR="/opt/nvidia-to-openai-proxy"
SERVICE_NAME="nvidia-proxy"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本"
    exit 1
fi

echo "[1/7] 检查环境..."

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "错误: Node.js 未安装"
    echo "请运行: curl -fsSL https://deb.nodesource.com/setup_18.x | bash -"
    exit 1
fi

echo "Node.js 版本: $(node --version)"

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo "错误: npm 未安装"
    exit 1
fi

echo "npm 版本: $(npm --version)"

echo
echo "[2/7] 创建用户和目录..."

# 创建用户
if ! id "$SERVICE_NAME" &>/dev/null; then
    useradd -r -s /bin/false $SERVICE_NAME
    echo "用户 $SERVICE_NAME 已创建"
fi

# 创建目录
mkdir -p $APP_DIR
mkdir -p $APP_DIR/logs

# 设置权限
chown -R $SERVICE_NAME:$SERVICE_NAME $APP_DIR

echo "[3/7] 复制文件..."

# 复制文件
cp server.js $APP_DIR/
cp package.json $APP_DIR/
cp .env $APP_DIR/ 2>/dev/null || echo "警告: .env 文件不存在"

echo "[4/7] 安装依赖..."

# 切换用户安装依赖
sudo -u $SERVICE_NAME bash -c "
    cd $APP_DIR && \
    npm install --only=production
"

echo "[5/7] 安装 Systemd 服务..."

# 复制服务文件
cp ${SERVICE_NAME}.service $SERVICE_FILE

# 替换路径（如果需要）
sed -i "s|/opt/nvidia-to-openai-proxy|$APP_DIR|g" $SERVICE_FILE

# 创建 .env 文件如果不存在
if [ ! -f "$APP_DIR/.env" ]; then
    echo "警告: 需要在 $APP_DIR/.env 中设置 NVIDIA_API_KEY"
fi

echo "[6/7] 启动服务..."

# 重载 systemd
systemctl daemon-reload

# 启用服务
systemctl enable $SERVICE_NAME

# 启动服务
systemctl start $SERVICE_NAME

# 等待启动
sleep 3

echo "[7/7] 验证服务..."

# 检查服务状态
if systemctl is-active --quiet $SERVICE_NAME; then
    echo "✅ 服务启动成功"
else
    echo "❌ 服务启动失败"
    echo "查看日志: journalctl -u $SERVICE_NAME -n 50"
    exit 1
fi

echo
echo "======================================"
echo "部署完成！"
echo "======================================"
echo
echo "服务状态:"
systemctl status $SERVICE_NAME --no-pager

echo
echo "常用命令:"
echo "  查看状态: sudo systemctl status $SERVICE_NAME"
echo "  停止服务: sudo systemctl stop $SERVICE_NAME"
echo "  启动服务: sudo systemctl start $SERVICE_NAME"
echo "  重启服务: sudo systemctl restart $SERVICE_NAME"
echo "  查看日志: sudo journalctl -u $SERVICE_NAME -f"
echo
echo "健康检查:"
echo "  curl http://localhost:3000/health"
echo
