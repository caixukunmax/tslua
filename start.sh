#!/bin/bash
# TS-Skynet 快速启动入口 (Linux/macOS)
# 使用跨平台 CLI，命令与 Windows 完全一致

cd "$(dirname "$0")"
npm run cli -- "$@"
