/**
 * 网关服务类型定义
 * 集中管理所有数据类型，提供类型安全
 */

// ErrorCode 直接从 proto 对象获取
import { proto } from '../../../common/protos';
export type ProtoErrorCode = (typeof proto.common.ErrorCode)[keyof typeof proto.common.ErrorCode];

/**
 * 客户端信息
 * 与 proto.gateway.ConnectRequest 对应
 */
export interface ClientInfo {
  /** 客户端 IP 地址 */
  ip: string;
  /** 客户端端口 */
  port: number;
  /** 连接时间戳 */
  timestamp: number;
  /** 客户端版本（可选） */
  version?: string;
  /** 客户端平台（可选）：如 'ios', 'android', 'web' */
  platform?: string;
  /** 设备 ID（可选） */
  deviceId?: string;
}

/**
 * 连接信息
 */
export interface Connection {
  /** 连接 ID */
  connId: number;
  /** 客户端信息 */
  clientInfo: ClientInfo;
  /** 连接时间 */
  connectTime: number;
  /** 绑定的用户 ID */
  userId: number | null;
}

/**
 * 消息类型枚举
 */
export enum MessageType {
  /** 心跳消息 */
  HEARTBEAT = 'heartbeat',
  /** 聊天消息 */
  CHAT = 'chat',
  /** 游戏消息 */
  GAME = 'game',
  /** 系统消息 */
  SYSTEM = 'system',
  /** 通知消息 */
  NOTIFICATION = 'notification',
}

/**
 * 消息基础结构
 */
export interface Message {
  /** 消息类型 */
  type: MessageType;
  /** 消息内容 */
  data: unknown;
  /** 消息时间戳 */
  timestamp: number;
}

/**
 * 心跳消息
 */
export interface HeartbeatMessage extends Message {
  type: MessageType.HEARTBEAT;
  data: {
    /** 客户端时间戳 */
    clientTime: number;
  };
}

/**
 * 聊天消息
 */
export interface ChatMessage extends Message {
  type: MessageType.CHAT;
  data: {
    /** 发送者 ID */
    from: number;
    /** 接收者 ID */
    to: number;
    /** 消息内容 */
    content: string;
    /** 消息 ID */
    msgId?: string;
  };
}

/**
 * 游戏消息
 */
export interface GameMessage extends Message {
  type: MessageType.GAME;
  data: {
    /** 游戏动作 */
    action: string;
    /** 游戏数据 */
    payload: Record<string, unknown>;
  };
}

/**
 * 所有消息类型的联合类型
 */
export type AnyMessage = HeartbeatMessage | ChatMessage | GameMessage | Message;

/**
 * 存储状态（用于热更新时的状态迁移）
 */
export interface DataState {
  /** 连接列表 */
  connections: Array<[number, Connection]>;
  /** 下一个连接 ID */
  nextConnId: number;
}

/**
 * 命令参数类型映射
 */
export interface CommandArgs {
  connect: [ClientInfo];
  disconnect: [number];
  forward: [number, AnyMessage];
  bind_user: [number, number];
  online_count: [];
  broadcast: [AnyMessage];
  kick: [number, string?];
  hotfix: [];
  get_state: [];
}

/**
 * 命令名称类型
 */
export type CommandName = keyof CommandArgs;
