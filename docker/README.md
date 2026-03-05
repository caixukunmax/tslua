# Docker 部署指南

本目录包含 TS-Skynet 项目的 Docker 部署配置，采用**双模式**架构：
- **开发模式**：volume 挂载代码，实时生效
- **生产模式**：代码嵌入镜像，自包含部署

## 目录结构

```
docker/
├── skynet/                 # Skynet 框架源码（git submodule）
│   ├── skynet              #    纯净原生，零修改
│   ├── lualib/
│   └── service/
│
├── skynet-runtime/
│   ├── Dockerfile          # 镜像构建配置
│   └── config.tslua        # 默认配置文件
│
└── service-ts/             # 编译好的 Lua 代码（生产模式使用）
    └── app/
        └── main.lua
```

## 双模式架构

### 开发模式（skynet-dev）

```
┌─────────────────────────────────────────┐
│  tslua-skynet-dev 容器                   │
│                                         │
│  /skynet/service-ts/ ← volume 挂载       │
│  ./server/dist/lua:/skynet/service-ts   │
│                                         │
│  特点：代码修改后立即生效，无需重建镜像     │
│  适用：本地开发调试                        │
└─────────────────────────────────────────┘
```

### 生产模式（skynet）

```
┌─────────────────────────────────────────┐
│  tslua-skynet 容器                       │
│                                         │
│  /skynet/service-ts/ ← 镜像内嵌          │
│  COPY docker/service-ts/ /skynet/...    │
│                                         │
│  特点：镜像自包含，独立部署                │
│  适用：测试环境、生产环境                  │
└─────────────────────────────────────────┘
```

## 快速开始

### 开发模式

```bash
# 1. 编译 TypeScript
cd server
npm run build:ts

# 2. 启动开发容器（代码挂载模式）
cd ..
docker-compose --profile dev up -d skynet-dev

# 3. 修改代码后重新编译，容器自动生效
npm run build:ts
```

### 生产模式

```bash
# 1. 编译 TypeScript 并复制到 docker/service-ts/
cd server
./scripts/build.sh docker

# 2. 构建镜像（包含代码）
cd ..
docker-compose build skynet

# 3. 启动生产容器
docker-compose up -d skynet

# 4. 查看日志
docker-compose logs -f skynet
```

## 常用命令

| 命令 | 说明 |
|------|------|
| `./scripts/build.sh docker` | 编译并准备 Docker 构建上下文 |
| `docker-compose build skynet` | 构建生产镜像 |
| `docker-compose up -d skynet` | 启动生产容器 |
| `docker-compose --profile dev up -d skynet-dev` | 启动开发容器 |
| `docker-compose logs -f skynet` | 查看日志 |

## 镜像构建流程

```bash
# 完整构建流程
./scripts/build.sh docker     # 编译 TS → 复制到 docker/service-ts/
docker-compose build skynet   # 构建镜像（Skynet + Lua代码 + 配置）
docker-compose up -d skynet   # 启动容器
```

## 配置管理

配置始终通过 volume 挂载，与代码分离：

```yaml
volumes:
  - ./server/config/skynet:/skynet-config:ro
environment:
  - SKYNET_CONFIG=/skynet-config/config.tslua
```

支持多环境：
- `config.tslua` - 默认配置
- `config.prod.tslua` - 生产环境
- `config.test.tslua` - 测试环境

## CI/CD 集成

```bash
# 构建并推送镜像
./scripts/build.sh docker
docker-compose build skynet
docker tag tslua-skynet your-registry/tslua-skynet:v1.0.0
docker push your-registry/tslua-skynet:v1.0.0

# 部署时只需拉取镜像和配置
docker pull your-registry/tslua-skynet:v1.0.0
docker-compose up -d skynet
```

## 注意事项

1. **开发模式**：代码通过 volume 挂载，镜像内代码被覆盖
2. **生产模式**：代码在镜像内，volume 只挂载配置
3. **service-ts/.gitignore**：编译产物不提交，由 CI/CD 构建
