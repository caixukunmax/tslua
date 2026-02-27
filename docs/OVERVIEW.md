# TS-Skynet 混合开发框架 - 项目总览

## 🎯 核心价值主张

```
┌─────────────────────────────────────────────────────────────┐
│                    一套代码，双环境运行                       │
│                                                             │
│  TypeScript 业务代码                                         │
│         ↓                                                   │
│    编译 + 适配                                              │
│    ↙         ↘                                             │
│ Node.js    Skynet                                          │
│ (开发)     (生产)                                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 完整项目结构

```
ts-skynet-hybrid/
│
├── 📂 src/ ────────────────── TypeScript 源码
│   ├── 📂 core/
│   │   └── interfaces.ts ───── 核心抽象接口 ⭐
│   │
│   ├── 📂 runtime/
│   │   ├── node-adapter.ts ── Node.js 适配器
│   │   ├── skynet-adapter.ts  Skynet 适配器 ⭐
│   │   └── async-bridge.ts ─── Promise↔Coroutine 桥接 ⭐
│   │
│   ├── 📂 examples/
│   │   └── login-service.ts ── 业务示例
│   │
│   ├── main-node.ts ────────── Node.js 入口
│   └── main.ts ─────────────── Skynet 入口
│
├── 📂 dist/ ───────────────── 编译输出
│   ├── 📂 lua/ ────────────── TSTL → Lua
│   └── 📂 nodejs/ ─────────── TSC → JS
│
├── 📂 skynet/ ─────────────── Skynet 框架
│   ├── lualib/
│   ├── service/
│   ├── service-ts/ ────────── TS 编译的服务
│   └── skynet ─────────────── 可执行文件
│
├── 📂 book/ ───────────────── 文档
│   ├── 项目起点提示词.md
│   ├── 架构设计文档.md ────── 详细技术方案 ⭐
│   └── 快速开始.md
│
├── package.json
├── tsconfig.json ──────────── Node.js TS 配置
├── tsconfig.tstl.json ─────── Lua 编译配置 ⭐
├── build.sh ───────────────── 构建脚本
└── README.md
```

---

## 🔧 技术栈

| 层级 | 技术 | 用途 |
|-----|------|------|
| 开发语言 | TypeScript 5.3 | 业务代码编写 |
| 编译工具 | TypeScriptToLua (TSTL) | TS → Lua |
| 运行时 A | Node.js 20+ | 开发测试 |
| 运行时 B | Skynet (Lua 5.4) | 生产部署 |
| 构建工具 | npm scripts + bash | 自动化构建 |

---

## 🏗️ 核心架构层次

```
┌─────────────────────────────────────────────────────┐
│  第 1 层: 业务逻辑层                                  │
│  ┌───────────────────────────────────────────────┐  │
│  │ LoginService, GameLogic, ChatService...      │  │
│  │ 纯 TypeScript 代码，不依赖任何平台 API         │  │
│  └───────────────────────────────────────────────┘  │
└──────────────────┬──────────────────────────────────┘
                   │ 依赖
                   ▼
┌─────────────────────────────────────────────────────┐
│  第 2 层: 抽象接口层 (interfaces.ts)                 │
│  ┌───────────────────────────────────────────────┐  │
│  │ ILogger  ITimer  INetwork  IService          │  │
│  │ 定义统一的系统能力接口                        │  │
│  └───────────────────────────────────────────────┘  │
└──────────────────┬──────────────────────────────────┘
                   │ 实现
        ┌──────────┴──────────┐
        ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│ 第 3A 层:        │  │ 第 3B 层:        │
│ Node.js 适配器   │  │ Skynet 适配器    │
│                  │  │                  │
│ NodeLogger       │  │ SkynetLogger     │
│ NodeTimer        │  │ SkynetTimer      │
│ NodeNetwork      │  │ SkynetNetwork    │
│ NodeService      │  │ SkynetService    │
└────────┬─────────┘  └────────┬─────────┘
         │                     │
         ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│ Node.js 原生 API │  │ Skynet Lua API   │
│                  │  │                  │
│ console.log      │  │ skynet.error     │
│ setTimeout       │  │ skynet.timeout   │
│ Promise          │  │ coroutine        │
└──────────────────┘  └──────────────────┘
```

---

## ⚡ 异步模型转换原理

### 开发者视角 (TypeScript)

```typescript
// 统一使用 async/await
async function login(username: string): Promise<User> {
  await runtime.timer.sleep(100);
  const result = await runtime.network.call('db', 'lua', 'query', username);
  return result;
}
```

### Node.js 运行时

```javascript
// 编译为 JavaScript，使用原生 Promise
async function login(username) {
  await new Promise(resolve => setTimeout(resolve, 100));
  const result = await fetch('db/query', { body: username });
  return result;
}
```

### Skynet 运行时

```lua
-- TSTL 编译为 Lua，使用 coroutine
function login(username)
  skynet.sleep(10)  -- 内部 coroutine.yield
  local result = skynet.call('db', 'lua', 'query', username)  -- 内部 yield
  return result
end
```

---

## 🎬 执行流程对比

### Node.js 执行流程

```
开始
  ↓
业务代码: await network.call(...)
  ↓
NodeNetwork.call() 返回 Promise
  ↓
Promise pending (非阻塞)
  ↓
事件循环继续
  ↓
Promise resolved
  ↓
继续执行业务代码
  ↓
结束
```

### Skynet 执行流程

```
开始 (在协程中)
  ↓
