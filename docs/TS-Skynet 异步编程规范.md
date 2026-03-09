# TS-Skynet 异步编程规范

## 背景

本框架使用 TypeScriptToLua (TSTL) 将 TypeScript 编译为 Lua 5.4，在 Skynet 环境中运行。由于两个环境的根本性差异，**某些 TypeScript 写法会导致运行时错误**。

本文档说明被禁用的写法及其替代方案，所有开发者必须遵守。

---

## 核心原则

1. **所有异步操作必须使用 `async/await`**
2. **所有系统访问必须通过 `runtime` 抽象层**
3. **服务启动回调必须同步完成**
4. **框架底层代码豁免（Promise polyfill 实现）**

---

## 规则 1：禁止使用 Promise.then() 链式调用

### ❌ 问题代码

```typescript
// 定时器递归 - 会导致 "cannot resume dead coroutine" 错误
const keepAlive = () => {
  runtime.timer.sleep(30000).then(() => {
    runtime.logger.debug('Keep alive');
    keepAlive();
  });
};
keepAlive();

// 消息处理链
runtime.network.dispatch('lua', (session, source, cmd, ...args) => {
  Promise.resolve()
    .then(() => handleCommand(cmd, args))
    .then(result => runtime.network.ret(result))
    .catch(err => runtime.network.ret(false, String(err)));
});
```

### ✅ 正确写法

```typescript
// 定时器递归 - 使用 async/await
const keepAlive = async () => {
  await runtime.timer.sleep(30000);
  runtime.logger.debug('Keep alive');
  keepAlive();
};
keepAlive();

// 消息处理 - dispatch 回调直接用 async
runtime.network.dispatch('lua', async (session, source, cmd, ...args) => {
  try {
    await handleCommand(cmd, args);
  } catch (error) {
    runtime.network.ret(false, String(error));
  }
});
```

### 🔬 原因分析

| 写法 | TSTL 编译结果 | 问题 |
|------|------------|------|
| `async/await` | `__TS__AsyncAwaiter` + 协程 | ✅ Skynet 正确管理协程生命周期 |
| `.then()` | 普通函数回调 | ❌ 回调不在协程管理下，服务退出时崩溃 |

**编译后对比：**

```lua
-- ❌ .then() 编译后（普通回调）
keepAlive = function()
  sleep(30000)["then"](sleep(30000), function()
    runtime.logger:debug("Keep alive")
    keepAlive()
  end)
end

-- ✅ async/await 编译后（协程）
keepAlive = function()
  return __TS__AsyncAwaiter(function(____awaiter_resolve)
    __TS__Await(runtime.timer:sleep(30000))
    runtime.logger:debug("Keep alive")
    keepAlive()
  end)
end
```

---

## 规则 2：禁止在 service.start 回调中使用 async

### ❌ 问题代码

```typescript
// Skynet 要求服务启动回调同步完成
runtime.service.start(async () => {
  await initServices();  // 返回 Promise，服务会立即退出
});
```

### ✅ 正确写法

```typescript
// 定义独立的异步引导函数
async function bootstrap(): Promise<void> {
  await initServices();
  runtime.logger.info('Bootstrap completed');
}

// 同步回调启动异步流程
runtime.service.start(() => {
  bootstrap().catch((error) => {
    runtime.logger.error('Bootstrap failed:', error);
    runtime.service.exit();
  });

  // 保持服务运行 - 推荐使用无限循环
  async function keepAlive(): Promise<void> {
    while (true) {
      await runtime.timer.sleep(60000);
      runtime.logger.debug('[Main] Keep alive');
    }
  }
  keepAlive();
});
```

### 🔬 原因分析

**核心区别**：
- `service.start` 回调：在**服务初始化阶段**执行，此时消息循环尚未启动，必须同步完成
- `dispatch` 回调：在**消息循环内**执行，此时协程管理机制已就绪，可以使用 async

Skynet 的 `skynet.start` 要求回调同步完成后才能进入消息循环。如果回调是 async，返回 Promise 后服务可能提前退出。

---

## 规则 3：dispatch 消息处理器可以使用 async

### ✅ 正确写法

```typescript
// dispatch 回调在消息循环内执行，可以安全使用 async
runtime.network.dispatch('lua', async (session, source, cmd, ...args) => {
  try {
    const result = await handleCommand(cmd, args);
    runtime.network.ret(result);
  } catch (error) {
    runtime.network.ret(false, String(error));
  }
});
```

### 🔬 原因分析

