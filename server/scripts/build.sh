#!/bin/bash
# =============================================================================
# TS-Skynet 构建脚本
# 功能: 编译 TS→Lua、清理构建产物、部署到 Docker 容器
# 注意: Skynet 引擎在 Docker 镜像构建时编译，本地不维护 Skynet
# =============================================================================

set -e

BASE_DIR=$(cd "$(dirname "$0")"/..; pwd)
cd "$BASE_DIR"

# 默认配置
SKYNET_CONTAINER="${SKYNET_CONTAINER:-tslua-skynet}"
SKYNET_SERVICE_DIR="${SKYNET_SERVICE_DIR:-/skynet/service-ts}"

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

    proto           编译 protobuf
    tables          编译 Luban 配置表
    all             完整构建 (proto + tables + ts)
    deploy          部署 Lua 代码到 Skynet 容器
    build:deploy    编译并部署到容器（开发模式）
    docker          编译并复制到 docker/service-ts/（生产镜像）
    clean           清理构建产物
    clean:all       完全清理 (包括 node_modules)

选项:
    -h, --help      显示帮助
    --container     指定 Skynet 容器名 (默认: tslua-skynet)

环境变量:
    SKYNET_CONTAINER   Skynet 容器名
    SKYNET_SERVICE_DIR 容器内服务目录路径

示例:
    ./scripts/build.sh                    # 编译 TS
    ./scripts/build.sh ts:watch           # 监视模式
    ./scripts/build.sh deploy             # 部署到容器
    ./scripts/build.sh build:deploy       # 编译并部署
    SKYNET_CONTAINER=my-skynet ./scripts/build.sh deploy
EOF
}

# 检查依赖
check_deps() {
    if [ ! -f "node_modules/.bin/tstl" ]; then
        error "缺少依赖，请先安装: npm install"
        info "所需依赖: typescript typescript-to-lua @types/node lua-types"
        exit 1
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
    local count=$(find dist/lua -name "*.lua" 2>/dev/null | wc -l)
    success "构建完成: $count 个 Lua 文件"
}

# 部署到 Skynet 容器
deploy_to_container() {
    info "部署 Lua 代码到 Skynet 容器..."

    # 检查是否有编译产物
    if [ ! -d "dist/lua" ] || [ -z "$(ls -A dist/lua 2>/dev/null)" ]; then
        error "没有编译产物，请先运行: ./scripts/build.sh ts"
        exit 1
    fi

    # 检查容器是否运行
    if ! docker ps --format '{{.Names}}' | grep -q "^${SKYNET_CONTAINER}$"; then
        warn "容器 ${SKYNET_CONTAINER} 未运行"
        info "请先启动容器: docker-compose up -d skynet"
        exit 1
    fi

    # 部署 Lua 文件
    local count=$(find dist/lua -name "*.lua" | wc -l)
    info "部署 $count 个 Lua 文件到容器..."

    # 使用 docker cp 复制文件到容器
    docker cp dist/lua/. "${SKYNET_CONTAINER}:${SKYNET_SERVICE_DIR}/"

    success "部署完成: $count 个文件已复制到 ${SKYNET_CONTAINER}:${SKYNET_SERVICE_DIR}"
    info "提示: 使用 volume 挂载时，文件会自动同步，无需重复部署"

    # 可选：发送信号让 Skynet 重新加载（如果需要热更新）
    # docker exec "${SKYNET_CONTAINER}" kill -USR1 1
}

# 复制 Lua 代码到 docker/service-ts/（用于镜像构建）
copy_to_docker() {
    info "复制 Lua 代码到 docker/service-ts/..."
    
    if [ ! -d "dist/lua" ] || [ -z "$(ls -A dist/lua 2>/dev/null)" ]; then
        error "没有编译产物，请先运行: ./scripts/build.sh ts"
        exit 1
    fi
    
    # 清理旧文件
    rm -rf "${BASE_DIR}/../../docker/service-ts"/*
    mkdir -p "${BASE_DIR}/../../docker/service-ts"
    
    # 复制新文件
    cp -r dist/lua/* "${BASE_DIR}/../../docker/service-ts/"
    
    local count=$(find "${BASE_DIR}/../../docker/service-ts" -name "*.lua" | wc -l)
    success "已复制 $count 个 Lua 文件到 docker/service-ts/"
}

# 编译并部署
build_and_deploy() {
    info "编译并部署..."
    build_ts
    deploy_to_container
}

# 编译并复制到 docker（用于镜像构建）
build_for_docker() {
    info "编译并准备 Docker 构建上下文..."
    build_ts
    copy_to_docker
    success "准备完成，现在可以构建镜像: docker-compose build skynet"
}

# 清理
clean() {
    info "清理构建产物..."
    rm -rf dist/lua
    success "清理完成"
}

# 完全清理
clean_all() {
    info "完全清理..."
    rm -rf dist node_modules
    success "完全清理完成"
}

# 清理配置
clean_config() {
    info "清理配置和构建产物..."
    rm -rf dist config/node_modules
    success "清理完成"
}

# 主逻辑
main() {
    case "${1:-ts}" in
        -h|--help) show_help ;;
        ts|lua) build_ts ;;
        ts:watch|watch) build_ts_watch ;;
        ts:service) build_service "$2" ;;

        proto|pb) build_proto ;;
        tables) build_tables ;;
        all|full) build_all ;;
        deploy) deploy_to_container ;;
        build:deploy) build_and_deploy ;;
        docker|build:docker) build_for_docker ;;
        clean) clean ;;
        clean:all|cleanall) clean_all ;;
        *) error "未知命令: $1"; show_help; exit 1 ;;
    esac
}

main "$@"
