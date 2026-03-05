# 脚本目录说明

本目录包含项目的管理脚本。

## 结构

```
scripts/
├── cli/              # 跨平台 CLI 工具 (TypeScript)
│   └── index.ts      # CLI 主程序
└── README.md         # 本文件
```

## 跨平台 CLI

项目现在使用 **TypeScript 编写的跨平台 CLI**，支持 Windows、Linux、macOS。

### 使用方式

```bash
# 显示交互式菜单
npm run menu

# 一键启动
npm run quick

# 查看状态
npm run cli -- status

# 编译 TS→Lua
npm run build:ts
```

所有命令在 Windows、Linux、macOS 下完全一致。

### 快捷入口

```bash
# Linux/macOS
./start.sh

# Windows PowerShell
.\start.ps1

# Windows CMD
start.bat
```

## 完整文档

详见 [docs/CLI_USAGE.md](../../docs/CLI_USAGE.md)
