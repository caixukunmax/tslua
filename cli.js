#!/usr/bin/env node
/**
 * TS-Skynet 跨平台 CLI 入口
 * 用法: node cli.js [command] [options]
 * 或:   npm run cli -- [command]
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const cliScript = path.join(__dirname, 'server/scripts/cli/index.ts');
const isWin = process.platform === 'win32';

// 检测可用的运行器
function getRunner() {
  const serverDir = path.join(__dirname, 'server');
  
  // 优先尝试 tsx（最快）
  const tsxPath = path.join(serverDir, 'node_modules/.bin/tsx');
  const tsxWinPath = tsxPath + '.cmd';
    
  if (fs.existsSync(tsxWinPath)) {
    return { cmd: 'cmd', args: ['/c', tsxWinPath, cliScript] };
  }
  if (fs.existsSync(tsxPath)) {
    return { cmd: tsxPath, args: [cliScript] };
  }

  // 回退到 ts-node
  const tsNodePath = path.join(serverDir, 'node_modules/.bin/ts-node');
  const tsNodeWinPath = tsNodePath + '.cmd';
    
  if (fs.existsSync(tsNodeWinPath)) {
    return { cmd: 'cmd', args: ['/c', tsNodeWinPath, cliScript] };
  }
  if (fs.existsSync(tsNodePath)) {
    return { cmd: tsNodePath, args: [cliScript] };
  }

  // 最后尝试全局 npx
  return { cmd: isWin ? 'npx.cmd' : 'npx', args: ['tsx', cliScript] };
}

const { cmd, args } = getRunner();
const child = spawn(cmd, [...args, ...process.argv.slice(2)], {
  stdio: 'inherit',
  cwd: path.join(__dirname, 'server'),
});

child.on('error', (err) => {
  console.error('启动失败:', err.message);
  console.error('请确保已安装依赖: npm install');
  process.exit(1);
});

child.on('close', (code) => process.exit(code || 0));
