# ✅ Linux 后台运行配置 - 创建完成

## 📦 项目位置
```
C:\Users\Administrator\.openclaw\workspace\nvidia-to-openai-proxy\linux-deployment\
```

## 📁 已创建的文件（11个）

### 📡 配置文件
| 文件 | 说明 |
|------|------|
| `ecosystem.config.cjs` | PM2 进程管理器配置 ⭐ |
| `nvidia-proxy.service` | Systemd 服务配置 ⭐ |
| `supervisord.conf` | Supervisord 配置 |
| `Dockerfile` | Docker 镜像构建文件 |
| `docker-compose.yml` | Docker Compose 配置 |
| `nginx.conf` | Nginx 反向代理配置 |

### 🛠️ 部署脚本
| 文件 | 说明 |
|------|------|
| `deploy-pm2.sh` | PM2 自动部署脚本 ⭐ |
| `deploy-systemd.sh` | Systemd 自动部署脚本 ⭐ |
| `deploy-docker.sh` | Docker 自动部署脚本 ⭐ |
| `health-check.sh` | 健康检查脚本 |

### 📚 文档文件
| 文件 | 说明 | 字数 |
|------|------|------|
| `README.md` | 详细部署指南 | 6200 |
| `QUICK_START.md` | 快速开始 | 5000 |

---

## 🚀 3 种推荐方案

### ⭐ 方案 1：PM2（推荐 - 最简单）

#### 优势
- ✅ 最简单易用
- ✅ 功能强大
- ✅ 监控面板
- ✅ 适合开发/中小项目

#### 快速开始
```bash
# 1. 安装 PM2
npm install -g pm2

# 2. 运行部署脚本
sudo bash linux-deployment/deploy-pm2.sh

# 3. 验证
pm2 status
pm2 logs nvidia-proxy
curl http://localhost:3000/health
```

#### 常用命令
```bash
pm2 status              # 查看状态
pm2 logs nvidia-proxy    # 查看日志
pm2 restart nvidia-proxy # 重启
pm2 stop nvidia-proxy    # 停止
pm2 monit                # 监控面板
```

---

### ⭐ 方案 2：Systemd（推荐 - 最稳定）

#### 优势
- ✅ 最稳定可靠
- ✅ Linux 原生
- ✅ 开机自启
- ✅ 适合生产环境

#### 快速开始
```bash
# 1. 运行部署脚本
sudo bash linux-deployment/deploy-systemd.sh

# 2. 验证
sudo systemctl status nvidia-proxy
sudo journalctl -u nvidia-proxy -f
curl http://localhost:3000/health
```

#### 常用命令
```bash
sudo systemctl status nvidia-proxy      # 查看状态
sudo systemctl start nvidia-proxy       # 启动
sudo systemctl stop nvidia-proxy        # 停止
sudo systemctl restart nvidia-proxy    # 重启
sudo journalctl -u nvidia-proxy -f      # 查看日志
```

---

### 方案 3：Docker（推荐 - 最灵活）

#### 优势
- ✅ 容器化部署
- ✅ 环境隔离
- ✅ 易于迁移
- ✅ 适合多环境

#### 快速开始
```bash
# 1. 运行部署脚本
bash linux-deployment/deploy-docker.sh

# 2. 验证
docker-compose ps
docker-compose logs -f
curl http://localhost:3000/health
```

#### 常用命令
```bash
docker-compose ps              # 查看状态
docker-compose logs -f         # 查看日志
docker-compose restart         # 重启
docker-compose stop           # 停止
docker-compose down           # 停止并删除
```

---

## 📋 部署步骤（通用）

### 1. 准备服务器
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证
node --version  # 应为 v18.x.x
npm --version   # 应为 9.x.x
```

### 2. 上传文件到服务器
```bash
# 在本地打包（Windows）
# 进入项目目录，打 tar 包

# 上传到服务器（使用 scp 或其他工具）
scp nvidia-proxy.tar.gz user@your-server:/opt/

# 在服务器上解压
ssh user@your-server
cd /opt
tar -xzf nvidia-proxy.tar.gz
cd nvidia-to-openai-proxy
```

### 3. 配置环境变量
```bash
# 编辑 .env 文件
nano .env

# 设置你的 NVIDIA_API_KEY
NVIDIA_API_KEY=your-nvidia-api-key-here
PORT=3000
```

### 4. 运行部署脚本

**选择一种方案：**

```bash
# PM2 方案（推荐）
chmod +x linux-deployment/deploy-pm2.sh
sudo bash linux-deployment/deploy-pm2.sh

