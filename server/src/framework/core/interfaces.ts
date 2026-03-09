/**
 * 核心抽象接口层
 * 所有业务代码必须依赖这些接口，而不是直接依赖 Node.js 或 Skynet API
 */

/**
 * 日志接口
 */
export interface ILogger {
  debug(message: string, ...args: any[]): void;
  info(message: string, ...args: any[]): void;
  warn(message: string, ...args: any[]): void;
  error(message: string, ...args: any[]): void;
}

/**
 * 定时器接口
 */
export interface ITimer {
  /**
   * 延迟执行
   * @param ms 延迟毫秒数
   * @param callback 回调函数
   * @returns 定时器句柄
   */
  setTimeout(ms: number, callback: () => void): any;

  /**
   * 取消定时器
   */
  clearTimeout(handle: any): void;

  /**
   * 睡眠
   * @param ms 睡眠毫秒数
   */
  sleep(ms: number): Promise<void>;

  /**
   * 获取当前时间戳（秒）
   */
  now(): number;

  /**
   * 协程安全的 setTimeout
   * 回调函数会在 Skynet 协程中执行，内部可以使用 async/await
   * @param callback 回调函数（可以是 async）
   * @param ms 延迟毫秒数
   */
  safeTimeout(callback: () => void | Promise<void>, ms?: number): void;

  /**
   * 协程安全的 setImmediate
   * 回调函数会在 Skynet 协程中执行，内部可以使用 async/await
   * @param callback 回调函数（可以是 async）
   */
  safeImmediate(callback: () => void | Promise<void>): void;
}

/**
 * 网络接口
 */
export interface INetwork {
  /**
   * 发送消息（不等待响应）
   */
  send(address: string, messageType: string, ...args: any[]): void;

  /**
   * 调用远程服务（等待响应）
   */
  call(address: string, messageType: string, ...args: any[]): Promise<any>;

  /**
   * 注册消息处理器
   */
  dispatch(messageType: string, handler: (session: number, source: string, ...args: any[]) => void | Promise<void>): void;

  /**
   * 返回响应
   */
  ret(...args: any[]): void;
}

/**
 * 数据库接口
 */
export interface IDatabase {
  /**
   * 查询
   */
  query(sql: string, params?: any[]): Promise<any[]>;

  /**
   * 执行
   */
  execute(sql: string, params?: any[]): Promise<number>;

  /**
   * 事务
   */
  transaction(callback: (db: IDatabase) => Promise<void>): Promise<void>;
}

/**
 * 服务接口
 */
export interface IService {
  /**
   * 启动服务
   */
  start(callback: () => void | Promise<void>): void;

  /**
   * 退出服务
   */
  exit(): void;

  /**
   * 创建新服务
   */
  newService(name: string, ...args: any[]): Promise<string>;

  /**
   * 获取当前服务地址
   */
  self(): string;

  /**
   * 获取环境变量
   */
  getenv(key: string): string | undefined;

  /**
   * 设置环境变量
   */
  setenv(key: string, value: string): void;
}

/**
 * Protocol Buffer 编解码接口
 * 统一不同环境的 protobuf 操作
 */
export interface IPbCodec {
  /**
   * 编码消息
   * @param messageType 消息类型名 (如 "login.LoginRequest")
   * @param message 消息对象
   * @returns 编码后的 Uint8Array
   */
  encode(messageType: string, message: any): Uint8Array;

  /**
   * 解码消息
   * @param messageType 消息类型名
   * @param data 编码后的数据
   * @returns 解码后的消息对象
   */
  decode(messageType: string, data: Uint8Array): any;

  /**
   * 创建消息对象
   * @param messageType 消息类型名
   * @param init 初始化数据
   */
  create(messageType: string, init?: any): any;

  /**
   * 打包 Packet 消息
   * @param msgId 消息ID
   * @param messageType 消息类型名
   * @param message 消息对象
   * @param session 会话ID
   */
  pack(msgId: number, messageType: string, message: any, session?: number): Uint8Array;

  /**
   * 解包 Packet 消息
   * @param data Packet 数据
   * @returns { msgId, messageType, message, session }
   */
  unpack(data: Uint8Array): { msgId: number; messageType: string; message: any; session: number };
}

/**
 * 运行时上下文
 * 统一不同环境的接口访问
 */
export interface IRuntime {
  logger: ILogger;
  timer: ITimer;
  network: INetwork;
  service: IService;
  database?: IDatabase;
  codec?: IPbCodec;
}

/**
 * 运行时环境类型
 */
export enum RuntimeEnvironment {
  NODE = 'node',
  SKYNET = 'skynet',
}

/**
 * 全局运行时实例
 * 注意：由于 TSTL 的模块缓存机制，需要使用可变对象
 */
const _runtime: IRuntime = {} as any;
export { _runtime as runtime };

/**
 * 设置运行时
 */
export function setRuntime(rt: IRuntime): void {
  // 复制所有属性到 runtime 对象
  const r = _runtime as any;
  r.logger = rt.logger;
  r.timer = rt.timer;
  r.network = rt.network;
  r.service = rt.service;
  r.database = rt.database;
  r.codec = rt.codec;  // 添加 codec 属性
}
