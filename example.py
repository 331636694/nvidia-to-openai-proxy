"""
NVIDIA to OpenAI Proxy - Python 客户端示例
使用标准 OpenAI 库调用本地代理
"""

import requests
import json

# 代理服务器配置
BASE_URL = "http://localhost:3000"
API_KEY = "your-api-key"  # 可以是任意值

class OpenAIClient:
    """模拟 OpenAI 客户端，连接到本地代理"""

    def __init__(self, base_url=BASE_URL, api_key=API_KEY):
        self.base_url = base_url
        self.api_key = api_key
        self.headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}"
        }

    def chat_completion(self, model, messages, **kwargs):
        """发送聊天完成请求"""
        url = f"{self.base_url}/v1/chat/completions"

        data = {
            "model": model,
            "messages": messages,
            **kwargs
        }

        response = requests.post(url, headers=self.headers, json=data)
        response.raise_for_status()
        return response.json()

    def list_models(self):
        """列出可用模型"""
        url = f"{self.base_url}/v1/models"

        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        return response.json()

    def health_check(self):
        """健康检查"""
        url = f"{self.base_url}/health"

        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        return response.json()


def example_1_basic_chat():
    """示例 1: 基本对话"""
    print("\n=== 示例 1: 基本对话 ===\n")

    client = OpenAIClient()

    response = client.chat_completion(
        model="z-ai/glm-4.7",
        messages=[
            {"role": "system", "content": "你是一个有用的AI助手。"},
            {"role": "user", "content": "你好，请介绍一下你自己。"}
        ]
    )

    print(f"回复: {response['choices'][0]['message']['content']}")
    print(f"使用的模型: {response['model']}")
    print(f"Token 使用: {response['usage']}")


def example_2_coding():
    """示例 2: 代码生成"""
    print("\n=== 示例 2: 代码生成 ===\n")

    client = OpenAIClient()

    response = client.chat_completion(
        model="qwen/qwen2.5-72b-instruct",
        messages=[
            {"role": "system", "content": "你是一个代码专家。"},
            {"role": "user", "content": "用 Python 写一个快速排序算法。"}
        ],
        temperature=0.7,
        max_tokens=1000
    )

    print(f"回复: {response['choices'][0]['message']['content']}")


def example_3_with_params():
    """示例 3: 使用更多参数"""
    print("\n=== 示例 3: 使用更多参数 ===\n")

    client = OpenAIClient()

    response = client.chat_completion(
        model="deepseek-ai/deepseek-v3",
        messages=[
            {"role": "system", "content": "你是一个创意写作助手。"},
            {"role": "user", "content": "写一个关于机器人的短故事，不超过 200 字。"}
        ],
        temperature=0.9,  # 更高温度，更创造性
        top_p=0.95,
        max_tokens=500
    )

    print(f"故事: {response['choices'][0]['message']['content']}")


def example_4_list_models():
    """示例 4: 列出所有可用模型"""
    print("\n=== 示例 4: 可用模型 ===\n")

    client = OpenAIClient()
    models = client.list_models()

    print(f"总共 {len(models['data'])} 个模型:\n")
    for model in models['data']:
        print(f"  - {model['id']}")


def example_5_health_check():
    """示例 5: 健康检查"""
    print("\n=== 示例 5: 健康检查 ===\n")

    client = OpenAIClient()
    health = client.health_check()

    print(f"状态: {health['status']}")
    print(f"服务: {health['service']}")
    print(f"时间: {health['timestamp']}")


def example_6_conversation():
    """示例 6: 多轮对话"""
    print("\n=== 示例 6: 多轮对话 ===\n")

    client = OpenAIClient()

    conversation = [
        {"role": "system", "content": "你是一个友好的助手。"},
        {"role": "user", "content": "我叫小明。"}
    ]

    # 第一轮
    response = client.chat_completion(
        model="z-ai/glm-4.7",
        messages=conversation
    )
    print(f"助手: {response['choices'][0]['message']['content']}")

    # 添加助手回复
    conversation.append({
        "role": "assistant",
        "content": response['choices'][0]['message']['content']
    })

    # 第二轮
    conversation.append({
        "role": "user",
        "content": "你记住了我的名字吗？"
    })

    response = client.chat_completion(
        model="z-ai/glm-4.7",
        messages=conversation
    )
    print(f"助手: {response['choices'][0]['message']['content']}")


# 使用真正的 OpenAI SDK（可选）
def example_7_with_openai_sdk():
    """示例 7: 使用官方 OpenAI SDK"""
    print("\n=== 示例 7: 使用 OpenAI SDK ===\n")
    print("安装: pip install openai")

    try:
        from openai import OpenAI

        # 连接到本地代理
        client = OpenAI(
            base_url=BASE_URL,
            api_key=API_KEY
        )

        response = client.chat.completions.create(
            model="z-ai/glm-4.7",
            messages=[
                {"role": "system", "content": "你是一个有用的AI助手。"},
                {"role": "user", "content": "用一句话介绍你自己。"}
            ]
        )

        print(f"回复: {response.choices[0].message.content}")
        print(f"模型: {response.model}")

    except ImportError:
        print("OpenAI SDK 未安装，跳过此示例")
        print("运行: pip install openai")


def main():
    """运行所有示例"""
    try:
        # 健康检查
        example_5_health_check()

        # 列出模型
        example_4_list_models()

        # 运行对话示例
        example_1_basic_chat()
        example_2_coding()
        example_3_with_params()
        example_6_conversation()

        # 可选：使用 OpenAI SDK
        example_7_with_openai_sdk()

    except requests.exceptions.ConnectionError:
        print("\n❌ 错误: 无法连接到代理服务器")
        print("请确保代理服务器正在运行: npm start")
    except Exception as e:
        print(f"\n❌ 错误: {e}")


if __name__ == "__main__":
    main()
