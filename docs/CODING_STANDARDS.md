# TS-Skynet 项目编码规范

## 核心原则

本项目采用 TypeScript 编写，通过 TypeScriptToLua (TSTL) 编译为 Lua 运行在 Skynet 框架上。

由于 TSTL 和 Skynet 的运行时差异，必须遵循以下规范。

---

## 🚨 关键规则

### 规则 1：服务初始化禁止 async

**级别**: ERROR (必须遵守)

**说明**: `runtime.service.start()` 的回调必须是**同步函数**。

#### ❌ 错误示例

```typescript
// 禁止！会导致服务启动后立即退出
runtime.service.start(async () => {
  const config = await loadConfig();  // ❌ 禁止
  runtime.network.dispatch('lua', handler);
});
```

#### ✅ 正确示例

```typescript
// 正确：同步初始化
runtime.service.start(() => {
  // 同步创建对象
  const data = new ConnectionData();
  
  // 注册消息处理器（handler 内部可以用 async）
  runtime.network.dispatch('lua', async (session, source, cmd) => {
    // 消息处理里可以用 await
    const result = await handleCommand(cmd);
    runtime.network.ret(result);
  });
  
  // 【重要】启动 keep-alive 定时器
  const keepAlive = () => {
    runtime.timer.sleep(30000).then(() => {
      keepAlive();
    });
  };
  keepAlive();
});
```

#### 原因

Skynet 的服务生命周期管理机制：
- `skynet.start(callback)` 执行完毕后，如果没有挂起的协程，服务会立即退出
- TSTL 转换的 `async/await` 会被包装成 Promise，Skynet 无法识别为挂起的协程
- 结果：服务启动后 `KILL self`

---

### 规则 2：消息处理器可以使用 async

**级别**: OK

**说明**: `runtime.network.dispatch()` 注册的回调函数**可以**使用 `async`。

```typescript
runtime.network.dispatch('lua', async (session, source, cmd, ...args) => {
  // ✅ 这里可以用 await
  const result = await processCommand(cmd, args);
  runtime.network.ret(result);
});
```

原因：每次消息调用是独立的执行上下文，处理完成后返回即可。

---

### 规则 3：保持服务运行

**级别**: WARNING (建议遵守)

**说明**: 服务初始化后，必须确保至少有一个活跃的协程，否则服务会退出。

#### 推荐做法

```typescript
runtime.service.start(() => {
  // ... 初始化代码 ...
  
  // 方式 1：定时器循环（推荐）
  const keepAlive = () => {
    runtime.timer.sleep(30000).then(() => {
      keepAlive();
    });
  };
  keepAlive();
  
  // 方式 2：如果有定时任务
  runtime.timer.setInterval(() => {
    doSomething();
  }, 60000);
});
```

---

## 代码示例

### 完整的服务模板

```typescript
/**
 * XXX 服务
 * 
 * 遵循规范：
 * - start 回调同步执行
 * - 消息处理器异步执行
 * - 保持服务运行
 */

import { runtime } from '../../../framework/core/interfaces';

// 数据层（同步创建）
const data = new DataStore();

// 逻辑层（同步创建）
const logic = new BusinessLogic(data);

/**
 * 命令处理（可以使用 async）
 */
async function handleCommand(cmd: string, args: any[]): Promise<any> {
  switch (cmd) {
    case 'get':
      return await logic.getData(args[0]);
    case 'set':
      return await logic.setData(args[0], args[1]);
    default:
      throw new Error(`Unknown command: ${cmd}`);
  }
}

// ==================== 服务入口 ====================

runtime.service.start(() => {
  runtime.logger.info('=== XXX Service Starting ===');
  
  // 注册消息处理器
  runtime.network.dispatch('lua', (session, source, cmd, ...args) => {
    // 异步处理命令
    Promise.resolve()
      .then(() => handleCommand(cmd, args))
      .then(result => runtime.network.ret(result))
      .catch(error => {
        runtime.logger.error(`Command failed:`, error);
        runtime.network.ret(false, String(error));
      });
  });
  
  runtime.logger.info('=== XXX Service Ready ===');
  
  // 【必须】保持服务运行
  const keepAlive = () => {
    runtime.timer.sleep(30000).then(() => {
      runtime.logger.debug('[XXX] Keep alive');
      keepAlive();
    });
  };
  keepAlive();
});
```

---

## ESLint 规则

项目已配置 ESLint 规则检测违规代码：

```bash
# 检查代码
npm run lint

# 自动修复
npm run lint:fix
```

相关规则：
- `@tslua/no-async-in-start`: 禁止在 service.start 回调中使用 async

---

## 调试技巧

### 问题：服务启动后立即退出

**现象**:
```
[:00000008] [INFO] === Gateway Service Ready ===
[:00000008] [INFO] Connections: 0
[:00000002] KILL self
```

**检查清单**:
1. [ ] `runtime.service.start()` 回调是否用了 `async`？
2. [ ] 是否有 `keepAlive` 定时器保持服务运行？
3. [ ] `runtime.network.dispatch` 是否正确注册？

### 验证服务运行状态

```bash
# 查看容器日志
docker logs tslua-skynet

# 查看服务是否存活
docker exec tslua-skynet ps aux | grep skynet
```

---

## 参考

- [Skynet 官方文档](https://github.com/cloudwu/skynet)
- [TypeScriptToLua 文档](https://typescripttolua.github.io/)
- [Lua 协程机制](https://www.lua.org/pil/9.1.html)
