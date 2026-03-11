# 快速集成脚本

根据你的环境选择对应的集成方案：

## 🟢 Python 环境

### 方案 A: 直接导入使用
```python
# 复制这段代码到你的项目中
import sys
sys.path.append('C:/Users/Administrator/.openclaw/workspace/nvidia-to-openai-proxy')

from nvidia_chat import NVIDIAChatCLI

# 使用
client = NVIDIAChatCLI()
answer = client.chat("你好！")
print(answer)
```

### 方案 B: 命令行调用
```bash
# 进入目录
cd C:\Users\Administrator\.openclaw\workspace\nvidia-to-openai-proxy

# 直接使用
python nvidia-chat.py "你好！"

# 列出模型
python nvidia-chat.py --list-models

# 检查服务
python nvidia-chat.py --check

# 使用其他模型
python nvidia-chat.py -m qwen/qwen2.5-72b-instruct "写代码"
```

## 🔵 Node.js 环境

### 方案 A: 直接导入
```javascript
// 复制到你的项目
const NVIDIAChat = require('./example');

// 使用
const answer = await NVIDIAChat.chatCompletion(
  'z-ai/glm-4.7',
  [{ role: 'user', content: '你好！' }]
);
```

### 方案 B: 使用 SDK
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

## 🌐 Web 前端

### 复制这个 HTML 文件到你的项目

创建 `nvidia-chat.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <title>NVIDIA AI Chat</title>
  <script>
    const PROXY_URL = "http://localhost:3000";

    async function chat(prompt) {
      const response = await fetch(`${PROXY_URL}/v1/chat/completions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-key'
        },
        body: JSON.stringify({
          model: 'z-ai/glm-4.7',
          messages: [{ role: 'user', content: prompt }]
        })
      });

      const data = await response.json();
      return data.choices[0].message.content;
    }

    async function send() {
      const input = document.getElementById('input');
      const output = document.getElementById('output');
      const prompt = input.value;

      if (!prompt) return;

      output.innerHTML = '思考中...';

      try {
        const answer = await chat(prompt);
        output.innerHTML = answer;
      } catch (error) {
        output.innerHTML = '错误: ' + error.message;
      }
    }
  </script>
</head>
<body>
  <h1>NVIDIA AI Chat</h1>
  <input id="input" type="text" placeholder="输入消息...">
  <button onclick="send()">发送</button>
  <br><br>
  <div id="output"></div>
</body>
</html>
```

## 🤖 其他框架

### LangChain
```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    base_url="http://localhost:3000",
    api_key="your-key",
    model="z-ai/glm-4.7"
)

response = llm.invoke("你好！")
print(response.content)
```

### LlamaIndex
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

## 📋 快速步骤

1. **启动代理服务器**
   ```bash
   cd C:\Users\Administrator\.openclaw\workspace\nvidia-to-openai-proxy
   npm start
   ```

2. **选择集成方式**
   - Python 环境 → 使用 `nvidia-chat.py`
   - Node.js 环境 → 导入 `example.js`
   - Web 前端 → 使用 HTML 示例
   - 其他框架 → 查看 `INTEGRATION_GUIDE.md`

3. **开始使用**
   ```python
   # Python
   python nvidia-chat.py "你好！"

   # Node.js
   node example.js

   # 命令行
   curl -X POST http://localhost:3000/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{"model":"z-ai/glm-4.7","messages":[{"role":"user","content":"你好！"}]}'
   ```

## 🔍 更多示例

查看完整集成指南：`INTEGRATION_GUIDE.md`

查看完整使用文档：`README.md`

---

**需要帮助？** 告诉我"小龙虾"是什么，我可以提供更精确的集成方案！
