# TypeScriptToLua Skynet 适配版本

基于 [TypeScriptToLua](https://github.com/TypeScriptToLua/TypeScriptToLua) 官方版本的 Skynet 框架适配分支。

## 概述

本版本在标准 TSTL 基础上新增了 **Skynet 协程兼容模式**，解决了 TypeScript `async/await` 和 `setTimeout` 编译后的 Lua 协程与 Skynet 消息循环不兼容的问题。

## 核心改动

### 1. 新增编译选项 `skynetCompat`

**文件**: `src/CompilerOptions.ts`

```typescript
export interface TypeScriptToLuaOptions {
    // ... 其他选项
    // Skynet compatibility mode - uses skynet.fork for async coroutines
    skynetCompat?: boolean;
}
```

**使用方式**: 在 `tsconfig.json` 中配置：

```json
{
  "tstl": {
    "skynetCompat": true
  }
}
```

### 2. 新增 `AwaitSkynet.ts` 运行时库

**文件**: `src/lualib/AwaitSkynet.ts`

这是标准 `Await.ts` 的 Skynet 兼容版本，核心差异：

| 特性 | 标准 Await.ts | AwaitSkynet.ts |
|------|--------------|----------------|
| 协程创建 | 直接 `coroutine.create` | 通过 `skynet.fork` 包装 |
| 调度机制 | Lua 原生协程 | Skynet 消息循环 |
| 兼容性 | 通用 Lua 环境 | Skynet 框架专用 |

**关键代码逻辑**:

```lua
-- 检测 Skynet 环境
local skynet = _G.package.loaded["skynet"] or _G.skynet

-- 使用 skynet.fork 包装协程创建
if skynet and type(skynet.fork) == "function" then
    skynet.fork(startCoroutine)  -- Skynet 调度
else
    startCoroutine()  -- 回退到原生协程
end
```

### 3. 新增 `SetTimeoutSkynet.ts` 运行时库

**文件**: `src/lualib/SetTimeoutSkynet.ts`

将 `setTimeout`/`setImmediate` 转换为 Skynet 协程安全实现：

| 原始调用 | 转换后行为 |
|----------|-----------|
| `setTimeout(cb, ms)` | `skynet.timeout(ms/10, () => skynet.fork(cb))` |
| `setImmediate(cb)` | `skynet.timeout(0, () => skynet.fork(cb))` |
| `clearTimeout(id)` | 空操作（Skynet 不支持取消） |

**特点**：
- 使用 `skynet.timeout` 实现定时
- 使用 `skynet.fork` 包装回调，确保协程安全
- 非 Skynet 环境自动降级

### 4. 修改 async/await 转换逻辑

**文件**: `src/transformation/visitors/async-await.ts`

```typescript
// 根据 skynetCompat 选项选择运行时库
export function getAwaitFeature(context: TransformationContext): LuaLibFeature {
    return context.options.skynetCompat 
        ? LuaLibFeature.AwaitSkynet 
        : LuaLibFeature.Await;
}
```

### 5. 新增 Timer 转换逻辑

**文件**: `src/transformation/builtins/global.ts`

```typescript
export function tryTransformTimerCall(
    context: TransformationContext,
    node: ts.CallExpression
): lua.Expression | undefined {
    if (!context.options.skynetCompat) return undefined;
    
    switch (name) {
        case "setTimeout":
        case "setImmediate":
            return transformLuaLibFunction(context, LuaLibFeature.SetTimeoutSkynet, ...);
    }
}
```

## 问题背景

### 为什么需要这个适配？

**标准 TSTL 的问题**:

```
TSTL async/await  →  Lua 原生协程 (coroutine.create/resume)
                           ↓
                    与 Skynet 消息循环冲突
                           ↓
                    "cannot resume dead coroutine" 错误
```

**Skynet 的协程管理**:

- Skynet 有自己的协程调度器 (`skynet.fork/sleep/call`)
- Lua 原生协程不在 Skynet 调度器管理范围内
- 直接使用原生协程会导致协程状态不同步

### 解决方案

```
TSTL async/await  →  skynet.fork 包装的协程
                           ↓
                    纳入 Skynet 调度器管理
                           ↓
                    协程状态正确同步
```

## 构建与使用

### 构建

```bash
cd tool/TypeScriptToLua_skynet
npm install
npm run build
```

### 配置项目使用

在 `server/config/tsconfig.lua.json` 中启用：

```json
{
  "tstl": {
    "luaTarget": "5.4",
    "skynetCompat": true
  }
}
```

**启用后自动转换**：

| TypeScript | Lua (skynetCompat: true) |
|------------|--------------------------|
| `await foo()` | 使用 `skynet.fork` 包装协程 |
| `setTimeout(cb, 100)` | `skynet.timeout(10, () => skynet.fork(cb))` |
| `setImmediate(cb)` | `skynet.timeout(0, () => skynet.fork(cb))` |

## 版本信息

| 项目 | 版本 |
|------|------|
| 基础版本 | TypeScriptToLua 1.34.0 |
| TypeScript | 5.9.3 |
| Lua Target | 5.4 |

## 文件清单

| 文件 | 说明 |
|------|------|
| `src/CompilerOptions.ts` | 新增 `skynetCompat` 选项定义 |
| `src/LuaLib.ts` | 新增 `SetTimeoutSkynet` feature |
| `src/lualib/AwaitSkynet.ts` | Skynet 兼容的 async/await 运行时 |
| `src/lualib/SetTimeoutSkynet.ts` | Skynet 兼容的 setTimeout 运行时 |
| `src/transformation/visitors/async-await.ts` | 条件选择 Await 实现 |
| `src/transformation/builtins/global.ts` | Timer 函数转换逻辑 |
| `src/transformation/builtins/index.ts` | 集成 Timer 转换 |

## 注意事项

1. **环境检测**: 运行时库会自动检测 Skynet 环境，非 Skynet 环境会回退到原生实现
2. **性能影响**: `skynet.fork` 有轻微调度开销，但对游戏服务器场景可忽略
3. **兼容性**: 仅影响 `async/await` 和 `setTimeout` 编译结果，其他功能与标准 TSTL 完全一致
4. **clearTimeout 限制**: Skynet 不支持取消 timeout，`clearTimeout` 为空操作

## 迁移指南

### 从外部插件迁移

如果之前使用 `server/plugins/safe-timers.ts` 插件：

1. **移除插件配置**：
```json
// tsconfig.lua.json - 删除这部分
"luaPlugins": [
  { "name": "../plugins/safe-timers.js" }
]
```

2. **启用 skynetCompat**：
```json
{
  "tstl": {
    "skynetCompat": true
  }
}
```

3. **删除插件文件**：
```bash
rm server/plugins/safe-timers.ts
rm server/plugins/safe-timers.js
```

## 相关文档

- [TS-Skynet 异步编程规范](../../docs/TS-Skynet 异步编程规范.md)
- [Skynet 协程机制](https://github.com/cloudwu/skynet/wiki/Coroutine)
- [TypeScriptToLua 官方文档](https://typescripttolua.github.io/)
