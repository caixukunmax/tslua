/**
 * Protocol Buffers 简化实现
 * Node.js 环境使用 JSON 序列化作为 fallback
 * Skynet 环境使用 lua-protobuf
 */

// ==================== ErrorCode 定义 ====================
export const ErrorCode = {
  SUCCESS: 0,
  UNKNOWN_ERROR: 1,
  INVALID_REQUEST: 2,
  UNAUTHORIZED: 3,
  FORBIDDEN: 4,
  NOT_FOUND: 5,
  TIMEOUT: 6,
  INTERNAL_ERROR: 7,
  SERVICE_UNAVAILABLE: 8,
} as const;

// ==================== 消息类型定义 ====================

// Common
export interface Packet {
  msgId: number;
  session: number;
  data: Uint8Array;
  timestamp: number;
}

// Login
export interface LoginRequest {
  username: string;
  password: string;
  deviceId?: string;
  platform?: string;
}

export interface LoginResponse {
  code: number;
  message: string;
  user?: UserInfo;
  token?: string;
}

export interface UserInfo {
  userId: number;
  username: string;
  loginTime: number;
  level?: number;
  exp?: number;
}

export interface LogoutRequest {
  userId: number;
}

export interface LogoutResponse {
  code: number;
  message: string;
}

export interface ValidateTokenRequest {
  token: string;
}

export interface ValidateTokenResponse {
  code: number;
  message: string;
  userId?: number;
  valid?: boolean;
}

export interface GetOnlineCountRequest {}

export interface GetOnlineCountResponse {
  count: number;
}

// Gateway
export interface HeartbeatRequest {
  clientTime: number;
}

export interface HeartbeatResponse {
  serverTime: number;
  clientTime: number;
}

export interface ConnectRequest {
  token: string;
  deviceId: string;
  platform: string;
}

export interface ConnectResponse {
  success: boolean;
  message?: string;
  sessionId?: string;
}

export interface DisconnectNotify {
  reason: string;
}

// Game
export interface EnterGameRequest {
  userId: number;
}

export interface EnterGameResponse {
  success: boolean;
  playerInfo?: PlayerInfo;
}

export interface LeaveGameRequest {
  userId: number;
}

export interface LeaveGameResponse {
  success: boolean;
}

export interface PlayerInfo {
  userId: number;
  username: string;
  level: number;
  exp: number;
  gold: number;
}

// ==================== 消息工厂 ====================

function createMessage<T>(defaults: T, init?: Partial<T>): T {
  return { ...defaults, ...init } as T;
}

function createEncoder<T>(message: T) {
  return {
    finish: (): Uint8Array => {
      const json = JSON.stringify(message);
      return new TextEncoder().encode(json);
    },
  };
}

function createDecoder<T>(data: Uint8Array): T {
  const json = new TextDecoder().decode(data);
  return JSON.parse(json) as T;
}

// ==================== Proto 对象 ====================

