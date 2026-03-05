# =============================================================================
# TS-Skynet 启动脚本 (Windows PowerShell)
# 功能: 启动服务、停止服务、查看状态
# =============================================================================

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "restart", "status", "logs")]
    [string]$Command = "status",
    
    [switch]$Daemon,
    [switch]$Help
)

function Show-Help {
    @"
TS-Skynet 启动脚本 (Windows)

用法: .\scripts\start.ps1 <命令> [选项]

命令:
    start           启动服务
    stop            停止服务
    restart         重启服务
    status          查看服务状态
    logs            查看日志

选项:
    -Daemon         后台运行 (仅 start)
    -Help           显示帮助

示例:
    .\scripts\start.ps1 start            # 前台启动
    .\scripts\start.ps1 start -Daemon    # 后台启动
    .\scripts\start.ps1 stop             # 停止
    .\scripts\start.ps1 restart          # 重启
    .\scripts\start.ps1 logs             # 查看日志
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

# 启动服务
function Start-Service {
    param([switch]$Daemon)
    
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "未找到 Docker，请先安装 Docker Desktop"
        exit 1
    }
    
    if ($Daemon) {
        Write-Info "后台启动服务..."
        docker-compose up -d skynet
        Start-Sleep -Seconds 2
        Show-Status
    } else {
        Write-Info "启动服务 (按 Ctrl+C 停止)..."
        docker-compose up skynet
    }
}

# 停止服务
function Stop-Service {
    Write-Info "停止服务..."
    docker-compose down
    Write-Success "服务已停止"
}

# 重启服务
function Restart-Service {
    Write-Info "重启服务..."
    Stop-Service
    Start-Sleep -Seconds 2
    Start-Service -Daemon
}

# 查看状态
function Show-Status {
    Write-Info "服务状态:"
    docker-compose ps
    
    Write-Host "`n容器状态:" -ForegroundColor Cyan
    $containers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-String "tslua"
    if ($containers) {
        $containers | ForEach-Object { Write-Host $_ }
    } else {
        Write-Warn "没有运行中的 tslua 容器"
    }
}

# 查看日志
function Show-Logs {
    Write-Info "查看日志 (按 Ctrl+C 退出)..."
    docker-compose logs -f skynet
}

# 主逻辑
if ($Help) {
    Show-Help
    exit 0
}

switch ($Command) {
    "start" { Start-Service -Daemon:$Daemon }
    "stop" { Stop-Service }
    "restart" { Restart-Service }
    "status" { Show-Status }
    "logs" { Show-Logs }
    default {
        Show-Status
    }
}
