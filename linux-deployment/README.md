# Linux 后台运行配置

本目录包含在 Linux 服务器上后台运行 NVIDIA 代理服务器的配置和脚本。

---

## 🚀 快速开始

### 推荐方案：PM2（最简单）

```bash
# 安装 PM2
npm install -g pm2

# 启动服务
pm2 start ecosystem.config.cjs

# 查看状态
pm2 status

# 查看日志
pm2 logs nvidia-proxy

# 停止服务
pm2 stop nvidia-proxy

# 重启服务
pm2 restart nvidia-proxy
```

---

## 📁 配置文件

### 1. PM2 配置
**文件**: `ecosystem.config.cjs`

PM2 是 Node.js 进程管理器，推荐用于生产环境。

### 2. Systemd 服务
**文件**: `nvidia-proxy.service`

Linux 原生服务管理器，更稳定，适合长期运行。

### 3. Supervisord 配置
**文件**: `supervisord.conf`

Python 编写的进程管理器，跨平台兼容性好。

### 4. Docker 配置
**文件**: `Dockerfile`, `docker-compose.yml`

容器化部署，便于迁移和管理。

---

## 🔧 使用不同方案

---

## 方案 1：PM2（推荐）

### 安装 PM2
```bash
npm install -g pm2
pm2 startup
# 按提示执行生成的命令
```

### 启动服务
```bash
cd /path/to/nvidia-to-openai-proxy
pm2 start ecosystem.config.cjs
pm2 save
```

### 常用命令
```bash
pm2 status              # 查看所有进程
pm2 logs nvidia-proxy    # 查看日志
pm2 logs nvidia-proxy --lines 100  # 查看最近 100 行
pm2 restart nvidia-proxy # 重启
pm2 stop nvidia-proxy    # 停止
pm2 delete nvidia-proxy  # 删除
pm2 monit                # 监控面板
pm2 info nvidia-proxy    # 详细信息
```

### PM2 开机自启
```bash
pm2 startup
pm2 save
# 按提示执行生成的命令
```

---

## 方案 2：Systemd 服务

### 安装服务
```bash
# 复制服务文件
sudo cp nvidia-proxy.service /etc/systemd/system/

# 编辑服务文件，修改路径
sudo nano /etc/systemd/system/nvidia-proxy.service
# 修改 WorkingDirectory 和 ExecStart 中的路径

# 重载 systemd
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start nvidia-proxy

# 设置开机自启
sudo systemctl enable nvidia-proxy
```

### 常用命令
```bash
sudo systemctl status nvidia-proxy     # 查看状态
sudo systemctl start nvidia-proxy      # 启动
sudo systemctl stop nvidia-proxy       # 停止
sudo systemctl restart nvidia-proxy    # 重启
sudo journalctl -u nvidia-proxy -f      # 查看日志
sudo journalctl -u nvidia-proxy -n 100  # 查看最近 100 行
```

---

## 方案 3：Supervisord

### 安装 Supervisord
```bash
# Ubuntu/Debian
sudo apt-get install supervisor

# CentOS/RHEL
sudo yum install supervisor

# 启动 supervisord
sudo systemctl start supervisord
sudo systemctl enable supervisord
```

### 配置服务
```bash
# 复制配置文件
sudo cp supervisord.conf /etc/supervisor/conf.d/nvidia-proxy.conf

# 编辑配置文件，修改路径
sudo nano /etc/supervisor/conf.d/nvidia-proxy.conf

# 重载配置
sudo supervisorctl reread
sudo supervisorctl update

# 启动服务
sudo supervisorctl start nvidia-proxy
```

### 常用命令
```bash
sudo supervisorctl status           # 查看状态
sudo supervisorctl start nvidia-proxy   # 启动
sudo supervisorctl stop nvidia-proxy    # 停止
sudo supervisorctl restart nvidia-proxy # 重启
sudo supervisorctl tail nvidia-proxy    # 查看日志
```

---

## 方案 4：Docker

### 构建镜像
```bash
docker build -t nvidia-proxy .
```

