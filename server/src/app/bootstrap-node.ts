/**
 * Node.js 环境启动入口（用于测试）
 */

import { setRuntime } from '../framework/core/interfaces';
import { createNodeRuntime } from '../framework/runtime/node-adapter';

// 设置 Node.js 运行时
setRuntime(createNodeRuntime());

// 导入要测试的服务（它们会自动启动）
import './services/gateway';
import './services/login';
import './services/game';

console.log('========================================');
console.log('  Game Server Starting (Node.js Mode)  ');
console.log('========================================');

// Node.js 模式下，import 已经触发了 top-level 的 runtime.service.start()
// 因为 NodeService.start 是异步的 (setImmediate)，所以它们会排队启动
