# TS-Skynet Docker 部署目录

本目录包含完整的 Docker 部署环境，**独立成体系**，不依赖外部源码。

## 目录结构

```
docker/
├── compose.yml              # Docker Compose 主配置
├── compose.override.yml     # 开发环境覆盖配置（可选）
├── .dockerignore            # Docker 构建忽略文件
├── README.md                # 本文件
├── config/                  # 运行时配置
│   └── skynet/
│       └── config.tslua     # Skynet 配置文件
├── service-ts/              # Lua 服务代码（外部编译后 copy 至此）
│   └── (编译后的 .lua 文件)
├── cli/                     # 远程管理工具
│   ├── index.js             # CLI 主程序
│   ├── config.json          # 远程服务器配置
│   └── README.md
├── scripts/                 # 本地部署脚本
│   ├── deploy.ps1           # PowerShell 部署脚本
│   └── deploy.bat           # CMD 入口
├── skynet/                  # Skynet 源码（git submodule）
└── skynet-runtime/          # 运行时镜像 Dockerfile
    └── Dockerfile
```

## 使用方式

### 1. 准备 Lua 代码

从外部编译并 copy Lua 代码到本目录：

```powershell
# 在项目根目录编译
npm run build:ts

# Copy Lua 代码到 docker/service-ts/
npm run docker:copy
```

### 2. 本地 Docker 部署（Windows + WSL2）

```powershell
cd docker

# 查看帮助
.\scripts\deploy.ps1 -Help

# 开发模式（volume 挂载，代码实时生效）
.\scripts\deploy.ps1 dev

# 生产模式（代码嵌入镜像）
.\scripts\deploy.ps1 build
.\scripts\deploy.ps1 start

# 查看状态/日志
.\scripts\deploy.ps1 status
.\scripts\deploy.ps1 logs
```

### 3. 远程服务器部署

使用 CLI 工具管理远程 Docker：

```powershell
# 配置远程服务器
npm run docker:init
# 编辑 docker/cli/config.json

# 启动管理器
npm run docker:manage
```

## 独立部署

本目录可以独立打包部署到服务器：

```bash
# 1. 在开发机准备
npm run build:ts
npm run docker:copy

# 2. 打包 docker/ 目录
cd docker
tar -czf tslua-docker.tar.gz .

# 3. 上传到服务器并解压
scp tslua-docker.tar.gz root@server:/opt/
ssh root@server "cd /opt && tar -xzf tslua-docker.tar.gz"

# 4. 在服务器启动
ssh root@server "cd /opt/docker && docker compose up -d"
```

## 配置说明

### 本地开发（docker compose）

- `compose.yml` - 主配置，使用 volume 挂载
- `config/skynet/` - Skynet 配置文件
- `service-ts/` - Lua 代码（编译后 copy 进来）

### 远程管理（docker/cli）

- `cli/config.json` - 远程服务器 SSH 配置
- 支持密钥/密码登录
- 支持代码同步、日志查看、容器管理

## 注意事项

1. **service-ts/ 目录** - 需要手动 copy 编译后的 Lua 代码
2. **config/skynet/** - 已包含默认配置，可根据需要修改
3. **远程部署** - 需要先在服务器安装 Docker 和 Docker Compose
