# 🚀 Linux 快速部署

## 方案选择

| 方案 | 简单度 | 稳定性 | 推荐场景 |
|------|--------|--------|----------|
| **PM2** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 开发/中小型项目 ⭐ |
| **Systemd** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 生产环境/大型项目 |
| **Docker** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 容器化/多环境 |
| **Supervisord** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 跨平台 |

---

## ⚡ 快速开始（推荐：PM2）

### 1. 准备服务器
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证安装
node --version  # v18.x.x
npm --version   # 9.x.x
```

### 2. 上传文件
```bash
# 在本地打包
cd nvidia-to-openai-proxy
tar -czf nvidia-proxy.tar.gz .

# 上传到服务器
scp nvidia-proxy.tar.gz user@your-server:/opt/

# 在服务器上解压
ssh user@your-server
cd /opt
tar -xzf nvidia-proxy.tar.gz
cd nvidia-to-openai-proxy
```

### 3. 配置环境变量
```bash
# 复制示例配置
cp .env.example .env

# 编辑配置
nano .env

# 设置 NVIDIA_API_KEY
NVIDIA_API_KEY=your-nvidia-api-key-here
PORT=3000
```

### 4. 安装依赖
```bash
npm install --only=production
```

### 5. 启动服务
```bash
# 给脚本执行权限
chmod +x linux-deployment/deploy-pm2.sh

# 运行部署脚本
sudo bash linux-deployment/deploy-pm2.sh
```

### 6. 验证
```bash
# 检查状态
pm2 status

# 查看日志
pm2 logs nvidia-proxy

# 健康检查
curl http://localhost:3000/health
```

---

## 🔧 方案 2：Systemd（更稳定）

```bash
# 上传文件（同 PM2）
# ...

# 运行部署脚本
chmod +x linux-deployment/deploy-systemd.sh
sudo bash linux-deployment/deploy-systemd.sh

# 验证
sudo systemctl status nvidia-proxy
sudo journalctl -u nvidia-proxy -f
curl http://localhost:3000/health
```

---

## 🐳 方案 3：Docker（容器化）

### 安装 Docker
```bash
# Ubuntu/Debian
sudo apt-get install docker.io docker-compose

# 启动 Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 部署
```bash
# 上传文件
# ...

# 运行部署脚本
chmod +x linux-deployment/deploy-docker.sh
bash linux-deployment/deploy-docker.sh

# 验证
docker-compose ps
docker-compose logs -f
curl http://localhost:3000/health
```

---

## 📋 部署检查清单

### 部署前
- [ ] Node.js 已安装（v18+）
- [ ] npm 已安装
- [ ] NVIDIA_API_KEY 已获取
- [ ] 文件已上传到服务器
- [ ] 端口 3000 未被占用

### 部署后
- [ ] 服务已启动
- [ ] 健康检查通过 (curl localhost:3000/health)
- [ ] 日志正常
- [ ] 开机自启已配置

### 安全配置
- [ ] 防火墙已配置（只允许必要端口）
- [ ] 非 root 用户运行
- [ ] 日志轮转已配置
- [ ] 环境变量已保护

---

## 🔍 故障排除

### 服务无法启动

**PM2:**
```bash
pm2 logs nvidia-proxy --err
pm2 restart nvidia-proxy
```

**Systemd:**
```bash
sudo systemctl status nvidia-proxy
sudo journalctl -u nvidia-proxy -n 50
sudo systemctl restart nvidia-proxy
```

**Docker:**
```bash
docker-compose logs
docker-compose restart
```

### 端口被占用
```bash
# 查看占用
netstat -tlnp | grep 3000

# 更换端口
# 修改 .env: PORT=3001
```

### 权限问题
```bash
# PM2
pm2 delete nvidia-proxy
pm2 start ecosystem.config.cjs

# Systemd
sudo chown -R nvidia-proxy:nvidia-proxy /opt/nvidia-to-openai-proxy
sudo systemctl restart nvidia-proxy
```

---

## 📊 监控和维护

### 定期检查
```bash
# 每天检查
curl http://localhost:3000/health

# 查看日志
pm2 logs nvidia-proxy --lines 100

# 检查磁盘空间
df -h

# 检查内存
free -h
```

### 清理日志
```bash
# PM2
pm2 flush

# Systemd
sudo journalctl --vacuum-time=7d

# Docker
docker system prune -a
```

### 备份配置
```bash
# 备份 .env 文件
cp .env .env.backup

# 备份整个项目
tar -czf nvidia-proxy-backup-$(date +%Y%m%d).tar.gz .
```

---

## 🔄 更新服务

### PM2
```bash
# 停止服务
pm2 stop nvidia-proxy

# 更新代码
git pull
# 或上传新文件

# 更新依赖
npm install --only=production

# 启动服务
pm2 start nvidia-proxy

pm2 save
```

### Systemd
```bash
# 停止服务
sudo systemctl stop nvidia-proxy

# 更新代码...

# 更新依赖
npm install --only=production

# 启动服务
sudo systemctl start nvidia-proxy
```

### Docker
```bash
# 重新构建
docker-compose build

# 重启
docker-compose up -d
```

---

## 🌐 配置 Nginx 反向代理（可选）

```bash
# 复制 Nginx 配置
sudo cp linux-deployment/nginx.conf /etc/nginx/sites-available/nvidia-proxy

# 创建软链接
sudo ln -s /etc/nginx/sites-available/nvidia-proxy /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx
```

访问：http://your-domain.com

---

## 🔐 安全建议

### 1. 防火墙配置
```bash
# Ubuntu UFW
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow from 127.0.0.1 to any port 3000
sudo ufw deny 3000

# CentOS firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="127.0.0.1" port protocol="tcp" port="3000" accept'
sudo firewall-cmd --reload
```

### 2. 使用 HTTPS
```bash
# 安装 Certbot
sudo apt-get install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo certbot renew --dry-run
```

### 3. 限制 API 访问
```bash
# 只允许特定 IP 访问
sudo ufw allow from YOUR_IP_ADDRESS to any port 3000
```

---

## 📞 获取帮助

### 日志位置
- **PM2**: `./logs/error.log`, `./logs/out.log`
- **Systemd**: `journalctl -u nvidia-proxy`
- **Docker**: `docker-compose logs`

### 调试命令
```bash
# 查看 Node.js 进程
ps aux | grep node

# 查看端口监听
netstat -tlnp | grep 3000

# 测试连接
curl -v http://localhost:3000/health

# 查看系统资源
top
htop
```

---

**选择方案：**
- 新手/快速部署 → PM2
- 生产环境/长期运行 → Systemd
- 容器化/多环境 → Docker

开始部署吧！🚀
