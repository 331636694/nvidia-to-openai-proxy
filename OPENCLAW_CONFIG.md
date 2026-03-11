# 在 OpenClaw 中添加 NVIDIA 代理服务器

## 📋 方式：将 NVIDIA 代理添加为 OpenClaw 的模型提供商

这样就可以像使用本地模型一样使用 NVIDIA 模型！

---

## 🔧 配置步骤

### 1. 编辑 openclaw.json

在 `C:\Users\Administrator\.openclaw\openclaw.json` 的 `models.providers` 部分添加：

```json
{
  "models": {
    "providers": {
      "nvidia-proxy": {
        "api": "openai-completions",
        "baseUrl": "http://127.0.0.1:3000",
        "apiKey": "openclaw-nvidia-proxy",
        "models": [
          {
            "id": "nvidia-proxy/z-ai/glm-4.7",
            "name": "GLM 4.7 (Proxy)",
            "contextWindow": 131072,
            "maxTokens": 4096,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "reasoning": true
          },
          {
            "id": "nvidia-proxy/qwen/qwen2.5-72b-instruct",
            "name": "Qwen 2.5 72B (Proxy)",
            "contextWindow": 131072,
            "maxTokens": 4096,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "reasoning": true
          },
          {
            "id": "nvidia-proxy/deepseek-ai/deepseek-v3",
            "name": "DeepSeek V3 (Proxy)",
            "contextWindow": 131072,
            "maxTokens": 4096,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "reasoning": true
          },
          {
            "id": "nvidia-proxy/deepseek-ai/deepseek-r1",
            "name": "DeepSeek R1 (Proxy)",
            "contextWindow": 131072,
            "maxTokens": 4096,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "reasoning": true
          },
          {
            "id": "nvidia-proxy/meta/llama-3.1-405b-instruct",
            "name": "Llama 3.1 405B (Proxy)",
            "contextWindow": 131072,
            "maxTokens": 4096,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "reasoning": true
          }
        ]
      }
    }
  }
}
```

---

## 🚀 使用

### 配置为默认模型

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "nvidia-proxy/z-ai/glm-4.7"
      }
    }
  }
}
```

### 或在特定会话中使用

```json
{
  "agents": {
    "defaults": {
      "models": {
        "nvidia-proxy/z-ai/glm-4.7": {
          "alias": "glm47proxy"
        },
        "nvidia-proxy/qwen/qwen2.5-72b-instruct": {
          "alias": "qwen72bproxy"
        }
      }
    }
  }
}
```

---

## ⚡ 快速测试

### 1. 启动 NVIDIA 代理
```bash
cd C:\Users\Administrator\.openclaw\workspace\nvidia-to-openai-proxy
npm start
```

### 2. 更新 openclaw.json
添加上面的 `nvidia-proxy` 配置

### 3. 重启 Gateway
```bash
openclaw gateway restart
```

### 4. 测试
在聊天中使用主模型，应该会通过代理调用 NVIDIA GLM-4.7

---

## 🔄 完整配置示例

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "nvidia-proxy/z-ai/glm-4.7",
        "fallbacks": [
          "local/default",
          "nvidia-proxy/qwen/qwen2.5-72b-instruct"
        ]
      },
      "models": {
        "nvidia-proxy/z-ai/glm-4.7": {
          "alias": "glmproxy"
        },
        "nvidia-proxy/qwen/qwen2.5-72b-instruct": {
          "alias": "qwenproxy"
        },
        "local/default": {
          "alias": "local"
        }
      }
    }
  },
  "models": {
    "providers": {
      "local": {
        "api": "openai-completions",
        "apiKey": "cs-sk-f863b5ea-b57a-40dc-9751-cd1cda9834fb",
        "baseUrl": "http://127.0.0.1:23333/v1",
        "models": [...]
      },
      "nvidia-proxy": {
        "api": "openai-completions",
        "baseUrl": "http://127.0.0.1:3000",
        "apiKey": "openclaw-nvidia-proxy",
        "models": [
          {
            "id": "nvidia-proxy/z-ai/glm-4.7",
            "name": "GLM 4.7 (Proxy)",
            "contextWindow": 131072,
            "maxTokens": 4096,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "reasoning": true
          }
        ]
      }
    }
  }
}
```

---

## ✅ 验证配置

检查配置是否正确：

```bash
openclaw status
```

应该能看到 `nvidia-proxy` 提供商和相关的模型。

---

## 💡 注意事项

1. **代理必须先启动** - 在使用前必须先运行 `npm start` 启动 NVIDIA 代理
2. **端口检查** - 确保端口 3000 没有被占用
3. **Fallback 链** - 建议配置 fallback，当代理不可用时可以切换到本地模型

---

## 🎯 优势

✅ **统一接口** - 和本地模型使用方式完全一致
✅ **透明切换** - 无缝切换模型
✅ **自动降级** - 配置 fallback 链实现容错
✅ **简单配置** - 一次配置，永久使用

---

需要我直接帮你修改 openclaw.json 吗？
