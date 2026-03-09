/**
 * 网关数据存储层
 * 职责：管理连接数据，不包含业务逻辑
 * 特点：不热更新，保持状态持久化
 */

import { Connection, ClientInfo, DataState } from './types';

// 从 types.ts 导入 Connection 接口，不再重复定义

/**
 * 连接数据存储
 * 这个类不会被热更新，确保数据持久性
 */
export class ConnectionData {
  private connections = new Map<number, Connection>();
  private nextConnId = 1;

  /**
   * 添加连接
   */
  addConnection(clientInfo: ClientInfo, connectTime: number): Connection {
    const connId = this.nextConnId++;
    const connection: Connection = {
      connId,
      clientInfo,
      connectTime,
      userId: null,
    };
    this.connections.set(connId, connection);
    return connection;
  }

  /**
   * 移除连接
   */
  removeConnection(connId: number): boolean {
    return this.connections.delete(connId);
  }

  /**
   * 获取连接
   */
  getConnection(connId: number): Connection | undefined {
    return this.connections.get(connId);
  }

  /**
   * 获取所有连接
   */
  getAllConnections(): Connection[] {
    return Array.from(this.connections.values());
  }

  /**
   * 获取连接数量
   */
  getCount(): number {
    return this.connections.size;
  }

  /**
   * 绑定用户ID
   */
  bindUser(connId: number, userId: number): boolean {
    const conn = this.connections.get(connId);
    if (!conn) {
      return false;
    }
    conn.userId = userId;
    return true;
  }

  /**
   * 通过用户ID查找连接
   */
  findByUserId(userId: number): Connection | undefined {
    for (const conn of this.connections.values()) {
      if (conn.userId === userId) {
        return conn;
      }
    }
    return undefined;
  }

  /**
   * 清空所有连接（慎用）
   */
  clear(): void {
    this.connections.clear();
  }

  /**
   * 导出状态（用于热更新时的状态迁移）
   */
  exportState(): DataState {
    return {
      connections: Array.from(this.connections.entries()),
      nextConnId: this.nextConnId,
    };
  }

  /**
   * 导入状态（用于热更新时的状态迁移）
   */
  importState(state: DataState): void {
    if (state.connections != null) {
      this.connections = new Map(state.connections);
    }
    if (state.nextConnId != null) {
      this.nextConnId = state.nextConnId;
    }
  }
}
