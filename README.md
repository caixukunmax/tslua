# TS-Skynet 混合开发框架

<div align="center">

**使用 TypeScript 开发，同时支持 Node.js 单机测试和 Skynet 生产部署**

[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue.svg)](https://www.typescriptlang.org/)
[![Skynet](https://img.shields.io/badge/Skynet-Latest-green.svg)](https://github.com/cloudwu/skynet)
[![Node.js](https://img.shields.io/badge/Node.js-20+-green.svg)](https://nodejs.org/)

</div>

---

## 🚀 快速开始

### 一键启动（推荐）
```bash
./start.sh
```
然后选择 **1. 一键启动**

### 手动启动
```bash
# 1. 编译 TypeScript → Lua
npm run build:ts

# 2. 启动 Skynet 服务
./start.sh start
```

### 更多命令
```bash
./start.sh help     # 查看所有命令
./start.sh status   # 查看服务状态
./start.sh stop     # 停止服务
./start.sh logs     # 查看日志
```

📖 详细文档：[docs/首次启动指南.md](docs/首次启动指南.md)

---

## 📋 项目简介

TS-Skynet Hybrid 是一个创新的游戏服务端开发框架，解决了以下核心痛点:

- **Skynet 性能卓越** 但 Lua 开发缺乏类型安全和现代工程化能力
- **TypeScript 开发体验优秀** 但直接运行在 Node.js 缺乏 Skynet 的 Actor 模型

本框架让你可以:
1. ✨ 使用 TypeScript 编写业务逻辑，享受类型安全和 IDE 智能提示
2. 🧪 在 Node.js 环境下快速验证逻辑和运行单元测试
3. 🚀 编译为 Lua 后在 Skynet 中高性能运行
4. 🔄 **一套代码，双环境运行**

---

## 🏗️ 架构设计

### 核心理念

```
┌─────────────────────────────────────────┐
│      TypeScript 业务代码层               │
│  (login-service.ts, game-logic.ts)      │
└──────────────┬──────────────────────────┘
               │
               │ 依赖抽象接口
               ▼
┌─────────────────────────────────────────┐
│        抽象接口层 (interfaces.ts)        │
│  ILogger | ITimer | INetwork | IService │
└──────────────┬──────────────────────────┘
               │
        ┌──────┴──────┐
        ▼             ▼
┌──────────────┐ ┌──────────────┐
│ Node.js 适配 │ │ Skynet 适配  │
│  (开发/测试) │ │  (生产环境)  │
└──────────────┘ └──────────────┘
```

### 目录结构

```
tslua/
├── protocols/                  # Proto 协议定义（前后端共用）
│   ├── proto/                  # .proto 源文件
│   │   ├── common.proto
│   │   ├── login.proto
│   │   ├── game.proto
│   │   ├── gateway.proto
│   │   └── message_id.proto
│   ├── scripts/                # 协议编译脚本
│   │   └── build_proto.ts
│   ├── package.json            # 独立的 npm 包
│   └── README.md               # 协议规范文档
│
├── tables/                     # Luban 配置表（策划、客户端、后端共用）
│   ├── datas/                  # Excel 数据文件
│   ├── defines/                # XML 定义文件
│   └── luban.conf              # Luban 配置文件
│
├── server/                     # 后端专属代码
│   ├── src/                    # TypeScript 源码
│   │   ├── app/                # 业务服务层
│   │   │   ├── services/       # 具体服务实现
│   │   │   │   ├── login/      # 登录服务
│   │   │   │   ├── gateway/    # 网关服务
│   │   │   │   └── game/       # 游戏服务
│   │   │   └── main.ts         # Skynet 入口
│   │   │
│   │   ├── common/             # 共用模块
│   │   │   └── protos/         # Protocol Buffers 协议定义 (生成)
│   │   │
│   │   └── framework/          # 框架核心
│   │       ├── core/           # 核心抽象接口 (interfaces.ts)
│   │       └── runtime/        # 运行时适配器
│   │
│   ├── config/                 # TypeScript 配置
│   │   ├── tsconfig.json       # Node.js 配置
│   │   └── tsconfig.lua.json   # TSTL 编译配置
│   │
│   ├── dist/                   # 编译输出
│   │   ├── lua/                # TSTL 编译的 Lua 代码
│   │   └── nodejs/             # TSC 编译的 JS 代码
│   │
│   ├── scripts/                # 构建脚本
│   ├── tools/                  # 工具 (Luban 等)
│   ├── package.json
│   └── start.sh
│
├── skynet/                     # Skynet 框架 (git submodule)
│   └── ...
│
├── docs/                       # 文档
├── package.json                # 根目录入口 (转发命令到 server/)
└── start.sh                    # 快速启动入口
```

---

## 🚀 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 构建项目

```bash
chmod +x build.sh
./build.sh
```

这会:
- 将 TypeScript 编译为 Lua (存放在 `dist/lua/`)
- 将 TypeScript 编译为 JavaScript (存放在 `dist/nodejs/`)
- 复制 Lua 文件到 `skynet/service-ts/`

### 3. 运行测试

#### Node.js 环境运行

```bash
npm run dev
```

你会看到类似输出:
```
[NodeService] Starting service node-service-1706432400000
[INFO] === Login Service Starting ===
[INFO] Service address: node-service-1706432400000
[INFO] LoginService initializing...
[NodeNetwork] Registered handler for lua
[INFO] LoginService initialized
[INFO] Session cleaner started
[INFO] === Login Service Ready ===
```

#### Skynet 环境运行

1. 编译 Skynet (首次需要):
```bash
cd skynet
make linux
```

2. 创建配置文件 `skynet/examples/config.ts`:
```lua
thread = 8
harbor = 0
start = "main"
bootstrap = "snlua bootstrap"
luaservice = "./service/?.lua;./service-ts/?.lua"
lua_path = "./lualib/?.lua;./lualib/?/init.lua;./service-ts/?.lua"
lua_cpath = "./luaclib/?.so"
```

3. 运行:
```bash
cd skynet
./skynet examples/config.ts
```

---

## 💡 核心功能详解

### 1. 抽象接口层

所有业务代码**必须**通过抽象接口访问系统功能，确保跨平台兼容:

```typescript
// ❌ 错误：直接使用 Node.js API
console.log('Hello');
setTimeout(() => {}, 1000);

// ✅ 正确：使用抽象接口
import { runtime } from './core/interfaces';

runtime.logger.info('Hello');
await runtime.timer.sleep(1000);
```

### 2. 异步模型统一

在 TypeScript 中统一使用 `async/await`:

```typescript
export class LoginService {
  async handleLogin(request: LoginRequest): Promise<LoginResponse> {
    // 在 Node.js: 这是真正的 Promise
    // 在 Skynet: TSTL 会转换为 coroutine.yield/resume
    await runtime.timer.sleep(100);
    
    const result = await runtime.network.call(
      'database', 
      'lua', 
      'query', 
      'SELECT * FROM users'
    );
    
    return { success: true, user: result };
  }
}
```

**关键技术点:**

- **Node.js 侧**: `await` 直接映射为标准 ES Promise
- **Skynet 侧**: TSTL 将 `await` 转换为 `coroutine.yield`，调用 `skynet.call` 等函数时自动挂起协程，响应返回时自动恢复

### 3. 双模式运行时切换

```typescript
// main-node.ts (Node.js 入口)
import { createNodeRuntime } from './runtime/node-adapter';
setRuntime(createNodeRuntime());

// main.ts (Skynet 入口)
import { createSkynetRuntime } from './runtime/skynet-adapter';
setRuntime(createSkynetRuntime());
```

### 4. 完整业务示例

参见 [`src/examples/login-service.ts`](src/examples/login-service.ts)，演示了:
- ✅ 消息分发和处理
- ✅ 异步 RPC 调用
- ✅ 定时任务
- ✅ 会话管理
- ✅ 错误处理

---

## 🔧 开发工作流

### 日常开发

```bash
# 1. 编写 TypeScript 业务代码
vim src/examples/my-service.ts

# 2. Node.js 环境快速测试
npm run dev

# 3. 满意后编译为 Lua
npm run build:lua

# 4. 在 Skynet 中验证
cd skynet && ./skynet examples/config
```

### 调试技巧

**Node.js 调试:**
```bash
# VS Code 断点调试
# 在 .vscode/launch.json 中配置:
{
  "type": "node",
  "request": "launch",
  "name": "Debug TS-Skynet",
  "program": "${workspaceFolder}/src/main-node.ts",
  "preLaunchTask": "tsc: build - tsconfig.json",
  "outFiles": ["${workspaceFolder}/dist/nodejs/**/*.js"]
}
```

**Skynet 调试:**
```bash
# 1. 配置 SourceMap (已在 tsconfig.tstl.json 中启用)
# 2. 查看编译后的 Lua 代码理解映射关系
cat dist/lua/examples/login-service.lua
```

---

## 📖 技术细节

### TypeScriptToLua (TSTL) 配置

关键配置项 (`tsconfig.tstl.json`):

```json
{
  "tstl": {
    "luaTarget": "5.4",              // Skynet 使用 Lua 5.4
    "luaLibImport": "require",       // 使用 require 导入模块
    "sourceMapTraceback": true,      // 启用 SourceMap
    "noImplicitSelf": true,          // 避免隐式 self
    "noHeader": true                 // 不生成头部注释
  }
}
```

### OOP 映射

TypeScript class 转换为 Lua table + metatable:

```typescript
// TypeScript
export class LoginService {
  private users = new Map<number, User>();
  
  async handleLogin(request: LoginRequest): Promise<LoginResponse> {
    // ...
  }
}
```

```lua
-- 编译后的 Lua (简化)
local LoginService = {}
LoginService.__index = LoginService

function LoginService.new()
  local self = setmetatable({}, LoginService)
  self.users = {}
  return self
end

function LoginService:handleLogin(request)
  -- TSTL 生成的协程包装代码
end
```

### 异步转换原理

```typescript
// TypeScript
async function fetchUser(id: number): Promise<User> {
  const result = await skynet.call('db', 'lua', 'query', id);
  return result;
}
```

```lua
-- 编译后的 Lua (简化)
function fetchUser(id)
  -- skynet.call 内部会 coroutine.yield
  local result = skynet.call('db', 'lua', 'query', id)
  return result
end
```

---

## 🎯 最佳实践

### ✅ DO

1. **始终通过 runtime 访问系统功能**
   ```typescript
   runtime.logger.info('message');
   await runtime.timer.sleep(1000);
   ```

2. **使用 async/await 处理异步**
   ```typescript
   const result = await runtime.network.call(addr, 'lua', 'getData');
   ```

3. **定义清晰的接口**
   ```typescript
   export interface LoginRequest { /* ... */ }
   export interface LoginResponse { /* ... */ }
   ```

### ❌ DON'T

1. **不要直接使用 Node.js API**
   ```typescript
   // ❌ 错误
   console.log('test');
   setTimeout(() => {}, 1000);
   ```

2. **不要依赖浏览器 API**
   ```typescript
   // ❌ 错误
   window.addEventListener('load', () => {});
   document.getElementById('test');
   ```

3. **避免使用不兼容的第三方库**
   ```typescript
   // ❌ 可能有问题
   import axios from 'axios';  // Node.js 专用
   import express from 'express';  // Node.js 专用
   ```

---

## 📚 开发路线图

### Phase 1: 基础框架 ✅

- [x] 抽象接口层设计
- [x] Node.js 适配器实现
- [x] Skynet 适配器实现
- [x] 异步模型统一
- [x] 基础业务示例

### Phase 2: 增强功能 🚧

- [ ] 数据库适配器 (MySQL, Redis)
- [ ] HTTP 服务支持
- [ ] WebSocket 支持
- [ ] 更完善的日志系统
- [ ] 配置管理模块

### Phase 3: 工程化 📋

- [ ] 单元测试框架集成
- [ ] 性能测试工具
- [ ] CI/CD 配置
- [ ] Docker 镜像
- [ ] 完整文档

### Phase 4: 生态 🌟

- [ ] 代码生成器
- [ ] 调试工具
- [ ] 性能分析工具
- [ ] 示例项目集合

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

开发步骤:
1. Fork 本仓库
2. 创建特性分支: `git checkout -b feature/amazing-feature`
3. 提交更改: `git commit -m 'Add amazing feature'`
4. 推送分支: `git push origin feature/amazing-feature`
5. 提交 Pull Request

---

## 📄 许可证

MIT License

---

## 🙏 致谢

- [Skynet](https://github.com/cloudwu/skynet) - 云风的高性能服务端框架
- [TypeScriptToLua](https://github.com/TypeScriptToLua/TypeScriptToLua) - TS 到 Lua 的转译器
- 所有贡献者

---

<div align="center">

**Happy Coding! 🎉**

如有问题，欢迎提交 [Issue](../../issues)

</div>
