/**
 * 游戏服务数据存储层
 * 职责：管理玩家数据，不包含业务逻辑
 * 特点：不热更新，保持状态持久化
 */

import { Player, PlayerUpdate, DataState } from './types';

/**
 * 玩家数据存储
 * 这个类不会被热更新，确保数据持久性
 */
export class PlayerData {
  private players = new Map<number, Player>();

  /**
   * 添加玩家
   */
  addPlayer(userId: number, enterTime: number): Player {
    const player: Player = {
      userId,
      level: 1,
      exp: 0,
      gold: 100,
      enterTime,
    };
    this.players.set(userId, player);
    return player;
  }

  /**
   * 移除玩家
   */
  removePlayer(userId: number): boolean {
    return this.players.delete(userId);
  }

  /**
   * 获取玩家
   */
  getPlayer(userId: number): Player | undefined {
    return this.players.get(userId);
  }

  /**
   * 更新玩家属性
   */
  updatePlayer(userId: number, update: PlayerUpdate): boolean {
    const player = this.players.get(userId);
    if (player == null) {
      return false;
    }

    if (update.level != null) {
      player.level = update.level;
    }
    if (update.exp != null) {
      player.exp = update.exp;
    }
    if (update.gold != null) {
      player.gold = update.gold;
    }

    return true;
  }

  /**
   * 获取所有玩家
   */
  getAllPlayers(): Player[] {
    return Array.from(this.players.values());
  }

  /**
   * 获取在线玩家数量
   */
  getCount(): number {
    return this.players.size;
  }

  /**
   * 检查玩家是否存在
   */
  hasPlayer(userId: number): boolean {
    return this.players.has(userId);
  }

  /**
   * 清空所有玩家（慎用）
   */
  clear(): void {
    this.players.clear();
  }

  /**
   * 导出状态（用于热更新时的状态迁移）
   */
  exportState(): DataState {
    return {
      players: Array.from(this.players.entries()),
    };
  }

  /**
   * 导入状态（用于热更新时的状态迁移）
   */
  importState(state: DataState): void {
    if (state.players != null) {
      this.players = new Map(state.players);
    }
  }
}
