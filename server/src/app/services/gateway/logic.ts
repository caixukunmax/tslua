/**
 * 网关业务逻辑层
 * 职责：处理业务逻辑，不持有状态
 * 特点：支持热更新，通过依赖注入获取数据
 */

import { runtime } from '../../../framework/core/interfaces';
import { ConnectionData } from './data';
import { ClientInfo, Connection, AnyMessage } from './types';

/**
 * 网关业务逻辑
 * 这个类可以被热更新，不持有任何状态
 */
export class GatewayLogic {
  constructor(private data: ConnectionData) {}

  /**
   * 处理客户端连接
   */
  async handleConnect(clientInfo: ClientInfo): Promise<number> {
    runtime.logger.info('Client connecting...');

    const connection = this.data.addConnection(clientInfo, runtime.timer.now());
    runtime.logger.info(`Client connected, connId: ${connection.connId}`);

    // 可以在这里添加更多的连接后处理逻辑
    // 例如：通知其他服务、记录日志等

    return connection.connId;
  }

  /**
   * 处理客户端断开
   */
  async handleDisconnect(connId: number): Promise<boolean> {
    runtime.logger.info(`Client disconnecting, connId: ${connId}`);

    const conn = this.data.getConnection(connId);
    if (!conn) {
      runtime.logger.warn(`Connection ${connId} not found`);
      return false;
    }

    // 可以在这里添加断开前的清理逻辑
    // 例如：保存用户数据、通知其他服务等

    const success = this.data.removeConnection(connId);
    if (success) {
      runtime.logger.info(`Client disconnected, connId: ${connId}`);
    }

    return success;
  }

  /**
   * 转发消息到后端服务
   */
  async handleForward(connId: number, message: AnyMessage): Promise<boolean> {
    const conn = this.data.getConnection(connId);
    if (!conn) {
      runtime.logger.warn(`Connection ${connId} not found`);
      return false;
    }

    runtime.logger.debug(`Forwarding message for connId: ${connId}`);

    // 这里实现消息转发逻辑
    // 可以根据 userId 路由到对应的游戏服务
    // 例如：
    // if (conn.userId) {
    //   const gameService = await this.findGameService(conn.userId);
    //   await runtime.network.call(gameService, 'lua', 'handle_message', message);
    // }

    return true;
  }

  /**
   * 绑定用户ID到连接
   */
  async handleBindUser(connId: number, userId: number): Promise<boolean> {
    const success = this.data.bindUser(connId, userId);
    if (success) {
      runtime.logger.info(`Bound userId ${userId} to connId ${connId}`);
    } else {
      runtime.logger.warn(`Failed to bind userId ${userId} to connId ${connId}`);
    }
    return success;
  }

  /**
   * 获取在线连接数
   */
  getOnlineCount(): number {
    return this.data.getCount();
  }

  /**
   * 获取所有在线连接
   */
  getAllConnections(): Connection[] {
    return this.data.getAllConnections();
  }

  /**
   * 通过用户ID查找连接
   */
  findConnectionByUserId(userId: number): Connection | undefined {
    return this.data.findByUserId(userId);
  }

  /**
   * 广播消息给所有连接
   */
  async broadcast(message: AnyMessage): Promise<void> {
    const connections = this.data.getAllConnections();
    runtime.logger.info(`Broadcasting message to ${connections.length} connections`);

    for (const conn of connections) {
      try {
        // 这里实现具体的广播逻辑
        runtime.logger.debug(`Broadcast to connId: ${conn.connId}`);
      } catch (error) {
        runtime.logger.error(`Failed to broadcast to connId ${conn.connId}:`, error);
      }
    }
  }

  /**
   * 踢出连接
   */
  async kickConnection(connId: number, reason: string): Promise<boolean> {
    runtime.logger.info(`Kicking connId ${connId}, reason: ${reason}`);

    const conn = this.data.getConnection(connId);
    if (!conn) {
      return false;
    }

    // 通知客户端被踢出
    // await this.sendToClient(connId, { type: 'kick', reason });

    // 断开连接
    return await this.handleDisconnect(connId);
  }
}
