# Windows Docker 部署指南

本指南介绍如何在 Windows 环境下使用 Docker 部署 TS-Skynet 项目。

## 系统要求

- **Windows 版本**: Windows 10 版本 2004+ 或 Windows 11
- **Docker Desktop**: 4.0+ (必须启用 WSL2 后端)
- **PowerShell**: 5.1+ 或 PowerShell Core 7.0+
- **Node.js**: 18+ (用于编译 TypeScript)
- **Git**: 2.0+ (用于克隆代码)

## 安装步骤

### 1. 安装 Docker Desktop

1. 下载安装: https://www.docker.com/products/docker-desktop
2. 安装时选择 **WSL2 后端**（推荐）
3. 启动 Docker Desktop
4. 设置 → General → 勾选 **Use the WSL 2 based engine**

### 2. 克隆项目

```powershell
# PowerShell
git clone git@github.com:caixukunmax/tslua.git
cd tslua
```

### 3. 初始化环境

```powershell
# 使用部署脚本初始化
.\docker-deploy.ps1 setup
```

这一步会：
- 检查 Docker 环境
- 创建必要目录
- 安装 npm 依赖

## 快速开始

### 开发模式（推荐）

开发模式使用 volume 挂载，代码修改后实时生效：

```powershell
# 1. 编译 TypeScript
cd server
npm run build:ts

# 2. 启动开发容器（前台运行，看日志）
cd ..
.\docker-deploy.ps1 dev

# 或者后台运行
.\docker-deploy.ps1 dev -Daemon
```

### 修改代码后热更新

```powershell
# 修改 TS 代码后，重新编译
cd server
npm run build:ts

# 开发模式下代码自动同步到容器，无需重启
# 查看效果
.\docker-deploy.ps1 logs
```

### 生产模式

生产模式将代码打包进镜像：

```powershell
# 1. 构建镜像（包含编译后的 Lua 代码）
.\docker-deploy.ps1 build

# 2. 启动容器
.\docker-deploy.ps1 start -Daemon

# 3. 查看状态
.\docker-deploy.ps1 status
```

## 常用命令

```powershell
# 查看帮助
.\docker-deploy.ps1 -Help

# 启动开发环境（前台）
.\docker-deploy.ps1 dev

# 启动开发环境（后台）
.\docker-deploy.ps1 dev -Daemon

# 查看日志
.\docker-deploy.ps1 logs

# 停止所有容器
.\docker-deploy.ps1 stop

# 重启容器
.\docker-deploy.ps1 restart

# 进入容器 Shell（调试）
.\docker-deploy.ps1 shell

# 完全清理
.\docker-deploy.ps1 clean
```

## 项目结构（Windows 路径）

```
tslua/
├── docker-deploy.ps1          # Windows Docker 部署脚本 ⭐
├── docker-compose.yml          # Docker 基础配置
├── docker-compose.windows.yml  # Windows 覆盖配置
├── docker/
│   ├── skynet/                 # Skynet 源码（Linux 编译）
│   ├── skynet-runtime/         # 运行时镜像配置
│   └── service-ts/             # 编译后的 Lua 代码（生产模式）
├── server/
│   ├── dist/lua/               # TS 编译输出 → 挂载到容器
│   └── config/skynet/          # 配置文件 → 挂载到容器
└── ...
```

## 路径映射说明

| Windows 路径 | 容器路径 | 说明 |
|-------------|---------|------|
| `.\server\dist\lua\` | `/skynet/service-ts/` | TS 编译的 Lua 代码 |
| `.\server\config\skynet\` | `/skynet-config/` | Skynet 配置文件 |
| Docker 具名卷 | `/skynet/logs/` | 日志持久化 |

## 文件换行符处理

项目已配置 `.gitattributes` 强制使用 LF 换行符，避免 Windows CRLF 导致容器内脚本执行失败。

```bash
# 如果文件被修改为有 CRLF，执行以下命令修复
git add --renormalize .
git commit -m "normalize line endings"
```

## 故障排除

### 1. Docker Desktop 未启动

```
[ERROR] Docker Desktop 未启动
```
**解决**: 启动 Docker Desktop，等待鲸鱼图标变绿。

### 2. 端口被占用

```
Error: Ports are not available
```
**解决**: 修改 `docker-compose.yml` 中的端口映射：
```yaml
ports:
  - "8889:8888"   # 改为其他端口
```

### 3. 权限错误

```
Error response from daemon: permission denied
```
**解决**: 以管理员身份运行 PowerShell。

### 4. 代码修改未生效

**开发模式**: 
- 检查是否编译成功 `npm run build:ts`
- 检查容器是否使用开发模式启动 `docker-deploy.ps1 dev`

**生产模式**:
- 需要重新构建镜像 `.\docker-deploy.ps1 build`
- 然后重启容器 `.\docker-deploy.ps1 restart`

### 5. WSL2 性能问题

如果在 WSL2 中访问 Windows 文件系统很慢：

**方案 1**: 将项目移到 WSL2 文件系统
```powershell
# 在 WSL2 中执行
mkdir -p ~/projects
cp -r /mnt/d/project/tslua ~/projects/
cd ~/projects/tslua
```

**方案 2**: 使用 Docker Desktop 的资源监控排查

## VS Code 开发推荐配置

安装以下插件：
- **Docker** - 容器管理
- **PowerShell** - 脚本支持
- **TypeScript to Lua** - TS 转 Lua 支持

创建 `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build TS",
      "type": "shell",
      "command": "npm run build:ts",
      "options": { "cwd": "${workspaceFolder}/server" }
    },
    {
      "label": "Docker: Start Dev",
      "type": "shell",
      "command": ".\\docker-deploy.ps1 dev -Daemon"
    },
    {
      "label": "Docker: View Logs",
      "type": "shell",
      "command": ".\\docker-deploy.ps1 logs"
    }
  ]
}
```

## 高级配置

### 自定义端口

编辑 `docker-compose.windows.yml`:

```yaml
services:
  skynet-dev:
    ports:
      - "8888:8888"   # 游戏服务
      - "9999:9999"   # 调试端口
```

### 环境变量

```powershell
# 设置环境变量
$env:SKYNET_CONTAINER = "my-skynet"
.\docker-deploy.ps1 dev
```

### 多阶段构建优化

生产镜像使用多阶段构建，体积更小：
- 构建阶段：包含编译工具和源码
- 运行阶段：仅包含运行时和编译产物

## 更新日志

### 2024-03
- 添加 Windows Docker 部署支持
- 创建 PowerShell 部署脚本
- 配置 LF 换行符强制转换

---

有问题请提交 Issue 或联系维护者。
