#!/bin/bash
# TS-Skynet 快速启动入口
# 实际脚本在 server/scripts/start.sh

cd "$(dirname "$0")/server"
./scripts/start.sh "$@"
