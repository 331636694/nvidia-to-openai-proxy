const express = require('express');
const cors = require('cors');
const https = require('https');
const http = require('http');
const url = require('url');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// 配置
const config = {
  nvidiaBaseUrl: 'https://integrate.api.nvidia.com',
  // 从环境变量读取 API Key，或使用默认值
  nvidiaApiKey: process.env.NVIDIA_API_KEY || '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',
  port: PORT
};

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 日志中间件
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  console.log(`Headers:`, JSON.stringify(req.headers, null, 2));
  if (req.body && req.body.model) {
    console.log(`Model:`, req.body.model);
  }
  next();
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'NVIDIA to OpenAI Proxy',
    timestamp: new Date().toISOString(),
    config: {
      port: config.port,
      nvidiaBaseUrl: config.nvidiaBaseUrl
    }
  });
});

// 根路径
app.get('/', (req, res) => {
  res.json({
    name: 'NVIDIA API to OpenAI Format Proxy',
    version: '1.0.0',
    endpoints: {
      'POST /v1/chat/completions': 'Chat completions (OpenAI format)',
      'GET /v1/models': 'List available models',
      'GET /health': 'Health check'
    },
    usage: {
      note: 'This proxy converts OpenAI format requests to NVIDIA API format',
      authentication: 'Use OpenAI API key header (any value, or NVIDIA_API_KEY token)'
    }
  });
});

// 列出可用模型
app.get('/v1/models', (req, res) => {
  const models = [
    'meta/llama-3.1-405b-instruct',
    'meta/llama-3.1-70b-instruct',
    'meta/llama-3.1-8b-instruct',
    'meta/llama-4-maverick-17b-128e-instruct',
    'meta/llama-4-scout-17b-16e-instruct',
    'deepseek-ai/deepseek-r1',
    'deepseek-ai/deepseek-v3',
    'google/gemma-2-27b-it',
    'google/gemma-2-9b-it',
    'mistralai/mistral-large',
    'mistralai/mixtral-8x7b-instruct',
    'mistralai/mistral-7b-instruct',
    'qwen/qwen2.5-72b-instruct',
    'qwen/qwen2.5-7b-instruct',
    'z-ai/glm-4.7',
    'z-ai/glm-5',
    'minimaxai/minimax-m2.5',
    'moonshotai/kimi-k2-instruct',
    'nvidia/llama-3.1-nemotron-70b-instruct',
    'nvidia/nemotron-4-340b-instruct',
    'microsoft/phi-3-medium-128k-instruct',
    'microsoft/phi-3-mini-128k-instruct'
  ];

  res.json({
    object: 'list',
    data: models.map(id => ({
      id: id,
      object: 'model',
      created: 1677610602,
      owned_by: 'nvidia'
    }))
  });
});

// Chat Completions - 核心 API
app.post('/v1/chat/completions', async (req, res) => {
  try {
    const openaiRequest = req.body;

    console.log('OpenAI Request:', JSON.stringify(openaiRequest, null, 2));

    // 转换为 NVIDIA API 格式
    const nvidiaRequest = {
      model: openaiRequest.model,
      messages: openaiRequest.messages,
      temperature: openaiRequest.temperature || 0.7,
      top_p: openaiRequest.top_p || 1,
      max_tokens: openaiRequest.max_tokens || 1024,
      stream: openaiRequest.stream || false
    };

    // 处理响应格式
    if (openaiRequest.response_format) {
      nvidiaRequest.response_format = openaiRequest.response_format;
    }

    // 处理工具调用
    if (openaiRequest.tools) {
      nvidiaRequest.tools = openaiRequest.tools;
    }
    if (openaiRequest.tool_choice) {
      nvidiaRequest.tool_choice = openaiRequest.tool_choice;
    }

    // 获取认证信息（从 X-API-Key 或 Authorization header）
    let apiKey = config.nvidiaApiKey;
    const authHeader = req.headers['authorization'] || req.headers['x-api-key'];
    if (authHeader) {
      apiKey = authHeader.toString().replace(/^Bearer\s+/i, '');
    }

    // 发送给 NVIDIA API
    const options = {
      hostname: new URL(config.nvidiaBaseUrl).hostname,
      port: 443,
      path: '/v1/chat/completions',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      }
    };

    console.log('Making request to NVIDIA API...');

    const nvidiaResponse = await new Promise((resolve, reject) => {
      const proxyReq = https.request(options, (proxyRes) => {
        let data = '';

        proxyRes.on('data', (chunk) => {
          data += chunk;
        });

        proxyRes.on('end', () => {
          try {
            resolve({
              statusCode: proxyRes.statusCode,
              headers: proxyRes.headers,
              body: data
            });
          } catch (error) {
            reject(error);
          }
        });
      });

      proxyReq.on('error', reject);
      proxyReq.write(JSON.stringify(nvidiaRequest));
      proxyReq.end();
    });

    console.log('NVIDIA Response Status:', nvidiaResponse.statusCode);

    if (nvidiaResponse.statusCode !== 200) {
      console.error('NVIDIA API Error:', nvidiaResponse.body);
      return res.status(nvidiaResponse.statusCode).json({
        error: {
          message: `NVIDIA API error: ${nvidiaResponse.body}`,
          type: 'nvidia_api_error',
          code: nvidiaResponse.statusCode
        }
      });
    }

    // 转换为 OpenAI 格式响应
    const nvidiaData = JSON.parse(nvidiaResponse.body);
    console.log('NVIDIA Response:', JSON.stringify(nvidiaData, null, 2));

    // NVIDIA API 返回的格式已经兼容 OpenAI，直接返回
    res.json(nvidiaData);

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({
      error: {
        message: error.message,
        type: 'proxy_error',
        code: 500
      }
    });
  }
});

// 错误处理
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: {
      message: err.message,
      type: 'internal_error',
      code: 500
    }
  });
});

// 404 处理
app.use((req, res) => {
  res.status(404).json({
    error: {
      message: 'Not found',
      type: 'invalid_request_error',
      code: 404
    }
  });
});

// 启动服务器
app.listen(config.port, '0.0.0.0', () => {
  console.log('='.repeat(60));
  console.log('NVIDIA to OpenAI Proxy Server Started!');
  console.log('='.repeat(60));
  console.log(`Server running at: http://localhost:${config.port}`);
  console.log(`Health check: http://localhost:${config.port}/health`);
  console.log(`Chat API: http://localhost:${config.port}/v1/chat/completions`);
  console.log(`Models: http://localhost:${config.port}/v1/models`);
  console.log('='.repeat(60));
  console.log(`NVIDIA API Base URL: ${config.nvidiaBaseUrl}`);
  console.log(`API Key configured: ${config.nvidiaApiKey ? 'Yes (masked)' : 'No'}`);
  console.log('='.repeat(60));
});

module.exports = app;
