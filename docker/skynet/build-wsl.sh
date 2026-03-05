#!/bin/bash
# Skynet 编译脚本 for WSL
# 禁用 jemalloc 以兼容 WSL 环境

set -e

echo "========================================="
echo "  Building Skynet for WSL (no jemalloc)"
echo "========================================="

# 清理旧的编译产物
echo "[1/2] Cleaning old build..."
make clean

# 编译 Skynet（禁用 jemalloc）
echo "[2/2] Building Skynet..."
make linux MALLOC_STATICLIB= SKYNET_DEFINES=-DNOUSE_JEMALLOC

echo ""
echo "========================================="
echo "  Build completed successfully!"
echo "========================================="
echo "Skynet executable: $(pwd)/skynet"
ls -lh skynet
