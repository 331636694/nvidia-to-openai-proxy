@echo off
REM 启动 NVIDIA to OpenAI Proxy 服务器

echo ========================================
echo NVIDIA to OpenAI Proxy Server
echo ========================================
echo.

REM 检查 Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Node.js 未安装，请先安装 Node.js
    pause
    exit /b 1
)

REM 检查依赖
if not exist "node_modules" (
    echo [信息] 首次运行，正在安装依赖...
    call npm install
    if %errorlevel% neq 0 (
        echo [错误] 依赖安装失败
        pause
        exit /b 1
    )
    echo [成功] 依赖安装完成
    echo.
)

echo [启动] 启动代理服务器...
echo [信息] 服务器将在 http://localhost:3000 运行
echo [信息] 按 Ctrl+C 停止服务器
echo.

REM 启动服务器
node server.js

pause
