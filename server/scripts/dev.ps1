# =============================================================================
# TS-Skynet 开发脚本 (Windows PowerShell)
# 功能: 启动开发环境、热重载、设置项目
# =============================================================================

param(
    [Parameter(Position=0)]
    [string]$Command = "setup",
    
    [string]$Mode = "ts",
    [switch]$Help
)

function Show-Help {
    @"
TS-Skynet 开发脚本 (Windows)

用法: .\scripts\dev.ps1 <命令> [选项]

命令:
    setup           初始化项目环境 (安装依赖、创建目录)
    node            启动 Node.js 开发模式 (默认)
    up              启动 Docker 开发环境
    up:daemon       后台启动 Docker 环境
    down            停止 Docker 环境
    hotfix          热更新服务代码

选项:
    -Help           显示帮助

示例:
    .\scripts\dev.ps1 setup              # 初始化项目
    .\scripts\dev.ps1 node               # Node.js 模式
    .\scripts\dev.ps1 up                 # Docker 开发环境
    .\scripts\dev.ps1 down               # 停止环境
"@
}

# 路径
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BASE_DIR = Resolve-Path "$SCRIPT_DIR\.." | Select-Object -Expand Path
Set-Location $BASE_DIR

function Write-Info { param([string]$msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success { param([string]$msg) Write-Host "[SUCCESS] $msg" -ForegroundColor Green }
function Write-Warn { param([string]$msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Error { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

# 设置项目
function Setup-Project {
    Write-Info "初始化项目..."
    
    # 创建目录
    $dirs = @("dist\lua", "logs", "tmp")
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Info "创建目录: $dir"
        }
    }
    
    # 检查 npm
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Error "未找到 npm，请先安装 Node.js"
        exit 1
    }
    
    # 安装依赖
    if (-not (Test-Path "node_modules")) {
        Write-Info "安装 npm 依赖..."
        npm install
    }
    
    # 检查 Docker
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        Write-Info "Docker 已安装"
        docker --version
    } else {
        Write-Warn "未找到 Docker，Docker 功能将不可用"
    }
    
    Write-Success "项目初始化完成！"
    Write-Info "下一步:"
    Write-Info "  开发模式: npm run dev"
    Write-Info "  Docker模式: docker-compose up -d skynet"
}

# Node.js 开发模式
function Start-NodeDev {
    Write-Info "启动 Node.js 开发模式..."
    if (-not (Test-Path "node_modules")) {
        Write-Error "缺少依赖，请先运行: .\scripts\dev.ps1 setup"
        exit 1
    }
    & npx ts-node src\app\bootstrap-node.ts
}

# Docker 开发环境
function Start-DockerDev {
    param([switch]$Daemon)
    if ($Daemon) {
        Write-Info "后台启动 Docker 开发环境..."
        docker-compose up -d skynet
    } else {
        Write-Info "启动 Docker 开发环境..."
        docker-compose up skynet
    }
}

# 停止 Docker
function Stop-Docker {
    Write-Info "停止 Docker 环境..."
    docker-compose down
}

# 热更新
function Hotfix-Code {
    Write-Info "热更新服务代码..."
    # 编译 TS
    & .\scripts\build.ps1 ts
    # 部署
    & .\scripts\build.ps1 deploy
}

# 主逻辑
if ($Help) {
    Show-Help
    exit 0
}

switch ($Command) {
    "setup" { Setup-Project }
    "node" { Start-NodeDev }
    "up" { Start-DockerDev }
    "up:daemon" { Start-DockerDev -Daemon }
    "down" { Stop-Docker }
    "hotfix" { Hotfix-Code }
    default {
        Write-Error "未知命令: $Command"
        Show-Help
        exit 1
    }
}
