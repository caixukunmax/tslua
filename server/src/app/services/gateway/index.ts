/**
 * 网关服务入口
 * 服务启动逻辑（稳定，很少修改）
 * 支持热更新架构
 */

import { runtime } from '../../../framework/core/interfaces';
import { ConnectionData } from './data';
import { GatewayLogic } from './logic';
import { MessageId, proto } from '../../../protos';
import type { CommandName, ClientInfo, AnyMessage } from './types';
import type { ProtoConnectResponse, ProtoHeartbeatResponse, ProtoLoginRequest } from '../../../protos';

// 数据层：持久化状态，不热更
const data = new ConnectionData();

// 逻辑层：业务逻辑，可热更
let logic = new GatewayLogic(data);

/**
 * 命令分发处理
 */
async function handleCommand(cmd: string, args: unknown[]): Promise<void> {
  switch (cmd) {
    case 'connect': {
      const [clientInfo] = args as [ClientInfo];
      const connId = await logic.handleConnect(clientInfo);
      
      // 使用 protobuf 返回连接响应
      if (runtime.codec) {
        const response = proto.gateway.ConnectResponse.create({
          success: connId > 0,
          message: connId > 0 ? 'Connected successfully' : 'Connection failed',
          sessionId: connId > 0 ? `session_${connId}` : undefined,
        });
        const encoded = runtime.codec.encode('gateway.ConnectResponse', response);
        runtime.network.ret(connId, encoded);
      } else {
        runtime.network.ret(connId);
      }
      break;
    }

    case 'disconnect': {
      const [connId, reason] = args as [number, string?];
      const success = await logic.handleDisconnect(connId);
      
      // 发送断开通知（使用 protobuf）
      if (runtime.codec && success) {
        const notify = proto.gateway.DisconnectNotify.create({
          reason: reason || 'user_disconnect',
        });
        // 可以广播给相关服务
        runtime.logger.info(`Disconnect notify: ${notify.reason}`);
      }
      
      runtime.network.ret(success);
      break;
    }

    case 'forward': {
      const [connId, message] = args as [number, AnyMessage];
      const success = await logic.handleForward(connId, message);
      runtime.network.ret(success);
      break;
    }

    case 'bind_user': {
      const [connId, userId] = args as [number, number];
      const success = await logic.handleBindUser(connId, userId);
      runtime.network.ret(success);
      break;
    }

    case 'online_count': {
      const count = logic.getOnlineCount();
      runtime.network.ret(count);
      break;
    }

    case 'broadcast': {
      const [message] = args as [AnyMessage];
      await logic.broadcast(message);
      runtime.network.ret(true);
      break;
    }

    case 'kick': {
      const [connId, reason] = args as [number, string?];
      const success = await logic.kickConnection(connId, reason || 'kicked');
      runtime.network.ret(success);
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

/**
 * 处理客户端心跳（演示 protobuf 解包）
 */
async function handleHeartbeat(packetData: Uint8Array): Promise<void> {
  if (!runtime.codec) {
    runtime.logger.warn('Codec not available for heartbeat');
    return;
  }

  try {
    // 解包 heartbeat 请求
    const heartbeat = runtime.codec.decode('gateway.HeartbeatRequest', packetData);
    const clientTime = heartbeat.clientTime;

    // 构建响应
    const response = proto.gateway.HeartbeatResponse.create({
      serverTime: runtime.timer.now(),
      clientTime: clientTime,
    });

    const encoded = runtime.codec.encode('gateway.HeartbeatResponse', response);
    runtime.network.ret(encoded);
  } catch (error) {
    runtime.logger.error('Heartbeat error:', error);
  }
}

/**
 * 转发消息到登录服务（演示服务间 protobuf 通信）
 */
async function forwardToLogin(packetData: Uint8Array): Promise<void> {
  if (!runtime.codec) {
    runtime.network.ret(false, 'Codec not available');
    return;
  }

  try {
    // 解包登录请求
    const { msgId, message } = runtime.codec.unpack(packetData);

    if (msgId === MessageId.LOGIN_REQ) {
      const loginReq = message as ProtoLoginRequest;
      runtime.logger.info(`Forwarding login request: ${loginReq.username}`);

      // 调用登录服务（传递 protobuf 数据）
      const loginService = await runtime.service.newService('login');
      const response = await runtime.network.call(loginService, 'lua', 'login', 
        loginReq.username, 
        loginReq.password
      );

      runtime.network.ret(response);
    } else {
      runtime.network.ret(false, 'Unknown message type');
    }
  } catch (error) {
    runtime.logger.error('Forward error:', error);
    runtime.network.ret(false, String(error));
  }
}

// 启动服务
runtime.service.start(async () => {
  runtime.logger.info('=== Gateway Service Starting ===');
  runtime.logger.info(`Service address: ${runtime.service.self()}`);

  // 注册消息处理器
  runtime.network.dispatch('lua', async (session: number, source: string, cmd: string, ...args: any[]) => {
    runtime.logger.debug(`Gateway received command: ${cmd} from ${source}`);

    try {
      // 特殊处理 protobuf 消息
      if (cmd === 'heartbeat' && args[0] instanceof Uint8Array) {
        await handleHeartbeat(args[0]);
      } else if (cmd === 'forward_login' && args[0] instanceof Uint8Array) {
        await forwardToLogin(args[0]);
      } else {
        await handleCommand(cmd, args);
      }
    } catch (error) {
      runtime.logger.error(`Command ${cmd} failed:`, error);
      runtime.network.ret(false, String(error));
    }
  });

  runtime.logger.info('=== Gateway Service Ready ===');
  runtime.logger.info(`Connections: ${data.getCount()}`);
});