### 运行容器
```bash
docker run -d \
  --name nvidia-proxy \
  -p 3000:3000 \
  -e NVIDIA_API_KEY=your-api-key \
  -e PORT=3000 \
  nvidia-proxy
```

### 使用 Docker Compose
```bash
# 启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止
docker-compose down

# 重启
docker-compose restart
```

---

## 📊 性监控

### PM2 监控
```bash
pm2 monit
```

### 系统监控
```bash
# 查看进程
ps aux | grep node

# 查看端口
netstat -tlnp | grep 3000
# 或
lsof -i :3000

# 查看 CPU/内存
top -p $(pgrep -f "node server.js")

# 查看日志文件大小
du -sh logs/
```

---

## 📝 日志管理

### PM2 日志轮转
PM2 默认会轮转日志，但你可以配置：

```javascript
// ecosystem.config.cjs
module.exports = {
  apps: [{
    name: 'nvidia-proxy',
    error_file: './logs/error.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    max_memory_restart: '1G'
  }]
}
```

### 清理日志
```bash
# PM2
pm2 flush

# 手动清理
rm -rf logs/*
```

---

## 🔍 健康检查

### 健康检查脚本
```bash
#!/bin/bash

URL="http://localhost:3000/health"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ $RESPONSE -eq 200 ]; then
    echo "✅ 服务正常运行"
    exit 0
else
    echo "❌ 服务异常 (HTTP $RESPONSE)"
    exit 1
fi
```

### 自动重启脚本（cron）
```bash
# 每 5 分钟检查一次
*/5 * * * * /path/to/scripts/health-check.sh
```

---

## 🌐 反向代理（Nginx）

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## 🛡️ 安全建议

1. **防火墙规则**
```bash
# 只允许本地访问
sudo ufw deny 3000
sudo ufw allow from 127.0.0.1 to any port 3000

# 或允许特定 IP
sudo ufw allow from 192.168.1.0/24 to any port 3000
```

2. **使用 HTTPS（via Nginx）**
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

3. **环境变量保护**
```bash
# 不要将 .env 文件提交到 git
echo ".env" >> .gitignore

# 设置正确权限
chmod 600 .env
```

---

## 🚨 故障排除

### 服务无法启动
```bash
# 查看详细日志
pm2 logs nvidia-proxy --err

# 检查端口占用
netstat -tlnp | grep 3000

# 检查 Node.js 版本
node --version

# 检查依赖
npm ls
```

### 服务频繁重启
```bash
# 查看重启原因
pm2 logs nvidia-proxy --lines 50

# 检查内存限制
pm2 info nvidia-proxy

# 调整配置
# 在 ecosystem.config.cjs 中增加内存限制
max_memory_restart: '2G'
```

### 性能问题
```bash
# 增加实例数）
pm2 ecosystem.config.cjs
# 修改 instances: 1 → instances: 'max'
```

---

## 📊 监控告警

### 简单监控脚本
```bash
#!/bin/bash
# scripts/monitor.sh

URL="http://localhost:3000/health"
LOG_FILE="/var/log/nvidia-proxy-monitor.log"

while true; do
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

    if [ $RESPONSE -ne 200 ]; then
        echo "[$(date)] 服务异常，尝试重启..." >> $LOG_FILE
        pm2 restart nvidia-proxy
    fi

    sleep 60
done
```

---

## 🎯 推荐配置

### 开发环境
```bash
# 使用 PM2，无需开机自启
pm2 start ecosystem.config.cjs --env development
```

### 生产环境
```bash
# 使用 PM2 + 开机自启
pm2 start ecosystem.config.cjs --env production
pm2 save
pm2 startup
```

### 企业环境
```bash
# 使用 Systemd 或 Docker
sudo systemctl start nvidia-proxy
docker-compose up -d
```

---

## 📞 获取帮助

查看日志文件定位问题：
- PM2: `pm2 logs nvidia-proxy`
- Systemd: `sudo journalctl -u nvidia-proxy -f`
- Docker: `docker-compose logs -f`
- Supervisord: `sudo supervisorctl tail nvidia-proxy`

---

**选择方案指南：**
- 简单快速 → PM2
- 稳定可靠 → Systemd
- 跨平台 → Supervisord
- 容器化 → Docker
