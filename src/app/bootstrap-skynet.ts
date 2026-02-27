/**
 * Skynet 环境入口文件
 * 初始化 Skynet 运行时并启动服务
 */

import { setRuntime } from '../framework/core/interfaces';
import { createSkynetRuntime } from '../framework/runtime/skynet-adapter';

// 初始化 Skynet 运行时
setRuntime(createSkynetRuntime());

// 预加载服务模块（可选，用于热更新）
require('./services/gateway/index');
require('./services/login/index');
require('./services/game/index');

// Skynet 服务会通过 skynet.start() 在各自的文件中启动
