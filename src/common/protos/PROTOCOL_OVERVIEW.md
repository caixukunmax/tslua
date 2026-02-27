# 协议系统概览

## 📋 协议文件清单

| 文件 | 说明 | 消息数量 | 状态 |
|------|------|----------|------|
| `common.proto` | 通用消息定义 | 3 | ✅ 完成 |
| `gateway.proto` | 网关服务协议 | 6 | ✅ 完成 |
| `login.proto` | 登录服务协议 | 9 | ✅ 完成 |
| `game.proto` | 游戏服务协议 | 17 | ✅ 完成 |
| `message_id.proto` | 消息ID映射 | 1 enum | ✅ 完成 |

**总计**: 35+ 消息定义

---

## 🎯 协议设计原则

### 1. 分层设计
- **通用层**: 所有服务共用（Packet, ErrorCode）
- **服务层**: 每个服务独立定义（Gateway, Login, Game）
- **消息ID层**: 统一的消息路由标识

### 2. 消息包装
所有消息通过 `Packet` 结构传输：
```protobuf
message Packet {
  uint32 msg_id = 1;      // 消息ID（用于路由）
  uint32 session = 2;     // 会话ID（请求响应匹配）
  bytes data = 3;         // 实际消息体
  uint64 timestamp = 4;   // 时间戳
}
```

### 3. 错误处理
统一的错误码定义：
```protobuf
enum ErrorCode {
  SUCCESS = 0;
  UNKNOWN_ERROR = 1;
  INVALID_REQUEST = 2;
  UNAUTHORIZED = 3;
  // ...
}
```

---

## 📊 消息ID分配表

| 服务 | ID范围 | 已使用 | 可用 |
|------|--------|--------|------|
| 系统 | 1-99 | 2 | 97 |
| Gateway | 100-199 | 5 | 95 |
| Login | 200-299 | 8 | 92 |
| Game | 300-399 | 14 | 86 |

### Gateway 消息 (100-199)
- 100: GATEWAY_HEARTBEAT_REQ
- 101: GATEWAY_HEARTBEAT_RSP
- 102: GATEWAY_CONNECT_REQ
- 103: GATEWAY_CONNECT_RSP
- 104: GATEWAY_DISCONNECT_NOTIFY

### Login 消息 (200-299)
- 200: LOGIN_LOGIN_REQ
- 201: LOGIN_LOGIN_RSP
- 202: LOGIN_LOGOUT_REQ
- 203: LOGIN_LOGOUT_RSP
- 204: LOGIN_VALIDATE_TOKEN_REQ
- 205: LOGIN_VALIDATE_TOKEN_RSP
- 206: LOGIN_GET_ONLINE_COUNT_REQ
- 207: LOGIN_GET_ONLINE_COUNT_RSP

### Game 消息 (300-399)
- 300: GAME_ENTER_REQ
- 301: GAME_ENTER_RSP
- 302: GAME_LEAVE_REQ
- 303: GAME_LEAVE_RSP
- 304: GAME_GET_PLAYER_INFO_REQ
- 305: GAME_GET_PLAYER_INFO_RSP
- 306: GAME_UPDATE_PLAYER_REQ
- 307: GAME_UPDATE_PLAYER_RSP
- 308: GAME_GET_ONLINE_PLAYERS_REQ
- 309: GAME_GET_ONLINE_PLAYERS_RSP
- 310: GAME_ADD_EXP_REQ
- 311: GAME_ADD_EXP_RSP
- 312: GAME_ADD_GOLD_REQ
- 313: GAME_ADD_GOLD_RSP

---

## 🔄 通信流程

### 客户端到服务器
```
1. 创建具体消息（如 LoginRequest）
2. 序列化消息为 bytes
3. 包装到 Packet（设置 msg_id, session, data）
4. 序列化 Packet
5. 发送到网关
```

### 服务器到客户端
```
1. 接收并反序列化 Packet
2. 根据 msg_id 路由到对应服务
3. 反序列化 data 为具体消息
4. 处理业务逻辑
5. 创建响应消息
6. 包装并发送回客户端
```

---

## 🛠️ 扩展指南

### 添加新消息
1. 在对应的 .proto 文件中定义消息
2. 在 message_id.proto 中添加消息ID
3. 运行 `npm run build:proto` 重新编译
4. 更新本文档的消息ID分配表

### 添加新服务
1. 创建 `service_name.proto` 文件
2. 在 message_id.proto 中预留100个ID
3. 在 build_proto.sh 中添加编译规则
4. 在 index.ts 中导出新服务的消息类型

### 版本兼容
- ✅ 允许：添加新字段（使用新的 field number）
- ✅ 允许：添加新消息
- ✅ 允许：标记字段为 deprecated
- ❌ 禁止：删除已有字段
- ❌ 禁止：修改字段编号
- ❌ 禁止：更改字段类型

---

## 📈 性能考虑

### 消息大小
- Packet 头：~20 bytes
- 小消息（登录）：~100-200 bytes
- 中消息（玩家信息）：~200-500 bytes
- 大消息（玩家列表）：根据数量动态

### 序列化性能
- Protobuf 比 JSON 快 2-10 倍
- 二进制大小比 JSON 小 30-70%
- 适合高频消息（心跳、移动同步等）

---

## 🔐 安全考虑

1. **密码传输**: 应使用加密后的密码（不要明文）
2. **Token验证**: 所有需要认证的请求都应携带 token
3. **数据校验**: 服务端应校验所有输入数据
4. **防重放**: 使用 timestamp 和 session 防止重放攻击

---

## 📝 开发建议

1. **命名规范**: 遵循 protobuf 官方命名规范
2. **注释**: 为每个消息和字段添加清晰的注释
3. **测试**: 编写协议序列化/反序列化测试
4. **文档**: 更新本文档保持同步
5. **版本**: 使用 git tag 标记协议版本

---

## 🚀 快速开始

```bash
# 1. 编译协议
npm run build:proto

# 2. 查看生成的文件
ls -la src/common/protos/
ls -la dist/lua/common/protos/

# 3. 在代码中使用
# TypeScript:
import { proto, MessageId } from '@/common/protos';

# Lua:
local pb = require "pb"
-- 加载协议描述文件
```

---

## 📚 相关文档

- [README.md](./README.md) - 详细使用文档
- [example.ts](./example.ts) - TypeScript 使用示例
- [Protocol Buffers 官方文档](https://protobuf.dev/)

---

**最后更新**: 2026-01-30  
**维护者**: 项目团队  
**版本**: 1.0.0
