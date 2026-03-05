# TS-Skynet 部署指南

## 🚀 快速部署流程

### 1. 编译 TypeScript → Lua

```bash
# 安装依赖（首次）
npm install
cd server && npm install

# 编译 protobuf
npm run build:proto

# 编译 TypeScript → Lua
npm run build:ts
```

### 2. 复制到 Docker 目录

```bash
npm run docker:copy
# 或手动：xcopy /E /I /Y server\dist\lua\* docker\lua\
```

### 3. 本地 Docker 部署（Windows + WSL2）

```bash
cd docker

# 开发模式（推荐，代码热更新）
docker compose --profile dev up -d

# 生产模式
docker compose up -d

# 查看日志
docker compose logs -f
```

### 4. 远程服务器部署

#### 方式一：使用 CLI 工具（推荐）

```bash
# 配置远程服务器
npm run docker:init
# 编辑 docker/cli/config.json

# 启动管理器
npm run docker:manage
```

#### 方式二：打包部署

```bash
# 1. 准备部署包
cd docker
tar -czf tslua-docker.tar.gz \
  compose.yml \
  config/ \
  lua/ \
  skynet-runtime/

# 2. 上传到服务器
scp tslua-docker.tar.gz root@your-server:/opt/

# 3. 服务器上解压并启动
ssh root@your-server "
  cd /opt &&
  tar -xzf tslua-docker.tar.gz &&
  cd docker &&
  docker compose up -d
"
```

---

## 📁 部署包结构

```
docker/
├── compose.yml          # Docker Compose 配置
├── config/skynet/       # 运行时配置
├── lua/                 # 编译后的 Lua 代码 ⭐
├── cli/                 # 远程管理工具（可选）
└── skynet-runtime/      # Dockerfile
```

---

## 🔧 常用命令

| 命令 | 说明 |
|------|------|
| `npm run build:ts` | 编译 TS → Lua |
| `npm run docker:copy` | 复制 Lua 到 docker/lua/ |
| `npm run docker:manage` | 远程管理工具 |
| `npm run quick` | 一键启动（本地 Node.js） |

---

## ⚠️ 注意事项

1. **Lua 代码路径**: `docker/lua/` 必须包含编译后的 `.lua` 文件
2. **配置文件**: `docker/config/skynet/config.tslua` 已预置默认配置
3. **远程部署**: 需要 SSH 密钥登录远程服务器
