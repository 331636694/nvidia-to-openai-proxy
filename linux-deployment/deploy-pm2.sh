#!/bin/bash
# 部署脚本 - PM2 方案

set -e

echo "======================================"
echo "NVIDIA Proxy Server 部署脚本"
echo "======================================"
echo

# 配置
APP_DIR="/opt/nvidia-to-openai-proxy"
SERVICE_NAME="nvidia-proxy"

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本"
    exit 1
fi

echo "[1/6] 检查环境..."

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
echo "[2/6] 创建应用目录..."

# 创建目录
mkdir -p $APP_DIR/logs
mkdir -p $APP_DIR/linux-deployment

echo "[3/6] 安装 PM2..."

# 安装 PM2
npm install -g pm2

echo "[4/6] 复制文件..."

# 复制文件（假设从当前目录运行）
cp server.js $APP_DIR/
cp package.json $APP_DIR/
cp ecosystem.config.cjs $APP_DIR/
cp .env $APP_DIR/ 2>/dev/null || echo "警告: .env 文件不存在"

# 安装依赖
cd $APP_DIR
npm install --only=production

echo "[5/6] 启动服务..."

# 启动服务
pm2 start ecosystem.config.cjs --env production

# 保存 PM2 配置
pm2 save

# 设置开机自启
pm2 startup systemd -u root --hp /root

echo
echo "[6/6] 配置防火墙..."

# 配置防火墙（可选）
if command -v ufw &> /dev/null; then
    echo "检测到 UFW 防火墙"
    read -p "是否配置防火墙规则？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ufw allow from 127.0.0.1 to any port 3000
        echo "已允许本地访问端口 3000"
    fi
fi

echo
echo "======================================"
echo "部署完成！"
echo "======================================"
echo
echo "服务状态:"
pm2 status $SERVICE_NAME

echo
echo "常用命令:"
echo "  查看日志: pm2 logs $SERVICE_NAME"
echo "  停止服务: pm2 stop $SERVICE_NAME"
echo "  重启服务: pm2 restart $SERVICE_NAME"
echo "  监控面板: pm2 monit"
echo
echo "健康检查:"
echo "  curl http://localhost:3000/health"
echo
