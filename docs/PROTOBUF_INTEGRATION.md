# Protobuf 集成方案

本文档说明 protobuf 如何融入 TS-Skynet 项目，确保 **TypeScript → TSTL → Lua** 工作流正常。

## 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                    业务代码层                                │
│         (login/game/gateway services)                       │
│              使用 proto 类型                                 │
└──────────────────────┬──────────────────────────────────────┘
                       │ import { proto, MessageId }
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Proto 类型定义层                                │
│      (src/protos/proto.d.ts, proto.js)              │
│         TypeScript 类型 + 运行时实现                        │
└──────────────────────┬──────────────────────────────────────┘
                       │ encode/decode/create
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              PB Codec 抽象接口层                             │
│              (IPbCodec interface)                           │
│        pack/unpack/encode/decode/create                     │
└──────────────┬─────────────────────┬────────────────────────┘
               │                     │
               ▼                     ▼
┌──────────────────────┐  ┌──────────────────────┐
│   Node.js Codec      │  │   Skynet Codec       │
│   (JSON fallback)    │  │   (lua-protobuf)     │
│                      │  │                      │
│  • 开发测试使用       │  │  • 生产环境使用       │
│  • 无需编译 proto    │  │  • 高性能二进制编码   │
│  • 易调试             │  │  • 标准 protobuf    │
└──────────────────────┘  └──────────────────────┘
```

## 工作流程

### 1. 定义协议

编辑 `common/protos/*.proto` 文件：

```protobuf
// common/protos/login.proto
syntax = "proto3";
package login;

message LoginRequest {
  string username = 1;
  string password = 2;
  string device_id = 3;
  string platform = 4;
}

message LoginResponse {
  common.ErrorCode code = 1;
  string message = 2;
  UserInfo user = 3;
  string token = 4;
}
```

### 2. 生成代码（可选，已有简化版）

项目已包含简化版的 proto 实现：
- `src/protos/proto.d.ts` - TypeScript 类型定义
- `src/protos/proto.js` - Node.js 运行时（JSON 序列化）

如需标准 protobuf 二进制编码，运行：
```bash
npm run build:proto
```

### 3. 业务代码中使用

```typescript
// src/app/services/login/index.ts
import { runtime } from '../../../framework/core/interfaces';
import { MessageId, proto } from '../../../common/protos';

async function handleLogin(request: LoginRequest): Promise<void> {
  // 执行业务逻辑
  const result = await logic.handleLogin(request);
  
  // 构建 proto 响应
  const protoResponse = proto.login.LoginResponse.create({
    code: result.success ? proto.common.ErrorCode.SUCCESS : proto.common.ErrorCode.UNAUTHORIZED,
    message: result.error || '',
    user: result.user ? {
      userId: result.user.userId,
      username: result.user.username,
      loginTime: result.user.loginTime,
    } : undefined,
  });
  
  // 使用 codec 编码
  if (runtime.codec) {
    const encoded = runtime.codec.encode('login.LoginResponse', protoResponse);
    runtime.network.ret(true, encoded);
  } else {
    // fallback
    runtime.network.ret(result.success, result.user, result.error);
  }
}
```

### 4. 编译到 Lua

```bash
# 编译 TypeScript → Lua
npm run build:lua

# 输出到 dist/lua/
# 业务代码被编译为 Lua
```

### 5. Skynet 运行

```lua
-- Skynet 中使用 lua-protobuf 解码
local pb = require "pb"

-- 加载 proto 描述文件（在 SkynetPbCodec 中自动完成）
-- 解码消息
local response = pb.decode("login.LoginResponse", encoded_data)
print(response.code)  -- 0 (SUCCESS)
print(response.user.username)
```

## 核心组件

### 1. 接口定义 (src/framework/core/interfaces.ts)

```typescript
export interface IPbCodec {
  encode(messageType: string, message: any): Uint8Array;
  decode(messageType: string, data: Uint8Array): any;
  create(messageType: string, init?: any): any;
  pack(msgId: number, messageType: string, message: any, session?: number): Uint8Array;
  unpack(data: Uint8Array): { msgId: number; messageType: string; message: any; session: number };
}

export interface IRuntime {
  logger: ILogger;
  timer: ITimer;
  network: INetwork;
  service: IService;
  database?: IDatabase;
  codec?: IPbCodec;  // <-- 新增
}
```

### 2. Node.js Codec (src/framework/runtime/node-pb-codec.ts)

- 使用 protobufjs（如果可用）
- 回退到 JSON 序列化（简化版 proto.js）
- 适用于开发和测试

### 3. Skynet Codec (src/framework/runtime/skynet-pb-codec.ts)

- 使用 lua-protobuf 库
- 标准 protobuf 二进制编码
- 适用于生产环境

### 4. 类型定义 (src/protos/)

| 文件 | 说明 |
|-----|------|
| `proto.d.ts` | TypeScript 类型定义 |
| `proto.js` | Node.js 运行时实现 |
| `index.ts` | 统一导出 |

## 消息 ID 映射

```typescript
// src/protos/proto.js
const MessageId = {
  // Gateway: 100-199
  HEARTBEAT_REQ: 100,
  HEARTBEAT_RESP: 101,
  CONNECT_REQ: 102,
  CONNECT_RESP: 103,
  DISCONNECT_NOTIFY: 104,
  
  // Login: 200-299
  LOGIN_REQ: 200,
  LOGIN_RESP: 201,
  LOGOUT_REQ: 202,
  LOGOUT_RESP: 203,
  VALIDATE_TOKEN_REQ: 204,
  VALIDATE_TOKEN_RESP: 205,
  GET_ONLINE_COUNT_REQ: 206,
  GET_ONLINE_COUNT_RESP: 207,
  
  // Game: 300-399
  ENTER_GAME_REQ: 300,
  ENTER_GAME_RESP: 301,
  LEAVE_GAME_REQ: 302,
  LEAVE_GAME_RESP: 303,
};
```

## Packet 消息包装

所有消息通过 `common.Packet` 包装：

```protobuf
message Packet {
  uint32 msg_id = 1;      // 消息ID
  uint32 session = 2;     // 会话ID
  bytes data = 3;         // 序列化的消息体
  uint64 timestamp = 4;   // 时间戳
}
```

编解码器提供 `pack` 和 `unpack` 方法：

```typescript
// 打包
const packet = runtime.codec.pack(
  MessageId.LOGIN_RESP,
  'login.LoginResponse',
  loginResponse,
  sessionId
);

// 解包
const { msgId, messageType, message, session } = runtime.codec.unpack(packetData);
```

## 环境适配

### Node.js 环境

```typescript
// 运行时自动创建 NodePbCodec
const runtime = createNodeRuntime();

// codec 在 proto.js 加载成功时可用
if (runtime.codec) {
  const encoded = runtime.codec.encode('login.LoginRequest', request);
}
```

### Skynet 环境

```typescript
// 运行时自动创建 SkynetPbCodec
const runtime = createSkynetRuntime();

// codec 在 lua-protobuf 加载成功时可用
if (runtime.codec) {
  const encoded = runtime.codec.encode('login.LoginRequest', request);
}
```

## 完整示例

### 发送消息

```typescript
import { runtime } from '../../../framework/core/interfaces';
import { MessageId, proto } from '../../../common/protos';

async function sendLoginRequest(username: string, password: string): Promise<void> {
  // 创建请求
  const request = proto.login.LoginRequest.create({
    username,
    password,
    deviceId: 'device123',
    platform: 'iOS',
  });
  
  // 打包为 Packet
  const packet = runtime.codec!.pack(
    MessageId.LOGIN_REQ,
    'login.LoginRequest',
    request
  );
  
  // 发送到网关
  runtime.network.send('gateway', 'lua', packet);
}
```

### 接收消息

```typescript
runtime.network.dispatch('lua', async (session, source, ...args) => {
  const [packetData] = args;
  
  // 解包
  const { msgId, messageType, message } = runtime.codec!.unpack(packetData);
  
  switch (msgId) {
    case MessageId.LOGIN_REQ:
      await handleLogin(message);
      break;
    case MessageId.LOGOUT_REQ:
      await handleLogout(message);
      break;
  }
});
```

## 注意事项

1. **Node.js 环境**：使用简化版 JSON 序列化，便于开发和调试
2. **Skynet 环境**：使用标准 protobuf 二进制编码，保证性能
3. **类型安全**：TypeScript 编译时检查 proto 类型
4. **消息 ID**：确保两端消息 ID 定义一致
5. **Codec 可用性**：始终检查 `runtime.codec` 是否存在

## 扩展指南

### 添加新消息

1. 编辑 `common/protos/*.proto` 添加消息定义
2. 更新 `src/protos/proto.d.ts` 添加类型
3. 更新 `src/protos/proto.js` 添加实现
4. 更新 `MessageId` 和 `MessageTypes` 映射
5. 业务代码中使用新消息

### 使用标准 Protobuf

如需使用标准 protobuf 二进制编码（替代 JSON）：

```bash
# 安装依赖
npm install protobufjs protobufjs-cli

# 生成代码
npm run build:proto

# 更新 node-pb-codec.ts 使用生成的代码
```
