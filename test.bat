@echo off
REM 快速测试 NVIDIA to OpenAI Proxy 服务器

echo ========================================
echo 测试代理服务器
echo ========================================
echo.

REM 检查 curl 是否可用
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] curl 未安装，请先安装 curl
    pause
    exit /b 1
)

echo [测试 1] 健康检查...
curl -s http://localhost:3000/health
echo.
echo.

echo [测试 2] 列出模型...
curl -s http://localhost:3000/v1/models
echo.
echo.

echo [测试 3] 简单对话...
curl -s -X POST http://localhost:3000/v1/chat/completions ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer test-key" ^
  -d "{\"model\": \"z-ai/glm-4.7\", \"messages\": [{\"role\": \"user\", \"content\": \"你好，请用一句话介绍你自己。\"}], \"max_tokens\": 50}"
echo.
echo.

echo ========================================
echo 测试完成
echo ========================================
pause
