/**
 * 游戏服务入口
 * 服务启动逻辑（稳定，很少修改）
 * 支持热更新架构
 */

import { runtime } from '../../../framework/core/interfaces';
import { PlayerData } from './data';
import { GameLogic } from './logic';
import { MessageId, proto } from '../../../common/protos';
import type { PlayerUpdate, Player } from './types';

// 数据层：持久化状态，不热更
const data = new PlayerData();

// 逻辑层：业务逻辑，可热更
let logic = new GameLogic(data);

/**
 * 命令分发处理
 */
async function handleCommand(cmd: string, args: unknown[]): Promise<void> {
  switch (cmd) {
    case 'enterGame': {
      const [userId] = args as [number];
      const player = await logic.handleEnterGame(userId);
      
      // 使用 protobuf 序列化响应
      if (runtime.codec && player) {
        const response = proto.game.EnterGameResponse.create({
          success: true,
          playerInfo: {
            userId: player.userId,
            username: `Player_${player.userId}`,
            level: player.level,
            exp: player.exp,
            gold: player.gold,
          },
        });
        const encoded = runtime.codec.encode('game.EnterGameResponse', response);
        runtime.network.ret(true, encoded);
      } else {
        runtime.network.ret(player !== null);
      }
      break;
    }

    case 'leaveGame': {
      const [userId] = args as [number];
      const success = await logic.handleLeaveGame(userId);
      runtime.network.ret(success);
      break;
    }

    case 'getPlayerInfo': {
      const [userId] = args as [number];
      const player = logic.getPlayerInfo(userId);
      
      // 使用 protobuf 返回玩家信息
      if (runtime.codec && player) {
        const playerInfo = proto.game.PlayerInfo.create({
          userId: player.userId,
          username: `Player_${player.userId}`,
          level: player.level,
          exp: player.exp,
          gold: player.gold,
        });
        const encoded = runtime.codec.encode('game.PlayerInfo', playerInfo);
        runtime.network.ret(true, encoded);
      } else {
        runtime.network.ret(player);
      }
      break;
    }

    case 'updatePlayer': {
      const [userId, update] = args as [number, PlayerUpdate];
      const success = await logic.updatePlayer(userId, update);
      runtime.network.ret(success);
      break;
    }

    case 'getOnlineCount': {
      const count = logic.getOnlineCount();
      runtime.network.ret(count);
      break;
    }

    case 'getAllPlayers': {
      const players = logic.getAllPlayers();
      runtime.network.ret(players);
      break;
    }

    // 热更新命令
    case 'hotfix': {
      try {
        await hotfixLogic();
        runtime.network.ret(true, 'Hotfix success');
      } catch (error) {
        runtime.logger.error('Hotfix failed:', error);
        runtime.network.ret(false, String(error));
      }
      break;
    }

    // 状态查询命令
    case 'get_state': {
      const state = data.exportState();
      runtime.network.ret(state);
      break;
    }

    default:
      runtime.logger.warn(`Unknown command: ${cmd}`);
      runtime.network.ret(false, 'Unknown command');
  }
}

/**
 * 热更新逻辑层
 */
async function hotfixLogic(): Promise<void> {
  runtime.logger.info('=== Starting Logic Hotfix ===');

  // 在 Lua 环境下清除模块缓存
  // @ts-ignore
  if (typeof _G !== 'undefined' && _G.package && _G.package.loaded) {
    // @ts-ignore
    _G.package.loaded['app.services.game.logic'] = null;
    runtime.logger.info('Cleared Lua module cache');
  }

  // 重新导入逻辑层
  const { GameLogic: NewLogic } = await import('./logic');
  
  // 替换逻辑层实例（保持数据层不变）
  logic = new NewLogic(data);

  runtime.logger.info('=== Logic Hotfix Complete ===');
}

// 启动服务
runtime.service.start(async () => {
  runtime.logger.info('=== Game Service Starting ===');
  runtime.logger.info(`Service address: ${runtime.service.self()}`);

  // 注册消息处理器
  runtime.network.dispatch('lua', async (session: number, source: string, cmd: string, ...args: unknown[]) => {
    runtime.logger.debug(`Game received command: ${cmd} from ${source}`);

    try {
      await handleCommand(cmd, args);
    } catch (error) {
      runtime.logger.error(`Command ${cmd} failed:`, error);
      runtime.network.ret(false, String(error));
    }
  });

  runtime.logger.info('=== Game Service Ready ===');
  runtime.logger.info(`Online players: ${data.getCount()}`);
});
