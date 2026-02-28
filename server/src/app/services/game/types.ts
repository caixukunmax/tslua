/**
 * 游戏服务类型定义
 * 集中管理所有数据类型，提供类型安全
 */

// ErrorCode 直接从 proto 对象获取
import { proto } from '../../../protos';
export type ProtoErrorCode = (typeof proto.common.ErrorCode)[keyof typeof proto.common.ErrorCode];

/**
 * 玩家数据结构
 * 与 proto.game.PlayerInfo 对应
 */
export interface Player {
  userId: number;
  level: number;
  exp: number;
  gold: number;
  enterTime: number;
}

/**
 * 玩家属性更新
 */
export interface PlayerUpdate {
  level?: number;
  exp?: number;
  gold?: number;
}

/**
 * 存储状态（用于热更新时的状态迁移）
 */
export interface DataState {
  /** 玩家列表 */
  players: Array<[number, Player]>;
}

/**
 * 命令参数类型映射
 */
export interface CommandArgs {
  enterGame: [number]; // userId
  leaveGame: [number]; // userId
  getPlayerInfo: [number]; // userId
  updatePlayer: [number, PlayerUpdate]; // userId, update
  getOnlineCount: [];
  getAllPlayers: [];
  hotfix: [];
  get_state: [];
}

/**
 * 命令名称类型
 */
export type CommandName = keyof CommandArgs;
