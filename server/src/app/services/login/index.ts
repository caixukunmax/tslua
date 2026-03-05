/**
 * 登录服务入口
 * 服务启动逻辑（稳定，很少修改）
 * 支持热更新架构
 */

import { runtime } from '../../../framework/core/interfaces';
import { SessionData } from './data';
import { LoginLogic } from './logic';
import { MessageId, proto } from '../../../protos';
import type { LoginRequest, LoginResponse, User } from './types';
import type { LoginResponse as ProtoLoginResponse } from '../../../protos';

// 数据层：持久化状态，不热更
const data = new SessionData();

// 逻辑层：业务逻辑，可热更
let logic = new LoginLogic(data);

// 会话清理定时器
let cleanupTimer: NodeJS.Timeout | null = null;

/**
 * 构建 proto 格式的登录响应
 */
function buildProtoLoginResponse(response: LoginResponse): ProtoLoginResponse {
  return proto.login.LoginResponse.create({
    code: response.success ? proto.common.ErrorCode.SUCCESS : proto.common.ErrorCode.UNAUTHORIZED,
    message: response.error || '',
    user: response.user
      ? {
          userId: response.user.userId,
          username: response.user.username,
          loginTime: response.user.loginTime,
          level: 1,
          exp: 0,
        }
      : undefined,
    token: response.user?.token,
  });
}

/**
 * 命令分发处理
 * 支持 proto 序列化
 */
async function handleCommand(cmd: string, args: unknown[]): Promise<void> {
  switch (cmd) {
    case 'login': {
      const [username, password] = args as [string, string];
      const response = await logic.handleLogin({ username, password });
      
      // 如果有 codec，使用 proto 序列化
      if (runtime.codec) {
        const protoResponse = buildProtoLoginResponse(response);
        const encoded = runtime.codec.encode('login.LoginResponse', protoResponse);
        runtime.network.ret(true, encoded);
      } else {
        // 回退到普通返回
        runtime.network.ret(response.success, response.user, response.error);
      }
      break;
    }

    case 'logout': {
      const [userId] = args as [number];
      const success = await logic.handleLogout(userId);
      runtime.network.ret(success);
      break;
    }

    case 'getUserInfo': {
      const [userId] = args as [number];
      const user = logic.getUserInfo(userId);
      runtime.network.ret(user);
      break;
    }

    case 'validateToken': {
      const [token] = args as [string];
      const session = logic.validateToken(token);
      runtime.network.ret(session);
      break;
    }

    case 'getOnlineCount': {
      const count = logic.getOnlineCount();
      runtime.network.ret(count);
      break;
    }

    case 'get_state': {
      const state = data.exportState();
      runtime.network.ret(state);
      break;
    }

    default:
      runtime.logger.warn(`Unknown command: ${cmd}`);
      runtime.network.ret(false, undefined, 'Unknown command');
  }
}

/**
 * 启动会话清理定时器
 */
function startSessionCleaner(): void {
  const cleanupInterval = 60000; // 1分钟
  const expireTime = 3600000; // 1小时

  const cleanup = async () => {
    await logic.cleanExpiredSessions(expireTime);
  };

  runtime.logger.info('Session cleaner started');
  
  // 使用定时器（注意：在 Lua 环境中需要使用 runtime.timer）
  const runCleanup = () => {
    cleanup().then(() => {
      runtime.timer.sleep(cleanupInterval).then(runCleanup);
    });
  };
  
  runCleanup();
}

// 启动服务
runtime.service.start(async () => {
  runtime.logger.info('=== Login Service Starting ===');
  runtime.logger.info(`Service address: ${runtime.service.self()}`);

  // 注册消息处理器
  runtime.network.dispatch('lua', async (session: number, source: string, cmd: string, ...args: unknown[]) => {
    runtime.logger.debug(`Login received command: ${cmd} from ${source}`);

    try {
      await handleCommand(cmd, args);
    } catch (error) {
      runtime.logger.error(`Command ${cmd} failed:`, error);
      runtime.network.ret(false, undefined, String(error));
    }
  });

  // 启动会话清理
  startSessionCleaner();

  runtime.logger.info('=== Login Service Ready ===');
  runtime.logger.info(`Sessions: ${data.getCount()}`);
});
