#!/usr/bin/env python3
"""
NVIDIA AI Chat - 通用 CLI 工具
在任何 Python 环境中使用
"""

import sys
import json
import requests
from typing import Optional, List, Dict

class NVIDIAChatCLI:
    """NVIDIA AI 聊天命令行工具"""

    def __init__(
        self,
        base_url: str = "http://localhost:3000",
        api_key: str = "your-key",
        model: str = "z-ai/glm-4.7"
    ):
        self.base_url = base_url
        self.api_key = api_key
        self.default_model = model
        self.headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}"
        }

    def chat(
        self,
        prompt: str,
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1000
    ) -> str:
        """发送聊天请求"""
        url = f"{self.base_url}/v1/chat/completions"

        data = {
            "model": model or self.default_model,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": temperature,
            "max_tokens": max_tokens
        }

        response = requests.post(url, headers=self.headers, json=data)
        response.raise_for_status()

        result = response.json()
        return result["choices"][0]["message"]["content"]

    def chat_with_history(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None
    ) -> str:
        """带历史记录的对话"""
        url = f"{self.base_url}/v1/chat/completions"

        data = {
            "model": model or self.default_model,
            "messages": messages
        }

        response = requests.post(url, headers=self.headers, json=data)
        response.raise_for_status()

        result = response.json()
        return result["choices"][0]["message"]["content"]

    def list_models(self) -> List[str]:
        """列出可用模型"""
        url = f"{self.base_url}/v1/models"

        response = requests.get(url, headers=self.headers)
        response.raise_for_status()

        result = response.json()
        return [model["id"] for model in result["data"]]

    def health_check(self) -> bool:
        """检查服务健康状态"""
        url = f"{self.base_url}/health"

        try:
            response = requests.get(url, headers=self.headers)
            return response.status_code == 200
        except:
            return False


def main():
    """命令行界面"""
    import argparse

    parser = argparse.ArgumentParser(description="NVIDIA AI Chat CLI")
    parser.add_argument("prompt", nargs="?", help="聊天提示词")
    parser.add_argument("-m", "--model", help="使用的模型")
    parser.add_argument("--list-models", action="store_true", help="列出可用模型")
    parser.add_argument("--check", action="store_true", help="检查服务状态")
    parser.add_argument("--temperature", type=float, default=0.7, help="温度参数")
    parser.add_argument("--max-tokens", type=int, default=1000, help="最大token数")
    parser.add_argument("--base-url", default="http://localhost:3000", help="代理服务器地址")
    parser.add_argument("--api-key", default="your-key", help="API密钥")

    args = parser.parse_args()

    # 初始化客户端
    client = NVIDIAChatCLI(
        base_url=args.base_url,
        api_key=args.api_key
    )

    # 列出模型
    if args.list_models:
        print("可用模型：")
        for model in client.list_models():
            print(f"  - {model}")
        return

    # 健康检查
    if args.check:
        if client.health_check():
            print("✅ 服务正常运行")
        else:
            print("❌ 服务不可用")
            sys.exit(1)
        return

    # 聊天
    if args.prompt:
        try:
            result = client.chat(
                prompt=args.prompt,
                model=args.model,
                temperature=args.temperature,
                max_tokens=args.max_tokens
            )
            print(result)
        except requests.exceptions.ConnectionError:
            print("❌ 无法连接到代理服务器")
            print("请确保服务器正在运行: npm start")
            sys.exit(1)
        except Exception as e:
            print(f"❌ 错误: {e}")
            sys.exit(1)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
