/**
 * Skynet Protocol Buffer 编解码器
 * 基于 lua-protobuf 库实现
 * 
 * 注意：此文件会被 TypeScriptToLua 编译为 Lua 代码
 * lua-protobuf API: https://github.com/starwing/lua-protobuf
 */

/** @noSelfInFile */

import { IPbCodec } from '../core/interfaces';

// @ts-ignore
const skynet = _G.require('skynet');

// 在 Lua 环境中动态加载 lua-protobuf
// @ts-ignore
const pb = _G.require('pb');
// @ts-ignore
const protoc = _G.require('protoc');

/**
 * 消息类型映射表
 */
const MSG_ID_TO_NAME: Record<number, string> = {
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

const MSG_NAME_TO_ID: Record<string, number> = {};
for (const [idStr, name] of Object.entries(MSG_ID_TO_NAME)) {
  MSG_NAME_TO_ID[name] = parseInt(idStr as string);
}

export class SkynetPbCodec implements IPbCodec {
  private initialized = false;
  private protoRoot = '';

  constructor() {
    this.initProto();
  }

  private initProto(): void {
    // 获取 Skynet 根目录
    const skynetRoot = skynet.getenv('skynet_root') || './skynet';
    this.protoRoot = `${skynetRoot}/service-ts/common/protos`;

    // 加载所有 proto 描述文件
    const protoFiles = [
      'common_pb.desc',
      'login_pb.desc',
      'game_pb.desc',
      'gateway_pb.desc',
      'message_id_pb.desc',
    ];

    for (const file of protoFiles) {
      const filepath = `${this.protoRoot}/${file}`;
      // @ts-ignore
      const f = _G.io.open(filepath, 'rb');
      if (f) {
        // @ts-ignore
        const data = f.read(_G, '*all');
        // @ts-ignore
        f.close(_G);
        
        // 加载到 pb
        const ok = pb.load(data);
        if (ok) {
          skynet.error(`[SkynetPbCodec] Loaded ${file}`);
        } else {
          skynet.error(`[SkynetPbCodec] Failed to load ${file}`);
        }
      } else {
        skynet.error(`[SkynetPbCodec] Proto file not found: ${filepath}`);
      }
    }

    this.initialized = true;
    skynet.error('[SkynetPbCodec] Initialized');
  }

  encode(messageType: string, message: any): Uint8Array {
    // pb.encode 返回 Lua string，需要转换为 Uint8Array
    // @ts-ignore
    const encoded = pb.encode(messageType, message);
    if (!encoded) {
      throw new Error(`[SkynetPbCodec] Failed to encode ${messageType}`);
    }
    // 在 Lua 中，string 可以直接作为 bytes 使用
    return encoded as any;
  }

  decode(messageType: string, data: Uint8Array): any {
    // @ts-ignore
    const decoded = pb.decode(messageType, data);
    if (!decoded) {
      throw new Error(`[SkynetPbCodec] Failed to decode ${messageType}`);
    }
    return decoded;
  }

  create(messageType: string, init?: any): any {
    // lua-protobuf 没有 create 方法，直接返回 init 或空表
    // @ts-ignore
    const result = init || {};
    return result;
  }

  pack(msgId: number, messageType: string, message: any, session: number = 0): Uint8Array {
    const payload = this.encode(messageType, message);
    const timestamp = skynet.time();

    const packet = {
      msgId,
      session,
      data: payload,
      timestamp,
    };

    return this.encode('common.Packet', packet);
  }

  unpack(data: Uint8Array): { msgId: number; messageType: string; message: any; session: number } {
    const packet = this.decode('common.Packet', data);
    const messageType = MSG_ID_TO_NAME[packet.msgId];

    if (!messageType) {
      throw new Error(`[SkynetPbCodec] Unknown msgId: ${packet.msgId}`);
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