业务代码: await network.call(...)
  ↓
SkynetNetwork.call() → skynet.call()
  ↓
coroutine.yield (挂起当前协程)
  ↓
Skynet 调度其他协程 (非阻塞)
  ↓
响应到达，coroutine.resume
  ↓
继续执行业务代码
  ↓
结束
```

**关键**: 两个环境对业务代码完全透明！

---

## 📊 编译流程

```
┌────────────────────────────────────────────┐
│  TypeScript 源码                            │
│  src/examples/login-service.ts             │
└──────────┬─────────────────────────────────┘
           │
    ┌──────┴──────┐
    │             │
    ▼             ▼
┌────────┐    ┌────────┐
│  TSC   │    │  TSTL  │
│ (标准) │    │ (转Lua)│
└────┬───┘    └───┬────┘
     │            │
     ▼            ▼
┌─────────┐  ┌─────────┐
│  .js    │  │  .lua   │
│ Node.js │  │ Skynet  │
└─────────┘  └─────────┘
```

### 构建命令

```bash
# 同时编译两个目标
npm run build

# 等价于:
npx tsc -p tsconfig.json         # → dist/nodejs/
npx tstl -p tsconfig.tstl.json   # → dist/lua/
```

---

## 🔍 代码转换示例

### TypeScript 源码

```typescript
export class LoginService {
  private users = new Map<number, User>();
  
  async handleLogin(username: string): Promise<boolean> {
    await runtime.timer.sleep(100);
    
    const user = { id: 1, name: username };
    this.users.set(user.id, user);
    
    return true;
  }
}
```

### 编译为 JavaScript (Node.js)

```javascript
class LoginService {
  constructor() {
    this.users = new Map();
  }
  
  async handleLogin(username) {
    await runtime.timer.sleep(100);
    
    const user = { id: 1, name: username };
    this.users.set(user.id, user);
    
    return true;
  }
}
```

### 编译为 Lua (Skynet)

```lua
local LoginService = {}
LoginService.__index = LoginService

function LoginService.new()
  local self = setmetatable({}, LoginService)
  self.users = {}
  return self
end

function LoginService:handleLogin(username)
  -- TSTL 生成的协程包装
  __TS__AsyncAwaiter(function()
    skynet.sleep(10)  -- 100ms → 10 centiseconds
    
    local user = {id = 1, name = username}
    self.users[user.id] = user
    
    return true
  end)
end
```

---

## 🚀 使用场景

| 场景 | 使用环境 | 优势 |
|-----|---------|-----|
| 本地开发 | Node.js | 快速迭代，VS Code 调试 |
| 单元测试 | Node.js | Jest/Mocha 生态 |
| 集成测试 | Node.js | 模拟完整流程 |
| 压力测试 | Skynet | 真实性能数据 |
| 生产部署 | Skynet | 高并发，低延迟 |

---

## 📈 性能对比

| 指标 | Node.js | Skynet |
|-----|---------|--------|
| 并发模型 | 事件循环 (单线程) | Actor 模型 (多线程) |
| 内存占用 | ~50MB | ~10MB |
| 单服 QPS | ~10K | ~100K |
| RPC 延迟 | ~5ms | ~0.5ms |
| 适用场景 | 开发测试 | 生产环境 |

---

## 📚 文档导航

1. **新手必读**
   - [快速开始](./book/快速开始.md) - 10分钟上手
   - [README](./README.md) - 项目概览

2. **深入理解**
   - [架构设计文档](./book/架构设计文档.md) - 完整技术方案 ⭐
   - [项目起点提示词](./book/项目起点提示词.md) - 原始需求

3. **实战开发**
   - [src/examples/login-service.ts](./src/examples/login-service.ts) - 业务示例
   - [src/core/interfaces.ts](./src/core/interfaces.ts) - 接口定义

---

## ✅ 检查清单

开始使用前确认:

- [ ] Node.js 20+ 已安装
- [ ] TypeScript 基础知识
- [ ] 理解 async/await 概念
- [ ] (可选) 了解 Lua 语法
- [ ] (可选) 熟悉 Skynet 框架

---

## 🎯 最佳实践

### ✅ 推荐做法

```typescript
// 1. 通过 runtime 访问系统功能
import { runtime } from './core/interfaces';
runtime.logger.info('Hello');

// 2. 使用 async/await 处理异步
async function getData() {
  const result = await runtime.network.call(...);
  return result;
}

// 3. 定义清晰的接口
export interface UserData {
  id: number;
  name: string;
}
```

### ❌ 避免做法

```typescript
// 1. 直接使用平台 API
console.log('Bad');  // ❌
setTimeout(() => {}, 1000);  // ❌

// 2. 依赖 Node.js 专用库
import axios from 'axios';  // ❌ Skynet 无法运行

// 3. 使用浏览器 API
document.getElementById('id');  // ❌
```

---

## 🔗 相关资源

- [Skynet GitHub](https://github.com/cloudwu/skynet)
- [TypeScriptToLua](https://typescripttolua.github.io/)
- [Lua 5.4 Manual](https://www.lua.org/manual/5.4/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

---

<div align="center">

## 🌟 开始你的 TS-Skynet 之旅！

**一套代码，双环境运行 - 开发效率与生产性能的完美结合**

[快速开始](./book/快速开始.md) | [架构文档](./book/架构设计文档.md) | [提交 Issue](../../issues)

</div>
