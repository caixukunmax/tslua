#!/bin/bash
# =============================================================================
# TS-Skynet 构建脚本
# 功能: 编译 TS→Lua、编译 Skynet 引擎、清理构建产物
# =============================================================================

set -e

BASE_DIR=$(cd "$(dirname "$0")"/..; pwd)
cd "$BASE_DIR"

# 颜色
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    cat << 'EOF'
TS-Skynet 构建脚本

用法: ./scripts/build.sh <命令> [选项]

命令:
    ts              编译 TypeScript → Lua (默认)
    ts:watch        监视模式编译 TS
    ts:service NAME 编译指定服务 (login/game/gateway)
    engine          编译 Skynet C 引擎
    proto           编译 protobuf
    tables          编译 Luban 配置表
    all             完整构建 (proto + tables + ts)
    clean           清理构建产物
    clean:all       完全清理 (包括 node_modules)

选项:
    -h, --help      显示帮助

示例:
    ./scripts/build.sh                    # 编译 TS
    ./scripts/build.sh ts:watch           # 监视模式
    ./scripts/build.sh ts:service login   # 编译登录服务
    ./scripts/build.sh engine             # 编译 Skynet 引擎
    ./scripts/build.sh all                # 完整构建
    ./scripts/build.sh clean              # 清理
EOF
}

# 检查依赖
check_deps() {
    if [ ! -f "node_modules/.bin/tstl" ]; then
        warn "依赖未安装，尝试安装..."
        npm install typescript typescript-to-lua @types/node lua-types --save-dev --legacy-peer-deps 2>&1 | tail -3
    fi
}

# 编译 TypeScript
build_ts() {
    info "编译 TypeScript → Lua..."
    check_deps
    npx tstl --project config/tsconfig.lua.json
    success "编译完成 → dist/lua/"
}

# 监视模式
build_ts_watch() {
    info "监视模式编译 (按 Ctrl+C 停止)..."
    check_deps
    npx tstl --watch
}

# 编译指定服务
build_service() {
    local service=$1
    if [ -z "$service" ]; then
        error "请指定服务名: login/game/gateway"
        exit 1
    fi
    info "编译服务: $service"
    check_deps
    npx tstl --project config/tsconfig.lua.json
    success "$service 编译完成"
}

# 编译 Skynet 引擎
build_engine() {
    info "编译 Skynet 引擎..."
    if [ ! -d "skynet" ]; then
        error "skynet/ 目录不存在"
        exit 1
    fi
    cd skynet
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        make PLAT=mingw
    else
        make linux
    fi
    cd ..
    success "Skynet 引擎编译完成"
}

# 编译 protobuf
build_proto() {
    info "编译 protobuf..."
    if [ -f "scripts/build_proto.sh" ]; then
        ./scripts/build_proto.sh
    else
        warn "protobuf 编译脚本不存在，跳过"
    fi
}

# 编译 Luban 配置表
build_tables() {
    info "编译 Luban 配置表..."
    if [ -f "scripts/build_tables.sh" ]; then
        ./scripts/build_tables.sh
    else
        warn "Luban 编译脚本不存在，跳过"
    fi
}

# 完整构建
build_all() {
    info "完整构建..."
    build_proto
    build_tables
    build_ts
    # 复制到 Skynet
    mkdir -p skynet/service-ts
    cp -r dist/lua/* skynet/service-ts/ 2>/dev/null || true
    local count=$(find skynet/service-ts -name "*.lua" 2>/dev/null | wc -l)
    success "构建完成: $count 个 Lua 文件已部署"
}

# 清理
clean() {
    info "清理构建产物..."
    rm -rf dist/lua skynet/service-ts
    success "清理完成"
}

# 完全清理
clean_all() {
    info "完全清理..."
    rm -rf dist node_modules skynet/service-ts
    success "完全清理完成"
}

# 清理配置
clean_config() {
    info "清理配置和构建产物..."
    rm -rf dist config/node_modules skynet/service-ts
    success "清理完成"
}

# 主逻辑
main() {
    case "${1:-ts}" in
        -h|--help) show_help ;;
        ts|lua) build_ts ;;
        ts:watch|watch) build_ts_watch ;;
        ts:service) build_service "$2" ;;
        engine|skynet) build_engine ;;
        proto|pb) build_proto ;;
        tables) build_tables ;;
        all|full) build_all ;;
        clean) clean ;;
        clean:all|cleanall) clean_all ;;
        *) error "未知命令: $1"; show_help; exit 1 ;;
    esac
}

main "$@"
