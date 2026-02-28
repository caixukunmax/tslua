#!/bin/bash
# TS-Skynet 快速启动
# 用法：./start.sh [命令]

cd "$(dirname "$0")"

case "${1:-}" in
    start|up)
        ./scripts/start.sh
        ;;
    build)
        npm run build:ts
        ;;
    tables)
        ./scripts/build_tables.sh
        ;;
    clean)
        ./scripts/build.sh clean
        ;;
    status)
        ./scripts/server.sh status
        ;;
    stop)
        ./scripts/server.sh stop
        ;;
    restart)
        ./scripts/server.sh restart
        ;;
    hotfix)
        ./scripts/dev.sh hotfix "${2:-all}"
        ;;
    node)
        npm run dev
        ;;
    logs)
        tail -50 logs/*.log 2>/dev/null || echo "无日志文件"
        ;;
    help|-h|--help)
        echo "TS-Skynet 快速命令"
        echo ""
        echo "用法：./start.sh [命令]"
        echo ""
        echo "命令:"
        echo "  start       打开菜单界面 (推荐)"
        echo "  build       编译 TS→Lua"
        echo "  tables      编译 Luban 配置表"
        echo "  clean       清理构建产物"
        echo "  status      查看服务状态"
        echo "  stop        停止服务"
        echo "  restart     重启服务"
        echo "  hotfix [服务]  热更新 (login/gateway/game/all)"
        echo "  node        Node.js 模式"
        echo "  logs        查看日志"
        echo "  help        显示帮助"
        echo ""
        echo "示例:"
        echo "  ./start.sh           # 打开菜单"
        echo "  ./start.sh build     # 编译 TS"
        echo "  ./start.sh tables    # 编译配置表"
        echo "  ./start.sh hotfix login  # 热更新登录服务"
        ;;
    *)
        ./scripts/start.sh
        ;;
esac
