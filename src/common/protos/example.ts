/**
 * Protobuf 使用示例
 * 展示如何在业务代码中使用 proto 类型和 codec
 */

import { runtime } from '../../framework/core/interfaces';
import { MessageId, proto } from './index';
import type { LoginRequest, LoginResponse, LogoutRequest } from './proto';

/**
 * 示例 1: 创建 Proto 消息
 */
export function createLoginRequestExample(): LoginRequest {
  // 使用 proto.create 创建消息
  const request = proto.login.LoginRequest.create({
    username: 'player1',
    password: 'encrypted_password',
    deviceId: 'device123',
    platform: 'iOS',
  });

  console.log('Created LoginRequest:', request);
  return request;
}

/**
 * 示例 2: 编码和解码
 */
export function encodeDecodeExample(): void {
  if (!runtime.codec) {
    console.log('Codec not available');
    return;
  }

  // 创建消息
  const request = proto.login.LoginRequest.create({
    username: 'player1',
    password: 'secret',
  });

  // 编码
  const encoded = runtime.codec.encode('login.LoginRequest', request);
  console.log('Encoded:', encoded);

  // 解码
  const decoded = runtime.codec.decode('login.LoginRequest', encoded);
  console.log('Decoded:', decoded);
}

/**
 * 示例 3: 打包和解包（Packet 包装）
 */
export function packUnpackExample(): void {
  if (!runtime.codec) {
    console.log('Codec not available');
    return;
  }

  // 创建响应
  const response = proto.login.LoginResponse.create({
    code: proto.common.ErrorCode.SUCCESS,
    message: 'Login successful',
    user: {
      userId: 10001,
      username: 'player1',
      loginTime: Math.floor(Date.now() / 1000),
      level: 5,
      exp: 1500,
    },
    token: 'abc123xyz',
  });

  // 打包为 Packet
  const packet = runtime.codec.pack(
    MessageId.LOGIN_RESP,
    'login.LoginResponse',
    response,
    12345 // session ID
  );

  console.log('Packed packet:', packet);

  // 解包
  const unpacked = runtime.codec.unpack(packet);
  console.log('Unpacked:', unpacked);
  console.log('Message Type:', unpacked.messageType);
  console.log('Message:', unpacked.message);
}

/**
 * 示例 4: 在消息处理中使用
 */
export async function handleLoginMessageExample(packetData: Uint8Array): Promise<void> {
  if (!runtime.codec) {
    runtime.logger.error('Codec not available');
    return;
  }

  try {
    // 解包
    const { msgId, messageType, message } = runtime.codec.unpack(packetData);

    runtime.logger.info(`Received message: ${messageType} (ID: ${msgId})`);

    switch (msgId) {
      case MessageId.LOGIN_REQ: {
        const loginReq = message as LoginRequest;
        runtime.logger.info(`Login request: ${loginReq.username}`);

        // 处理登录逻辑...
        const loginResp = proto.login.LoginResponse.create({
          code: proto.common.ErrorCode.SUCCESS,
          message: 'Welcome!',
          user: {
            userId: 10001,
            username: loginReq.username,
            loginTime: Math.floor(Date.now() / 1000),
          },
          token: 'token_' + Date.now(),
        });

        // 发送响应
        const responsePacket = runtime.codec.pack(
          MessageId.LOGIN_RESP,
          'login.LoginResponse',
          loginResp
        );

        runtime.network.send('gateway', 'lua', responsePacket);
        break;
      }

      case MessageId.LOGOUT_REQ: {
        const logoutReq = message as LogoutRequest;
        runtime.logger.info(`Logout request: userId=${logoutReq.userId}`);
        break;
      }

      default:
        runtime.logger.warn(`Unknown message ID: ${msgId}`);
    }
  } catch (error) {
    runtime.logger.error('Failed to handle message:', error);
  }
}

/**
 * 示例 5: 使用 MessageId 和 MessageTypes
 */
export function messageIdExample(): void {
  // 获取消息 ID
  const loginReqId = MessageId.LOGIN_REQ;
  console.log('Login Request ID:', loginReqId); // 200

  // 反向查找 - 注意：MessageId 的值是数字，不是字符串
  const targetMessageType = 'login.LoginRequest';
  let foundId: number | undefined;

  // MessageId 对象的结构是 { LOGIN_REQ: 200, ... }
  // 我们需要查找值为 200 的键，然后映射到类型名
  for (const [name, value] of Object.entries(MessageId)) {
    if (value === 200) {  // 200 是 LOGIN_REQ 的值
      foundId = value;
      console.log(`Found MessageId: ${name} = ${value}`);
      break;
    }
  }

  console.log('Message type lookup:', foundId);
}

// 如果直接运行此文件，执行示例
if (require.main === module) {
  console.log('=== Protobuf Examples ===\n');

  console.log('1. Create LoginRequest:');
  createLoginRequestExample();

  console.log('\n2. Encode/Decode:');
  encodeDecodeExample();

  console.log('\n3. Pack/Unpack:');
  packUnpackExample();

  console.log('\n4. MessageId usage:');
  messageIdExample();
}
