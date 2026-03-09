/**
 * 游戏服启动入口
 * 负责启动所有游戏服务
 */

/** @noSelfInFile */

import { runtime } from '../framework/core/interfaces';

/**
 * 服务配置
 */
interface ServiceConfig {
  name: string;
  path: string;
  count?: number;  // 服务实例数量，默认为 1
}

/**
 * 游戏服务配置列表
 */
const serviceConfigs: ServiceConfig[] = [
  { name: 'gateway', path: 'app/services/gateway/index', count: 1 },
  { name: 'login', path: 'app/services/login/index', count: 1 },
  { name: 'game', path: 'app/services/game/index', count: 2 },  // 启动2个游戏服务实例
];

/**
 * 启动所有服务
 */
async function startAllServices(): Promise<void> {
  const rt = runtime;
  rt.logger.info('========================================');
  rt.logger.info('    Game Server Bootstrap Starting     ');
  rt.logger.info('========================================');

  const startedServices: Array<{ name: string; address: string }> = [];

  for (const config of serviceConfigs) {
    const count = config.count || 1;
    
    for (let i = 0; i < count; i++) {
      try {
        rt.logger.info(`Starting service: ${config.name} (${i + 1}/${count})...`);
        
        // 使用 ts_launcher 启动 TS 服务
        const address = await rt.service.newService('ts_launcher', config.path);
        
        startedServices.push({
          name: `${config.name}-${i + 1}`,
          address,
        });
        
        rt.logger.info(`✓ Service ${config.name}-${i + 1} started: ${address}`);
        
        // 等待一小段时间，让服务完成初始化
        await rt.timer.sleep(100);
      } catch (error) {
        rt.logger.error(`✗ Failed to start service ${config.name}:`, error);
        throw error;
      }
    }
  }

  rt.logger.info('========================================');
  rt.logger.info('    All Services Started Successfully  ');
  rt.logger.info('========================================');
  rt.logger.info('Started services:');
  
  startedServices.forEach(({ name, address }) => {
    rt.logger.info(`  - ${name}: ${address}`);
  });
  
  rt.logger.info('========================================');
  rt.logger.info('    Game Server Ready!                 ');
  rt.logger.info('========================================');
}

/**
 * 启动所有服务（引导函数）
 */
async function bootstrap(): Promise<void> {
  await startAllServices();
  runtime.logger.info('========================================');
  runtime.logger.info('    Bootstrap completed                 ');
  runtime.logger.info('========================================');
}

// 启动服务
// ⚠️ 注意：start 回调必须是同步函数（禁止 async）
runtime.service.start(() => {
  // 启动异步引导流程，错误时退出服务
  bootstrap().catch((error) => {
    runtime.logger.error('Bootstrap failed:', error);
    runtime.service.exit();
  });

  // 【必须】保持主服务运行 - 使用纯协程方式，避免 Promise 回调问题
  const keepAlive = async () => {
    await runtime.timer.sleep(60000);
    runtime.logger.debug('[Main] Keep alive');
    keepAlive();
  };
  keepAlive();
});
