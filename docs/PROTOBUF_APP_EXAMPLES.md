# Protobuf 应用层使用案例

本文档展示所有服务（login/game/gateway）中 protobuf 的实际使用案例。

## 目录

1. [Login 服务](#login-服务)
2. [Game 服务](#game-服务)
3. [Gateway 服务](#gateway-服务)
4. [服务间通信](#服务间通信)

---

## Login 服务

### 文件: `src/app/services/login/index.ts`

#### 1. 构建 Proto 响应

```typescript
import { MessageId, proto } from '../../../common/protos';

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

#### 2. 登录请求处理

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

#### 3. 类型定义集成

```typescript
// src/app/services/login/types.ts
import { proto } from '../../../common/protos';

// 导出 proto 类型供业务使用
export type ProtoLoginRequest = proto.login.LoginRequest;
export type ProtoLoginResponse = proto.login.LoginResponse;
export type ProtoUserInfo = proto.login.UserInfo;
export type ProtoErrorCode = proto.common.ErrorCode;
```

---

## Game 服务

### 文件: `src/app/services/game/index.ts`

#### 1. 进入游戏响应

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

#### 2. 获取玩家信息

```typescript
case 'getPlayerInfo': {
  const [userId] = args as [number];
  const player = logic.getPlayerInfo(userId);
  
  // 使用 protobuf 返回玩家信息
  if (runtime.codec && player) {
    const playerInfo = proto.game.PlayerInfo.create({
      userId: player.userId,
      username: `Player_${player.userId}`,
      level: player.level,
      exp: player.exp,
      gold: player.gold,
    });
    const encoded = runtime.codec.encode('game.PlayerInfo', playerInfo);
    runtime.network.ret(true, encoded);
  } else {
    runtime.network.ret(player);
  }
  break;
}
```

#### 3. 类型定义

```typescript
// src/app/services/game/types.ts
import { proto } from '../../../common/protos';

export type ProtoEnterGameRequest = proto.game.EnterGameRequest;
export type ProtoEnterGameResponse = proto.game.EnterGameResponse;
export type ProtoPlayerInfo = proto.game.PlayerInfo;
export type ProtoErrorCode = proto.common.ErrorCode;
```

---

## Gateway 服务

### 文件: `src/app/services/gateway/index.ts`

#### 1. 连接响应

```typescript
case 'connect': {
  const [clientInfo] = args as [ClientInfo];
  const connId = await logic.handleConnect(clientInfo);
  
  // 使用 protobuf 返回连接响应
  if (runtime.codec) {
    const response = proto.gateway.ConnectResponse.create({
      success: connId > 0,
      message: connId > 0 ? 'Connected successfully' : 'Connection failed',
      sessionId: connId > 0 ? `session_${connId}` : undefined,
    });
    const encoded = runtime.codec.encode('gateway.ConnectResponse', response);
    runtime.network.ret(connId, encoded);
  } else {
    runtime.network.ret(connId);
  }
  break;
}
```

#### 2. 断开连接通知

```typescript
case 'disconnect': {
  const [connId, reason] = args as [number, string?];
  const success = await logic.handleDisconnect(connId);
  
  // 发送断开通知（使用 protobuf）
  if (runtime.codec && success) {
    const notify = proto.gateway.DisconnectNotify.create({
      reason: reason || 'user_disconnect',
    });
    runtime.logger.info(`Disconnect notify: ${notify.reason}`);
  }
  
  runtime.network.ret(success);
  break;
}
```

#### 3. 心跳处理（Protobuf 解包）

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

#### 4. 转发到登录服务（服务间通信）

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
      const response = await runtime.network.call(loginService, 'lua', 'login', 
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
import { MessageId, proto } from '../../../common/protos';

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
    const responseId = msgId + 1; // 假设响应ID = 请求ID + 1
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

## 类型转换最佳实践

### 内部类型 ↔ Proto 类型转换

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

---

## 完整的请求-响应流程

```
┌─────────────┐                     ┌──────────────┐
│   Client    │ ──LoginRequest────▶ │   Gateway    │
│             │    (protobuf)       │              │
└─────────────┘                     └──────┬───────┘
                                           │
                                           │ unpack
                                           ▼
                                    ┌──────────────┐
                                    │ 解压LoginRequest│
                                    └──────┬───────┘
                                           │
                                           │ network.call
                                           ▼
                                    ┌──────────────┐
                                    │ Login Service │
                                    └──────┬───────┘
                                           │
                                           │ 业务处理
                                           ▼
                                    ┌──────────────┐
                                    │ 构建LoginResponse│
                                    │ (protobuf)     │
                                    └──────┬───────┘
                                           │
                                           │ return
                                           ▼
                                    ┌──────────────┐
                                    │   Gateway    │
                                    │ pack响应      │
                                    └──────┬───────┘
                                           │
                                           │ ret
                                           ▼
┌─────────────┐                     ┌──────────────┐
│   Client    │ ◀──LoginResponse────│   Gateway    │
│             │    (protobuf)       │              │
└─────────────┘                     └──────────────┘
```

---

## 注意事项

1. **始终检查 codec 可用性**
   ```typescript
   if (runtime.codec) {
     // 使用 protobuf
   } else {
     // 使用 fallback
   }
   ```

2. **类型安全**
   - 使用 TypeScript 类型检查 proto 消息结构
   - 在类型定义文件中导出 proto 类型

3. **错误处理**
   ```typescript
   try {
     const decoded = runtime.codec.decode('login.LoginRequest', data);
   } catch (error) {
     runtime.logger.error('Decode error:', error);
     // 返回错误响应
   }
   ```

4. **消息 ID 一致性**
   - 所有服务使用相同的 `MessageId` 定义
   - 新增消息时同步更新所有相关服务
