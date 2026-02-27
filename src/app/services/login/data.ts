/**
 * 登录服务数据存储层
 * 职责：管理会话数据，不包含业务逻辑
 * 特点：不热更新，保持状态持久化
 */

import { Session, DataState } from './types';

/**
 * 会话数据存储
 * 这个类不会被热更新，确保数据持久性
 */
export class SessionData {
  private sessions = new Map<number, Session>();
  private nextUserId = 1;

  /**
   * 添加会话
   */
  addSession(username: string, token: string, loginTime: number): Session {
    const userId = this.nextUserId++;
    const session: Session = {
      userId,
      username,
      token,
      loginTime,
      lastActivityTime: loginTime,
    };
    this.sessions.set(userId, session);
    return session;
  }

  /**
   * 移除会话
   */
  removeSession(userId: number): boolean {
    return this.sessions.delete(userId);
  }

  /**
   * 获取会话
   */
  getSession(userId: number): Session | undefined {
    return this.sessions.get(userId);
  }

  /**
   * 通过 token 查找会话
   */
  findSessionByToken(token: string): Session | undefined {
    for (const session of this.sessions.values()) {
      if (session.token === token) {
        return session;
      }
    }
    return undefined;
  }

  /**
   * 获取所有会话
   */
  getAllSessions(): Session[] {
    return Array.from(this.sessions.values());
  }

  /**
   * 获取会话数量
   */
  getCount(): number {
    return this.sessions.size;
  }

  /**
   * 更新最后活动时间
   */
  updateActivity(userId: number, time: number): boolean {
    const session = this.sessions.get(userId);
    if (session === undefined) {
      return false;
    }
    session.lastActivityTime = time;
    return true;
  }

  /**
   * 清理过期会话
   */
  cleanExpiredSessions(currentTime: number, expireTime: number): number {
    let cleanedCount = 0;
    for (const [userId, session] of this.sessions.entries()) {
      if (currentTime - session.loginTime > expireTime) {
        this.sessions.delete(userId);
        cleanedCount++;
      }
    }
    return cleanedCount;
  }

  /**
   * 清空所有会话（慎用）
   */
  clear(): void {
    this.sessions.clear();
  }

  /**
   * 导出状态（用于热更新时的状态迁移）
   */
  exportState(): DataState {
    return {
      sessions: Array.from(this.sessions.entries()),
      nextUserId: this.nextUserId,
    };
  }

  /**
   * 导入状态（用于热更新时的状态迁移）
   */
  importState(state: DataState): void {
    if (state.sessions !== undefined) {
      this.sessions = new Map(state.sessions);
    }
    if (state.nextUserId !== undefined) {
      this.nextUserId = state.nextUserId;
    }
  }
}
