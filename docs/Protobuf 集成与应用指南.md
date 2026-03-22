# Protobuf 集成与应用指南

本文档详细介绍 Protocol Buffers 在 TS-Skynet 项目中的完整集成方案，包括架构设计、使用案例和最佳实践。

## 📋 目录

1. [架构设计](#架构设计)
2. [核心组件](#核心组件)
3. [快速开始](#快速开始)
4. [应用层使用案例](#应用层使用案例)
5. [服务间通信](#服务间通信)
6. [环境适配](#环境适配)
7. [最佳实践](#最佳实践)

---

## 架构设计

### 整体架构

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
│      (src/protos/proto.d.ts, proto.js)                      │
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

### 两种序列化方案

#### 方案 A: 简化 JSON（当前默认）

**优点：**
- 无需额外依赖
- 易于调试（人类可读）
- 开发体验好

**缺点：**
- 消息体积较大
- 无严格类型验证

**适用场景：** 开发、测试、内部服务通信

#### 方案 B: 标准 Protobuf（可选）

**优点：**
- 二进制编码，体积小
- 高性能
- 跨语言兼容

**缺点：**
- 需要编译 proto 文件
- 依赖 protobufjs/lua-protobuf

**适用场景：** 生产环境、客户端通信

---

## 核心组件

### 1. 接口定义

```typescript
// src/framework/core/interfaces.ts
export interface IPbCodec {
  encode(messageType: string, message: any): Uint8Array;
  decode(messageType: string, data: Uint8Array): any;
  create(messageType: string, init?: any): any;
  pack(msgId: number, messageType: string, message: any, session?: number): Uint8Array;
  unpack(data: Uint8Array): { 
    msgId: number; 
    messageType: string; 
    message: any; 
    session: number 
  };
}

export interface IRuntime {
  logger: ILogger;
  timer: ITimer;
  network: INetwork;
  service: IService;
  database?: IDatabase;
  codec?: IPbCodec;  // <-- Protobuf Codec
}
```

### 2. 消息 ID 映射

```typescript
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
  
  // Game: 300-399
  ENTER_GAME_REQ: 300,
  ENTER_GAME_RESP: 301,
  LEAVE_GAME_REQ: 302,
  LEAVE_GAME_RESP: 303,
};
```

### 3. Packet 消息包装

所有消息通过 `common.Packet` 包装：

```protobuf
message Packet {
  uint32 msg_id = 1;      // 消息 ID
  uint32 session = 2;     // 会话 ID
  bytes data = 3;         // 序列化的消息体
  uint64 timestamp = 4;   // 时间戳
}
```

---

## 快速开始

### 1. 定义协议

编辑 `protocols/proto/*.proto` 文件：

```protobuf
// protocols/proto/login.proto
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

### 2. 生成代码（可选）

项目已包含简化版的 proto 实现，如需标准 protobuf 二进制编码：

```bash
# 安装依赖
npm install protobufjs protobufjs-cli

# 生成代码
npm run build:proto
```

### 3. 业务代码中使用

```typescript
import { runtime } from '../../../framework/core/interfaces';
import { MessageId, proto } from '../../../protos';

async function handleLogin(request: LoginRequest): Promise<void> {
  const result = await logic.handleLogin(request);
  
  // 构建 proto 响应
  const protoResponse = proto.login.LoginResponse.create({
    code: result.success 
      ? proto.common.ErrorCode.SUCCESS 
      : proto.common.ErrorCode.UNAUTHORIZED,
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

---

## 应用层使用案例

### Login 服务

#### 构建 Proto 响应

```typescript
import { MessageId, proto } from '../../../protos';

function buildProtoLoginResponse(response: LoginResponse): proto.login.LoginResponse {
  return proto.login.LoginResponse.create({
    code: response.success 
      ? proto.common.ErrorCode.SUCCESS 
      : proto.common.ErrorCode.UNAUTHORIZED,
    message: response.error || '',
    user: response.user
      ? {
          userId: response.user.userId,
          username: response.user.username,
          loginTime: response.user.loginTime,
          level: 1,
          exp: 0,
        }
      : undefined,
    token: response.user?.token,
  });
}
```

#### 登录请求处理

```typescript
case 'login': {
  const [username, password] = args as [string, string];
  const response = await logic.handleLogin({ username, password });
  
  // 使用 codec 进行 protobuf 序列化
  if (runtime.codec) {
    const protoResponse = buildProtoLoginResponse(response);
    const encoded = runtime.codec.encode('login.LoginResponse', protoResponse);
    runtime.network.ret(true, encoded);
  } else {
    // 回退到普通返回
    runtime.network.ret(response.success, response.user, response.error);
  }
  break;
}
```

### Game 服务

#### 进入游戏响应

```typescript
case 'enterGame': {
  const [userId] = args as [number];
  const player = await logic.handleEnterGame(userId);
  
  // 使用 protobuf 序列化响应
  if (runtime.codec && player) {
    const response = proto.game.EnterGameResponse.create({
      success: true,
      playerInfo: {
        userId: player.userId,
        username: `Player_${player.userId}`,
        level: player.level,
        exp: player.exp,
        gold: player.gold,
      },
    });
    const encoded = runtime.codec.encode('game.EnterGameResponse', response);
    runtime.network.ret(true, encoded);
  } else {
    runtime.network.ret(player !== null);
  }
  break;
}
```

### Gateway 服务

#### 心跳处理（Protobuf 解包）

```typescript
async function handleHeartbeat(packetData: Uint8Array): Promise<void> {
  if (!runtime.codec) {
    runtime.logger.warn('Codec not available for heartbeat');
    return;
  }

  try {
    // 解包 heartbeat 请求
    const heartbeat = runtime.codec.decode('gateway.HeartbeatRequest', packetData);
    const clientTime = heartbeat.clientTime;

    // 构建响应
    const response = proto.gateway.HeartbeatResponse.create({
      serverTime: runtime.timer.now(),
      clientTime: clientTime,
    });

    const encoded = runtime.codec.encode('gateway.HeartbeatResponse', response);
    runtime.network.ret(encoded);
  } catch (error) {
    runtime.logger.error('Heartbeat error:', error);
  }
}
```

#### 转发到登录服务（服务间通信）

```typescript
async function forwardToLogin(packetData: Uint8Array): Promise<void> {
  if (!runtime.codec) {
    runtime.network.ret(false, 'Codec not available');
    return;
  }

  try {
    // 解包登录请求
    const { msgId, message } = runtime.codec.unpack(packetData);

    if (msgId === MessageId.LOGIN_REQ) {
      const loginReq = message as proto.login.LoginRequest;
      runtime.logger.info(`Forwarding login request: ${loginReq.username}`);

      // 调用登录服务（传递 protobuf 数据）
      const loginService = await runtime.service.newService('login');
      const response = await runtime.network.call(
        loginService, 
        'lua', 
        'login',
        loginReq.username, 
        loginReq.password
      );

      runtime.network.ret(response);
    } else {
      runtime.network.ret(false, 'Unknown message type');
    }
  } catch (error) {
    runtime.logger.error('Forward error:', error);
    runtime.network.ret(false, String(error));
  }
}
```

---

## 服务间通信

### 完整的登录流程示例

```typescript
// Gateway 接收客户端登录请求
async function handleClientLogin(packetData: Uint8Array): Promise<void> {
  if (!runtime.codec) return;

  // 1. 解包客户端请求
  const { msgId, message } = runtime.codec.unpack(packetData);
  
  if (msgId !== MessageId.LOGIN_REQ) {
    runtime.network.ret(false, 'Invalid message');
    return;
  }

  const loginReq = message as proto.login.LoginRequest;

  // 2. 调用登录服务
  const loginService = await runtime.service.newService('login');
  const loginResult = await runtime.network.call(
    loginService, 
    'lua', 
    'login',
    loginReq.username,
    loginReq.password
  );

  // 3. 如果登录成功，调用游戏服务
  if (loginResult.success) {
    const gameService = await runtime.service.newService('game');
    const playerInfo = await runtime.network.call(
      gameService,
      'lua',
      'enterGame',
      loginResult.user.userId
    );

    // 4. 构建统一的登录响应
    const response = proto.login.LoginResponse.create({
      code: proto.common.ErrorCode.SUCCESS,
      message: 'Login and enter game success',
      user: {
        userId: loginResult.user.userId,
        username: loginResult.user.username,
        loginTime: loginResult.user.loginTime,
        level: playerInfo.level,
        exp: playerInfo.exp,
      },
      token: loginResult.user.token,
    });

    // 5. 打包并返回给客户端
    const responsePacket = runtime.codec.pack(
      MessageId.LOGIN_RESP,
      'login.LoginResponse',
      response
    );

    runtime.network.ret(responsePacket);
  }
}
```

### 使用 MessageId 进行消息路由

```typescript
import { MessageId, proto } from '../../../protos';

// 消息处理器映射
const messageHandlers: Record<number, (msg: any) => Promise<any>> = {
  [MessageId.LOGIN_REQ]: handleLoginRequest,
  [MessageId.LOGOUT_REQ]: handleLogoutRequest,
  [MessageId.ENTER_GAME_REQ]: handleEnterGameRequest,
  [MessageId.HEARTBEAT_REQ]: handleHeartbeatRequest,
};

async function dispatchMessage(packetData: Uint8Array): Promise<void> {
  if (!runtime.codec) return;

  const { msgId, message, messageType } = runtime.codec.unpack(packetData);
  
  const handler = messageHandlers[msgId];
  if (!handler) {
    runtime.logger.warn(`No handler for message ID: ${msgId}`);
    return;
  }

  try {
    const result = await handler(message);
    
    // 构建响应
    const responseId = msgId + 1; // 假设响应 ID = 请求 ID + 1
    const responsePacket = runtime.codec.pack(
      responseId,
      messageType.replace('Request', 'Response'),
      result
    );
    
    runtime.network.ret(responsePacket);
  } catch (error) {
    runtime.logger.error(`Handler error for ${msgId}:`, error);
  }
}
```

---

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

### Skynet 运行时的 Lua 侧

```lua
-- Skynet 中使用 lua-protobuf 解码
local pb = require "pb"

-- 加载 proto 描述文件（在 SkynetPbCodec 中自动完成）
-- 解码消息
local response = pb.decode("login.LoginResponse", encoded_data)
print(response.code)  -- 0 (SUCCESS)
print(response.user.username)
```

---

## 最佳实践

### 1. 始终检查 codec 可用性

```typescript
if (runtime.codec) {
  // 使用 protobuf
} else {
  // 使用 fallback
}
```

### 2. 类型转换

```typescript
// 内部 Player 转换为 Proto PlayerInfo
function toProtoPlayerInfo(player: Player): proto.game.PlayerInfo {
  return proto.game.PlayerInfo.create({
    userId: player.userId,
    username: `Player_${player.userId}`,
    level: player.level,
    exp: player.exp,
    gold: player.gold,
  });
}

// Proto PlayerInfo 转换为内部 Player
function fromProtoPlayerInfo(info: proto.game.PlayerInfo): Player {
  return {
    userId: info.userId,
    level: info.level,
    exp: info.exp,
    gold: info.gold,
    enterTime: Date.now(),
  };
}

// 错误码转换
function toProtoErrorCode(success: boolean, error?: string): proto.common.ErrorCode {
  if (success) return proto.common.ErrorCode.SUCCESS;
  if (error?.includes('timeout')) return proto.common.ErrorCode.TIMEOUT;
  if (error?.includes('not found')) return proto.common.ErrorCode.NOT_FOUND;
  return proto.common.ErrorCode.INTERNAL_ERROR;
}
```

### 3. 错误处理

```typescript
try {
  const decoded = runtime.codec.decode('login.LoginRequest', data);
} catch (error) {
  runtime.logger.error('Decode error:', error);
  // 返回错误响应
}
```

### 4. 消息 ID 一致性

确保所有服务使用相同的 `MessageId` 定义，新增消息时同步更新所有相关服务。

---

## 扩展指南

### 添加新消息

1. 编辑 `protocols/proto/*.proto` 添加消息定义
2. 更新 `src/protos/proto.d.ts` 添加类型
3. 更新 `src/protos/proto.js` 添加实现
4. 更新 `MessageId` 和 `MessageTypes` 映射
5. 业务代码中使用新消息

### 切换到标准 Protobuf

如需使用标准 protobuf 二进制编码（替代 JSON）：

```bash
# 安装依赖
npm install protobufjs protobufjs-cli

# 生成代码
npm run build:proto

# 更新 node-pb-codec.ts 使用生成的代码
```

---

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
