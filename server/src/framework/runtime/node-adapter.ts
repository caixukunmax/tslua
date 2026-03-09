/**
 * Node.js 运行时适配器
 * 实现抽象接口，底层使用 Node.js 原生 API
 */

import {
  ILogger,
  ITimer,
  INetwork,
  IService,
  IRuntime,
  IPbCodec,
} from '../core/interfaces';
import { NodePbCodec } from './node-pb-codec';

/**
 * Node.js 日志实现
 */
export class NodeLogger implements ILogger {
  debug(message: string, ...args: any[]): void {
    console.debug(`[DEBUG] ${message}`, ...args);
  }

  info(message: string, ...args: any[]): void {
    console.info(`[INFO] ${message}`, ...args);
  }

  warn(message: string, ...args: any[]): void {
    console.warn(`[WARN] ${message}`, ...args);
  }

  error(message: string, ...args: any[]): void {
    console.error(`[ERROR] ${message}`, ...args);
  }
}

/**
 * Node.js 定时器实现
 */
export class NodeTimer implements ITimer {
  setTimeout(ms: number, callback: () => void): any {
    return global.setTimeout(() => callback(), ms);
  }

  clearTimeout(handle: any): void {
    global.clearTimeout(handle);
  }

  async sleep(ms: number): Promise<void> {
    return new Promise((resolve) => global.setTimeout(() => resolve(), ms));
  }

  now(): number {
    return Math.floor(Date.now() / 1000);
  }

  /**
   * 协程安全的 setTimeout（Node.js 环境下直接映射）
   */
  safeTimeout(callback: () => void | Promise<void>, ms?: number): void {
    global.setTimeout(() => {
      const result = callback();
      // Node.js 不需要特殊处理 Promise
      if (result && typeof (result as any).catch === 'function') {
        (result as Promise<void>).catch((err) => {
          console.error('[safeTimeout] Error:', err);
        });
      }
    }, ms || 0);
  }

  /**
   * 协程安全的 setImmediate（Node.js 环境下直接映射）
   */
  safeImmediate(callback: () => void | Promise<void>): void {
    global.setImmediate(() => {
      const result = callback();
      if (result && typeof (result as any).catch === 'function') {
        (result as Promise<void>).catch((err) => {
          console.error('[safeImmediate] Error:', err);
        });
      }
    });
  }
}

/**
 * Node.js 网络实现
 * 这里使用简单的事件模拟，实际应用可以使用 Socket.IO 或其他 RPC 框架
 */
export class NodeNetwork implements INetwork {
  private handlers = new Map<string, (session: number, source: string, ...args: any[]) => void | Promise<void>>();
  private sessionId = 1;
  private pendingCalls = new Map<number, { resolve: (value: any) => void; reject: (reason: any) => void }>();

  send(address: string, messageType: string, ...args: any[]): void {
    // 在 Node.js 环境下，这里可以实现为消息队列或事件发射
    console.log(`[NodeNetwork] SEND to ${address}, type: ${messageType}`, args);
  }

  async call(address: string, messageType: string, ...args: any[]): Promise<any> {
    // 模拟远程调用
    return new Promise((resolve, reject) => {
      const session = this.sessionId++;
      this.pendingCalls.set(session, { resolve, reject });

      console.log(`[NodeNetwork] CALL to ${address}, type: ${messageType}, session: ${session}`, args);

      // 模拟异步响应
      global.setTimeout(() => {
        const pending = this.pendingCalls.get(session);
        if (pending) {
          this.pendingCalls.delete(session);
          pending.resolve({ success: true, data: 'mock response' });
        }
      }, 100);
    });
  }

  dispatch(messageType: string, handler: (session: number, source: string, ...args: any[]) => void | Promise<void>): void {
    this.handlers.set(messageType, handler);
    console.log(`[NodeNetwork] Registered handler for ${messageType}`);
  }

  ret(...args: any[]): void {
    console.log('[NodeNetwork] RET', args);
  }
}

/**
 * Node.js 服务实现
 */
export class NodeService implements IService {
  private serviceId = 'node-service-' + Date.now();

  start(callback: () => void | Promise<void>): void {
    console.log(`[NodeService] Starting service ${this.serviceId}`);
    // 使用 setImmediate 模拟 skynet.start
    global.setImmediate(async () => {
      try {
        await callback();
      } catch (error) {
        console.error('[NodeService] Service start error:', error);
      }
    });
  }

  exit(): void {
    console.log(`[NodeService] Exiting service ${this.serviceId}`);
    // Node.js 环境下可以选择退出进程或仅清理资源
    // process.exit(0);
  }

  async newService(name: string, ...args: any[]): Promise<string> {
    // 在 Node.js 环境下，可以使用 child_process 或返回模拟地址
    const address = `node-service-${name}-${Date.now()}`;
    console.log(`[NodeService] Creating new service: ${name}`, args);
    return address;
  }

  self(): string {
    return this.serviceId;
  }

  getenv(key: string): string | undefined {
    return process.env[key];
  }

  setenv(key: string, value: string): void {
    process.env[key] = value;
  }
}

/**
 * 创建 Node.js 运行时
 */
export function createNodeRuntime(): IRuntime {
  let codec: IPbCodec | undefined;

  try {
    codec = new NodePbCodec();
  } catch (error) {
    console.warn('[NodeRuntime] PbCodec not available:', error);
  }

  return {
    logger: new NodeLogger(),
    timer: new NodeTimer(),
    network: new NodeNetwork(),
    service: new NodeService(),
    codec,  // 添加 codec 到返回对象
  };
}
