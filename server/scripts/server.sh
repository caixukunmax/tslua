#!/bin/bash
# =============================================================================
# TS-Skynet 服务器管理脚本
# 功能: 启动、停止、重启、查看状态
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
header() { echo -e "${CYAN}$1${NC}"; }

SKYNET_DIR="$BASE_DIR/skynet"
PID_FILE="$BASE_DIR/logs/skynet.pid"
CONFIG_FILE="${CONFIG_FILE:-$SKYNET_DIR/config.tslua}"
DAEMON=false
FORCE=false

show_help() {
    cat << 'EOF'
TS-Skynet 服务器管理脚本

用法: ./scripts/server.sh <命令> [选项]

命令:
    start       启动服务器
    stop        停止服务器
    restart     重启服务器
    status      查看服务器状态

选项:
    -d, --daemon        后台模式 (start/restart)
    -f, --force         强制停止 (stop/restart)
    -c, --config FILE   指定配置文件
    -l, --log FILE      指定日志文件 (后台模式)
    -h, --help          显示帮助

示例:
    ./scripts/server.sh start             # 前台启动
    ./scripts/server.sh start -d          # 后台启动
    ./scripts/server.sh stop              # 优雅停止
    ./scripts/server.sh stop -f           # 强制停止
    ./scripts/server.sh restart -d        # 后台重启
    ./scripts/server.sh status            # 查看状态
    ./scripts/server.sh status -w         # 持续监视
EOF
}

# 查找 PID
find_pid() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            echo "$pid"; return 0
        fi
    fi
    local pid=$(pgrep -f "skynet.*config" | head -1)
    if [ -n "$pid" ]; then echo "$pid"; return 0; fi
    echo ""; return 1
}

# 启动服务器
cmd_start() {
    local pid=$(find_pid)
    if [ -n "$pid" ]; then
        warn "服务器已在运行 (PID: $pid)"
        return 0
    fi

    info "启动服务器..."
    mkdir -p logs

    # 检查 Skynet
    if [ ! -f "$SKYNET_DIR/skynet" ]; then
        error "Skynet 未编译，运行: ./scripts/build.sh engine"
        exit 1
    fi

    # 检查 Lua 文件是否存在
    if [ ! -d "$BASE_DIR/dist/lua" ]; then
        warn "Lua 文件不存在，尝试构建..."
        ./scripts/build.sh ts
    fi

    cd "$SKYNET_DIR"

    if [ "$DAEMON" = true ]; then
        local logfile="${LOG_FILE:-$BASE_DIR/logs/skynet_$(date +%Y%m%d_%H%M%S).log}"
        nohup ./skynet "$CONFIG_FILE" > "$logfile" 2>&1 &
        echo $! > "$PID_FILE"
        success "后台启动成功 (PID: $!)"
        info "日志: $logfile"
        info "查看日志: tail -f $logfile"
    else
        success "前台启动 (按 Ctrl+C 停止)"
        echo ""
        ./skynet "$CONFIG_FILE"
    fi
}

# 停止服务器
cmd_stop() {
    local pid=$(find_pid)
    if [ -z "$pid" ]; then
        warn "服务器未运行"
        rm -f "$PID_FILE"
        return 0
    fi

    info "停止服务器 (PID: $pid)..."

    if [ "$FORCE" = true ]; then
        kill -9 "$pid" 2>/dev/null || true
        success "强制停止完成"
    else
        kill -TERM "$pid" 2>/dev/null || true
        local count=0
        while kill -0 "$pid" 2>/dev/null && [ $count -lt 30 ]; do
            sleep 1; count=$((count + 1))
        done
        if kill -0 "$pid" 2>/dev/null; then
            warn "优雅停止超时，使用 -f 强制停止"
            return 1
        fi
        success "优雅停止完成"
    fi

    rm -f "$PID_FILE"
}

# 重启服务器
cmd_restart() {
    info "重启服务器..."
    cmd_stop || true
    sleep 2
    cmd_start
}

# 查看状态
cmd_status() {
    local watch_mode=false
    if [ "$1" = "-w" ] || [ "$1" = "--watch" ]; then
        watch_mode=true
    fi

    show_status() {
        header "========================================"
        header "  TS-Skynet 服务器状态"
        header "========================================"
        echo ""

        local pid=$(find_pid)
        if [ -z "$pid" ]; then
            error "状态: 未运行 ❌"
            return
        fi

        success "状态: 运行中 ✅"
        echo "  PID:      $pid"
        echo "  启动时间: $(ps -o lstart= -p $pid 2>/dev/null || echo 'N/A')"
        echo "  运行时长: $(ps -o etime= -p $pid 2>/dev/null || echo 'N/A')"

        local cpu=$(ps -p $pid -o %cpu= 2>/dev/null | tr -d ' ')
        local mem=$(ps -p $pid -o %mem= 2>/dev/null | tr -d ' ')
        echo "  CPU:      ${cpu:-0}%"
        echo "  内存:     ${mem:-0}%"

        local lua_count=$(find "$SKYNET_DIR/service-ts" -name "*.lua" 2>/dev/null | wc -l)
        echo "  Lua文件:  $lua_count 个"
        echo ""
        header "操作命令:"
        echo "  停止:  ./scripts/server.sh stop"
        echo "  重启:  ./scripts/server.sh restart"
        echo "  热更:  ./scripts/dev.sh hotfix login"
        echo ""
        header "========================================"
    }

    if [ "$watch_mode" = true ]; then
        while true; do clear; show_status; echo "按 Ctrl+C 退出监视"; sleep 2; done
    else
        show_status
    fi
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--daemon) DAEMON=true; shift ;;
            -f|--force) FORCE=true; shift ;;
            -c|--config) CONFIG_FILE="$2"; shift 2 ;;
            -l|--log) LOG_FILE="$2"; shift 2 ;;
            -h|--help) show_help; exit 0 ;;
            -w|--watch) shift ;; # status 命令处理
            *) shift ;;
        esac
    done
}

# 主逻辑
main() {
    case "${1:-}" in
        start)
            shift; parse_args "$@"
            cmd_start
            ;;
        stop)
            shift; parse_args "$@"
            cmd_stop
            ;;
        restart|reload)
            shift; parse_args "$@"
            cmd_restart
            ;;
        status)
            shift
            cmd_status "$@"
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
