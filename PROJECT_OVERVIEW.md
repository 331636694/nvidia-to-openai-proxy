# 📦 NVIDIA 代理服务器 - 项目总览

## 🎯 项目简介

这是一个完整的 NVIDIA API 到 OpenAI 格式的代理服务器，让你可以在任何环境（包括"小龙虾"）中通过标准 OpenAI 接口调用 NVIDIA 模型。

## 📁 项目结构

```
nvidia-to-openai-proxy/
├── server.js                  # 主服务器 - 代理核心逻辑
├── example.js                 # Node.js 使用示例（6个示例）
├── example.py                 # Python 使用示例（7个示例）
├── nvidia-chat.py             # Python CLI 工具（推荐）
├── start.bat                  # Windows 启动脚本
├── test.bat                   # Windows 测试脚本
├── package.json               # Node.js 依赖
├── requirements.txt           # Python 依赖
├── .env                       # 环境变量配置
├── README.md                  # 完整文档（6000+字）
├── QUICKSTART.md              # 快速开始指南
├── INTEGRATION_GUIDE.md       # 完整集成指南（12000+字）
├── QUICK_INTEGRATION.md       # 快速集成脚本
└── README.md                  # 本文档
```

## 🚀 快速开始（3 步）

### 1. 启动服务器
```bash
cd C:\Users\Administrator\.openclaw\workspace\nvidia-to-openai-proxy
npm start
```

### 2. 验证运行
```bash
curl http://localhost:3000/health
```

### 3. 开始使用
```bash
# Python CLI（最简单）
python nvidia-chat.py "你好！"

# Node.js
node example.js

# 或直接调用 API
curl -X POST http://localhost:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"z-ai/glm-4.7","messages":[{"role":"user","content":"你好！"}]}'
```

## 📚 文档指南

| 文档 | 说明 | 适用场景 |
|------|------|----------|
| `README.md` | 完整项目文档 | 了解所有功能和配置 |
| `QUICKSTART.md` | 快速开始指南 | 第一次使用 |
| `INTEGRATION_GUIDE.md` | 完整集成指南 | 在不同环境中集成 |
| `QUICK_INTEGRATION.md` | 快速集成脚本 | 立即开始使用 |

## 🎨 不同环境的集成方式

### 🟢 Python 环境

#### 方式 1: 命令行 CLI（最简单）
```bash
python nvidia-chat.py "你好！"
python nvidia-chat.py --list-models  # 列出模型
python nvidia-chat.py --check        # 检查服务
```

#### 方式 2: 代码集成
```python
import requests

def chat(prompt):
    response = requests.post(
        'http://localhost:3000/v1/chat/completions',
        headers={'Content-Type': 'application/json'},
        json={
            'model': 'z-ai/glm-4.7',
            'messages': [{'role': 'user', 'content': prompt}]
        }
    )
    return response.json()['choices'][0]['message']['content']

# 使用
answer = chat("介绍一下你自己")
print(answer)
```

#### 方式 3: 使用 OpenAI SDK
```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:3000", api_key="your-key")
response = client.chat.completions.create(
    model="z-ai/glm-4.7",
    messages=[{"role": "user", "content": "你好！"}]
)
print(response.choices[0].message.content)
```

### 🔵 Node.js 环境

#### 方式 1: 直接导入
```javascript
const { chatCompletion } = require('./example');

const answer = await chatCompletion(
  'z-ai/glm-4.7',
  [{ role: 'user', content: '你好！' }]
);
```

#### 方式 2: 使用 OpenAI SDK
```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'http://localhost:3000',
  apiKey: 'your-key'
});

const response = await client.chat.completions.create({
  model: 'z-ai/glm-4.7',
  messages: [{ role: 'user', content: '你好！' }]
});
```

### 🌐 Web 前端

```javascript
const response = await fetch('http://localhost:3000/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer your-key'
  },
  body: JSON.stringify({
    model: 'z-ai/glm-4.7',
    messages: [{ role: 'user', content: '你好！' }]
  })
});

const data = await response.json();
console.log(data.choices[0].message.content);
```

### 🤖 AI 框架

**LangChain:**
```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    base_url="http://localhost:3000",
    api_key="your-key",
    model="z-ai/glm-4.7"
)
```

**LlamaIndex:**
```python
from llama_index.llms.openai import OpenAI

llm = OpenAI(
    api_base="http://localhost:3000",
    api_key="your-key",
    model="z-ai/glm-4.7"
)
```

## 🤖 可用模型（24个）

