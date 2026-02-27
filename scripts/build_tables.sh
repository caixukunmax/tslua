#!/bin/bash
# =============================================================================
# Luban 配置表编译脚本
# 功能：从 Excel 生成 Lua 配置代码
# =============================================================================

set -e

BASE_DIR=$(cd "$(dirname "$0")"/..; pwd)
cd "$BASE_DIR"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 目录定义
LUBAN_DLL="$BASE_DIR/tools/luban/Luban/Luban.dll"
TABLES_DIR="$BASE_DIR/config/tables"
OUTPUT_DIR="$BASE_DIR/src/common/tables"

echo "========================================"
echo "  Compiling Luban Configuration Tables"
echo "========================================"
echo "Luban DLL:  $LUBAN_DLL"
echo "Tables dir: $TABLES_DIR"
echo "Output dir: $OUTPUT_DIR"
echo ""

# 检查 Luban DLL
if [ ! -f "$LUBAN_DLL" ]; then
    error "Luban.dll not found: $LUBAN_DLL"
    exit 1
fi

# 检查 dotnet 命令
if ! command -v dotnet &> /dev/null; then
    error "dotnet not found"
    echo ""
    echo "Luban 需要 .NET SDK 才能运行。"
    echo ""
    echo "安装 .NET SDK:"
    echo "  Ubuntu/Debian: sudo apt-get install dotnet-sdk-8.0"
    echo "  CentOS/RHEL:   sudo yum install dotnet-sdk-8.0"
    echo "  macOS:         brew install --cask dotnet-sdk"
    echo "  Windows:       访问 https://dotnet.microsoft.com/download"
    echo ""
    echo "或者使用预编译的 Luban 可执行文件 (如果有)"
    exit 1
fi

# 检查配置文件
if [ ! -f "$TABLES_DIR/luban.conf" ]; then
    error "luban.conf not found: $TABLES_DIR/luban.conf"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

cd "$TABLES_DIR"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/data"

echo "----------------------------------------"
info "Generating Lua code and JSON data..."
echo "----------------------------------------"

# 生成 Lua 代码和数据
dotnet "$LUBAN_DLL" \
    -t all \
    -c lua-lua \
    -d lua \
    -f \
    --conf luban.conf \
    -x outputCodeDir="$OUTPUT_DIR" \
    -x outputDataDir="$OUTPUT_DIR/data" \
    -x l10n.textProviderFile=datas/l10n/texts.json \
    2>&1 && \
    success "Lua code and JSON data generated: $OUTPUT_DIR" || \
    error "Failed to generate Luban output"

echo ""
echo "========================================"
success "Luban compilation complete!"
echo "========================================"
echo ""
