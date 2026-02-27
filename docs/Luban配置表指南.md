# Luban 配置表集成指南

## 📦 Luban 简介

Luban 是一个强大的配置表工具，支持从 Excel 生成多种语言的数据和代码。

在本项目中，Luban 用于：
- 从 Excel 配置表生成 Lua 代码（TypeScript 风格）
- 生成 JSON 数据文件
- 支持热更新和版本管理

---

## 📁 目录结构

```
tslua/
├── tools/luban/              # Luban 工具
│   └── Luban/                # Luban DLL 和依赖
├── config/tables/            # 配置表定义
│   ├── luban.conf            # Luban 配置文件
│   ├── defines/              # 表定义 XML
│   │   ├── item.xml
│   │   ├── common.xml
│   │   └── ...
│   └── datas/                # Excel 数据文件
│       ├── __tables__.xlsx   # 表配置
│       ├── __beans__.xlsx    # Bean 定义
│       ├── __enums__.xlsx    # 枚举定义
│       └── item/             # 具体数据表
└── src/common/tables/        # 生成的代码（构建产物）
    ├── cfg.lua               # Lua 代码
    └── data/                 # JSON 数据
```

---

## 🔧 前置要求

### 安装 .NET SDK

Luban 需要 .NET SDK 8.0 或更高版本。

**Ubuntu/Debian:**
```bash
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update && sudo apt-get install -y dotnet-sdk-8.0
```

**macOS:**
```bash
brew install --cask dotnet-sdk
```

**验证安装:**
```bash
dotnet --version
```

---

## 🚀 使用指南

### 编译配置表

```bash
# 方法 1: 使用构建脚本
./scripts/build_tables.sh

# 方法 2: 使用快速命令
./start.sh tables

# 方法 3: 使用菜单
./start.sh
# 选择 9. 编译 Luban 配置表
```

### 完整构建

```bash
# 编译所有（Proto + Luban + TS）
./scripts/build.sh all

# 或使用菜单
./start.sh
# 选择 10. 完整构建
```

---

## 📝 配置说明

### luban.conf 配置

```json
{
  "groups": [
    {"names":["c"], "default":true},   // 客户端
    {"names":["s"], "default":true},   // 服务器
    {"names":["e"], "default":true},   // 编辑器
    {"names":["t"], "default":false}   // 测试
  ],
  "targets": [
    {
      "name":"lua",
      "manager":"Tables",
      "groups":["c","s","e"],
      "topModule":"cfg",
      "exportCode":"lua"              // 生成 Lua 代码
    },
    {
      "name":"json",
      "manager":"Tables",
      "groups":["c","s","e"],
      "exportData":"json"             // 生成 JSON 数据
    }
  ]
}
```

### Excel 表格规范

1. **表配置表** (`__tables__.xlsx`): 定义所有表的元数据
2. **Bean 定义** (`__beans__.xlsx`): 定义复杂数据结构
3. **枚举定义** (`__enums__.xlsx`): 定义枚举类型
4. **数据表** (`item/`, `common/`, etc.): 具体配置数据

---

## 🔨 开发流程

### 1. 修改配置表

在 `config/tables/datas/` 目录下编辑 Excel 文件。

### 2. 编译配置表

```bash
./start.sh tables
```

### 3. 在 TypeScript 中使用

```typescript
import { Tables } from './common/tables/cfg';

// 读取配置表数据
const item = Tables.TbItem.get(1001);
console.log(item.name, item.quality);
```

### 4. 编译 TS → Lua

```bash
./start.sh build
```

---

## 📋 常见问题

### Q: dotnet 命令找不到
A: 需要安装 .NET SDK 8.0 或更高版本。

### Q: 生成的 Lua 代码报错
A: 检查 luban.conf 中的 `exportCode` 是否设置为 `lua`。

### Q: 如何添加新的配置表
A:
1. 在 `config/tables/datas/` 创建新的 Excel 文件
2. 在 `config/tables/defines/` 创建对应的 XML 定义
3. 在 `__tables__.xlsx` 中注册新表
4. 重新编译

---

## 🔗 相关资源

- [Luban 官方文档](https://luban.doc.code-philosophy.com/)
- [Luban GitHub](https://github.com/focus-creative-games/luban)
- [Excel 配置表规范](https://luban.doc.code-philosophy.com/docs/03_quick_start/)

---

## 📦 集成说明

本项目已集成 Luban 4.5.0，保留了以下核心组件：

| 组件 | 位置 | 说明 |
|------|------|------|
| Luban DLL | `tools/luban/Luban/` | Luban 执行文件 |
| 配置定义 | `config/tables/defines/` | XML 格式表定义 |
| 配置数据 | `config/tables/datas/` | Excel 数据文件 |
| 生成代码 | `src/common/tables/` | 构建产物，不要手动修改 |

**已删除的不必要文件：**
- luban-4.5.0/ 源码目录
- Projects/ 各种语言的示例项目
- githooks-demo/ Git Hooks 演示
- .git/ Luban 示例项目的 Git 历史
