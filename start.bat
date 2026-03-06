@echo off
chcp 65001 >nul
REM TS-Skynet 快速启动入口 (Windows CMD)
REM 使用跨平台 CLI，命令与 Linux/macOS 完全一致
REM 
REM 用法: 
REM   start.bat [命令]                      使用默认配置 (tslua.config.yaml)
REM   start.bat [命令] [配置文件路径]       使用指定配置文件
REM
REM 示例:
REM   start.bat                             显示菜单
REM   start.bat quick                       一键启动（默认配置）
REM   start.bat build:ts                    编译 TS→Lua（默认配置）
REM   start.bat build:ts tslua.config.test.yaml      使用测试配置

cd /d "%~dp0"

REM 设置默认配置文件
set "TSLUA_CONFIG=tslua.config.yaml"

REM 获取第一个参数（命令）
set "CMD=%~1"

REM 获取第二个参数（配置文件路径）
set "CONFIG_FILE=%~2"

if not "%CONFIG_FILE%"=="" (
    echo [Config] %CONFIG_FILE%
    set "TSLUA_CONFIG=%CONFIG_FILE%"
)

if "%CMD%"=="" (
    REM 没有参数，显示菜单
    npm run cli
) else (
    REM 执行指定命令
    npm run cli -- %CMD%
)
