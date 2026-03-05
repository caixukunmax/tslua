#!/usr/bin/env pwsh
# TS-Skynet 快速启动入口 (Windows PowerShell)
# 使用跨平台 CLI，命令与 Linux/macOS 完全一致

Set-Location $PSScriptRoot
npm run cli -- $args
