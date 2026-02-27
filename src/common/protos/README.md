# Protocol Buffers 协议定义

本目录包含项目的所有 Protocol Buffers 协议定义文件。

## 📁 目录结构

```
common/protos/
├── common.proto        # 通用消息定义（Packet, ErrorCode, Response）
├── gateway.proto       # 网关服务协议
├── login.proto         # 登录服务协议
├── game.proto          # 游戏服务协议
└── message_id.proto    # 消息ID映射表
```

## 🎯 协议分层

### 1. 通用层 (`common.proto`)
- **Packet**: 消息包装，所有消息都通过此结构发送
- **ErrorCode**: 统一错误码定义
- **Response**: 通用响应结构

### 2. 服务层
每个服务有独立的 proto 文件：
- **Gateway**: 连接管理、心跳、转发
- **Login**: 用户登录、登出、Token验证
- **Game**: 游戏逻辑、玩家数据、经验金币

### 3. 消息ID (`message_id.proto`)
统一的消息ID枚举，用于消息路由：
- 系统消息: 1-99
- Gateway: 100-199
- Login: 200-299
- Game: 300-399

## 🔧 使用方法

### 编译协议

```bash
# 编译所有协议文件
./scripts/build_proto.sh

# 或使用 npm 命令
npm run build:proto
```

编译后会生成：
- **TypeScript**: `src/common/protos/`
- **Lua**: `dist/lua/common/protos/`

### TypeScript 中使用

```typescript
import { proto, MessageId, MessageTypes } from '@/common/protos';

// 创建消息
const loginReq = proto.login.LoginRequest.create({
  username: 'player1',
  password: 'encrypted_password',
  deviceId: 'device123',
  platform: 'iOS'
});

// 序列化
const buffer = proto.login.LoginRequest.encode(loginReq).finish();

// 反序列化
const decoded = proto.login.LoginRequest.decode(buffer);

// 使用消息ID
const msgId = MessageId.LOGIN_LOGIN_REQ;  // 200
```

### Lua 中使用

```lua
local pb = require "pb"
local protoc = require "protoc"

-- 加载协议描述文件
local f = assert(io.open("dist/lua/common/protos/login_pb.desc", "rb"))
local data = f:read("*all")
f:close()

assert(pb.load(data))

-- 编码消息
local login_req = {
  username = "player1",
  password = "encrypted_password",
  device_id = "device123",
  platform = "iOS"
}

local bytes = assert(pb.encode("login.LoginRequest", login_req))

-- 解码消息
local decoded = assert(pb.decode("login.LoginRequest", bytes))
print(decoded.username)  -- player1
```

## 📝 协议规范

### 命名规范
- **消息类型**: PascalCase，如 `LoginRequest`, `HeartbeatResponse`
- **字段名**: snake_case，如 `user_id`, `client_time`
- **枚举**: UPPER_SNAKE_CASE，如 `UNKNOWN_ERROR`, `LOGIN_LOGIN_REQ`

### 消息ID分配
- 每个服务预留 100 个ID
- 请求消息使用偶数，响应消息使用奇数（推荐）
- 新增消息时更新 `message_id.proto`

### 版本兼容
- 不要删除已有字段
- 不要修改字段编号
- 新增字段使用新的编号
- 使用 `optional` 或 `repeated` 保证向后兼容

## 🔄 热更新支持

协议定义支持热更新：
- 协议文件本身可以热更新
- 服务端通过重新加载协议描述文件实现热更新
- 客户端需要重新下载并加载新协议

## 🛠️ 工具链

- **protoc**: v33.5 (位于 `common/tools/protoc`)
- **protobufjs**: TypeScript 支持
- **lua-protobuf**: Lua 支持

## 📚 参考资料

- [Protocol Buffers 官方文档](https://protobuf.dev/)
- [protobufjs 文档](https://github.com/protobufjs/protobuf.js)
- [lua-protobuf 文档](https://github.com/starwing/lua-protobuf)
