@echo off
REM 测试不同环境的连接

echo ========================================
echo NVIDIA 代理服务器 - 环境测试
echo ========================================
echo.

REM 检查服务是否运行
echo [1/4] 检查服务状态...
curl -s http://localhost:3000/health >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 服务未运行！
    echo 请先启动服务: npm start
    echo.
    pause
    exit /b 1
)
echo [成功] 服务正常运行
echo.

REM 测试 Python CLI
echo [2/4] 测试 Python CLI...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [跳过] Python 未安装
) else (
    python nvidia-chat.py --check >nul 2>&1
    if %errorlevel% neq 0 (
        echo [失败] Python CLI 测试失败
    ) else (
        echo [成功] Python CLI 可用
        echo.
        echo 测试调用:
        python nvidia-chat.py "说个简短的问候语"
    )
)
echo.

REM 测试 API 调用
echo [3/4] 测试 API 调用...
echo 发送请求...
curl -s -X POST http://localhost:3000/v1/chat/completions ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer test-key" ^
  -d "{\"model\":\"z-ai/glm-4.7\",\"messages\":[{\"role\":\"user\",\"content\":\"说一个字\"}],\"max_tokens\":10}"
echo.
echo.

REM 测试模型列表
echo [4/4] 测试模型列表...
curl -s http://localhost:3000/v1/models | findstr "\"id\":" >nul 2>&1
if %errorlevel% neq 0 (
    echo [失败] 获取模型列表失败
) else (
    echo [成功] 模型列表可用
    echo.
    echo 前 5 个模型:
    curl -s http://localhost:3000/v1/models | find "\"id\":" | findstr /C:"glm" /C:"qwen" /C:"llama" | head -5
)
echo.

echo ========================================
echo 测试完成！
echo ========================================
echo.
echo 如果所有测试通过，你可以开始使用！
echo.
echo 快速开始:
echo   - Python: python nvidia-chat.py "你的问题"
echo   - Node.js: node example.js
echo   - API: curl http://localhost:3000/v1/models
echo.
echo 详细文档:
echo   - PROJECT_OVERVIEW.md (项目总览)
echo   - QUICKSTART.md (快速开始)
echo   - INTEGRATION_GUIDE.md (完整集成)
echo.
pause
