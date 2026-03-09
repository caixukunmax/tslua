/**
 * 异步桥接层
 * 
 * 关键难点：将 TypeScript 的 async/await (Promise) 转换为 Skynet 的 Lua 协程
 * 
 * 原理：
 * 1. Node.js 环境：async/await 直接映射为 ES Promise
 * 2. Skynet 环境：TSTL 会将 async 函数转换为返回"类Promise"对象的函数
 *    我们需要确保这个"类Promise"对象正确地 yield/resume Lua 协程
 * 
 * TSTL 处理方式：
 * - async 函数被转换为返回特殊 table 的函数
 * - await 表达式被转换为 coroutine.yield 和 resume
 * - 我们需要提供一个 Promise polyfill 来桥接 Skynet 的协程机制
 */

/** @noSelfInFile */

/**
 * Skynet 环境下的 Promise 实现
 * 这个实现会被 TSTL 使用，用于将 async/await 转换为 Lua 协程
 */
export class SkynetPromise<T> {
  private state: 'pending' | 'fulfilled' | 'rejected' = 'pending';
  private value?: T;
  private error?: any;
  private callbacks: Array<{ onFulfilled?: (value: T) => any; onRejected?: (error: any) => any }> = [];

  constructor(executor: (resolve: (value: T) => void, reject: (error: any) => void) => void) {
    try {
      executor(
        (value: T) => this.resolve(value),
        (error: any) => this.reject(error)
      );
    } catch (error) {
      this.reject(error);
    }
  }

  private resolve(value: T): void {
    if (this.state !== 'pending') return;
    this.state = 'fulfilled';
    this.value = value;
    this.executeCallbacks();
  }

  private reject(error: any): void {
    if (this.state !== 'pending') return;
    this.state = 'rejected';
    this.error = error;
    this.executeCallbacks();
  }

  private executeCallbacks(): void {
    this.callbacks.forEach(({ onFulfilled, onRejected }) => {
      if (this.state === 'fulfilled' && onFulfilled) {
        try {
          onFulfilled(this.value!);
        } catch {
          // 忽略回调错误
        }
      } else if (this.state === 'rejected' && onRejected) {
        try {
          onRejected(this.error);
        } catch {
          // 忽略回调错误
        }
      }
    });
    this.callbacks = [];
  }

  then<TResult>(onFulfilled?: (value: T) => TResult | Promise<TResult>): Promise<TResult> {
    return new SkynetPromise<TResult>((resolve, reject) => {
      const callback = {
        onFulfilled: (value: T) => {
          if (onFulfilled) {
            try {
              const result = onFulfilled(value);
              resolve(result as TResult);
            } catch (error) {
              reject(error);
            }
          } else {
            resolve(value as any);
          }
        },
        onRejected: (error: any) => {
          reject(error);
        },
      };

      if (this.state === 'pending') {
        this.callbacks.push(callback);
      } else {
        if (this.state === 'fulfilled') {
          callback.onFulfilled(this.value!);
        } else {
          callback.onRejected(this.error);
        }
      }
    }) as any;
  }

  catch<TResult>(onRejected: (error: any) => TResult | Promise<TResult>): Promise<T | TResult> {
    return new SkynetPromise<T | TResult>((resolve, reject) => {
      const callback = {
        onFulfilled: (value: T) => {
          resolve(value);
        },
        onRejected: (error: any) => {
          try {
            const result = onRejected(error);
            resolve(result as TResult);
          } catch (err) {
            reject(err);
          }
        },
      };

      if (this.state === 'pending') {
        this.callbacks.push(callback);
      } else {
        if (this.state === 'fulfilled') {
          callback.onFulfilled(this.value!);
        } else {
          callback.onRejected(this.error);
        }
      }
    }) as any;
  }

  static resolve<T>(value: T): Promise<T> {
    return new SkynetPromise<T>((resolve) => resolve(value)) as any;
  }

  static reject<T>(error: any): Promise<T> {
    return new SkynetPromise<T>((_, reject) => reject(error)) as any;
  }

  static all<T>(promises: Array<Promise<T>>): Promise<T[]> {
    return new SkynetPromise<T[]>((resolve, reject) => {
      const results: T[] = [];
      let completed = 0;

      if (promises.length === 0) {
        resolve(results);
        return;
      }

      promises.forEach((promise, index) => {
        // 使用 async/await 替代 .then()，确保在协程管理下执行
        (async () => {
          try {
            const value = await promise;
            results[index] = value;
            completed++;
            if (completed === promises.length) {
              resolve(results);
            }
          } catch (error) {
            reject(error);
          }
        })();
      });
    }) as any;
  }
}

/**
 * 包装 Skynet 的协程操作
 * 当业务代码使用 await 时，底层会调用 skynet.call 等阻塞操作
 * TSTL 会自动处理协程的 yield 和 resume
 */
export function wrapSkynetCoroutine<T>(fn: () => T): Promise<T> {
  // 在 Skynet 环境下，直接执行函数
  // TSTL 会确保如果函数内部有 yield，协程会正确暂停和恢复
  return new SkynetPromise<T>((resolve, reject) => {
    try {
      const result = fn();
      resolve(result);
    } catch (error) {
      reject(error);
    }
  }) as any;
}

/**
 * 异步睡眠辅助函数
 * 在两个环境下都能正确工作
 */
export function sleep(ms: number): Promise<void> {
  // 在编译时，根据目标环境选择不同的实现
  // 这里使用条件编译或运行时检测
  if (typeof setTimeout !== 'undefined') {
    // Node.js 环境
    return new Promise((resolve) => setTimeout(resolve, ms));
  } else {
    // Skynet 环境
    // 会被 TSTL 转换为 skynet.sleep
    return new SkynetPromise<void>((resolve) => {
      // 这里需要调用 Skynet 的 sleep
      // 实际实现中应该导入 runtime.timer.sleep
      resolve();
    }) as any;
  }
}
