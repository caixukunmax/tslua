#!/bin/bash
# =============================================================================
# TS-Skynet 快速启动脚本
# 提供简单的菜单式操作，无需记忆复杂命令
# =============================================================================

set -e

BASE_DIR=$(cd "$(dirname "$0")"/..; pwd)
cd "$BASE_DIR"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 显示菜单
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}       ${BLUE}TS-Skynet 快速启动菜单${NC}                          ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}1. 一键启动${NC} (自动检查 + 构建 + 启动)              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}2. 启动服务${NC} (自动检查依赖)                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}3. 停止服务${NC}                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}4. 重启服务${NC}                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}5. 查看状态${NC}                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}6. 热更新服务${NC}                                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}7. Node.js 模式 (开发调试)${NC}                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}8. 编译 TS→Lua${NC}                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}9. 编译 Luban 配置表${NC}                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}10. 完整构建${NC} (Proto+Luban+TS)                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}11. 清理构建产物${NC}                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}0. 退出${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${BLUE}快捷命令:${NC}                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    q     - 退出                                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    s     - 查看状态                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    h     - 热更新                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    b     - 编译 TS                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    t     - 编译配置表                            ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${BLUE}高级选项:${NC}                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    d     - 后台启动                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    f     - 强制重新构建                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    r     - 查看日志                              ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}按数字键或字母键选择操作${NC}                          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}提示:${NC} 首次运行请选择 1. 一键启动"
    echo ""
}

# 查找 PID
find_pid() {
    if [ -f "$BASE_DIR/logs/skynet.pid" ]; then
        local pid=$(cat "$BASE_DIR/logs/skynet.pid" 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then echo "$pid"; return 0; fi
    fi
    local pid=$(pgrep -f "skynet.*config" | head -1)
    if [ -n "$pid" ]; then echo "$pid"; return 0; fi
    echo ""
}

# 1. 一键启动
cmd_quick_start() {
    echo -e "${BLUE}>>> 一键启动...${NC}"
    echo ""
    # 检查 Skynet 是否已编译
    if [ ! -f "$BASE_DIR/skynet/skynet" ]; then
        echo -e "${YELLOW}Skynet 引擎未编译，正在编译...${NC}"
        ./scripts/build.sh engine
        echo ""
    fi
    # 编译 TS→Lua
    ./scripts/build.sh ts
    echo ""
    # 启动服务
    ./scripts/server.sh start
}

# 2. 启动服务 (只启动，不构建)
cmd_start() {
    echo -e "${BLUE}>>> 启动 Skynet 服务...${NC}"
    # 检查 Skynet 是否已编译
    if [ ! -f "$BASE_DIR/skynet/skynet" ]; then
        echo -e "${YELLOW}Skynet 引擎未编译，正在编译...${NC}"
        ./scripts/build.sh engine
        echo ""
    fi
    # 检查 Lua 文件是否存在
    if [ ! -d "$BASE_DIR/dist/lua" ]; then
        echo -e "${YELLOW}Lua 文件未编译，正在编译...${NC}"
        ./scripts/build.sh ts
        echo ""
    fi
    ./scripts/server.sh start
}

# 3. 停止服务
cmd_stop() {
    echo -e "${BLUE}>>> 停止服务...${NC}"
    ./scripts/server.sh stop
}

# 4. 重启服务
cmd_restart() {
    echo -e "${BLUE}>>> 重启服务...${NC}"
    ./scripts/server.sh restart
}

# 5. 查看状态
cmd_status() {
    echo -e "${BLUE}>>> 服务器状态:${NC}"
    ./scripts/server.sh status
}

# 6. 热更新服务
cmd_hotfix() {
    echo -e "${BLUE}>>> 热更新服务${NC}"
    echo "选择要热更新的服务:"
    echo "  1) login (登录服务)"
    echo "  2) gateway (网关服务)"
    echo "  3) game (游戏服务)"
    echo "  4) all (所有服务)"
    read -p "请选择 [1-4]: " choice
    case $choice in
        1) ./scripts/dev.sh hotfix login ;;
        2) ./scripts/dev.sh hotfix gateway ;;
        3) ./scripts/dev.sh hotfix game ;;
        4) ./scripts/dev.sh hotfix all ;;
        *) echo "无效选择" ;;
    esac
}

# 7. Node.js 模式
cmd_node() {
    echo -e "${BLUE}>>> Node.js 模式启动 (开发调试)...${NC}"
    npm run dev
}

# 8. 编译 TS→Lua
cmd_build() {
    echo -e "${BLUE}>>> 编译 TypeScript → Lua...${NC}"
    npm run build:ts
}

# 9. 编译 Luban 配置表
cmd_tables() {
    echo -e "${BLUE}>>> 编译 Luban 配置表...${NC}"
    ./scripts/build_tables.sh
    echo -e "${GREEN}配置表编译完成${NC}"
    read -p "按回车继续..."
}

# 10. 完整构建
cmd_build_all() {
    echo -e "${BLUE}>>> 完整构建 (Proto+Luban+TS)...${NC}"
    ./scripts/build.sh all
    echo -e "${GREEN}完整构建完成${NC}"
    read -p "按回车继续..."
}

# 11. 清理
cmd_clean() {
    echo -e "${BLUE}>>> 清理构建产物...${NC}"
    ./scripts/build.sh clean
    echo -e "${GREEN}清理完成${NC}"
    read -p "按回车继续..."
}

# 后台启动
cmd_daemon() {
    echo -e "${BLUE}>>> 后台启动服务...${NC}"
    ./scripts/server.sh start -d
    echo -e "${GREEN}服务已在后台启动${NC}"
    read -p "按回车继续..."
}

# 强制重新构建
cmd_force_build() {
    echo -e "${BLUE}>>> 强制重新构建...${NC}"
    ./scripts/build.sh clean
    ./scripts/build.sh all
    echo -e "${GREEN}构建完成${NC}"
    read -p "按回车继续..."
}

# 查看日志
cmd_logs() {
    echo -e "${BLUE}>>> 最新日志 (最后 50 行):${NC}"
    local latest_log=$(ls -t "$BASE_DIR/logs/"*.log 2>/dev/null | head -1)
    if [ -n "$latest_log" ]; then
        tail -50 "$latest_log"
    else
        echo "未找到日志文件"
    fi
    read -p "按回车继续..."
}

# 主循环
while true; do
    show_menu
    read -p "请选择操作： " choice
    case $choice in
        1) cmd_quick_start ;;
        2) cmd_start ;;
        3) cmd_stop ;;
        4) cmd_restart ;;
        5) cmd_status ;;
        6) cmd_hotfix ;;
        7) cmd_node ;;
        8) cmd_build ;;
        9) cmd_tables ;;
        10) cmd_build_all ;;
        11) cmd_clean ;;
        0|q|Q) echo -e "${GREEN}再见!${NC}"; exit 0 ;;
        s|S) cmd_status ;;
        h|H) cmd_hotfix ;;
        b|B) cmd_build ;;
        t|T) cmd_tables ;;
        d|D) cmd_daemon ;;
        f|F) cmd_force_build ;;
        r|R) cmd_logs ;;
        *) echo -e "${RED}无效选择，请重试${NC}"; sleep 1 ;;
    esac
done
