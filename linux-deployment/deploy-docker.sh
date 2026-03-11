#!/bin/bash
# 部署脚本 - Docker 方案

set -e

echo "======================================"
echo "NVIDIA Proxy Server Docker 部署脚本"
echo "======================================"
echo

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装"
    echo "请访问 https://docs.docker.com/engine/install/ 安装 Docker"
    exit 1
fi

echo "Docker 版本: $(docker --version)"

# 检查 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "错误: Docker Compose 未安装"
    echo "请访问 https://docs.docker.com/compose/install/ 安装 Docker Compose"
    exit 1
fi

echo "Docker Compose 版本: $(docker-compose --version)"

echo
echo "[1/5] 检查配置..."

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo "错误: .env 文件不存在"
    echo "请创建 .env 文件并设置 NVIDIA_API_KEY"
    exit 1
fi

# 读取 NVIDIA_API_KEY
source .env
if [ -z "$NVIDIA_API_KEY" ]; then
    echo "错误: NVIDIA_API_KEY 未设置"
    exit 1
fi

echo "✅ 配置检查通过"

echo
echo "[2/5] 构建 Docker 镜像..."

docker-compose build

echo
echo "[3/5] 启动容器..."

docker-compose up -d

echo
echo "[4/5] 等待服务启动..."

sleep 5

# 检查容器状态
if docker-compose ps | grep -q "Up"; then
    echo "✅ 容器启动成功"
else
    echo "❌ 容器启动失败"
    docker-compose logs
    exit 1
fi

echo
echo "[5/5] 验证服务..."

# 健康检查
MAX_RETRIES=10
RETRY=0

while [ $RETRY -lt $MAX_RETRIES ]; do
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health)
    if [ $RESPONSE -eq 200 ]; then
        echo "✅ 服务健康检查通过"
        break
    fi
    echo "等待服务启动... ($((RETRY + 1))/$MAX_RETRIES)"
    sleep 2
    RETRY=$((RETRY + 1))
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "❌ 服务健康检查失败"
    docker-compose logs
    exit 1
fi

echo
echo "======================================"
echo "部署完成！"
echo "======================================"
echo
echo "容器状态:"
docker-compose ps

echo
echo "常用命令:"
echo "  查看日志: docker-compose logs -f"
echo "  停止服务: docker-compose stop"
echo "  启动服务: docker-compose start"
echo "  重启服务: docker-compose restart"
echo "  停止并删除: docker-compose down"
echo
echo "健康检查:"
echo "  curl http://localhost:3000/health"
echo
echo "查看实时日志:"
echo "  docker-compose logs -f --tail=100"
echo
