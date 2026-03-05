@echo off
chcp 65001 >nul
:: =============================================================================
:: TS-Skynet Windows Docker 部署脚本 (批处理版本)
:: 功能: 简化版入口，完整功能请使用 docker-deploy.ps1
:: =============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║       TS-Skynet Windows Docker 部署脚本                        ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: 检查参数
if "%~1"=="" goto :show_help
if "%~1"=="-h" goto :show_help
if "%~1"=="--help" goto :show_help
if "%~1"=="help" goto :show_help

:: 调用 PowerShell 脚本
powershell -ExecutionPolicy Bypass -File "%~dp0deploy.ps1" %*
goto :end

:show_help
echo 用法: deploy.bat [命令] [选项]
echo.
echo 命令:
echo   setup      初始化环境
echo   build      构建镜像
echo   dev        启动开发环境
echo   start      启动生产环境
echo   stop       停止容器
echo   restart    重启容器
echo   status     查看状态
echo   logs       查看日志
echo   deploy     部署代码
echo   shell      进入容器 Shell
echo   clean      清理环境
echo.
echo 选项:
echo   -Daemon    后台运行 (用于 dev/start)
echo   -NoCache   不使用缓存 (用于 build)
echo.
echo 示例:
echo   docker-deploy.bat setup
echo   docker-deploy.bat dev
echo   docker-deploy.bat dev -Daemon
echo   docker-deploy.bat build
echo   docker-deploy.bat start -Daemon
echo   docker-deploy.bat status
echo.
echo 提示: 完整功能请使用 PowerShell 脚本
echo   powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Help
echo.
goto :end

:end
