/**
 * Skynet 运行时适配器
 * 实现抽象接口，底层封装 Skynet 的 Lua API
 * 
 * 注意：此文件会被 TypeScriptToLua 编译为 Lua 代码
 */

/** @noSelfInFile */

// @ts-expect-error - require 是 Lua 全局函数
const skynet = _G.require('skynet');

import {
  ILogger,
  ITimer,
  INetwork,
  IService,
  IRuntime,
  IPbCodec,
} from '../core/interfaces';
import { SkynetPbCodec } from './skynet-pb-codec';

// Skynet Lua API 声明（仅用于类型提示，已有 const skynet）

/**
 * Skynet 日志实现
 */
export class SkynetLogger implements ILogger {
  private logLevel: 'debug' | 'info' | 'warn' | 'error' = 'info';

  debug(message: string, ...args: any[]): void {
    if (this.logLevel !== 'debug') return;
    skynet.error(`[DEBUG] ${this.timestamp()} ${message} ${this.formatArgs(args)}`);
  }

  info(message: string, ...args: any[]): void {
    skynet.error(`[INFO] ${this.timestamp()} ${message} ${this.formatArgs(args)}`);
  }

  warn(message: string, ...args: any[]): void {
    skynet.error(`[WARN] ${this.timestamp()} ${message} ${this.formatArgs(args)}`);
  }

  error(message: string, ...args: any[]): void {
    skynet.error(`[ERROR] ${this.timestamp()} ${message} ${this.formatArgs(args)}`);
  }

  private timestamp(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`;
  }

  private formatArgs(args: any[]): string {
    if (args.length === 0) return '';
    // 在 Lua 环境下简单拼接
    return args.map(arg => {
      if (typeof arg === 'object') {
        return JSON.stringify(arg);
      }
      return String(arg);
    }).join(' ');
  }
}

/**
 * Skynet 定时器实现
 * 注意：Skynet 使用厘秒（1/100秒）作为时间单位
 */
export class SkynetTimer implements ITimer {
  setTimeout(ms: number, callback: () => void): any {
    const centiseconds = Math.floor(ms / 10);
    skynet.timeout(centiseconds, callback);
    return centiseconds;
  }

  clearTimeout(_handle: any): void {
    // Skynet 不支持取消 timeout，这里留空
    // 实际使用中可以通过标志位来实现
  }

  sleep(ms: number): Promise<void> {
    // 使用 skynet.timeout 实现非阻塞等待
    // 这会在 Skynet 事件循环中调度回调
    return new Promise<void>((resolve) => {
      const centiseconds = Math.floor(ms / 10);
      skynet.timeout(centiseconds, () => {
        resolve();
      });
    });
  }

  now(): number {
    return skynet.time();
  }

  /**
   * 协程安全的 setTimeout
   * 使用 skynet.fork 包装回调，确保在 Skynet 协程中执行
   */
  safeTimeout(callback: () => void | Promise<void>, ms?: number): void {
    const centiseconds = Math.floor((ms || 0) / 10);
    skynet.timeout(centiseconds, () => {
      // skynet.fork 创建受管理的协程
      (skynet as any).fork(() => {
        const result = callback();
        // 如果回调返回 Promise，等待完成
        if (result && typeof (result as any).then === 'function') {
          (result as Promise<void>).catch((err) => {
            skynet.error(`[safeTimeout] Error: ${err}`);
          });
        }
      });
    });
  }

  /**
   * 协程安全的 setImmediate
   */
  safeImmediate(callback: () => void | Promise<void>): void {
    this.safeTimeout(callback, 0);
  }
}

/**
 * Skynet 网络实现
 */
export class SkynetNetwork implements INetwork {
  send(address: string, messageType: string, ...args: any[]): void {
    skynet.send(address, messageType, ...args);
  }

  async call(address: string, messageType: string, ...args: any[]): Promise<any> {
    // skynet.call 会 yield 并等待响应
    // TSTL 会将这个 async/await 转换为 Lua 协程
    const result = skynet.call(address, messageType, ...args);
    return result;
  }

  dispatch(messageType: string, handler: (session: number, source: string, ...args: any[]) => void | Promise<void>): void {
    skynet.dispatch(messageType, (session: number, source: number, ...args: any[]) => {
      const result = handler(session, String(source), ...args);
      // Promise 会自己管理协程，不需要额外处理
      // 只需要捕获错误
      if (result && typeof (result as any).then === 'function') {
        (result as Promise<void>).catch((err) => {
          skynet.error(`Dispatch error: ${err}`);
        });
      }
    });
  }

  ret(...args: any[]): void {
    skynet.retpack(...args);
  }
}

/**
 * Skynet 服务实现
 */
export class SkynetService implements IService {
  start(callback: () => void | Promise<void>): void {
    skynet.start(() => {
      // 使用 skynet.fork 创建新协程来执行回调
      // 这样回调中的异步操作不会阻塞服务启动
      (skynet as any).fork(() => {
        const result = callback();
        if (result && typeof (result as any).then === 'function') {
          (result as Promise<void>).catch((err) => {
            skynet.error(`Service start error: ${err}`);
          });
        }
      });
    });
  }

  exit(): void {
    skynet.exit();
  }

  newService(name: string, ...args: any[]): Promise<string> {
    // Skynet 的 newservice 接收一个包含参数的字符串
    const fullCommand = args.length > 0 ? `${name} ${args.join(' ')}` : name;
    const address = skynet.newservice(fullCommand);
    // 返回一个已解决的 Promise
    return Promise.resolve(String(address));
  }

  self(): string {
    return skynet.self();
  }

  getenv(key: string): string | undefined {
    return skynet.getenv(key);
  }

  setenv(key: string, value: string): void {
    skynet.setenv(key, value);
  }
}

/**
 * 创建 Skynet 运行时
 */
export function createSkynetRuntime(): IRuntime {
  let codec: IPbCodec | undefined;
  
  try {
    codec = new SkynetPbCodec();
  } catch (error) {
    skynet.error('[SkynetRuntime] PbCodec not available:', error);
  }

  return {
    logger: new SkynetLogger(),
    timer: new SkynetTimer(),
    network: new SkynetNetwork(),
    service: new SkynetService(),
    codec,
  };
}
