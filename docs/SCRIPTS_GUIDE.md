# TS-Skynet 脚本使用指南

项目脚本已整理为 **3 个核心脚本**，覆盖所有常用操作。

---

## 📜 核心脚本

| 脚本 | 功能 | 常用命令 |
|-----|------|---------|
| **`build.sh`** | 编译构建 | 编译 TS→Lua、编译 Skynet 引擎、清理 |
| **`server.sh`** | 服务器管理 | 启动、停止、重启、查看状态 |
| **`dev.sh`** | 开发工具 | 一键启动、热更新、Node.js 模式 |

---

## 🔧 build.sh - 编译构建

```bash
# 编译 TypeScript → Lua（默认）
./scripts/build.sh
./scripts/build.sh ts

# 监视模式（自动重建）
./scripts/build.sh ts:watch

# 编译指定服务
./scripts/build.sh ts:service login
./scripts/build.sh ts:service game
./scripts/build.sh ts:service gateway

# 编译 Skynet C 引擎
./scripts/build.sh engine

# 编译 protobuf
./scripts/build.sh proto

# 完整构建（proto + ts + 复制）
./scripts/build.sh all

# 清理构建产物
./scripts/build.sh clean

# 完全清理（包括 node_modules）
./scripts/build.sh clean:all
```

---

## 🎮 server.sh - 服务器管理

```bash
# 前台启动（默认）
./scripts/server.sh start

# 后台启动
./scripts/server.sh start -d
./scripts/server.sh start -d -l logs/server.log

# 指定配置文件
./scripts/server.sh start -c skynet/config.tslua

# 停止服务器（优雅）
./scripts/server.sh stop

# 强制停止
./scripts/server.sh stop -f

# 重启服务器
./scripts/server.sh restart
./scripts/server.sh restart -d

# 查看状态
./scripts/server.sh status

# 持续监视状态（每 2 秒刷新）
./scripts/server.sh status -w
```

---

## 🚀 dev.sh - 开发工具

```bash
# 一键启动（构建 + 部署 + 启动）⭐
./scripts/dev.sh up

# 一键后台启动
./scripts/dev.sh up:daemon
./scripts/dev.sh up -d

# 强制重新构建后启动
./scripts/dev.sh up -f

# 跳过构建直接启动
./scripts/dev.sh up -s

# 热更新服务
./scripts/dev.sh hotfix login
./scripts/dev.sh hotfix game
./scripts/dev.sh hotfix gateway
./scripts/dev.sh hotfix all

# Node.js 模式运行（开发调试）
./scripts/dev.sh node

# Docker 构建（解决网络问题）
./scripts/dev.sh docker:build

# 安装依赖并构建
./scripts/dev.sh setup
```

---

## 📋 常用命令速查

### 开发工作流

```bash
# 开发调试（Node.js 模式，快速）
./scripts/dev.sh node

# 完整开发（自动编译 + 前台运行）
./scripts/dev.sh up

# 修改代码后热更新
./scripts/dev.sh hotfix login

# 查看状态
./scripts/server.sh status
```

### 测试工作流

```bash
# 后台启动
./scripts/dev.sh up:daemon

# 查看状态
./scripts/server.sh status

# 修改代码后重启
./scripts/server.sh restart -d

# 停止
./scripts/server.sh stop
```

### 生产部署

```bash
# 强制重新构建
./scripts/build.sh clean
./scripts/build.sh all

# 后台启动并指定日志
./scripts/server.sh start -d -l logs/prod.log

# 验证启动
./scripts/server.sh status

# 后续热更新
./scripts/dev.sh hotfix all
```

---

## 🎯 典型场景

| 场景 | 命令 |
|-----|------|
| 第一次运行 | `./scripts/dev.sh setup` |
| 日常开发 | `./scripts/dev.sh node` |
| 完整启动 | `./scripts/dev.sh up` |
| 后台运行 | `./scripts/dev.sh up:daemon` |
| 热更新 | `./scripts/dev.sh hotfix login` |
| 查看状态 | `./scripts/server.sh status` |
| 停止服务 | `./scripts/server.sh stop` |
| 重启服务 | `./scripts/server.sh restart -d` |
| 编译 Skynet | `./scripts/build.sh engine` |
| 清理项目 | `./scripts/build.sh clean` |

---

## 💡 提示

1. **彩色输出**: 脚本使用颜色区分信息类型
   - 🟢 绿色: 成功
   - 🔴 红色: 错误
   - 🟡 黄色: 警告
   - 🔵 蓝色: 信息

2. **自动检查**: 脚本会自动检查依赖和环境

3. **获取帮助**: 任何脚本都可以加 `-h` 查看帮助
   ```bash
   ./scripts/build.sh -h
   ./scripts/server.sh -h
   ./scripts/dev.sh -h
   ```
