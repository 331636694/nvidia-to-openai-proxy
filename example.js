const http = require('http');

// 配置
const PROXY_URL = 'http://localhost:3000';
const API_KEY = 'your-api-key'; // 可以是任意值，或者从环境变量读取

/**
 * 使用 OpenAI 格式调用 NVIDIA 模型
 */
async function chatCompletion(model = 'z-ai/glm-4.7', messages, options = {}) {
  const data = {
    model: model,
    messages: messages,
    ...options
  };

  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/v1/chat/completions',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_KEY}`
      }
    };

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (res.statusCode !== 200) {
            reject(new Error(`API Error: ${JSON.stringify(response)}`));
          } else {
            resolve(response);
          }
        } catch (error) {
          reject(error);
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

// 示例：简单的对话
async function example1() {
  console.log('\n=== 示例 1: 简单对话 ===\n');

  try {
    const response = await chatCompletion('z-ai/glm-4.7', [
      { role: 'system', content: '你是一个有用的AI助手。' },
      { role: 'user', content: '你好，请介绍一下你自己。' }
    ]);

    console.log('回复:', response.choices[0].message.content);
    console.log('使用的模型:', response.model);
    console.log('Token 使用:', response.usage);
  } catch (error) {
    console.error('错误:', error.message);
  }
}

// 示例：使用其他参数
async function example2() {
  console.log('\n=== 示例 2: 使用不同参数 ===\n');

  try {
    const response = await chatCompletion('qwen/qwen2.5-72b-instruct', [
      { role: 'system', content: '你是一个代码助手。' },
      { role: 'user', content: '用 Python 写一个快速排序算法。' }
    ], {
      temperature: 0.7,
      max_tokens: 1000,
      top_p: 0.9
    });

    console.log('回复:', response.choices[0].message.content);
    console.log('使用的模型:', response.model);
  } catch (error) {
    console.error('错误:', error.message);
  }
}

// 示例：检查可用模型
async function listModels() {
  console.log('\n=== 可用模型列表 ===\n');

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/v1/models',
      method: 'GET'
    };

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          response.data.forEach(model => {
            console.log(`- ${model.id}`);
          });
          resolve(response);
        } catch (error) {
          reject(error);
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
}

// 示例：健康检查
async function healthCheck() {
  console.log('\n=== 健康检查 ===\n');

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/health',
      method: 'GET'
    };

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          console.log('状态:', response.status);
          console.log('服务:', response.service);
          console.log('时间:', response.timestamp);
          resolve(response);
        } catch (error) {
          reject(error);
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
}

// 主函数
async function main() {
  try {
    // 健康检查
    await healthCheck();

    // 列出可用模型
    await listModels();

    // 运行示例
    await example1();
    await example2();

  } catch (error) {
    console.error('错误:', error.message);
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  main();
}

module.exports = { chatCompletion, listModels, healthCheck };
