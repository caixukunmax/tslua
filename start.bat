@echo off
chcp 65001 >nul
REM TS-Skynet 快速启动入口 (Windows CMD)
REM 使用跨平台 CLI，命令与 Linux/macOS 完全一致

cd /d "%~dp0"
npm run cli -- %*
