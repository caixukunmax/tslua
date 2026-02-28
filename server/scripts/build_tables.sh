#!/usr/bin/env bash
# =============================================================================
# Luban 配置表编译脚本（服务器侧调用）
# 功能：调用 tables/ 目录的编译脚本
# =============================================================================

BASE_DIR=$(cd "$(dirname "$0")"/..; pwd)
TABLES_SCRIPT="$BASE_DIR/../tables/scripts/build_tables.ts"

# 检查 tsx 是否可用
if command -v tsx &> /dev/null; then
    exec tsx "$TABLES_SCRIPT" "$@"
else
    # 回退到 npx
    exec npx tsx "$TABLES_SCRIPT" "$@"
fi