### 推荐模型
- ✨ `z-ai/glm-4.7` - GLM 4.7（最佳平衡）
- ✨ `qwen/qwen2.5-72b-instruct` - Qwen 2.5 72B（大模型）
- ✨ `deepseek-ai/deepseek-v3` - DeepSeek V3（出色性能）

### 完整列表
- **Llama**: 405B、70B、8B
- **DeepSeek**: R1（推理）、V3
- **Qwen**: 72B、7B
- **Gemma**: 27B、9B
- **Mistral**: Large、Mixtral、7B
- **GLM**: 4.7、5
- **其他**: MiniMax、Kimi、Nemotron、Phi-3 等

查看所有模型：
```bash
python nvidia-chat.py --list-models
# 或
curl http://localhost:3000/v1/models
```

## 🔧 配置

### 环境变量（`.env`）
```env
NVIDIA_API_KEY=your-nvidia-api-key
PORT=3000
```

### 在代码中配置
```python
# Python
client = NVIDIAChatCLI(
    base_url="http://localhost:3000",
    api_key="your-key",
    model="z-ai/glm-4.7"
)

# Node.js
const client = new OpenAI({
  baseURL: 'http://localhost:3000',
  apiKey: 'your-key'
})

# JavaScript
const config = {
  baseURL: 'http://localhost:3000',
  apiKey: 'your-key'
}
```

## 📡 API 端点

| 端点 | 方法 | 说明 |
|------|------|------|
| `/` | GET | 服务信息 |
| `/health` | GET | 健康检查 |
| `/v1/models` | GET | 列出模型 |
| `/v1/chat/completions` | POST | 聊天完成 |

## 🔍 故障排除

### 问题：无法连接
```bash
# 检查服务是否运行
curl http://localhost:3000/health

# 检查端口占用
netstat -ano | findstr :3000
```

### 问题：API 错误
- 检查 NVIDIA API Key 是否正确
- 确认网络连接正常
- 检查 API 配额

### 问题：响应慢
- 尝试更小的模型（如 `z-ai/glm-4.7`）
- 减少响应长度（降低 `max_tokens`）
- 检查网络延迟

## 📖 使用示例

### Python CLI 示例
```bash
# 基本对话
python nvidia-chat.py "你好！"

# 使用特定模型
python nvidia-chat.py -m deepseek-ai/deepseek-v3 "写代码"

# 查看状态
python nvidia-chat.py --check

# 列出所有模型
python nvidia-chat.py --list-models
```

### Node.js 示例
```bash
# 运行所有示例
node example.js
```

### Python 完整示例
```bash
# 运行所有示例
python example.py
```

## 🎯 根据你的环境选择

| 环境 | 推荐方式 | 文件 |
|------|----------|------|
| **Python 后端** | CLI 或导入 | `nvidia-chat.py` / `example.py` |
| **Node.js 后端** | 导入或 SDK | `example.js` |
| **Web 前端** | fetch API | 查看 `QUICK_INTEGRATION.md` |
| **命令行** | CLI 或 curl | `nvidia-chat.py` 或 `curl` |
| **AI 框架** | SDK 集成 | LangChain/LlamaIndex |
| **桌面应用** | HTTP 调用 | 查看 `INTEGRATION_GUIDE.md` |

## 📞 需要帮助？

### 常见问题
1. **如何更换端口？** 修改 `.env` 中的 `PORT` 变量
2. **如何调用其他模型？** 使用 `-m` 参数指定模型 ID
3. **如何在生产环境使用？** 使用 PM2 或 Docker 部署
4. **如何添加更多功能？** 查看 `server.js`，添加自定义逻辑

### 详细文档
- **快速开始**：`QUICKSTART.md`
- **完整集成**：`INTEGRATION_GUIDE.md`
- **快速集成**：`QUICK_INTEGRATION.md`
- **项目说明**：`README.md`

## 🔗 相关链接

- NVIDIA API: https://build.nvidia.com/
- OpenAI API: https://platform.openai.com/docs/
- 项目位置: `C:\Users\Administrator\.openclaw\workspace\nvidia-to-openai-proxy`

---

## ✅ 检查清单

开始使用前请确认：

- [ ] 已安装 Node.js
- [ ] 已运行 `npm install`
- [ ] 已配置 `.env` 中的 API Key
- [ ] 已启动服务器（`npm start`）
- [ ] 已运行测试（`test.bat`）
- [ ] 已选择合适的集成方式

## 🎉 完成！

现在你可以在"小龙虾"环境或其他任何环境中使用 NVIDIA 模型了！

选择你最方便的方式开始使用吧！

---

**作者**：2B 🤖
**最后更新**：2026-03-11
**版本**：1.0.0
