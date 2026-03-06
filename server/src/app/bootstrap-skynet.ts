/**
 * Skynet 环境入口文件
 * 初始化 Skynet 运行时并启动服务
 */

import { setRuntime } from '../framework/core/interfaces';
import { createSkynetRuntime } from '../framework/runtime/skynet-adapter';

// 声明 Lua 全局变量
declare const _G: any;

// 初始化 Skynet 运行时
setRuntime(createSkynetRuntime());

// 预加载服务模块（使用 _G.require 绕过 TSTL 转换）
_G.require('app.services.gateway.index');

// Skynet 服务通过 runtime.service:start() 启动
// 服务需要保持活动状态，否则 Skynet 会自动退出
