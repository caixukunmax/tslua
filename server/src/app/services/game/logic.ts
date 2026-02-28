/**
 * 游戏服务业务逻辑层
 * 职责：处理业务逻辑，不持有状态
 * 特点：支持热更新，通过依赖注入获取数据
 */

import { runtime } from '../../../framework/core/interfaces';
import { PlayerData } from './data';
import { Player, PlayerUpdate } from './types';

/**
 * 游戏业务逻辑
 * 这个类可以被热更新，不持有任何状态
 */
export class GameLogic {
  constructor(private data: PlayerData) {}

  /**
   * 处理进入游戏
   * @returns 玩家对象或 null（失败时）
   */
  async handleEnterGame(userId: number): Promise<Player | null> {
    runtime.logger.info(`User ${userId} entering game`);

    // 检查是否已经在游戏中
    if (this.data.hasPlayer(userId)) {
      runtime.logger.warn(`User ${userId} already in game`);
      return this.data.getPlayer(userId) || null;
    }

    // 模拟异步操作（如加载玩家数据）
    await runtime.timer.sleep(50);

    // 创建玩家数据
    const player = this.data.addPlayer(userId, runtime.timer.now());
    runtime.logger.info(`User ${userId} entered game successfully`);

    return player;
  }

  /**
   * 处理离开游戏
   */
  async handleLeaveGame(userId: number): Promise<boolean> {
    runtime.logger.info(`User ${userId} leaving game`);

    const player = this.data.getPlayer(userId);
    if (player === undefined) {
      runtime.logger.warn(`Player ${userId} not found`);
      return false;
    }

    // 保存玩家数据（模拟）
    await this.savePlayerData(player);

    const success = this.data.removePlayer(userId);
    if (success) {
      runtime.logger.info(`User ${userId} left game`);
    }

    return success;
  }

  /**
   * 获取玩家信息
   */
  getPlayerInfo(userId: number): Player | undefined {
    return this.data.getPlayer(userId);
  }

  /**
   * 更新玩家属性
   */
  async updatePlayer(userId: number, update: PlayerUpdate): Promise<boolean> {
    const success = this.data.updatePlayer(userId, update);
    
    if (success) {
      runtime.logger.debug(`Player ${userId} updated:`, update);
    } else {
      runtime.logger.warn(`Failed to update player ${userId}`);
    }

    return success;
  }

  /**
   * 获取所有在线玩家
   */
  getAllPlayers(): Player[] {
    return this.data.getAllPlayers();
  }

  /**
   * 获取在线玩家数量
   */
  getOnlineCount(): number {
    return this.data.getCount();
  }

  /**
   * 保存玩家数据
   */
  private async savePlayerData(player: Player): Promise<void> {
    // 这里可以调用数据库服务保存数据
    runtime.logger.debug(`Saving player data for userId: ${player.userId}`);
    await runtime.timer.sleep(10);
  }

  /**
   * 玩家升级
   */
  async levelUp(userId: number): Promise<boolean> {
    const player = this.data.getPlayer(userId);
    if (player === undefined) {
      return false;
    }

    return await this.updatePlayer(userId, {
      level: player.level + 1,
      exp: 0,
    });
  }

  /**
   * 增加经验
   */
  async addExp(userId: number, expAmount: number): Promise<boolean> {
    const player = this.data.getPlayer(userId);
    if (player === undefined) {
      return false;
    }

    const newExp = player.exp + expAmount;
    const expToLevel = 100 * player.level; // 简单的升级公式

    if (newExp >= expToLevel) {
      // 升级
      await this.levelUp(userId);
      runtime.logger.info(`Player ${userId} leveled up to ${player.level + 1}`);
    } else {
      // 只增加经验
      await this.updatePlayer(userId, { exp: newExp });
    }

    return true;
  }

  /**
   * 增加金币
   */
  async addGold(userId: number, goldAmount: number): Promise<boolean> {
    const player = this.data.getPlayer(userId);
    if (player === undefined) {
      return false;
    }

    return await this.updatePlayer(userId, {
      gold: player.gold + goldAmount,
    });
  }
}
