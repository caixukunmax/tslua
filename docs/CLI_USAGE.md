# TS-Skynet 跨平台 CLI 使用指南

本项目使用 **TypeScript 编写的跨平台 CLI**，支持 **Windows、Linux、macOS**，所有命令完全一致。

## 快速开始

```bash
# 显示交互式菜单
npm run menu

# 一键启动
npm run quick
```

## 命令列表

| 命令 | 说明 | 示例 |
|------|------|------|
| `menu` | 显示交互式菜单 | `npm run menu` |
| `quick` | 一键启动（检查+编译+启动） | `npm run quick` |
| `start` | 启动 Skynet 服务 | `npm run cli -- start` |
| `stop` | 停止服务 | `npm run cli -- stop` |
| `restart` | 重启服务 | `npm run cli -- restart` |
| `status` | 查看服务状态 | `npm run cli -- status` |
| `logs` | 查看日志 | `npm run cli -- logs` |
| `build:ts` | 编译 TypeScript → Lua | `npm run build:ts` |
| `build:all` | 完整构建（Proto+Tables+TS） | `npm run build` |
| `build:clean` | 清理构建产物 | `npm run clean` |
| `dev` | Node.js 开发模式 | `npm run dev` |
| `setup` | 初始化项目环境 | `npm run setup` |
| `hotfix` | 热更新代码 | `npm run hotfix` |

## 使用方式

### 方式一：npm 命令（推荐）⭐

所有平台使用完全相同的命令：

```bash
# 在根目录或 server 目录下都可以运行
npm run cli -- <命令>

# 常用命令有快捷方式
npm run menu        # 显示菜单
npm run quick       # 一键启动
npm run dev         # Node.js 开发模式
npm run build:ts    # 编译 TS→Lua
```

### 方式二：直接运行入口脚本

```bash
# Linux/macOS
./start.sh
./start.sh quick

# Windows PowerShell
.\start.ps1
.\start.ps1 quick

# Windows CMD
start.bat
start.bat quick
```

### 方式三：Node.js 直接运行

```bash
node cli.js <命令>

# 示例
node cli.js status
node cli.js build:ts
```

## 交互式菜单

运行 `npm run menu` 会显示交互式菜单：

```
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║         TS-Skynet 跨平台 CLI 工具                          ║
║                                                            ║
╠════════════════════════════════════════════════════════════╣
║  1. 一键启动 (自动检查 + 构建 + 启动)                      ║
║  2. 启动服务 (自动检查依赖)                                ║
║  3. 停止服务                                               ║
║  4. 重启服务                                               ║
║  5. 查看状态                                               ║
║  6. 热更新服务                                             ║
║  7. Node.js 模式 (开发调试)                                ║
║  8. 编译 TS→Lua                                            ║
║  9. 完整构建 (Proto+Luban+TS)                              ║
║  10. 清理构建产物                                          ║
║  0. 退出                                                   ║
╠════════════════════════════════════════════════════════════╣
║  快捷命令: q=退出, s=状态, h=热更新, b=编译, l=日志       ║
╚════════════════════════════════════════════════════════════╝
```

### 菜单快捷按键

在菜单界面下，可以直接输入：

| 按键 | 功能 |
|------|------|
| `1-10` | 选择对应菜单项 |
| `0` 或 `q` | 退出 |
| `s` | 查看状态 |
| `h` | 热更新 |
| `b` | 编译 TS→Lua |
| `l` | 查看日志 |

## 环境要求

- Node.js 18+
- npm 9+
- Docker & Docker Compose（运行服务需要）

## 安装依赖

首次使用前需要安装依赖：

```bash
# 安装根目录依赖
npm install

# 安装 server 目录依赖
cd server && npm install
```

## 故障排除

### 命令未找到

确保已安装依赖：
```bash
npm install
cd server && npm install
```

### Docker 相关命令失败

确保 Docker Desktop 已启动。

### Windows PowerShell 执行策略

如果遇到执行策略限制：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

或使用 CMD 替代：`start.bat`

## 技术实现

CLI 工具使用 TypeScript 编写，核心文件：

- `server/scripts/cli/index.ts` - CLI 主程序
- `cli.js` - Node.js 入口，自动检测 tsx/ts-node

CLI 内部使用 Node.js 的 `child_process` 模块执行命令，因此可以在所有支持 Node.js 的平台上运行。
