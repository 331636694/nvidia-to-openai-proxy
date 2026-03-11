# 小龙虾环境集成指南

## 📋 在不同环境中调用 NVIDIA 代理服务器

本项目提供多种方式让你的应用（包括"小龙虾"）通过标准 OpenAI 接口调用 NVIDIA 模型。

---

## 🔗 方式一：HTTP 直接调用（最通用）

### 基本调用

```javascript
// 适用于任何支持 HTTP 请求的环境
const response = await fetch('http://localhost:3000/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer your-api-key'
  },
  body: JSON.stringify({
    model: 'z-ai/glm-4.7',
    messages: [
      { role: 'user', content: '你好！' }
    ]
  })
});

const data = await response.json();
console.log(data.choices[0].message.content);
```

---

## 🐍 方式二：Python 集成

### 2.1 使用 requests 库

```python
import requests

def chat_with_nvidia(prompt, model='z-ai/glm-4.7'):
    url = "http://localhost:3000/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer your-api-key"
    }

    data = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}]
    }

    response = requests.post(url, headers=headers, json=data)
    return response.json()['choices'][0]['message']['content']

# 使用
result = chat_with_nvidia("介绍一下你自己")
print(result)
```

### 2.2 使用官方 OpenAI SDK

```python
from openai import OpenAI

# 连接到本地代理
client = OpenAI(
    base_url="http://localhost:3000",
    api_key="your-api-key"
)

def chat_with_nvidia(prompt, model='z-ai/glm-4.7'):
    response = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content

# 使用
result = chat_with_nvidia("写一个 Python 函数")
print(result)
```

### 2.3 封装为类（推荐用于项目）

```python
class NVIDIAChat:
    def __init__(self, base_url="http://localhost:3000", api_key="your-key"):
        self.client = OpenAI(base_url=base_url, api_key=api_key)

    def chat(self, prompt, model='z-ai/glm-4.7', **kwargs):
        response = self.client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": prompt}],
            **kwargs
        )
        return response.choices[0].message.content

    def chat_with_history(self, messages, model='z-ai/glm-4.7', **kwargs):
        """支持对话历史"""
        response = self.client.chat.completions.create(
            model=model,
            messages=messages,
            **kwargs
        )
        return response.choices[0].message.content

# 使用
chat = NVIDIAChat()
answer = chat.chat("用 Python 写一个快速排序")
print(answer)

# 多轮对话
history = [
    {"role": "system", "content": "你是一个编程助手"},
    {"role": "user", "content": "我叫小明"}
]
answer1 = chat.chat_with_history(history)
print(answer1)
```

---

## 🟢 Node.js 集成

### 3.1 使用 fetch API

```javascript
async function chatWithNVIDIA(prompt, model = 'z-ai/glm-4.7') {
  const response = await fetch('http://localhost:3000/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer your-api-key'
    },
    body: JSON.stringify({
      model,
      messages: [{ role: 'user', content: prompt }]
    })
  });

  const data = await response.json();
  return data.choices[0].message.content;
}

// 使用
const result = await chatWithNVIDIA('你好！');
console.log(result);
```

### 3.2 使用 OpenAI SDK

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'http://localhost:3000',
  apiKey: 'your-api-key'
});

async function chatWithNVIDIA(prompt, model = 'z-ai/glm-4.7') {
  const response = await client.chat.completions.create({
    model,
    messages: [{ role: 'user', content: prompt }]
  });

  return response.choices[0].message.content;
}

// 使用
const result = await chatWithNVIDIA('写一段 JavaScript 代码');
console.log(result);
```

### 3.3 封装为服务类

```javascript
class NVIDIAChatService {
  constructor(config = {}) {
    this.client = new OpenAI({
      baseURL: config.baseURL || 'http://localhost:3000',
      apiKey: config.apiKey || 'your-key',
      maxRetries: config.maxRetries || 3
    });
    this.defaultModel = config.defaultModel || 'z-ai/glm-4.7';
  }

