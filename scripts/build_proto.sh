#!/bin/bash
# =============================================================================
# Protocol Buffers 编译脚本
# 功能：编译 .proto 文件生成 Lua 描述文件和 TypeScript 代码
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
PROTO_DIR="$BASE_DIR/protocols"              # .proto 源文件
PROTO_OUT_LUA="$BASE_DIR/dist/lua/common/protos"  # Lua 输出 (描述文件)
PROTO_OUT_TS="$BASE_DIR/src/common/protos"   # TypeScript 输出

echo "========================================"
echo "  Compiling Protocol Buffers"
echo "========================================"
echo "Proto src:  $PROTO_DIR"
echo "Lua out:    $PROTO_OUT_LUA"
echo "TS out:     $PROTO_OUT_TS"
echo ""

# 检查 .proto 源文件是否存在
if [ ! -d "$PROTO_DIR" ]; then
    error "Protocol source directory not found: $PROTO_DIR"
    exit 1
fi

# 创建输出目录
mkdir -p "$PROTO_OUT_LUA"
mkdir -p "$PROTO_OUT_TS"

# 查找所有 .proto 文件
PROTO_FILES=$(find "$PROTO_DIR" -name "*.proto" 2>/dev/null | sort)

if [ -z "$PROTO_FILES" ]; then
    error "No .proto files found in $PROTO_DIR"
    exit 1
fi

info "Found proto files:"
for file in $PROTO_FILES; do
    echo "  - $(basename "$file")"
done
echo ""

# 检查 protoc 命令
PROTOC_CMD=""
if command -v protoc &> /dev/null; then
    PROTOC_CMD="protoc"
elif [ -f "$BASE_DIR/node_modules/.bin/protoc" ]; then
    PROTOC_CMD="$BASE_DIR/node_modules/.bin/protoc"
else
    warn "protoc not found, skipping .desc generation"
    PROTOC_CMD=""
fi

# 1. 生成 Lua 描述文件 (用于 Skynet 的 lua-protobuf)
if [ -n "$PROTOC_CMD" ]; then
    echo "----------------------------------------"
    info "Generating Lua descriptor files..."
    echo "----------------------------------------"

    for proto_file in $PROTO_FILES; do
        filename=$(basename "$proto_file" .proto)
        "$PROTOC_CMD" --proto_path="$PROTO_DIR" \
            --descriptor_set_out="$PROTO_OUT_LUA/${filename}_pb.desc" \
            --include_imports \
            "$proto_file" 2>/dev/null && \
            success "  $filename.desc" || \
            warn "  $filename.desc (failed)"
    done
    echo ""
else
    warn "Skipping .desc generation (protoc not available)"
    echo ""
fi

# 2. 生成 TypeScript 代码 (如果安装了 protobufjs-cli)
echo "----------------------------------------"
info "Generating TypeScript files..."
echo "----------------------------------------"

if npm list pbjs >/dev/null 2>&1 || npm list -g pbjs >/dev/null 2>&1; then
    PBJS="npx pbjs"

    # 生成静态模块
    $PBJS -t static-module -w commonjs -o "$PROTO_OUT_TS/proto.js" $PROTO_FILES 2>/dev/null && \
        success "  proto.js" || \
        warn "  proto.js (failed, using handwritten version)"

    # 生成类型定义
    if [ -f "$PROTO_OUT_TS/proto.js" ]; then
        npx pbts -o "$PROTO_OUT_TS/proto.d.ts" "$PROTO_OUT_TS/proto.js" 2>/dev/null && \
            success "  proto.d.ts" || \
            warn "  proto.d.ts (failed)"
    fi
else
    warn "protobufjs-cli not installed, skipping auto-generation"
    info "Using handwritten proto.ts"
fi

echo ""
echo "========================================"
success "Protocol compilation complete!"
echo "========================================"
echo ""
echo "Output:"
echo "  Lua descriptors: $PROTO_OUT_LUA/*.desc"
echo "  TypeScript:      $PROTO_OUT_TS/proto.{ts,js,d.ts}"
echo ""