与 `service.start` 不同，`dispatch` 回调执行时：
- 服务已成功启动并进入消息循环
- Skynet 的协程管理机制已经就绪
- 异步操作可以在受控的协程环境中执行

框架底层实现([skynet-adapter.ts:100-111](file:///d:/project/tslua/server/src/framework/runtime/skynet-adapter.ts#L100-L111))会正确处理 async handler 的 Promise 结果。

---

## 规则 4：禁止直接使用 Node.js API

### ❌ 问题代码

```typescript
console.log('test');           // 无 console 对象
setTimeout(() => {}, 1000);    // 无 setTimeout
require('fs').readFileSync();  // 无 Node.js 模块系统
```

### ✅ 正确写法

```typescript
import { runtime } from './framework/core/interfaces';

runtime.logger.info('test');           // 日志
await runtime.timer.sleep(1000);       // 定时器
// 文件操作通过 Skynet API
```

---

## 规则 5：禁止使用浏览器 API

### ❌ 问题代码

```typescript
window.addEventListener('load', ...);
document.getElementById('xxx');
localStorage.getItem('xxx');
fetch('/api/data');
```

### ✅ 正确写法

服务端环境，使用 Skynet 提供的能力：
- 网络请求：`runtime.network.call()`
- 数据存储：数据库/Redis 适配器

---

## 规则 6：禁止使用 Node.js/浏览器全局对象

> ⚠️ **部分已解决**：`console`、`process`、`global` 已通过 `docker/native/` 注入实现，可直接使用。

### ✅ 已支持的全局对象

以下全局对象已在 Skynet 环境中实现，可直接使用：

```typescript
// console - 日志输出
console:log('message');
console:info('info');
console:warn('warning');
console:error('error');
console:time('label');
console:timeEnd('label');

// process - 进程信息
process.env.NODE_ENV;              // 读取环境变量
process.env.MY_VAR = 'value';      // 设置环境变量
process:exit(0);                   // 退出服务
process:cwd();                     // 当前工作目录
process:pid();                     // 服务地址

// global - 全局对象
global.someValue = 1;              // 设置全局变量
```

### ✅ Buffer 已支持（Lua 实现）

**方案**：通过 `docker/native/buffer.lua` 提供 Buffer API

```typescript
// ✅ 支持的用法
const buf = Buffer.from('hello');
const buf = Buffer.from([0x01, 0x02, 0x03]);
const buf = Buffer.alloc(1024);
const buf = Buffer.concat([buf1, buf2]);

buf:length();
buf:toString('utf8');           // 或 'base64', 'hex'
buf:slice(0, 10);

// 读取方法（支持 LE/BE 两种字节序）
buf:readUInt8(0);
buf:readUInt16LE(0);
buf:readUInt32BE(0);
buf:readInt32LE(0);
buf:readFloatLE(0);
buf:readDoubleBE(0);

// 写入方法
buf:writeUInt8(255, 0);
buf:writeUInt32LE(12345, 0);
buf:writeInt16BE(-100, 0);
buf:writeFloatLE(3.14, 0);

// 其他方法
buf:copy(targetBuf, 0);
buf:fill(0);
buf:equals(otherBuf);
```

### ❌ Buffer 不支持的 API

```typescript
// ❌ 禁止使用 - Lua 无 BigInt 类型
buf.readBigInt64BE(0);
buf.readBigUInt64LE(0);
buf.writeBigInt64BE(0n, 0);

// ❌ 禁止使用 - 未实现（很少使用）
buf.readIntLE(0, 6);            // 变长整数
buf.readUIntLE(0, 6);
buf.swap16();
buf.swap32();

// ❌ 禁止使用 - 迭代器未实现
buf.toJSON();
buf.entries();
buf.keys();
buf.values();
```

### ⚠️ Buffer 使用注意事项

1. **方法调用使用 `:` 而非 `.`**
   ```typescript
   // ✅ 正确（Lua 语法）
   buf:toString();
   buf:readUInt32LE(0);

   // ❌ 错误
   buf.toString();
   buf.readUInt32LE(0);
   ```

2. **64 位整数处理**
   ```typescript
   // ❌ 禁止
   const big = buf.readBigUInt64LE(0);

   // ✅ 替代方案
   const high = buf:readUInt32LE(0);
   const low = buf:readUInt32LE(4);
   const bigIntStr = `${high * 0x100000000 + low}`;
   ```

### ✅ setTimeout/setImmediate 已支持（TSTL Plugin 转换）

**方案**：通过 TSTL Plugin 在编译期自动转换

```typescript
// 开发者写的代码
setTimeout(async () => {
    await doSomething();
    console.log('done');
}, 1000);

// TSTL Plugin 编译时自动转换为：
runtime.timer.safeTimeout(async () => {
    await doSomething();
    console.log('done');
}, 1000);
```

**实现机制**：
- `safeTimeout` 使用 `skynet.fork` 创建受管理的协程
- 回调在协程中执行，内部 `await` 正常工作
- Node.js 环境直接映射到原生 `setTimeout`

**限制**：
- `clearTimeout` 仍不支持（Skynet 限制）
- 高频使用可能影响性能（每次调用创建新协程）

### 🔬 实现位置

| 组件 | 位置 | 作用 |
|------|------|------|
| 全局对象注入 | `docker/native/` | `console`、`process`、`global`、`Buffer`、`Date`、`String` |
| TSTL Plugin | `server/plugins/safe-timers.ts` | 编译期转换 `setTimeout/setImmediate` |
| 运行时实现 | `server/src/framework/runtime/` | `safeTimeout/safeImmediate` 方法 |

---

## 规则 7：避免动态模块加载

### ❌ 禁止：动态路径 require

```typescript
// 动态路径 - TSTL 编译时无法解析，会导致运行时错误
const module = require(`./services/${serviceName}`);
const module = require(someVariable);
const module = require('./' + name);
```

### ⚠️ 警告：条件导入（可用但不推荐）

```typescript
// 条件导入 - 可以工作，但会被编译时全部打包，无法节省资源
if (condition) {
  require('./optional-module');  // ⚠️ 模块会被打包，只是运行时不执行
}
```

**原因**：TSTL 会把所有条件分支中的模块都打包进去，无法实现真正的懒加载。如果目的是减少内存占用，这种写法无效。

### ✅ 正确写法

```typescript
// 静态导入
import { GatewayService } from './services/gateway';
import { LoginService } from './services/login';

// 使用映射表替代动态加载
const serviceMap: Record<string, any> = {
  gateway: GatewayService,
  login: LoginService,
};
const Service = serviceMap[serviceName];
```

### 🔬 原因分析

| 写法 | 编译结果 | 运行时行为 | 建议 |
|------|---------|-----------|------|
| `require(\`./${name}\`)` | 路径无法解析 | ❌ 找不到模块 | **禁止** |
| `require('./module')` | 正确编译 | ✅ 正常加载 | 推荐 |
| `if (cond) require(...)` | 模块被打包 | ⚠️ 可用但浪费资源 | 不推荐 |

---

## 规则 8：注意数组边界与索引

### ❌ 问题代码

```typescript
const arr = [1, 2, 3];
arr[-1];           // Lua: 访问键为 -1 的值，返回 nil（不是倒数第一个）
arr.at(-1);        // TSTL polyfill 可能不完整
```

### ✅ 正确写法

```typescript
const arr = [1, 2, 3];
arr[arr.length - 1];  // 显式计算正索引

// 或使用辅助函数
function last<T>(arr: T[]): T | undefined {
  return arr.length > 0 ? arr[arr.length - 1] : undefined;
}
```

### 🔬 原因分析

**Lua 索引规则**：
- Lua 数组索引从 **1** 开始，不是 0
- 负索引 `arr[-1]` 不是"倒数第 N 个"，而是访问键为 `-1` 的值，返回 `nil`
- TSTL 会正确转换 `arr[0]` → `arr[1]`，但负索引行为不同

```lua
-- Lua 中
local arr = {10, 20, 30}
arr[1]    -- 10 (第一个元素)
arr[-1]   -- nil (不是最后一个元素！)
arr[0]    -- nil
```

---

## 规则 9：避免高级正则特性

> ⚠️ 已添加 ESLint 规则 `tslua/no-advanced-regex`（warn 级别）

### ❌ 问题代码

```typescript
// Lua pattern 不支持这些特性
const re1 = /(?<=@)\w+/g;           // lookbehind
const re2 = /(a)(b)\2\1/;           // 反向引用
const re3 = /\d{3,5}?/;             // 非贪婪量词
```

### ✅ 正确写法

```typescript
// 使用简单 pattern 或手写解析
const emailPattern = /^[\w.-]+@[\w.-]+\.\w+$/;

// 复杂解析用代码实现
function extractAfterAt(str: string): string | null {
  const idx = str.indexOf('@');
  return idx >= 0 ? str.slice(idx + 1) : null;
}
```

### 🔬 原因分析

Lua 使用 pattern matching，不是完整的正则表达式。TSTL 的正则 polyfill 有功能限制。

---

## 规则 10：统一空值判断方式

> ⚠️ 已添加 ESLint 规则 `tslua/no-strict-null-compare`（warn 级别）
> ⚠️ 已添加 ESLint 规则 `tslua/no-implicit-null-check`（warn 级别）

### ❌ 问题代码

```typescript
// Node.js: undefined, Skynet: nil
if (obj.foo === undefined) { }     // 在 Lua 中可能不匹配 nil

if (obj.foo === null) { }          // 在 Lua 中可能不匹配 nil

// 隐式判断 - 会同时过滤 falsy 值
if (obj.foo) { }                   // 0, '', false 也会被过滤，可能有歧义

if (!obj.foo) { }                  // 同上
```

### ✅ 正确写法

```typescript
// 使用 == null 兼容两种环境
if (obj.foo == null) { }           // 匹配 undefined、null 和 Lua 的 nil

if (obj.foo != null) { }           // 明确检查非空

// 或使用显式检查
if (typeof obj.foo === 'undefined') { }  // 显式类型检查
```

### 🔬 原因分析

Lua 的 `nil` 与 JavaScript 的 `undefined`/`null` 不同。`== null` 在 TSTL 编译后会正确处理。

**隐式判断的问题**：
- JavaScript: `if (obj.foo)` 会匹配所有 falsy 值 (`0`, `''`, `false`, `null`, `undefined`)
- Lua: `if obj.foo then` 只匹配 `nil` 和 `false`
- 行为差异可能导致跨环境 bug

**推荐做法**：
- 使用 `== null` 或 `!= null` 进行明确的空值检查
- 避免依赖隐式 falsy 判断

---

## 规则 11：注意时间处理差异

> ✅ **已支持**：`Date.now()` 已通过 `docker/native/date.lua` 实现，可直接使用。

### ✅ 已支持的 API

```typescript
// Date.now() - 获取当前时间戳（毫秒）
const timestamp = Date.now();

// Date.UTC() - 返回 UTC 时间戳（毫秒）
Date.UTC(2024, 0, 1, 0, 0, 0, 0);  // 2024-01-01T00:00:00.000Z

// Date.parse() - 解析日期字符串
Date.parse("2024-01-01T00:00:00.000Z");
Date.parse("2024-01-01");

// new Date(timestamp) - 创建 Date 对象
const date = new Date(Date.now());
date:toISOString();       // 格式化为 ISO 8601 字符串
date:getTime();           // 获取时间戳
date:getTimezoneOffset(); // 获取时区偏移（分钟）

// UTC 版本（返回 UTC 时间）
date:getUTCFullYear();    // 年
date:getUTCMonth();       // 月 (0-11)
date:getUTCDate();        // 日
date:getUTCDay();         // 星期 (0-6, 0=周日)
date:getUTCHours();       // 时
date:getUTCMinutes();     // 分
date:getUTCSeconds();     // 秒
date:getUTCMilliseconds(); // 毫秒

// 本地时间版本
date:getFullYear();
date:getMonth();
date:getDate();
date:getDay();
date:getHours();
date:getMinutes();
date:getSeconds();
date:getMilliseconds();
```

### ⚠️ 使用注意事项

1. **方法调用使用 `:` 而非 `.`**（Lua 语法）
   ```typescript
   // ✅ 正确
   date:toISOString();
   date:getFullYear();

   // ❌ 错误
   date.toISOString();
   date.getFullYear();
   ```

2. **时区处理有限**
   - `getTimezoneOffset()` 是简化实现
   - 复杂时区操作建议在应用层处理

3. **Date.parse() 支持格式有限**
   - ISO 8601: `YYYY-MM-DDTHH:mm:ss.sssZ`
   - 简化格式: `YYYY-MM-DD`
   - 其他格式可能不支持

### 🔬 实现位置

| 组件 | 位置 | 作用 |
|------|------|------|
| Date polyfill | `docker/native/date.lua` | `Date.now()`、`toISOString()` 等 |
| 启动加载 | `docker/native/ts_bootstrap.lua` | 注入全局 Date 对象 |

---

## 规则 12：禁止 BigInt，位运算已支持

### ❌ 禁止：BigInt（已添加 ESLint 规则）

```typescript
// ❌ 禁止 - BigInt 字面量
const big = 9007199254740993n;

// ❌ 禁止 - BigInt 类型
function foo(x: bigint) { }

// ❌ 禁止 - BigInt 构造函数
const big = BigInt(123);
```

**替代方案**：使用字符串或分段处理大整数。

### ✅ 已支持：位运算

Lua 5.4 原生支持位运算符，TSTL 直接编译：

```typescript
// TypeScript                  // 编译后 Lua
const a = 1 & 3;              // local a = 1 & 3
const b = 1 | 2;              // local b = 1 | 2
const c = 1 ^ 3;              // local c = 1 ~ 3
const d = 1 << 4;             // local d = 1 << 4
const e = 16 >> 2;            // local e = 16 >> 2
const f = ~0;                 // local f = ~0
```

### ⚠️ 位运算注意事项

1. **32 位限制**：JavaScript 位运算使用 32 位有符号整数
   ```typescript
   // ⚠️ 注意符号位
   (1 << 31);   // TypeScript: -2147483648（负数）
   // Lua: 同样结果，因为都是 32 位有符号

   // ✅ 安全范围
   (1 << 30);   // 1073741824（正数）
   ```

2. **无符号右移 `>>>`**：Lua 不支持，TSTL 有 polyfill
   ```typescript
   // TSTL 会转换为函数调用
   const x = -1 >>> 0;  // 4294967295
   ```

### 🔬 原因分析

- **BigInt**：Lua 没有原生 BigInt 类型，TSTL 无法编译
- **位运算**：Lua 5.4 原生支持 `&`、`|`、`~`、`<<`、`>>`，与 JavaScript 行为一致（32 位有符号整数）

---

## 规则 13：字符串长度计算（已支持 UTF-8）

> ✅ **已支持**：通过 `docker/native/string.lua` 提供 UTF-8 兼容的 String API。
> ❌ **已禁用**：`str.length` 已被 ESLint 规则禁止（error 级别）

### ✅ 已支持的 API

```typescript
// String.length(str) - 获取字符数（UTF-8 兼容）
const str = '你好世界';
String.length(str);           // 4（字符数）
// 注意：str.length 仍返回字节数（TSTL 限制）

// String.charAt(str, index) - 获取指定位置字符
String.charAt(str, 0);        // '你'

// String.charCodeAt(str, index) - 获取 Unicode 码点
String.charCodeAt(str, 0);    // 20320

// String.substring(str, start, end) - 提取子字符串
String.substring(str, 1, 3);  // '好世'

// String.indexOf(str, search) - 查找位置
String.indexOf(str, '世');    // 2

// String.split(str, separator) - 分割字符串
String.split('a,b,c', ',');   // ['a', 'b', 'c']

// 其他方法
String.trim(str);             // 去除首尾空白
String.includes(str, '好');   // true
String.startsWith(str, '你'); // true
String.endsWith(str, '界');   // true
String.repeatStr(str, 2);     // '你好世界你好世界'
String.replace(str, '你', '我'); // '我好世界'
String.toLowerCase(str);      // 转小写
String.toUpperCase(str);      // 转大写
```

### ⚠️ 使用注意事项

1. **`str.length` 返回字节数**（TSTL 编译限制）
   ```typescript
   const str = '你好世界';
   str.length;              // 12（字节数，不是字符数！）
   String.length(str);      // 4（字符数 ✅）
   ```

2. **方法调用方式不同**
   ```typescript
   // ❌ JavaScript 风格
   str.charAt(0);

   // ✅ Lua 风格
   String.charAt(str, 0);
   ```

### 🔬 实现位置

| 组件 | 位置 | 作用 |
|------|------|------|
| String polyfill | `docker/native/string.lua` | UTF-8 兼容的 String API |
| Lua utf8 库 | Lua 5.4 内置 | `utf8.len()`, `utf8.offset()` |

---

## 规则 14：Map/Set 使用注意事项

> ❌ **已禁用**：NaN 作为 Map 键已被 ESLint 规则禁止（error 级别）
> ✅ **对象作为键**：支持引用比较，与 JavaScript 行为一致

### ❌ 禁止：NaN 作为键

```typescript
// ❌ error - NaN 作为键
map.set(NaN, 'value');
map.set(Number.NaN, 'value');
map.set(0/0, 'value');
new Map([[NaN, 'value']]);

// ✅ 替代方案
map.set('__NaN__', 'value');
map.set('NaN', 'value');
```

### ✅ 支持的特性

```typescript
// ✅ 对象作为键（引用比较）
const obj = { a: 1 };
map.set(obj, 'value');
map.get(obj);      // 'value' ✅
map.has(obj);      // true ✅

const obj2 = { a: 1 };
map.has(obj2);     // false（不同引用，与 JavaScript 一致）

// ✅ string/number 键
map.set('key', 1);
map.set(123, 'num');

// ✅ 迭代
map.forEach((v, k) => { });  // ✅
for (const [k, v] of map) { } // ✅
```

### ✅ 正确写法

```typescript
// 简单场景使用普通对象
const obj: Record<string, number> = {};
obj['a'] = 1;

// Map/Set 各种键类型
const map = new Map();
map.set('str', 1);           // ✅ string
map.set(123, 'num');         // ✅ number
map.set({ id: 1 }, 'obj');   // ✅ 对象（引用比较）
```

### 🔬 原因分析

| 特性 | JavaScript | Lua (TSTL) |
|------|-----------|------------|
| string/number 键 | ✅ | ✅ |
| 对象作为键 | ✅ 引用比较 | ✅ 引用比较 |
| NaN 作为键 | ✅ | ❌ 不支持 |
| 插入顺序迭代 | ✅ | ✅ |
| for...of 迭代 | ✅ | ✅ |
| forEach 迭代 | ✅ | ✅ |

> **注意**：Lua table 原生支持 table 作为键，TSTL 直接利用此特性，对象键的比较是引用比较，与 JavaScript Map 行为一致。

---

## 完整对照表

| 场景 | ❌ 禁用写法 | ✅ 替代方案 |
|------|----------|-----------|
| **异步链式** | `promise.then().catch()` | `async/await` + `try/catch` |
| **定时器** | `setTimeout(fn, ms)` | `await runtime.timer.sleep(ms)` |
| **日志** | `console.log()` | `runtime.logger.info()` |
| **服务启动** | `service.start(async () => {})` | `service.start(() => { asyncFn().catch(...) })` |
| **循环定时** | `while(true) { promise.then() }` | `while(true) { await work(); await sleep(); }` |
| **服务调用** | `skynet.call(addr, ...)` | `await runtime.network.call(addr, ...)` |
| **消息分发** | `dispatch('lua', () => {...})` | `dispatch('lua', async () => {...})` |
| **Node.js API** | `require('fs')` | `runtime.file.read()` |
| **浏览器 API** | `fetch()` | `runtime.network.call()` |
| **全局对象** | `console/process/global` | ✅ 已实现，可直接使用 |
| **定时器** | `setTimeout/setImmediate` | ✅ TSTL Plugin 自动转换 |
| **Buffer** | `Buffer.from()` | ✅ 已实现（禁用 BigInt 相关 API） |
| **Buffer BigInt** | `readBigInt64BE()` | ❌ 禁用，Lua 无 BigInt |
| **动态加载** | `require(\`./${name}\`)` | ❌ 禁止，静态导入 + 映射表 |
| **条件导入** | `if (cond) require(...)` | ⚠️ 警告，可用但浪费资源 |
| **数组负索引** | `arr[-1]` | `arr[arr.length - 1]` |
| **高级正则** | `/(?<=@)\w+/` | ⚠️ 警告，简单 pattern + 代码解析 |
| **空值判断** | `=== undefined`, `if (obj.foo)` | ⚠️ 警告，使用 `== null` 或 `!= null` |
| **时间处理** | `Date.now()` | ✅ 已支持，`docker/native/date.lua` |
| **BigInt** | `9007199254740993n` | ❌ 禁止，字符串或分段处理 |
| **位运算** | `<<`, `>>`, `&`, `\|` | ✅ 已支持，Lua 5.4 原生 |
| **字符串长度** | `str.length` | ❌ 禁止，`String.length(str)`（UTF-8） |
| **Map NaN键** | `map.set(NaN, v)` | ❌ 禁止，使用字符串键 |
| **Map/Set迭代** | `for...of map` | ✅ 已支持 |

---

## ESLint 自动检查

### 自定义规则

项目配置了自定义 ESLint 规则，自动检测违规代码：

```bash
npm run lint
```

### 规则配置

```javascript
// eslint.config.mjs
export default [
  {
    rules: {
      'tslua/no-promise-then': 'error',           // 禁止 .then()
      'tslua/no-async-in-service-start': 'error', // 禁止 service.start 中用 async
      'tslua/no-dynamic-require': 'error',        // 禁止动态路径 require()
      'tslua/no-bigint': 'error',                 // 禁止 BigInt
      'tslua/no-string-length': 'error',          // 禁止 str.length（字节 vs 字符）
      'tslua/no-nan-map-key': 'error',            // 禁止 NaN 作为 Map 键
      'tslua/no-conditional-require': 'warn',     // 警告：条件 require（可用但不推荐）
      'tslua/no-advanced-regex': 'warn',          // 警告：高级正则特性
      'tslua/no-strict-null-compare': 'warn',     // 警告：严格空值比较
      'tslua/no-implicit-null-check': 'warn',     // 警告：隐式空值判断
      // dispatch 回调允许使用 async，无需额外规则
    }
  }
];
```

### 建议补充的规则

以下规则可根据项目需要逐步添加：

```javascript
{
  // 禁止 Buffer BigInt 相关方法（已支持基础 Buffer，但 BigInt 相关不可用）
  // 需要自定义规则检测 readBigInt64BE/writeBigInt64BE 等
}
```

> **注意**：`console`、`process`、`global`、`Buffer`、`Date`、`String`、`setTimeout`、`setImmediate` 已在 Skynet 环境中实现，不需要通过 `no-restricted-globals` 禁止。BigInt 已通过 `tslua/no-bigint` 规则禁止（error 级别），动态 `require()` 已通过 `tslua/no-dynamic-require` 规则禁止（error 级别），条件 `require()` 已通过 `tslua/no-conditional-require` 规则警告（warn 级别）。

### 豁免文件

以下框架底层文件豁免 `.then()` 限制（需要实现 Promise polyfill）：

- `framework/runtime/async-bridge.ts`
- `framework/runtime/skynet-adapter.ts`
- `framework/runtime/node-adapter.ts`
- `framework/core/interfaces.ts`

---

## 常见场景示例

### 场景 1：服务启动 + 保持运行

```typescript
runtime.service.start(() => {
  // 1. 启动异步引导
  bootstrap().catch(err => runtime.service.exit());

  // 2. 保持服务运行（必须）
  const keepAlive = async () => {
    await runtime.timer.sleep(60000);
    keepAlive();
  };
  keepAlive();
});
```

### 场景 2：消息处理器

```typescript
// ✅ 正确：async 回调
runtime.network.dispatch('lua', async (session, source, cmd, ...args) => {
  try {
    const result = await handleCommand(cmd, args);
    runtime.network.ret(result);
  } catch (error) {
    runtime.network.ret(false, String(error));
  }
});
```

### 场景 3：定时任务

```typescript
// ✅ 正确：async 循环
async function sessionCleaner(): Promise<void> {
  while (true) {
    await cleanupExpiredSessions();
    await runtime.timer.sleep(60000);
  }
}
```

### 场景 4：服务间 RPC 调用

```typescript
// ✅ 正确：await 等待响应
async function callLoginService(username: string): Promise<User> {
  const loginAddr = await runtime.service.newService('login');
  const result = await runtime.network.call(loginAddr, 'lua', 'getUser', username);
  return result;
}
```

---

## 调试技巧

### 查看编译后的 Lua 代码

```bash
npm run build:ts
cat dist/lua/app/services/login/index.lua
```

检查点：
- `async` 函数 → `__TS__AsyncAwaiter(function() ... end)`
- `await` 表达式 → `__TS__Await(...)`
- 不应有 `["then"](` 调用（框架层除外）

### 查看 SourceMap

`tsconfig.lua.json` 已启用 `sourceMapTraceback: true`，Lua 错误堆栈会映射回 TypeScript 行号。

---

## 总结

| 要点 | 说明 |
|------|------|
| **核心** | 一律使用 `async/await`，禁止 `.then()` 链式 |
| **原因** | TSTL 将 `async/await` 转换为协程，`.then()` 只是普通回调 |
| **检查** | `npm run lint` 自动检测违规代码 |
| **例外** | 框架底层可实现 Promise polyfill，豁免 `.then()` 限制 |

遵守本规范可确保代码：
1. ✅ 在 Node.js 环境正确运行（开发调试）
2. ✅ 编译为 Lua 后在 Skynet 正确运行（生产环境）
3. ✅ 避免 `cannot resume dead coroutine` 等运行时错误

---

## 规则 15：TSTL 插件编译规范

> ⚠️ TSTL 插件是编译时工具，不参与 Lua 编译

### 问题说明

TSTL 插件（如 `safe-timers.ts`）在编译时运行，用于转换 AST。它们：
- 不应该被 TSTL 编译为 Lua
- 必须编译为 JavaScript 供 Node.js 运行

### ✅ 正确做法

```bash
# 1. 编译插件为 JavaScript
cd server
npx tsc plugins/safe-timers.ts --module commonjs --target ES2020 --skipLibCheck --outDir plugins

# 2. 在 tsconfig.lua.json 中配置
{
  "tstl": {
    "luaPlugins": [
      { "name": "../plugins/safe-timers.js" }  // 使用 .js 文件
    ]
  },
  "exclude": ["../plugins"]  // 排除 plugins 目录
}
```

### 🔬 实现位置

| 文件 | 作用 |
|------|------|
| `server/plugins/safe-timers.ts` | 插件源码 |
| `server/plugins/safe-timers.js` | 编译产物（需版本控制） |
| `server/config/tsconfig.lua.json` | 排除 plugins 目录 |

---

## 规则 16：Lua 全局对象调用语法

> ⚠️ TSTL 默认将 `_G.method()` 编译为 `_G:method()`（冒号语法）

### 问题说明

TSTL 编译 `_G.require("skynet")` 时，默认使用冒号语法：
```lua
-- 错误编译结果
local skynet = _G:require("skynet")  -- 等价于 require(_G, "skynet")
```

这会把 `_G` 作为第一个参数传入，导致 `string expected, got table` 错误。

### ✅ 正确做法

在类型声明中添加 `this: void` 强制点号调用：

```typescript
// ✅ 正确
declare const _G: {
  require: (this: void, name: string) => any;
  pcall: (this: void, fn: () => void) => boolean;
  print: (this: void, ...args: any[]) => void;
  io: { open: (this: void, path: string, mode: string) => any };
  load: (this: void, code: string) => (...args: any[]) => any;
};

const skynet = _G.require('skynet');  // 编译为 _G.require("skynet") ✅
```

### 编译结果对比

| 声明方式 | 编译结果 | 说明 |
|---------|---------|------|
| `(name: string) => any` | `_G:require(name)` | 冒号语法（默认）❌ |
| `(this: void, name: string) => any` | `_G.require(name)` | 点号语法 ✅ |

---

## 规则 17：Docker 镜像与容器命名

### 问题说明

代码中硬编码的镜像名称与实际构建的镜像名称不一致，导致每次都重新构建。

### ✅ 正确做法

确保代码中的镜像名称与 `docker-compose.yml` 中定义的一致：

```yaml
# compose.yml
services:
  skynet:
    container_name: tslua-skynet    # 容器名
    # 镜像名默认为 docker-skynet（目录名-service名）
```

```typescript
// cli/index.ts
const IMAGE_NAME = 'docker-skynet';     // 镜像名
const CONTAINER_NAME = 'tslua-skynet';  // 容器名
```

---

## 待解决问题

### ⚠️ TSTL Promise 协程与 Skynet 协程兼容性

**问题描述**：
- TSTL 的 `async/await` 使用 Lua 原生协程（`coroutine.create/resume`）
- Skynet 有自己的协程管理（`skynet.fork/sleep`）
- 两者不完全兼容，可能导致 `cannot resume dead coroutine` 错误

**已修复的部分**：
- `runtime.timer.sleep()` 改用 `skynet.timeout` 而非 `skynet.sleep`
- `runtime.service.start()` 使用 `skynet.fork` 包装回调
- `runtime.network.dispatch()` 简化为直接调用

**剩余问题**：
- 某些异步流程仍可能出现协程错误
- 需要深入研究 TSTL `__TS__AsyncAwaiter` 与 Skynet 协程的交互

**可能的解决方案**：
1. 修改 `lualib_bundle.lua` 中的 `__TS__AsyncAwaiter`，使用 Skynet 协程
2. 创建 Skynet 专用的 Promise polyfill
3. 在关键位置使用 `skynet.fork` 包装异步操作

**相关文件**：
- `server/dist/lua/lualib_bundle.lua` - TSTL Promise 实现
- `server/src/framework/runtime/skynet-adapter.ts` - Skynet 适配器
- `docker/native/ts_bootstrap.lua` - 启动脚本

---

## 本次修复清单

| 问题 | 文件 | 修改内容 |
|------|------|---------|
| TSTL 插件编译 | `tsconfig.lua.json` | 排除 plugins，使用 .js 插件 |
| 插件编译产物 | `plugins/safe-timers.js` | 新增编译产物 |
| Docker 镜像名 | `scripts/cli/index.ts` | 修正为 `docker-skynet` |
| _G.require 语法 | `skynet-pb-codec.ts` | 添加 `this: void` |
| _G.io.open 语法 | `skynet-pb-codec.ts` | 添加 `this: void` |
| sleep 协程 | `skynet-adapter.ts` | 改用 `skynet.timeout` |
| service.start | `skynet-adapter.ts` | 使用 `skynet.fork` 包装 |
| dispatch | `skynet-adapter.ts` | 简化为直接调用 |
| 智能启动 | `scripts/cli/index.ts` | 完整启动流程 |

