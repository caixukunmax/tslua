#!/usr/bin/env pwsh
# TS-Skynet 快速启动入口 (Windows PowerShell)
# 使用跨平台 CLI，命令与 Linux/macOS 完全一致
#
# 用法:
#   .\start.ps1 [命令]                      使用默认配置
#   .\start.ps1 [命令] [配置文件路径]       使用指定配置文件
#
# 示例:
#   .\start.ps1                             显示菜单
#   .\start.ps1 quick                       一键启动
#   .\start.ps1 build:ts                    编译 TS→Lua
#   .\start.ps1 build:ts tslua.config.test.yaml    使用指定配置

Set-Location $PSScriptRoot

# 设置默认配置文件
$env:TSLUA_CONFIG = "tslua.config.yaml"

# 获取参数
$cmd = $args[0]
$configFile = $args[1]

if ($configFile) {
    Write-Host "[Config] $configFile"
    $env:TSLUA_CONFIG = $configFile
}

if (-not $cmd) {
    # 没有参数，显示菜单
    npm run cli
} else {
    # 执行指定命令
    npm run cli -- $cmd
}
