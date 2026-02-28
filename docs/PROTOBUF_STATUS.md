# Protobuf 集成状态报告

## 集成完成度

```
┌─────────────────────────────────────────────────────────────┐
│                    Protobuf 集成状态                         │
├─────────────────────────────────────────────────────────────┤
│ ✅ 核心接口层        IPbCodec 接口定义                        │
│ ✅ Node.js Codec     JSON 序列化实现                         │
│ ✅ Skynet Codec      lua-protobuf 适配                       │
│ ✅ 类型定义          TypeScript 类型完整                      │
│ ✅ 运行时集成        codec 加入 IRuntime                     │
│ ✅ 业务代码示例      login service 已更新                    │
│ ⚠️  标准 Protobuf    依赖 protobufjs（可选）                 │
│ ⚠️  Lua 描述文件     需手动/自动编译生成                     │
└─────────────────────────────────────────────────────────────┘
```

## 已完成的工作

### 1. 核心架构

| 文件 | 说明 |
|-----|------|
| `src/framework/core/interfaces.ts` | 新增 `IPbCodec` 接口，集成到 `IRuntime` |
| `src/framework/runtime/node-pb-codec.ts` | Node.js 环境编解码器 |
| `src/framework/runtime/skynet-pb-codec.ts` | Skynet 环境编解码器 |
| `src/framework/runtime/node-adapter.ts` | 集成 codec 到 Node.js 运行时 |
| `src/framework/runtime/skynet-adapter.ts` | 集成 codec 到 Skynet 运行时 |

### 2. Proto 定义

| 文件 | 说明 |
|-----|------|
| `src/protos/proto.d.ts` | TypeScript 类型定义（完整） |
| `src/protos/proto.js` | Node.js 运行时实现（JSON 序列化） |
| `src/protos/index.ts` | 统一导出 |
| `src/protos/example.ts` | 使用示例 |

### 3. 业务集成

| 文件 | 说明 |
|-----|------|
| `src/app/services/login/types.ts` | 导出 proto 类型 |
| `src/app/services/login/index.ts` | 集成 codec 到消息处理 |

## 使用方式

### 1. 开发环境 (Node.js)

```bash
# 启动服务
npm run dev

# codec 自动加载，使用 JSON 序列化
# 便于调试和开发
```

### 2. 生产环境 (Skynet)

```bash
# 1. 编译 Lua 代码
npm run build:lua

# 2. （可选）编译 proto 描述文件
npm run build:proto

# 3. 运行 Skynet
cd skynet && ./skynet examples/config
```

### 3. 代码示例

```typescript
import { runtime } from '../../../framework/core/interfaces';
import { MessageId, proto } from '../../../common/protos';

// 创建消息
const request = proto.login.LoginRequest.create({
  username: 'player1',
  password: 'secret',
});

// 编码
if (runtime.codec) {
  const encoded = runtime.codec.encode('login.LoginRequest', request);
  
  // 打包为 Packet
  const packet = runtime.codec.pack(
    MessageId.LOGIN_REQ,
    'login.LoginRequest',
    request
  );
  
  // 发送
  runtime.network.send('gateway', 'lua', packet);
}
```

## 两种序列化方案

### 方案 A: 简化 JSON（当前默认）

**优点：**
- 无需额外依赖
- 易于调试（人类可读）
- 开发体验好

**缺点：**
- 消息体积较大
- 无严格类型验证

**适用场景：** 开发、测试、内部服务通信

### 方案 B: 标准 Protobuf（可选）

**优点：**
- 二进制编码，体积小
- 高性能
- 跨语言兼容

**缺点：**
- 需要编译 proto 文件
- 依赖 protobufjs/lua-protobuf

**适用场景：** 生产环境、客户端通信

## 切换到标准 Protobuf

### 1. 安装依赖

```bash
npm install protobufjs protobufjs-cli
```

### 2. 生成代码

```bash
npm run build:proto
```

这会生成：
- `src/protos/proto.js` - 替换当前的 JSON 实现
- `src/protos/proto.d.ts` - 类型定义

### 3. 验证 Lua 描述文件

确保 `dist/lua/protos/*.desc` 文件存在，供 lua-protobuf 加载。

## 注意事项

### 1. 消息 ID 一致性

确保两端使用相同的 `MessageId` 定义：

```typescript
// src/protos/proto.js
const MessageId = {
  LOGIN_REQ: 200,
  LOGIN_RESP: 201,
  // ...
};
```

### 2. Codec 可用性检查

始终检查 codec 是否存在：

```typescript
if (runtime.codec) {
  // 使用 protobuf
} else {
  // 使用 fallback
}
```

### 3. 类型转换

Node.js 和 Skynet 的 `Uint8Array` 处理可能有差异，codec 内部已处理转换。

## 后续优化建议

1. **自动代码生成**
   - 从 .proto 文件自动生成 proto.d.ts 和 proto.js
   - 避免手动维护两份定义

2. **性能优化**
   - 添加消息缓存池
   - 零拷贝序列化

3. **工具支持**
   - Proto 文件 lint
   - 消息 ID 冲突检测
   - 版本兼容性检查

4. **文档完善**
   - 各服务协议文档
   - 消息变更日志

## 总结

Protobuf 已成功集成到 TS-Skynet 项目，**TypeScript → TSTL → Lua** 工作流已打通：

```
TypeScript 业务代码
       ↓
 使用 proto 类型
       ↓
 调用 runtime.codec
       ↓
  ┌──────────┬──────────┐
  ▼          ▼          ▼
Node.js   TSTL       Skynet
(JSON)    编译       (lua-protobuf)
  ↓         ↓          ↓
开发测试  →  Lua 代码  →  生产运行
```

当前实现已满足开发和测试需求，生产环境可根据需要切换到标准 Protobuf 二进制编码。
