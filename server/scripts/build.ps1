# =============================================================================
# TS-Skynet 构建脚本 (Windows PowerShell)
# 功能: 编译 TS→Lua、清理构建产物、部署到 Docker 容器
# =============================================================================

param(
    [Parameter(Position=0)]
    [string]$Command = "ts",
    
    [Parameter(Position=1)]
    [string]$ServiceName = "",
    
    [string]$Container = $env:SKYNET_CONTAINER,
    [switch]$Help
)

# 默认值
if (-not $Container) { $Container = "tslua-skynet" }
$SKYNET_SERVICE_DIR = "/skynet/service-ts"

# 路径设置
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BASE_DIR = Resolve-Path "$SCRIPT_DIR\.." | Select-Object -Expand Path
Set-Location $BASE_DIR

# 颜色输出
function Write-Info { param([string]$msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success { param([string]$msg) Write-Host "[SUCCESS] $msg" -ForegroundColor Green }
function Write-Warn { param([string]$msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Error { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

function Show-Help {
    @"
TS-Skynet 构建脚本 (Windows)

用法: .\scripts\build.ps1 <命令> [选项]

命令:
    ts              编译 TypeScript → Lua (默认)
    ts:watch        监视模式编译 TS
    ts:service NAME 编译指定服务
    proto           编译 protobuf
    tables          编译 Luban 配置表
    all             完整构建 (proto + tables + ts)
    deploy          部署 Lua 代码到 Skynet 容器
    build:deploy    编译并部署到容器
    docker          编译并复制到 docker/service-ts/
    clean           清理构建产物
    clean:all       完全清理

选项:
    -Help           显示帮助
    -Container      指定容器名

示例:
    .\scripts\build.ps1                    # 编译 TS
    .\scripts\build.ps1 ts:watch           # 监视模式
    .\scripts\build.ps1 deploy             # 部署到容器
    .\scripts\build.ps1 -Container my-skynet deploy
"@
}

# 检查依赖
function Test-Dependencies {
    if (-not (Test-Path "node_modules\.bin\tstl.cmd")) {
        Write-Error "缺少依赖，请先安装: npm install"
        exit 1
    }
}

# 编译 TypeScript
function Build-TS {
    Write-Info "编译 TypeScript → Lua..."
    Test-Dependencies
    & npx tstl --project config\tsconfig.lua.json
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    Write-Success "编译完成 → dist\lua\"
}

# 监视模式
function Build-TSWatch {
    Write-Info "监视模式编译 (按 Ctrl+C 停止)..."
    Test-Dependencies
    & npx tstl --watch
}

# 编译指定服务
function Build-Service {
    param([string]$service)
    if (-not $service) {
        Write-Error "请指定服务名: login/game/gateway"
        exit 1
    }
    Write-Info "编译服务: $service"
    Test-Dependencies
    & npx tstl --project config\tsconfig.lua.json
    Write-Success "$service 编译完成"
}

# 编译 protobuf
function Build-Proto {
    Write-Info "编译 protobuf..."
    if (Test-Path "scripts\build_proto.ps1") {
        & .\scripts\build_proto.ps1
    } else {
        Write-Warn "protobuf 编译脚本不存在，跳过"
    }
}

# 编译配置表
function Build-Tables {
    Write-Info "编译 Luban 配置表..."
    if (Test-Path "scripts\build_tables.ps1") {
        & .\scripts\build_tables.ps1
    } else {
        Write-Warn "Luban 编译脚本不存在，跳过"
    }
}

# 完整构建
function Build-All {
    Write-Info "完整构建..."
    Build-Proto
    Build-Tables
    Build-TS
    $count = (Get-ChildItem -Path "dist\lua" -Filter "*.lua" -Recurse).Count
    Write-Success "构建完成: $count 个 Lua 文件"
}

# 部署到容器
function Deploy-ToContainer {
    Write-Info "部署 Lua 代码到 Skynet 容器..."
    
    if (-not (Test-Path "dist\lua")) {
        Write-Error "没有编译产物，请先运行: .\scripts\build.ps1 ts"
        exit 1
    }
    
    # 检查容器是否运行
    $running = docker ps --format "{{.Names}}" | Select-String "^$Container$"
    if (-not $running) {
        Write-Warn "容器 $Container 未运行"
        Write-Info "请先启动容器: docker-compose up -d skynet"
        exit 1
    }
    
    $count = (Get-ChildItem -Path "dist\lua" -Filter "*.lua" -Recurse).Count
    Write-Info "部署 $count 个 Lua 文件到容器..."
    
    docker cp "dist\lua\." "${Container}:${SKYNET_SERVICE_DIR}/"
    
    Write-Success "部署完成: $count 个文件已复制到 ${Container}:${SKYNET_SERVICE_DIR}"
}

# 复制到 docker/service-ts/
function Copy-ToDocker {
    Write-Info "复制 Lua 代码到 docker\service-ts\..."
    
    if (-not (Test-Path "dist\lua")) {
        Write-Error "没有编译产物，请先运行: .\scripts\build.ps1 ts"
        exit 1
    }
    
    $dockerServicePath = "..\..\docker\service-ts"
    if (Test-Path $dockerServicePath) {
        Remove-Item -Path $dockerServicePath\* -Recurse -Force
    } else {
        New-Item -ItemType Directory -Path $dockerServicePath -Force | Out-Null
    }
    
    Copy-Item -Path "dist\lua\*" -Destination $dockerServicePath -Recurse -Force
    
    $count = (Get-ChildItem -Path $dockerServicePath -Filter "*.lua" -Recurse).Count
    Write-Success "已复制 $count 个 Lua 文件到 docker\service-ts\"
}

# 编译并部署
function Build-AndDeploy {
    Build-TS
    Deploy-ToContainer
}

# 编译并准备 Docker 构建
function Build-ForDocker {
    Build-TS
    Copy-ToDocker
    Write-Success "准备完成，现在可以构建镜像: docker-compose build skynet"
}

# 清理
function Clean {
    Write-Info "清理构建产物..."
    if (Test-Path "dist\lua") {
        Remove-Item -Path "dist\lua" -Recurse -Force
    }
    Write-Success "清理完成"
}

# 完全清理
function Clean-All {
    Write-Info "完全清理..."
    if (Test-Path "dist") { Remove-Item -Path "dist" -Recurse -Force }
    if (Test-Path "node_modules") { Remove-Item -Path "node_modules" -Recurse -Force }
    Write-Success "完全清理完成"
}

# 主逻辑
if ($Help) {
    Show-Help
    exit 0
}

switch ($Command) {
    "ts" { Build-TS }
    "lua" { Build-TS }
    "ts:watch" { Build-TSWatch }
    "watch" { Build-TSWatch }
    "ts:service" { Build-Service -service $ServiceName }
    "proto" { Build-Proto }
    "pb" { Build-Proto }
    "tables" { Build-Tables }
    "all" { Build-All }
    "full" { Build-All }
    "deploy" { Deploy-ToContainer }
    "build:deploy" { Build-AndDeploy }
    "docker" { Build-ForDocker }
    "build:docker" { Build-ForDocker }
    "clean" { Clean }
    "clean:all" { Clean-All }
    "cleanall" { Clean-All }
    default { 
        Write-Error "未知命令: $Command"
        Show-Help
        exit 1
    }
}
