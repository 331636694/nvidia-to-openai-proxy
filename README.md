# NVIDIA to OpenAI Proxy Server

将 NVIDIA API 转换为标准 OpenAI 格式的代理服务器，让你可以用任何支持 OpenAI API 的工具和库调用 NVIDIA 的模型。

## 🚀 功能特性

- ✅ **完全兼容 OpenAI API 格式** - 可直接使用 OpenAI SDK
- ✅ **支持所有 NVIDIA 模型** - Llama、Qwen、DeepSeek、GLM 等
- ✅ **本地代理** - 无需暴露 NVIDIA API Key
- ✅ **流式响应支持** - 实时获取 AI 回复
- ✅ **多语言支持** - Node.js 和 Python 示例
- ✅ **健康检查** - 服务器状态监控
- ✅ **模型列表** - 动态获取可用模型

## 📦 安装

### 1. 克隆或下载项目

```bash
cd nvidia-to-openai-proxy
```

### 2. 安装依赖

```bash
npm install
```

## ⚙️ 配置

### 方法 1: 使用环境变量（推荐）

编辑 `.env` 文件：

```env
NVIDIA_API_KEY=your-nvidia-api-key
PORT=3000
```

### 方法 2: 直接修改 server.js

在 `server.js` 中修改配置：

```javascript
const config = {
  nvidiaBaseUrl: 'https://integrate.api.nvidia.com',
  nvidiaApiKey: 'your-nvidia-api-key',
  port: 3000
};
```

## 🏃 运行

### 启动代理服务器

```bash
npm start
```

或使用 npm scripts：

```bash
# 开发模式
npm run dev

# 生产模式（可以结合 PM2）
npm start
```

### 启动成功输出

```
============================================================
NVIDIA to OpenAI Proxy Server Started!
============================================================
Server running at: http://localhost:3000
Health check: http://localhost:3000/health
Chat API: http://localhost:3000/v1/chat/completions
Models: http://localhost:3000/v1/models
============================================================
```

## 📚 API 端点

### 1. 健康检查

```bash
GET http://localhost:3000/health
```

### 2. 列出可用模型

```bash
GET http://localhost:3000/v1/models
```

响应格式：
```json
{
  "object": "list",
  "data": [
    {
      "id": "z-ai/glm-4.7",
      "object": "model",
      "created": 1677610602,
      "owned_by": "nvidia"
    }
  ]
}
```

### 3. 聊天完成（核心端点）

```bash
POST http://localhost:3000/v1/chat/completions
```

请求格式（标准 OpenAI 格式）：
```json
{
  "model": "z-ai/glm-4.7",
  "messages": [
    {
      "role": "system",
      "content": "你是一个有用的AI助手。"
    },
    {
      "role": "user",
      "content": "你好！"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 1000,
  "top_p": 0.9
}
```

响应格式：
```json
{
  "id": "chatcmpl-xxx",
  "object": "chat.completion",
  "created": 1234567890,
  "model": "z-ai/glm-4.7",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "你好！我是AI助手，有什么可以帮助你的吗？"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 20,
    "completion_tokens": 15,
    "total_tokens": 35
  }
}
```

## 💻 使用示例

### Node.js 示例

#### 基本使用

```javascript
const http = require('http');

const data = {
  model: 'z-ai/glm-4.7',
  messages: [
    { role: 'user', content: '你好！' }
  ]
};

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/v1/chat/completions',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer your-api-key'
  }
};

const req = http.request(options, (res) => {
  let data = '';
  res.on('data', (chunk) => data += chunk);
  res.on('end', () => {
    const response = JSON.parse(data);
    console.log(response.choices[0].message.content);
  });
});

req.write(JSON.stringify(data));
req.end();
```

#### 使用内置示例

```bash
# 运行所有示例
node example.js
```

### Python 示例

#### 基本使用（使用 requests）

