#!/bin/bash
# =============================================================================
# TS-Skynet 开发工具脚本
# 功能: 一键启动、热更新、Docker构建、Node.js模式运行
# =============================================================================

set -e

BASE_DIR=$(cd "$(dirname "$0")"/..; pwd)
cd "$BASE_DIR"

# 颜色
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${CYAN}[STEP]${NC} $1"; }

show_help() {
    cat << 'EOF'
TS-Skynet 开发工具脚本

用法: ./scripts/dev.sh <命令> [选项]

命令:
    up                  一键启动 (构建 + 部署 + 启动)
    up:daemon           一键后台启动
    hotfix SERVICE      热更新服务 (login/game/gateway/all)
    node                Node.js 模式运行 (开发调试)
    docker:build        Docker 构建模式
    setup               安装依赖并构建

选项:
    -h, --help          显示帮助
    -f, --force         强制重新构建
    -s, --skip-build    跳过构建

示例:
    ./scripts/dev.sh up                 # 一键启动
    ./scripts/dev.sh up:daemon          # 后台启动
    ./scripts/dev.sh hotfix login       # 热更新登录服务
    ./scripts/dev.sh hotfix all         # 热更新所有服务
    ./scripts/dev.sh node               # Node.js 模式调试
    ./scripts/dev.sh docker:build       # Docker 构建
EOF
}

# 查找 PID
find_pid() {
    if [ -f "$BASE_DIR/logs/skynet.pid" ]; then
        local pid=$(cat "$BASE_DIR/logs/skynet.pid" 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then echo "$pid"; return 0; fi
    fi
    local pid=$(pgrep -f "skynet.*config" | head -1)
    if [ -n "$pid" ]; then echo "$pid"; return 0; fi
    echo ""; return 1
}

# 一键启动
cmd_up() {
    local daemon=${1:-false}
    local force=${2:-false}
    local skip=${3:-false}

    echo "========================================"
    echo "  TS-Skynet 一键启动"
    echo "========================================"
    echo ""

    # 构建
    if [ "$skip" != true ]; then
        if [ "$force" = true ]; then
            ./scripts/build.sh clean
        fi
        step "1/3 构建项目..."
        ./scripts/build.sh all
        echo ""
    fi

    # 启动
    step "2/3 启动服务器..."
    if [ "$daemon" = true ]; then
        ./scripts/server.sh start -d
    else
        step "3/3 服务器运行中 (按 Ctrl+C 停止)..."
        echo ""
        ./scripts/server.sh start
    fi
}

# 热更新
cmd_hotfix() {
    local service=$1
    if [ -z "$service" ]; then
        error "请指定服务: login/game/gateway/all"
        exit 1
    fi

    info "热更新服务: $service"
    warn "注意：热更新功能需要在 Docker 环境中实现"
    
    # 编译
    if [ "$service" = "all" ]; then
        ./scripts/build.sh ts
    else
        ./scripts/build.sh ts:service "$service"
    fi

    info "编译完成，请手动部署到 Docker 容器:"
    echo "  ./scripts/build.sh deploy"
    
    success "$service 热更新文件准备完成"
}

# Node.js 模式运行
cmd_node() {
    info "Node.js 模式启动 (开发调试)..."
    if ! command -v ts-node &> /dev/null; then
        error "缺少 ts-node，请先安装: npm install -g ts-node"
        exit 1
    fi
    ts-node src/app/bootstrap-node.ts
}

# Docker 构建
cmd_docker() {
    info "Docker 构建模式..."

    # 创建 Dockerfile.build (如果不存在)
    if [ ! -f "Dockerfile.build" ]; then
        cat > Dockerfile.build << 'DOCKERFILE'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps --no-audit 2>/dev/null || \
    npm install typescript typescript-to-lua @types/node lua-types --save-dev --legacy-peer-deps
COPY . .
CMD ["npm", "run", "build"]
DOCKERFILE
    fi

    # 构建镜像
    docker build -t ts-skynet-build -f Dockerfile.build .

    # 运行构建
    docker run --rm -v "$(pwd):/app" -w /app ts-skynet-build sh -c "npm run build"

    success "Docker 构建完成"
}

# 安装依赖并构建
cmd_setup() {
    info "安装依赖..."
    npm install typescript typescript-to-lua @types/node lua-types --save-dev --legacy-peer-deps
    info "开始构建..."
    ./scripts/build.sh all
    success "安装和构建完成"
}

# 主逻辑
main() {
    case "${1:-}" in
        up)
            shift
            local daemon=false force=false skip=false
            while [[ $# -gt 0 ]]; do
                case $1 in -d|--daemon) daemon=true; shift ;; -f|--force) force=true; shift ;; -s|--skip) skip=true; shift ;; *) shift ;; esac
            done
            cmd_up "$daemon" "$force" "$skip"
            ;;
        up:daemon)
            cmd_up true false false
            ;;
        hotfix|hf)
            cmd_hotfix "$2"
            ;;
        node|dev)
            cmd_node
            ;;
        docker:build|docker)
            cmd_docker
            ;;
        setup|install)
            cmd_setup
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