  async chat(prompt, options = {}) {
    const response = await this.client.chat.completions.create({
      model: options.model || this.defaultModel,
      messages: [{ role: 'user', content: prompt }],
      temperature: options.temperature || 0.7,
      max_tokens: options.maxTokens || 1000,
      ...options
    });

    return {
      content: response.choices[0].message.content,
      model: response.model,
      usage: response.usage
    };
  }

  async chatWithHistory(messages, options = {}) {
    const response = await this.client.chat.completions.create({
      model: options.model || this.defaultModel,
      messages,
      ...options
    });

    return {
      content: response.choices[0].message.content,
      model: response.model,
      usage: response.usage
    };
  }
}

// 使用
const chatService = new NVIDIAChatService();

const result = await chatService.chat('你好，介绍一下你自己');
console.log(result.content);
```

---

## 🌐 Web 前端集成

### 4.1 纯 JavaScript

```javascript
class OpenAIProxyClient {
  constructor(baseURL = 'http://localhost:3000', apiKey = 'your-key') {
    this.baseURL = baseURL;
    this.apiKey = apiKey;
  }

  async chat(messages, model = 'z-ai/glm-4.7') {
    const response = await fetch(`${this.baseURL}/v1/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`
      },
      body: JSON.stringify({ model, messages })
    });

    const data = await response.json();
    return data.choices[0].message.content;
  }
}

// 使用
const client = new OpenAIProxyClient();

async function askQuestion() {
  const result = await client.chat([
    { role: 'user', content: '你好！' }
  ]);
  console.log(result);
}

askQuestion();
```

### 4.2 React 集成

```javascript
import React, { useState } from 'react';

function ChatComponent() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  const sendMessage = async () => {
    if (!input.trim()) return;

    setLoading(true);
    const userMessage = { role: 'user', content: input };
    const newMessages = [...messages, userMessage];

    try {
      const response = await fetch('http://localhost:3000/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-key'
        },
        body: JSON.stringify({
          model: 'z-ai/glm-4.7',
          messages: newMessages
        })
      });

      const data = await response.json();
      const assistantMessage = {
        role: 'assistant',
        content: data.choices[0].message.content
      };

      setMessages([...newMessages, assistantMessage]);
      setInput('');
    } catch (error) {
      console.error('Error:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div>
        {messages.map((msg, idx) => (
          <div key={idx}>
            <strong>{msg.role}:</strong> {msg.content}
          </div>
        ))}
      </div>
      <input
        value={input}
        onChange={(e) => setInput(e.target.value)}
        onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
        placeholder="输入消息..."
      />
      <button onClick={sendMessage} disabled={loading}>
        {loading ? '发送中...' : '发送'}
      </button>
    </div>
  );
}

export default ChatComponent;
```

---

## 🤖 方式三：命令行工具

### 5.1 使用 curl

```bash
# 基本调用
curl -X POST http://localhost:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-key" \
  -d '{
    "model": "z-ai/glm-4.7",
    "messages": [{"role": "user", "content": "你好！"}]
  }'
```

### 5.2 创建 CLI 工具

创建 `nvidia-chat` 文件：

```bash
#!/bin/bash

PROXY_URL="http://localhost:3000"
MODEL="z-ai/glm-4.7"
PROMPT="$1"

if [ -z "$PROMPT" ]; then
  echo "Usage: nvidia-chat \"your prompt\""
  exit 1
fi

curl -s -X POST "$PROXY_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-key" \
  -d "{\"model\": \"$MODEL\", \"messages\": [{\"role\": \"user\", \"content\": \"$PROMPT\"}]}" \
  | grep -o '"content":"[^"]*"' | cut -d '"' -f 4
```

使用：
```bash
chmod +x nvidia-chat
./nvidia-chat "写一个 Python 函数计算斐波那契数列"
```

---

## 📦 方式四：Docker 容器集成

### 6.1 Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

### 6.2 docker-compose.yml

```yaml
version: '3.8'

