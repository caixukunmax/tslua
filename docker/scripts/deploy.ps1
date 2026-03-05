# =============================================================================
# TS-Skynet Windows Docker 部署脚本
# 功能: 构建镜像、启动/停止服务、部署代码、查看日志
# 要求: Windows 10/11 + Docker Desktop (WSL2 后端)
# =============================================================================

param(
    [Parameter(Position=0)]
    [ValidateSet("setup", "build", "start", "stop", "restart", "status", "logs", "deploy", "dev", "shell", "clean")]
    [string]$Command = "status",
    
    [switch]$Daemon,
    [switch]$NoCache,
    [switch]$Help
)

# =============================================================================
# 配置
# =============================================================================
$PROJECT_NAME = "tslua"
$COMPOSE_FILE = "compose.yml"
$COMPOSE_FILE_WIN = "compose.override.yml"
$CONTAINER_NAME = "$PROJECT_NAME-skynet"
$CONTAINER_DEV_NAME = "$PROJECT_NAME-skynet-dev"

# =============================================================================
# 输出函数
# =============================================================================
function Write-Info { param([string]$msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success { param([string]$msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn { param([string]$msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Error { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Step { param([int]$n, [int]$total, [string]$msg) Write-Host "[$n/$total] $msg" -ForegroundColor Cyan }

# =============================================================================
# 帮助信息
# =============================================================================
function Show-Help {
    $help = @"
╔══════════════════════════════════════════════════════════════════════════════╗
║           TS-Skynet Windows Docker 部署脚本                                  ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  要求: Windows 10/11 + Docker Desktop (WSL2 后端)                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

用法: .\deploy.ps1 <命令> [选项]

命令:
    setup           初始化环境（检查依赖、创建目录）
    build           构建 Docker 镜像
    start           启动生产环境容器
    dev             启动开发环境容器（volume 挂载，代码实时生效）
    stop            停止所有容器
    restart         重启容器
    status          查看容器状态
    logs            查看日志 (Ctrl+C 退出)
    deploy          编译 TS 并部署到运行中的容器
    shell           进入容器 Shell（调试用）
    clean           清理容器和镜像

选项:
    -Daemon         后台运行（用于 start/dev）
    -NoCache        构建时不使用缓存（用于 build）
    -Help           显示帮助

示例:
    # 首次使用
    .\docker-deploy.ps1 setup

    # 开发模式（推荐）
    .\docker-deploy.ps1 dev              # 前台运行，看日志
    .\docker-deploy.ps1 dev -Daemon      # 后台运行

    # 生产模式
    .\docker-deploy.ps1 build            # 先构建镜像
    .\docker-deploy.ps1 start            # 启动容器

    # 代码更新
    npm run build:ts                     # 编译 TypeScript
    .\docker-deploy.ps1 deploy           # 部署到容器

    # 查看状态
    .\docker-deploy.ps1 status
    .\docker-deploy.ps1 logs

文件路径说明:
    Windows 路径: .\lua\   → 容器: /skynet/lua/
    Windows 路径: .\config\skynet\ → 容器: /skynet-config/

故障排除:
    1. Docker Desktop 未启动 -> 启动 Docker Desktop
    2. 端口被占用 -> 修改 docker-compose.yml 中的端口映射
    3. 权限错误 -> 以管理员身份运行 PowerShell
"@
    Write-Host $help
}

# =============================================================================
# 检查环境
# =============================================================================
function Test-Environment {
    Write-Step 1 3 "检查 Docker 环境..."
    
    # 检查 Docker 命令
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "未找到 Docker 命令"
        Write-Info "请安装 Docker Desktop: https://www.docker.com/products/docker-desktop"
        exit 1
    }
    
    # 检查 Docker 守护进程
    try {
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Docker 未运行"
        }
    } catch {
        Write-Error "Docker Desktop 未启动"
        Write-Info "请启动 Docker Desktop 后重试"
        exit 1
    }
    
    Write-Success "Docker 环境正常"
    
    # 检查 Docker Compose
    Write-Step 2 3 "检查 Docker Compose..."
    $composeVersion = docker compose version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Docker Compose 不可用"
        exit 1
    }
    Write-Success "Docker Compose 正常"
    
    # 检查 WSL2 后端（Windows 特有）
    Write-Step 3 3 "检查 WSL2 后端..."
    $wslInfo = docker info 2>&1 | Select-String "WSL2"
    if ($wslInfo) {
        Write-Success "使用 WSL2 后端"
    } else {
        Write-Warn "未使用 WSL2 后端，性能可能受影响"
        Write-Info "建议在 Docker Desktop 设置中启用 WSL2"
    }
}

# =============================================================================
# 初始化环境
# =============================================================================
function Initialize-Environment {
    Write-Info "初始化项目环境..."
    
    # 检查环境
    Test-Environment
    
    # 创建必要目录
    $dirs = @(
        "lua",
        "logs"
    )
    
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Info "创建目录: $dir"
        }
    }
    
    # 注意：本项目已独立于源码，如需要编译请使用根目录 npm run build:ts
    
    Write-Success "环境初始化完成！"
}

# =============================================================================
# 构建镜像
# =============================================================================
function Build-Image {
    param([switch]$NoCache)
    
    Write-Info "构建 Docker 镜像..."
    
    # 确保有编译好的 Lua 代码（用于生产镜像）
    if (-not (Test-Path "server/dist/lua/*.lua")) {
        Write-Warn "未找到编译后的 Lua 代码"
        Write-Error "请先编译 TypeScript 到 Lua，并复制到 docker/lua/ 目录"
        Write-Info "编译命令: cd .. && npm run build:ts"
        Write-Info "复制命令: Copy-Item -Path server/dist/lua/* -Destination docker/lua/ -Recurse"
        exit 1
    }
    
    # 检查代码是否已复制到 lua/
    Write-Info "检查 Lua 代码..."
    if (-not (Test-Path "lua/*.lua")) {
        Write-Warn "未找到 lua/ 目录下的 Lua 文件"
        Write-Info "请确保已将编译后的 Lua 代码复制到 docker/lua/ 目录"
    }
    
    # 构建镜像
    $buildArgs = @("compose", "-f", $COMPOSE_FILE, "build")
    if ($NoCache) {
        $buildArgs += "--no-cache"
        Write-Info "不使用缓存构建..."
    }
    
    docker @buildArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "镜像构建完成"
    } else {
        Write-Error "镜像构建失败"
        exit 1
    }
}

# =============================================================================
# 启动容器（生产模式）
# =============================================================================
function Start-Production {
    param([switch]$Daemon)
    
    Write-Info "启动生产环境容器..."
    
    # 先构建（如果镜像不存在）
    $imageExists = docker images --format "{{.Repository}}" | Select-String "tslua-skynet-runtime"
    if (-not $imageExists) {
        Write-Warn "镜像不存在，先构建..."
        Build-Image
    }
    
    $upArgs = @("compose", "-f", $COMPOSE_FILE, "up")
    if ($Daemon) {
        $upArgs += "-d"
        Write-Info "后台启动模式..."
    } else {
        Write-Info "前台启动模式 (按 Ctrl+C 停止)..."
    }
    $upArgs += "--remove-orphans"
    
    docker @upArgs
}

# =============================================================================
# 启动开发容器（volume 挂载模式）
# =============================================================================
function Start-Development {
    param([switch]$Daemon)
    
    Write-Info "启动开发环境容器..."
    Write-Info "代码路径: .\server\dist\lua → /skynet/lua/"
    
    # 确保有编译好的代码
    if (-not (Test-Path "server/dist/lua/*.lua")) {
        Write-Warn "未找到 Lua 代码，请先编译"
        Set-Location server
        npm run build:ts
        Set-Location ..
    }
    
    # 使用 Windows 覆盖配置
    $upArgs = @(
        "compose", 
        "-f", $COMPOSE_FILE, 
        "-f", $COMPOSE_FILE_WIN,
        "--profile", "dev",
        "up"
    )
    
    if ($Daemon) {
        $upArgs += "-d"
        Write-Info "后台启动模式..."
    } else {
        Write-Info "前台启动模式 (按 Ctrl+C 停止)..."
    }
    $upArgs += "--remove-orphans"
    
    docker @upArgs
}

# =============================================================================
# 停止容器
# =============================================================================
function Stop-Containers {
    Write-Info "停止容器..."
    docker compose -f $COMPOSE_FILE down --remove-orphans
    Write-Success "容器已停止"
}

# =============================================================================
# 重启容器
# =============================================================================
function Restart-Containers {
    Write-Info "重启容器..."
    Stop-Containers
    Start-Sleep -Seconds 2
    Start-Production -Daemon
}

# =============================================================================
# 查看状态
# =============================================================================
function Show-Status {
    Write-Info "容器状态:"
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    
    $containers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-String "tslua"
    if ($containers) {
        Write-Host "NAME                 STATUS              PORTS" -ForegroundColor Yellow
        $containers | ForEach-Object { 
            $line = $_ -replace "^\s+", ""
            Write-Host "  $line"
        }
    } else {
        Write-Warn "没有运行中的 tslua 容器"
    }
    
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    
    # 显示镜像信息
    Write-Info "本地镜像:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | Select-String "tslua|skynet"
}

# =============================================================================
# 查看日志
# =============================================================================
function Show-Logs {
    Write-Info "查看日志 (按 Ctrl+C 退出)..."
    docker compose -f $COMPOSE_FILE logs -f skynet
}

# =============================================================================
# 部署代码到容器
# =============================================================================
function Deploy-Code {
    Write-Info "编译并部署代码..."
    
    # 编译
    Set-Location server
    npm run build:ts
    if ($LASTEXITCODE -ne 0) {
        Write-Error "编译失败"
        Set-Location ..
        exit 1
    }
    Set-Location ..
    
    # 检查容器是否运行
    $containerRunning = docker ps --format "{{.Names}}" | Select-String $CONTAINER_DEV_NAME
    if (-not $containerRunning) {
        $containerRunning = docker ps --format "{{.Names}}" | Select-String $CONTAINER_NAME
        if (-not $containerRunning) {
            Write-Error "没有运行中的容器"
            Write-Info "请先启动容器: .\docker-deploy.ps1 dev"
            exit 1
        }
    }
    
    # 开发模式下 volume 挂载会自动同步，不需要手动复制
    # 但如果使用生产容器，需要手动复制
    if ($containerRunning -match $CONTAINER_NAME) {
        Write-Info "复制代码到生产容器..."
        docker cp "server/dist/lua/." "${CONTAINER_NAME}:/skynet/lua/"
        Write-Success "代码已部署"
    } else {
        Write-Success "开发模式下代码自动同步，无需手动部署"
        Write-Info "提示: 修改 TS 代码后编译即可 (npm run build:ts)"
    }
}

# =============================================================================
# 进入容器 Shell
# =============================================================================
function Enter-Shell {
    Write-Info "进入容器 Shell..."
    
    # 优先进入开发容器
    $container = docker ps --format "{{.Names}}" | Select-String $CONTAINER_DEV_NAME
    if (-not $container) {
        $container = docker ps --format "{{.Names}}" | Select-String $CONTAINER_NAME
    }
    
    if (-not $container) {
        Write-Error "没有运行中的容器"
        exit 1
    }
    
    docker exec -it $container /bin/bash
}

# =============================================================================
# 清理
# =============================================================================
function Clean-Up {
    Write-Warn "这将删除所有容器和镜像！"
    $confirm = Read-Host "确认清理? (输入 'yes')"
    
    if ($confirm -eq 'yes') {
        Write-Info "停止并删除容器..."
        docker compose -f $COMPOSE_FILE down --rmi all --volumes
        Write-Success "清理完成"
    } else {
        Write-Info "已取消"
    }
}

# =============================================================================
# 主逻辑
# =============================================================================
if ($Help) {
    Show-Help
    exit 0
}

# 切换到脚本所在目录
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $SCRIPT_DIR

switch ($Command) {
    "setup" { Initialize-Environment }
    "build" { Build-Image -NoCache:$NoCache }
    "start" { Start-Production -Daemon:$Daemon }
    "dev" { Start-Development -Daemon:$Daemon }
    "stop" { Stop-Containers }
    "restart" { Restart-Containers }
    "status" { Show-Status }
    "logs" { Show-Logs }
    "deploy" { Deploy-Code }
    "shell" { Enter-Shell }
    "clean" { Clean-Up }
    default { Show-Status }
}