export const proto = {
  common: {
    ErrorCode,
    Packet: {
      create: (init?: Partial<Packet>): Packet =>
        createMessage({ msgId: 0, session: 0, data: new Uint8Array(), timestamp: 0 }, init),
      encode: (message: Packet) => createEncoder(message),
      decode: (data: Uint8Array): Packet => createDecoder<Packet>(data),
    },
  },
  login: {
    LoginRequest: {
      create: (init?: Partial<LoginRequest>): LoginRequest =>
        createMessage({ username: '', password: '', deviceId: '', platform: '' }, init),
      encode: (message: LoginRequest) => createEncoder(message),
      decode: (data: Uint8Array): LoginRequest => createDecoder<LoginRequest>(data),
    },
    LoginResponse: {
      create: (init?: Partial<LoginResponse>): LoginResponse =>
        createMessage({ code: 0, message: '', user: undefined, token: '' }, init),
      encode: (message: LoginResponse) => createEncoder(message),
      decode: (data: Uint8Array): LoginResponse => createDecoder<LoginResponse>(data),
    },
    UserInfo: {
      create: (init?: Partial<UserInfo>): UserInfo =>
        createMessage({ userId: 0, username: '', loginTime: 0 }, init),
      encode: (message: UserInfo) => createEncoder(message),
      decode: (data: Uint8Array): UserInfo => createDecoder<UserInfo>(data),
    },
    LogoutRequest: {
      create: (init?: Partial<LogoutRequest>): LogoutRequest =>
        createMessage({ userId: 0 }, init),
      encode: (message: LogoutRequest) => createEncoder(message),
      decode: (data: Uint8Array): LogoutRequest => createDecoder<LogoutRequest>(data),
    },
    LogoutResponse: {
      create: (init?: Partial<LogoutResponse>): LogoutResponse =>
        createMessage({ code: 0, message: '' }, init),
      encode: (message: LogoutResponse) => createEncoder(message),
      decode: (data: Uint8Array): LogoutResponse => createDecoder<LogoutResponse>(data),
    },
    ValidateTokenRequest: {
      create: (init?: Partial<ValidateTokenRequest>): ValidateTokenRequest =>
        createMessage({ token: '' }, init),
      encode: (message: ValidateTokenRequest) => createEncoder(message),
      decode: (data: Uint8Array): ValidateTokenRequest => createDecoder<ValidateTokenRequest>(data),
    },
    ValidateTokenResponse: {
      create: (init?: Partial<ValidateTokenResponse>): ValidateTokenResponse =>
        createMessage({ code: 0, message: '', userId: 0, valid: false }, init),
      encode: (message: ValidateTokenResponse) => createEncoder(message),
      decode: (data: Uint8Array): ValidateTokenResponse => createDecoder<ValidateTokenResponse>(data),
    },
    GetOnlineCountRequest: {
      create: (): GetOnlineCountRequest => ({}),
      encode: () => createEncoder({}),
      decode: (): GetOnlineCountRequest => ({}),
    },
    GetOnlineCountResponse: {
      create: (init?: Partial<GetOnlineCountResponse>): GetOnlineCountResponse =>
        createMessage({ count: 0 }, init),
      encode: (message: GetOnlineCountResponse) => createEncoder(message),
      decode: (data: Uint8Array): GetOnlineCountResponse => createDecoder<GetOnlineCountResponse>(data),
    },
  },
  gateway: {
    HeartbeatRequest: {
      create: (init?: Partial<HeartbeatRequest>): HeartbeatRequest =>
        createMessage({ clientTime: 0 }, init),
      encode: (message: HeartbeatRequest) => createEncoder(message),
      decode: (data: Uint8Array): HeartbeatRequest => createDecoder<HeartbeatRequest>(data),
    },
    HeartbeatResponse: {
      create: (init?: Partial<HeartbeatResponse>): HeartbeatResponse =>
        createMessage({ serverTime: 0, clientTime: 0 }, init),
      encode: (message: HeartbeatResponse) => createEncoder(message),
      decode: (data: Uint8Array): HeartbeatResponse => createDecoder<HeartbeatResponse>(data),
    },
    ConnectRequest: {
      create: (init?: Partial<ConnectRequest>): ConnectRequest =>
        createMessage({ token: '', deviceId: '', platform: '' }, init),
      encode: (message: ConnectRequest) => createEncoder(message),
      decode: (data: Uint8Array): ConnectRequest => createDecoder<ConnectRequest>(data),
    },
    ConnectResponse: {
      create: (init?: Partial<ConnectResponse>): ConnectResponse =>
        createMessage({ success: false, message: '', sessionId: '' }, init),
      encode: (message: ConnectResponse) => createEncoder(message),
      decode: (data: Uint8Array): ConnectResponse => createDecoder<ConnectResponse>(data),
    },
    DisconnectNotify: {
      create: (init?: Partial<DisconnectNotify>): DisconnectNotify =>
        createMessage({ reason: '' }, init),
      encode: (message: DisconnectNotify) => createEncoder(message),
      decode: (data: Uint8Array): DisconnectNotify => createDecoder<DisconnectNotify>(data),
    },
  },
  game: {
    EnterGameRequest: {
      create: (init?: Partial<EnterGameRequest>): EnterGameRequest =>
        createMessage({ userId: 0 }, init),
      encode: (message: EnterGameRequest) => createEncoder(message),
      decode: (data: Uint8Array): EnterGameRequest => createDecoder<EnterGameRequest>(data),
    },
    EnterGameResponse: {
      create: (init?: Partial<EnterGameResponse>): EnterGameResponse =>
        createMessage({ success: false, playerInfo: undefined }, init),
      encode: (message: EnterGameResponse) => createEncoder(message),
      decode: (data: Uint8Array): EnterGameResponse => createDecoder<EnterGameResponse>(data),
    },
    LeaveGameRequest: {
      create: (init?: Partial<LeaveGameRequest>): LeaveGameRequest =>
        createMessage({ userId: 0 }, init),
      encode: (message: LeaveGameRequest) => createEncoder(message),
      decode: (data: Uint8Array): LeaveGameRequest => createDecoder<LeaveGameRequest>(data),
    },
    LeaveGameResponse: {
      create: (init?: Partial<LeaveGameResponse>): LeaveGameResponse =>
        createMessage({ success: false }, init),
      encode: (message: LeaveGameResponse) => createEncoder(message),
      decode: (data: Uint8Array): LeaveGameResponse => createDecoder<LeaveGameResponse>(data),
    },
    PlayerInfo: {
      create: (init?: Partial<PlayerInfo>): PlayerInfo =>
        createMessage({ userId: 0, username: '', level: 0, exp: 0, gold: 0 }, init),
      encode: (message: PlayerInfo) => createEncoder(message),
      decode: (data: Uint8Array): PlayerInfo => createDecoder<PlayerInfo>(data),
    },
  },
};