services:
  nvidia-proxy:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NVIDIA_API_KEY=${NVIDIA_API_KEY}
      - PORT=3000
    restart: unless-stopped
```

### 6.3 启动

```bash
# 构建并启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止
docker-compose down
```

---

## 🧩 为不同框架创建适配器

### 7.1 LangChain 集成

```python
from langchain_openai import ChatOpenAI

# 使用本地代理
llm = ChatOpenAI(
    base_url="http://localhost:3000",
    api_key="your-key",
    model="z-ai/glm-4.7"
)

# 使用
response = llm.invoke("你好！")
print(response.content)
```

### 7.2 LlamaIndex 集成

```python
from llama_index.llms.openai import OpenAI

llm = OpenAI(
    api_base="http://localhost:3000",
    api_key="your-key",
    model="z-ai/glm-4.7"
)

response = llm.complete("写一个故事")
print(response.text)
```

---

## 🔌 RESTful API 封装

创建一个更友好的 API 接口：

```javascript
// api.js
class NVIDIAAPI {
  constructor(options = {}) {
    this.baseURL = options.baseURL || 'http://localhost:3000';
    this.apiKey = options.apiKey || 'your-key';
    this.timeout = options.timeout || 30000;
  }

  async request(endpoint, data) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const response = await fetch(`${this.baseURL}/v1${endpoint}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiKey}`
        },
        body: JSON.stringify(data),
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      clearTimeout(timeoutId);
      throw error;
    }
  }

  // 简单对话
  async chat(prompt, model = 'z-ai/glm-4.7') {
    const data = await this.request('/chat/completions', {
      model,
      messages: [{ role: 'user', content: prompt }]
    });
    return data.choices[0].message.content;
  }

  // 带参数对话
  async chatWithParams(prompt, params = {}) {
    const data = await this.request('/chat/completions', {
      model: params.model || 'z-ai/glm-4.7',
      messages: params.messages || [{ role: 'user', content: prompt }],
      temperature: params.temperature,
      max_tokens: params.maxTokens,
      top_p: params.topP
    });
    return {
      content: data.choices[0].message.content,
      model: data.model,
      usage: data.usage
    };
  }

  // 流式对话
  async* chatStream(prompt, model = 'z-ai/glm-4.7') {
    const response = await fetch(`${this.baseURL}/v1/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`
      },
      body: JSON.stringify({
        model,
        messages: [{ role: 'user', content: prompt }],
        stream: true
      })
    });

    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value);
      const lines = chunk.split('\n');

      for (const line of lines) {
        if (line.startsWith('data: ')) {
          const data = line.slice(6);
          if (data === '[DONE]') break;

          try {
            const parsed = JSON.parse(data);
            yield parsed.choices[0].delta.content;
          } catch (e) {
            // 忽略解析错误
          }
        }
      }
    }
  }
}

// 导出
module.exports = NVIDIAAPI;

// 使用示例
if (require.main === module) {
  (async () => {
    const api = new NVIDIAAPI();

    // 简单对话
    console.log(await api.chat('你好！'));

    // 流式对话
    for await (const chunk of api.chatStream('写一首短诗')) {
      process.stdout.write(chunk);
    }
  })();
}
```

---

## 🎯 根据"小龙虾"环境选择合适的方式

### 如果是：
- **Web 应用** → 使用前端 JavaScript 集成
- **后端服务** → 使用 Python/Node.js 后端集成
- **命令行工具** → 使用 CLI 或 curl
- **AI 框架** → 使用 LangChain/LlamaIndex 适配器
- **桌面应用** → 使用 HTTP 直接调用
- **现有系统** → 创建 RESTful API 封装

---

## 📞 需要帮助？

如果你能告诉我"小龙虾"具体是什么技术栈（前端框架、后端语言等），我可以提供更精确的集成方案！

---

**作者**：2B 🤖
**最后更新**：2026-03-11