# 或 Systemd 方案
chmod +x linux-deployment/deploy-systemd.sh
sudo bash linux-deployment/deploy-systemd.sh

# 或 Docker 方案
chmod +x linux-deployment/deploy-docker.sh
bash linux-deployment/deploy-docker.sh
```

### 5. 验证部署
```bash
# 健康检查
curl http://localhost:3000/health

# 应该返回：
# {"status":"ok","service":"NVIDIA to OpenAI Proxy",...}
```

---

## 🔧 高级配置

### 配置 Nginx 反向代理
```bash
# 复制配置
sudo cp linux-deployment/nginx.conf /etc/nginx/sites-available/nvidia-proxy

# 创建软链接
sudo ln -s /etc/nginx/sites-available/nvidia-proxy /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx
```

访问：`http://your-domain.com`

### 配置 HTTPS（Let's Encrypt）
```bash
# 安装 Certbot
sudo apt-get install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo certbot renew --dry-run
```

### 配置防火墙
```bash
# UFW（Ubuntu）
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow from 127.0.0.1 to any port 3000
sudo ufw deny 3000

# firewalld（CentOS）
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="127.0.0.1" port protocol="tcp" port="3000" accept'
sudo firewall-cmd --reload
```

---

## 🔍 监控和维护

### 健康检查
```bash
# 自动健康检查脚本
chmod +x linux-deployment/health-check.sh

# 手动运行
bash linux-deployment/health-check.sh

# 添加到 cron（每 5 分钟）
crontab -e
# 添加：*/5 * * * * /opt/nvidia-to-openai-proxy/linux-deployment/health-check.sh
```

### 日志管理
```bash
# PM2
pm2 logs nvidia-proxy --lines 100
pm2 flush

# Systemd
sudo journalctl -u nvidia-proxy -n 100
sudo journalctl --vacuum-time=7d

# Docker
docker-compose logs -f
docker-compose logs --tail=100
```

### 性能监控
```bash
# PM2 监控面板
pm2 monit

# 系统资源
htop

# 查看进程
ps aux | grep node

# 查看端口
netstat -tlnp | grep 3000
```

---

## 🛠️ 故障排除

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
```

**Docker:**
```bash
docker-compose logs
docker-compose restart
```

### 端口被占用
```bash
# 查看
netstat -tlnp | grep 3000

# 更换端口
# 编辑 .env: PORT=3001
```

### 权限问题
```bash
# PM2
pm2 restart nvidia-proxy

# Systemd
sudo chown -R nvidia-proxy:nvidia-proxy /opt/nvidia-to-openai-proxy
sudo systemctl restart nvidia-proxy
```

---

## 📊 方案对比

| 特性 | PM2 | Systemd | Docker |
|------|-----|---------|--------|
| **简单度** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **稳定性** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **资源占用** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **维护性** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **推荐场景** | 开发/中小型项目 | 生产环境 | 容器化/多环境 |

---

## 📞 使用建议

### 推荐 PM2 如果：
- ✅ 你是新手
- ✅ 需要快速部署
- ✅ 开发或中小型项目
- ✅ 需要监控面板

### 推荐 Systemd 如果：
- ✅ 生产环境
- ✅ 需要最高稳定性
- ✅ 大型项目
- ✅ 长期运行

### 推荐 Docker 如果：
- ✅ 需要容器化
- ✅ 多环境部署
- ✅ 需要环境隔离
- ✅ 微服务架构

---

## 📖 文档导航

### 想要...
- 📖 **详细了解** → README.md
- 🚀 **快速开始** → QUICK_START.md
- 🔍 **故障排除** → 各文档中的"故障排除"部分

---

## ✅ 检查清单

### 部署前
- [ ] Node.js v18+ 已安装
- [ ] NVIDIA_API_KEY 已设置
- [ ] 文件已上传到服务器
- [ ] 端口 3000 未被占用

### 部署后
- [ ] 服务已启动
- [ ] 健康检查通过
- [ ] 开机自启已配置
- [ ] 日志正常

---

## 🎉 完成！

现在你可以在 Linux 服务器上后台运行 NVIDIA 代理服务器了！

**选择方案并开始部署：**
1. PM2 → `sudo bash linux-deployment/deploy-pm2.sh`
2. Systemd → `sudo bash linux-deployment/deploy-systemd.sh`
3. Docker → `bash linux-deployment/deploy-docker.sh`

祝部署顺利！🚀

---

**创建者**：2B 🤖
**最后更新**：2026-03-11
**文件总数**：11 个
**文档字数**：11,200+
