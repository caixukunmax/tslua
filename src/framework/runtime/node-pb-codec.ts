/**
 * Node.js Protocol Buffer 编解码器
 * 基于 protobufjs 实现
 */

import { IPbCodec } from '../core/interfaces';

// protobufjs 类型声明（实际使用时通过 require 导入）
type PbType = {
  encode: (message: any) => { finish: () => Uint8Array };
  decode: (reader: Uint8Array) => any;
  create: (init?: any) => any;
};

/**
 * 消息类型映射表
 * 从 proto 生成的代码中获取
 */
const MESSAGE_TYPE_MAP: Record<number, string> = {
  // Gateway: 100-199
  100: 'gateway.HeartbeatRequest',
  101: 'gateway.HeartbeatResponse',
  102: 'gateway.ConnectRequest',
  103: 'gateway.ConnectResponse',
  104: 'gateway.DisconnectNotify',
  // Login: 200-299
  200: 'login.LoginRequest',
  201: 'login.LoginResponse',
  202: 'login.LogoutRequest',
  203: 'login.LogoutResponse',
  204: 'login.ValidateTokenRequest',
  205: 'login.ValidateTokenResponse',
  206: 'login.GetOnlineCountRequest',
  207: 'login.GetOnlineCountResponse',
  // Game: 300-399
  300: 'game.EnterGameRequest',
  301: 'game.EnterGameResponse',
  302: 'game.LeaveGameRequest',
  303: 'game.LeaveGameResponse',
};

const MSG_ID_TO_NAME: Record<number, string> = MESSAGE_TYPE_MAP;
const MSG_NAME_TO_ID: Record<string, number> = Object.fromEntries(
  Object.entries(MESSAGE_TYPE_MAP).map(([id, name]) => [name, parseInt(id)])
);

export class NodePbCodec implements IPbCodec {
  private proto: any = null;
  private root: any = null;

  constructor() {
    this.initProto();
  }

  private initProto(): void {
    try {
      // 动态加载 proto.js（编译后生成）
      const protoPath = require.resolve('../../common/protos/proto.js');
      const protoModule = require(protoPath);
      this.proto = protoModule.proto;
      this.root = protoModule;
    } catch (error) {
      console.warn('[NodePbCodec] Failed to load proto module:', error);
      // 在未编译 proto 时允许空实现
    }
  }

  encode(messageType: string, message: any): Uint8Array {
    if (!this.proto) {
      throw new Error('[NodePbCodec] Proto module not loaded');
    }

    const parts = messageType.split('.');
    if (parts.length !== 2) {
      throw new Error(`[NodePbCodec] Invalid message type: ${messageType}`);
    }

    const [namespace, typeName] = parts;
    const type = this.proto[namespace]?.[typeName];

    if (!type) {
      throw new Error(`[NodePbCodec] Unknown message type: ${messageType}`);
    }

    return type.encode(message).finish();
  }

  decode(messageType: string, data: Uint8Array): any {
    if (!this.proto) {
      throw new Error('[NodePbCodec] Proto module not loaded');
    }

    const parts = messageType.split('.');
    if (parts.length !== 2) {
      throw new Error(`[NodePbCodec] Invalid message type: ${messageType}`);
    }

    const [namespace, typeName] = parts;
    const type = this.proto[namespace]?.[typeName];

    if (!type) {
      throw new Error(`[NodePbCodec] Unknown message type: ${messageType}`);
    }

    return type.decode(data);
  }

  create(messageType: string, init?: any): any {
    if (!this.proto) {
      throw new Error('[NodePbCodec] Proto module not loaded');
    }

    const parts = messageType.split('.');
    if (parts.length !== 2) {
      throw new Error(`[NodePbCodec] Invalid message type: ${messageType}`);
    }

    const [namespace, typeName] = parts;
    const type = this.proto[namespace]?.[typeName];

    if (!type) {
      throw new Error(`[NodePbCodec] Unknown message type: ${messageType}`);
    }

    return type.create(init);
  }

  pack(msgId: number, messageType: string, message: any, session: number = 0): Uint8Array {
    const payload = this.encode(messageType, message);
    const timestamp = Math.floor(Date.now() / 1000);

    const packet = this.proto.common.Packet.create({
      msgId,
      session,
      data: payload,
      timestamp,
    });

    return this.proto.common.Packet.encode(packet).finish();
  }

  unpack(data: Uint8Array): { msgId: number; messageType: string; message: any; session: number } {
    const packet = this.proto.common.Packet.decode(data);
    const messageType = MSG_ID_TO_NAME[packet.msgId];

    if (!messageType) {
      throw new Error(`[NodePbCodec] Unknown msgId: ${packet.msgId}`);
    }

    const message = this.decode(messageType, packet.data);

    return {
      msgId: packet.msgId,
      messageType,
      message,
      session: packet.session,
    };
  }
}
