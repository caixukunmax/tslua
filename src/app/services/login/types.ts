/**
 * 登录服务类型定义
 * 集中管理所有数据类型，提供类型安全
 *
 * 注意：业务逻辑使用内部类型，与外部通信时通过 codec 转换为 proto 类型
 */

// ErrorCode 直接从 proto 对象获取
import { proto } from '../../../common/protos';
export type ProtoErrorCode = (typeof proto.common.ErrorCode)[keyof typeof proto.common.ErrorCode];

/**
 * 内部用户数据结构
 * 与 proto.login.UserInfo 对应
 */
export interface User {
  userId: number;
  username: string;
  token: string;
  loginTime: number;
}

/**
 * 内部登录请求
 * 与 proto.login.LoginRequest 对应
 */
export interface LoginRequest {
  username: string;
  password: string;
  deviceId?: string;
  platform?: string;
}

/**
 * 内部登录响应
 * 与 proto.login.LoginResponse 对应
 */
export interface LoginResponse {
  success: boolean;
  user?: User;
  error?: string;
}

/**
 * 会话信息
 */
export interface Session {
  userId: number;
  username: string;
  token: string;
  loginTime: number;
  lastActivityTime: number;
}

/**
 * 存储状态（用于热更新时的状态迁移）
 */
export interface DataState {
  /** 用户会话列表 */
  sessions: Array<[number, Session]>;
  /** 下一个用户 ID */
  nextUserId: number;
}

/**
 * 命令参数类型映射
 */
export interface CommandArgs {
  login: [string, string]; // username, password
  logout: [number]; // userId
  getUserInfo: [number]; // userId
  validateToken: [string]; // token
  getOnlineCount: [];
  hotfix: [];
  get_state: [];
}

/**
 * 命令名称类型
 */
export type CommandName = keyof CommandArgs;