// ==================== MessageId 定义 ====================

export const MessageId = {
  HEARTBEAT_REQ: 100,
  HEARTBEAT_RESP: 101,
  CONNECT_REQ: 102,
  CONNECT_RESP: 103,
  DISCONNECT_NOTIFY: 104,
  LOGIN_REQ: 200,
  LOGIN_RESP: 201,
  LOGOUT_REQ: 202,
  LOGOUT_RESP: 203,
  VALIDATE_TOKEN_REQ: 204,
  VALIDATE_TOKEN_RESP: 205,
  GET_ONLINE_COUNT_REQ: 206,
  GET_ONLINE_COUNT_RESP: 207,
  ENTER_GAME_REQ: 300,
  ENTER_GAME_RESP: 301,
  LEAVE_GAME_REQ: 302,
  LEAVE_GAME_RESP: 303,
} as const;

// ==================== MessageTypes 映射 ====================

export const MessageTypes: Record<number, string> = {
  // Gateway
  100: 'gateway.HeartbeatRequest',
  101: 'gateway.HeartbeatResponse',
  102: 'gateway.ConnectRequest',
  103: 'gateway.ConnectResponse',
  104: 'gateway.DisconnectNotify',
  // Login
  200: 'login.LoginRequest',
  201: 'login.LoginResponse',
  202: 'login.LogoutRequest',
  203: 'login.LogoutResponse',
  204: 'login.ValidateTokenRequest',
  205: 'login.ValidateTokenResponse',
  206: 'login.GetOnlineCountRequest',
  207: 'login.GetOnlineCountResponse',
  // Game
  300: 'game.EnterGameRequest',
  301: 'game.EnterGameResponse',
  302: 'game.LeaveGameRequest',
  303: 'game.LeaveGameResponse',
};

export default proto;