```python
import requests

url = "http://localhost:3000/v1/chat/completions"
headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer your-api-key"
}

data = {
    "model": "z-ai/glm-4.7",
    "messages": [
        {"role": "user", "content": "你好！"}
    ]
}

response = requests.post(url, headers=headers, json=data)
result = response.json()
print(result['choices'][0]['message']['content'])
```

#### 使用官方 OpenAI SDK

```python
from openai import OpenAI

# 连接到本地代理
client = OpenAI(
    base_url="http://localhost:3000",
    api_key="your-api-key"
)

# 像使用 OpenAI API 一样使用
response = client.chat.completions.create(
    model="z-ai/glm-4.7",
    messages=[
        {"role": "user", "content": "你好！"}
    ]
)

print(response.choices[0].message.content)
```

#### 运行 Python 示例

```bash
# 安装依赖
pip install requests

# 运行示例
python example.py
```

## 🤖 可用模型

### GLM 系列
- `z-ai/glm-4.7` - GLM 4.7（推荐）
- `z-ai/glm-5` - GLM 5

### Llama 系列
- `meta/llama-3.1-405b-instruct` - Llama 3.1 405B
- `meta/llama-3.1-70b-instruct` - Llama 3.1 70B
- `meta/llama-3.1-8b-instruct` - Llama 3.1 8B

### DeepSeek 系列
- `deepseek-ai/deepseek-r1` - DeepSeek R1（推理模型）
- `deepseek-ai/deepseek-v3` - DeepSeek V3

### Qwen 系列
- `qwen/qwen2.5-72b-instruct` - Qwen 2.5 72B
- `qwen/qwen2.5-7b-instruct` - Qwen 2.5 7B

### 其他模型
- `google/gemma-2-27b-it` - Gemma 2 27B
- `google/gemma-2-9b-it` - Gemma 2 9B
- `mistralai/mistral-large` - Mistral Large
- `minimaxai/minimax-m2.5` - MiniMax M2.5
- `microsoft/phi-3-medium-128k-instruct` - Phi-3 Medium
- `microsoft/phi-3-mini-128k-instruct` - Phi-3 Mini

## 🔧 高级配置

### 自定义端口

修改环境变量：
```env
PORT=8080
```

或命令行：
```bash
PORT=8080 npm start
```

### 使用 PM2 保持运行

```bash
# 安装 PM2
npm install -g pm2

# 启动服务
pm2 start server.js --name nvidia-proxy

# 查看状态
pm2 status

# 查看日志
pm2 logs nvidia-proxy

# 重启
pm2 restart nvidia-proxy

# 停止
pm2 stop nvidia-proxy
```

### Windows 服务（使用 node-windows）

```bash
npm install -g node-windows

# 创建服务
node-windows-service start --name "NVIDIA Proxy" --script server.js
```

## 🛠️ 故障排除

### 1. 无法连接到服务器

检查端口是否被占用：
```bash
# Windows
netstat -ano | findstr :3000

# Linux/Mac
lsof -i :3000
```

### 2. NVIDIA API 错误

- 确认 API Key 正确
- 检查配额是否用完
- 访问 https://build.nvidia.com/ 查看状态

### 3. 请求超时

检查网络连接，确认能访问 NVIDIA API：
```bash
ping integrate.api.nvidia.com
```

## 📝 开发

### 项目结构

```
nvidia-to-openai-proxy/
├── server.js          # 主服务器文件
├── example.js         # Node.js 示例
├── example.py         # Python 示例
├── package.json       # Node.js 依赖
├── .env              # 环境变量配置
└── README.md         # 本文档
```

### 添加新功能

1. 编辑 `server.js`
2. 重启服务：`npm start`
3. 测试新功能

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 🔗 相关链接

- [NVIDIA API 文档](https://build.nvidia.com/explore/discover)
- [OpenAI API 文档](https://platform.openai.com/docs/api-reference)
- [NVIDIA 模型列表](https://build.nvidia.com/models)

## 📧 联系

如有问题，请提交 Issue 或联系作者。

---

**作者**：2B 🤖
**最后更新**：2026-03-11
**版本**：1.0.0
