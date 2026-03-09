/**
 * 登录服务业务逻辑层
 * 职责：处理业务逻辑，不持有状态
 * 特点：支持热更新，通过依赖注入获取数据
 */

import { runtime } from '../../../framework/core/interfaces';
import { SessionData } from './data';
import { LoginRequest, LoginResponse, Session, User } from './types';

/**
 * 登录业务逻辑
 * 这个类可以被热更新，不持有任何状态
 */
export class LoginLogic {
  constructor(private data: SessionData) {}

  /**
   * 处理登录请求
   */
  async handleLogin(request: LoginRequest): Promise<LoginResponse> {
    runtime.logger.info(`Login attempt: ${request.username}`);

    try {
      // 模拟异步验证（实际应用中应该查询数据库）
      await runtime.timer.sleep(100);

      // 简单的验证逻辑
      if (!request.username || !request.password) {
        return {
          success: false,
          error: 'Username and password are required',
        };
      }

      if (request.password !== 'password123') {
        return {
          success: false,
          error: 'Invalid credentials',
        };
      }

      // 创建会话
      const token = this.generateToken(request.username);
      const loginTime = runtime.timer.now();
      const session = this.data.addSession(request.username, token, loginTime);

      runtime.logger.info(`User ${session.username} logged in successfully, userId: ${session.userId}`);

      // 转换为 User 对象返回
      const user: User = {
        userId: session.userId,
        username: session.username,
        token: session.token,
        loginTime: session.loginTime,
      };

      return {
        success: true,
        user,
      };
    } catch (error) {
      runtime.logger.error('Login error:', error);
      return {
        success: false,
        error: String(error),
      };
    }
  }

  /**
   * 处理登出请求
   */
  async handleLogout(userId: number): Promise<boolean> {
    runtime.logger.info(`Logout userId: ${userId}`);

    const session = this.data.getSession(userId);
    if (session == null) {
      runtime.logger.warn(`User ${userId} not found`);
      return false;
    }

    const success = this.data.removeSession(userId);
    if (success) {
      runtime.logger.info(`User ${session.username} logged out`);
    }

    return success;
  }

  /**
   * 获取用户信息
   */
  getUserInfo(userId: number): User | undefined {
    const session = this.data.getSession(userId);
    if (session == null) {
      return undefined;
    }

    return {
      userId: session.userId,
      username: session.username,
      token: session.token,
      loginTime: session.loginTime,
    };
  }

  /**
   * 验证 token
   */
  validateToken(token: string): Session | undefined {
    return this.data.findSessionByToken(token);
  }

  /**
   * 获取在线用户数
   */
  getOnlineCount(): number {
    return this.data.getCount();
  }

  /**
   * 获取所有在线会话
   */
  getAllSessions(): Session[] {
    return this.data.getAllSessions();
  }

  /**
   * 清理过期会话
   */
  async cleanExpiredSessions(expireTime: number): Promise<number> {
    const currentTime = runtime.timer.now();
    const cleanedCount = this.data.cleanExpiredSessions(currentTime, expireTime);
    
    if (cleanedCount > 0) {
      runtime.logger.info(`Cleaned ${cleanedCount} expired sessions`);
    }
    
    return cleanedCount;
  }

  /**
   * 生成令牌
   */
  private generateToken(username: string): string {
    const timestamp = runtime.timer.now();
    return `${username}_${timestamp}_${Math.random().toString(36).substring(7)}`;
  }
}
