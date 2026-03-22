/**
 * 游戏服务入口
 * 服务启动逻辑（稳定，很少修改）
 * 支持热更新架构
 */

import { runtime } from '../../../framework/core/interfaces';
import { PlayerData } from './data';
import { GameLogic } from './logic';
// eslint-disable-next-line @typescript-eslint/no-unused-vars
import { MessageId, proto, ErrorCode } from '../../../protos';
import type { PlayerUpdate } from './types';

// 数据层：持久化状态，不热更
const data = new PlayerData();

// 逻辑层：业务逻辑，可热更
const logic = new GameLogic(data);

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
          code: ErrorCode.SUCCESS,
          message: 'Enter game success',
          player: {
            userId: player.userId,
            level: player.level,
            exp: player.exp,
            gold: player.gold,
            enterTime: Date.now(),
          },
        });
        const encoded = runtime.codec.encode('game.EnterGameResponse', response);
        runtime.network.ret(true, encoded);
      } else {
        runtime.network.ret(player != null);
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
          level: player.level,
          exp: player.exp,
          gold: player.gold,
          enterTime: Date.now(),
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

// 启动服务
// ⚠️ 注意：start 回调必须是同步函数（禁止 async）
runtime.service.start(() => {
  runtime.logger.info('=== Game Service Starting ===');
  runtime.logger.info(`Service address: ${runtime.service.self()}`);

  // 注册消息处理器（handler 内部可以用 async）
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

  // 【必须】保持服务运行 - 使用纯协程方式
  const keepAlive = async () => {
    await runtime.timer.sleep(30000);
    runtime.logger.debug(`[Game] Keep alive, players: ${data.getCount()}`);
    keepAlive();
  };
  keepAlive();
});