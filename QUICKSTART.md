# 🚀 快速开始指南

## 1️⃣ 安装依赖

### Node.js 依赖（必需）
```bash
cd nvidia-to-openai-proxy
npm install
```

### Python 依赖（可选）
```bash
pip install -r requirements.txt
```

## 2️⃣ 配置 API Key

编辑 `.env` 文件，填入你的 NVIDIA API Key：
```env
NVIDIA_API_KEY=your-nvidia-api-key-here
PORT=3000
```

## 3️⃣ 启动服务器

### Windows
双击运行 `start.bat`

或者命令行：
```bash
npm start
```

### Linux/Mac
```bash
npm start
```

## 4️⃣ 测试服务器

### Windows
双击运行 `test.bat`

或者命令行：
```bash
curl http://localhost:3000/health
```

## 5️⃣ 开始使用

### Node.js
```bash
node example.js
```

### Python
```bash
python example.py
```

### API 调用
```bash
curl -X POST http://localhost:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-key" \
  -d '{
    "model": "z-ai/glm-4.7",
    "messages": [{"role": "user", "content": "你好！"}]
  }'
```

## 📚 更多使用方式

 查看 `README.md` 获取详细文档和更多示例！

## ✅ 检查清单

- [ ] 安装了 Node.js
- [ ] 运行了 `npm install`
- [ ] 配置了 `.env` 文件中的 API Key
- [ ] 启动了服务器
- [ ] 运行了测试
- [ ] 开始使用 API

## 🆘 常见问题

### Q: 服务器无法启动？
A: 检查 3000 端口是否被占用，修改 `.env` 中的 PORT 变量。

### Q: API 调用失败？
A: 确认 NVIDIA API Key 正确，并且配额充足。

### Q: 如何更换端口？
A: 修改 `.env` 文件中的 `PORT` 变量并重启服务器。

## 📞 需要帮助？

查看 `README.md` 获取更多信息和故障排除指南。
