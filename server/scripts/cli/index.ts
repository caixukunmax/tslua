#!/usr/bin/env node
/**
 * TS-Skynet 跨平台 CLI 工具
 * 支持 Windows、Linux、macOS
 * 
 * 用法: npx tsx scripts/cli/index.ts <command> [options]
 * 或:   node scripts/cli/index.js <command> [options]
 */

import * as fs from 'fs';
import * as path from 'path';
import { spawn, execSync } from 'child_process';
import * as readline from 'readline';
import * as yaml from 'js-yaml';

// 颜色输出（跨平台，不依赖外部包）
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m',
};

const c = {
  red: (s: string) => `${colors.red}${s}${colors.reset}`,
  green: (s: string) => `${colors.green}${s}${colors.reset}`,
  yellow: (s: string) => `${colors.yellow}${s}${colors.reset}`,
  blue: (s: string) => `${colors.blue}${s}${colors.reset}`,
  cyan: (s: string) => `${colors.cyan}${s}${colors.reset}`,
  gray: (s: string) => `${colors.gray}${s}${colors.reset}`,
};

// 路径配置
const SCRIPT_DIR = __dirname;
const SERVER_DIR = path.resolve(SCRIPT_DIR, '../..');
const PROJECT_ROOT = path.resolve(SERVER_DIR, '..');

// 工具函数（提前定义，供配置加载使用）
function log(msg: string) { console.log(msg); }
function info(msg: string) { console.log(c.cyan(`[INFO] ${msg}`)); }
function success(msg: string) { console.log(c.green(`[SUCCESS] ${msg}`)); }
function warn(msg: string) { console.log(c.yellow(`[WARN] ${msg}`)); }
function error(msg: string) { console.error(c.red(`[ERROR] ${msg}`)); }

// 配置文件管理
interface Config {
  name?: string;
  version?: string;
  paths?: {
    server?: string;
    docker?: string;
    protocols?: string;
    tables?: string;
  };
  build?: {
    sourceDir?: string;
    targetDir?: string;
    protoOutput?: string;
    tableOutput?: string;
  };
  docker?: {
    composeFile?: string;
    serviceName?: string;
    containerName?: string;
  };
}

// 默认配置
function getDefaultConfig(): Config {
  return {
    paths: {
      server: './server',
      docker: './docker',
      protocols: './protocols',
      tables: './tables'
    },
    build: {
      sourceDir: './server/dist/lua',
      targetDir: './docker/lua'
    },
    docker: {
      composeFile: './docker/compose.yml',
      serviceName: 'skynet',
      containerName: 'tslua-skynet'
    }
  };
}

// 解析命令行参数
function parseArgs(): { configFile?: string; options: Record<string, string> } {
  const args = process.argv.slice(2);
  let configFile: string | undefined;
  const options: Record<string, string> = {};
  
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    
    // --config=xxx 或 --config xxx 格式
    if (arg === '--config' && i + 1 < args.length) {
      configFile = args[++i];
    } else if (arg.startsWith('--config=')) {
      configFile = arg.slice(9);
    }
    // 其他 --key=value 参数
    else if (arg.startsWith('--')) {
      const eqIndex = arg.indexOf('=');
      if (eqIndex > 2) {
        const key = arg.slice(2, eqIndex);
        const value = arg.slice(eqIndex + 1);
        options[key] = value;
      }
    }
  }
  
  return { configFile, options };
}

// 加载配置
function loadConfig(explicitConfigFile?: string): Config {
  const defaultConfig = getDefaultConfig();
  
  // 如果显式指定了配置文件，优先使用
  if (explicitConfigFile) {
    const configPath = path.isAbsolute(explicitConfigFile) 
      ? explicitConfigFile 
      : path.join(PROJECT_ROOT, explicitConfigFile);
    
    if (!fs.existsSync(configPath)) {
      error(`指定的配置文件不存在: ${explicitConfigFile}`);
      error(`完整路径: ${configPath}`);
      process.exit(1);
    }
    
    try {
      const content = fs.readFileSync(configPath, 'utf-8');
      const ext = path.extname(configPath).toLowerCase();
      const isYaml = ext === '.yaml' || ext === '.yml';
      const userConfig = isYaml ? yaml.load(content) : JSON.parse(content);
      info(`已加载配置: ${explicitConfigFile}`);
      return { ...defaultConfig, ...userConfig };
    } catch (e) {
      error(`配置文件解析失败: ${explicitConfigFile}`);
      error(`错误: ${e}`);
      process.exit(1);
    }
  }
  
  // 自动查找默认配置文件
  const yamlPath = path.join(PROJECT_ROOT, 'tslua.config.yaml');
  const ymlPath = path.join(PROJECT_ROOT, 'tslua.config.yml');
  const jsonPath = path.join(PROJECT_ROOT, 'tslua.config.json');
  
  let configPath: string | null = null;
  let configType: 'yaml' | 'json' | null = null;
  
  if (fs.existsSync(yamlPath)) {
    configPath = yamlPath;
    configType = 'yaml';
  } else if (fs.existsSync(ymlPath)) {
    configPath = ymlPath;
    configType = 'yaml';
  } else if (fs.existsSync(jsonPath)) {
    configPath = jsonPath;
    configType = 'json';
  }
  
  if (configPath) {
    try {
      const content = fs.readFileSync(configPath, 'utf-8');
      let userConfig: Config;
      
      if (configType === 'yaml') {
        userConfig = yaml.load(content) as Config;
      } else {
        userConfig = JSON.parse(content);
      }
      
      const fileName = path.basename(configPath);
      info(`已加载配置: ${fileName}`);
      return { ...defaultConfig, ...userConfig };
    } catch (e) {
      warn(`配置文件解析失败: ${configPath}`);
      warn(`错误: ${e}`);
      warn(`使用默认配置`);
      return defaultConfig;
    }
  }
  
  return defaultConfig;
}

// 先解析命令行参数（提取 --config 和其他选项）
const PARSED_ARGS = (() => {
  const args = process.argv.slice(2);
  let configFile: string | undefined = process.env.TSLUA_CONFIG;  // 支持环境变量
  const options: Record<string, string> = {};
  
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    
    // --config=xxx 或 --config xxx 格式
    if (arg === '--config' && i + 1 < args.length) {
      configFile = args[++i];
    } else if (arg.startsWith('--config=')) {
      configFile = arg.slice(9);
    }
    // 其他 --key=value 参数
    else if (arg.startsWith('--')) {
      const eqIndex = arg.indexOf('=');
      if (eqIndex > 2) {
        const key = arg.slice(2, eqIndex);
        const value = arg.slice(eqIndex + 1);
        options[key] = value;
      }
    }
  }
  
  return { configFile, options };
})();

// 加载配置（传入显式指定的配置文件路径）
const CONFIG = loadConfig(PARSED_ARGS.configFile);

// 获取路径（优先级: 命令行参数 > 配置文件 > 默认值）
function getPath(key: keyof Config['paths'] | keyof Config['build'] | keyof Config['docker'], type: 'paths' | 'build' | 'docker'): string {
  const cliKey = `${type}.${key}`;
  if (PARSED_ARGS.options[cliKey]) {
    return path.resolve(PROJECT_ROOT, PARSED_ARGS.options[cliKey]);
  }
  const configValue = CONFIG[type]?.[key as any];
  return path.resolve(PROJECT_ROOT, configValue || '');
}

// 计算最终路径
const SERVER_DIR_CFG = getPath('server', 'paths');
const DOCKER_DIR = getPath('docker', 'paths');
const SOURCE_LUA_DIR = getPath('sourceDir', 'build');
const TARGET_LUA_DIR = getPath('targetDir', 'build');
const COMPOSE_FILE = getPath('composeFile', 'docker');

function exec(cmd: string, args: string[] = [], options: any = {}): Promise<number> {
  return new Promise((resolve) => {
    const isWindows = process.platform === 'win32';
    const shell = isWindows ? 'cmd' : 'bash';
    const shellFlag = isWindows ? '/c' : '-c';
    
    // 使用 shell 执行命令以支持跨平台
    const fullCmd = isWindows ? cmd + ' ' + args.join(' ') : `${cmd} ${args.map(a => `"${a}"`).join(' ')}`;
    
    const child = spawn(shell, [shellFlag, fullCmd], {
      stdio: 'inherit',
      cwd: options.cwd || SERVER_DIR,
      env: { ...process.env, ...options.env },
    });
    
    child.on('close', (code) => resolve(code || 0));
  });
}

function execOutput(cmd: string, options: any = {}): string {
  try {
    return execSync(cmd, { 
      encoding: 'utf-8', 
      cwd: options.cwd || SERVER_DIR,
      stdio: ['pipe', 'pipe', 'pipe']
    }).trim();
  } catch (e) {
    return '';
  }
}

function exists(p: string): boolean {
  return fs.existsSync(p);
}

// 递归复制目录（跨平台）
function copyDirSync(src: string, dest: string) {
  // 确保目标目录存在
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }
  
  const entries = fs.readdirSync(src, { withFileTypes: true });
  
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    
    if (entry.isDirectory()) {
      copyDirSync(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

// 命令实现
const commands: Record<string, { desc: string; fn: () => Promise<void> }> = {
  menu: {
    desc: '显示交互式菜单（默认）',
    fn: showMenu,
  },
  quick: {
    desc: '一键启动（自动检查 + 构建 + 启动）',
    fn: cmdQuickStart,
  },
  start: {
    desc: '启动 Skynet 服务',
    fn: cmdStart,
  },
  stop: {
    desc: '停止 Skynet 服务',
    fn: cmdStop,
  },
  restart: {
    desc: '重启 Skynet 服务',
    fn: cmdRestart,
  },
  status: {
    desc: '查看服务状态',
    fn: cmdStatus,
  },
  logs: {
    desc: '查看服务日志',
    fn: cmdLogs,
  },
  'build:ts': {
    desc: '编译 TypeScript → Lua',
    fn: cmdBuildTS,
  },
  'build:all': {
    desc: '完整构建（Proto + Tables + TS）',
    fn: cmdBuildAll,
  },
  'build:clean': {
    desc: '清理构建产物',
    fn: cmdClean,
  },
  dev: {
    desc: 'Node.js 开发模式',
    fn: cmdDev,
  },
  setup: {
    desc: '初始化项目环境',
    fn: cmdSetup,
  },
  hotfix: {
    desc: '热更新服务代码',
    fn: cmdHotfix,
  },
};

// 菜单显示
function showBanner() {
  log(c.cyan('╔════════════════════════════════════════════════════════════╗'));
  log(c.cyan('║                                                            ║'));
  log(c.cyan('║         ') + c.blue('TS-Skynet 跨平台 CLI 工具') + c.cyan('                     ║'));
  log(c.cyan('║                                                            ║'));
  log(c.cyan('╠════════════════════════════════════════════════════════════╣'));
}

async function showMenu() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const ask = (q: string): Promise<string> => new Promise(resolve => rl.question(q, resolve));

  while (true) {
    console.clear();
    showBanner();
    log(c.cyan('║  ') + c.green('1. 一键启动') + c.cyan(' (自动检查 + 构建 + 启动)             ║'));
    log(c.cyan('║  ') + c.green('2. 启动服务') + c.cyan(' (自动检查依赖)                       ║'));
    log(c.cyan('║  ') + c.green('3. 停止服务') + c.cyan('                                             ║'));
    log(c.cyan('║  ') + c.green('4. 重启服务') + c.cyan('                                             ║'));
    log(c.cyan('║  ') + c.green('5. 查看状态') + c.cyan('                                             ║'));
    log(c.cyan('║  ') + c.green('6. 热更新服务') + c.cyan('                                           ║'));
    log(c.cyan('║  ') + c.green('7. Node.js 模式') + c.cyan(' (开发调试)                            ║'));
    log(c.cyan('║  ') + c.green('8. 编译 TS→Lua') + c.cyan('                                          ║'));
    log(c.cyan('║  ') + c.green('9. 完整构建') + c.cyan(' (Proto+Luban+TS)                       ║'));
    log(c.cyan('║  ') + c.green('10. 清理构建产物') + c.cyan('                                        ║'));
    log(c.cyan('║  ') + c.yellow('0. 退出') + c.cyan('                                                 ║'));
    log(c.cyan('╠════════════════════════════════════════════════════════════╣'));
    log(c.cyan('║  ') + c.blue('快捷命令: q=退出, s=状态, h=热更新, b=编译, l=日志') + c.cyan('      ║'));
    log(c.cyan('╚════════════════════════════════════════════════════════════╝'));
    log('');
    
    const choice = await ask(c.cyan('请选择操作: '));
    
    switch (choice.trim()) {
      case '1': await cmdQuickStart(); await ask('按回车继续...'); break;
      case '2': await cmdStart(); await ask('按回车继续...'); break;
      case '3': await cmdStop(); await ask('按回车继续...'); break;
      case '4': await cmdRestart(); await ask('按回车继续...'); break;
      case '5': await cmdStatus(); await ask('按回车继续...'); break;
      case '6': await cmdHotfix(); await ask('按回车继续...'); break;
      case '7': await cmdDev(); await ask('按回车继续...'); break;
      case '8': await cmdBuildTS(); await ask('按回车继续...'); break;
      case '9': await cmdBuildAll(); await ask('按回车继续...'); break;
      case '10': await cmdClean(); await ask('按回车继续...'); break;
      case '0':
      case 'q':
      case 'Q':
        log(c.green('再见!'));
        rl.close();
        return;
      case 's':
      case 'S': await cmdStatus(); await ask('按回车继续...'); break;
      case 'h':
      case 'H': await cmdHotfix(); await ask('按回车继续...'); break;
      case 'b':
      case 'B': await cmdBuildTS(); await ask('按回车继续...'); break;
      case 'l':
      case 'L': await cmdLogs(); break;
      default:
        error('无效选择，请重试');
        await new Promise(r => setTimeout(r, 1000));
    }
  }
}

// 命令实现
async function cmdQuickStart() {
  info('一键启动...');
  const buildSuccess = await cmdBuildTS();
  if (!buildSuccess) {
    error('编译失败，停止启动');
    return;
  }
  const code = await exec('docker', ['compose', '-f', 'compose.yml', 'up', '-d', 'skynet'], { cwd: DOCKER_DIR });
  if (code === 0) {
    success('服务已启动');
    info('查看日志: docker compose logs -f skynet');
  } else {
    error(`Docker 启动失败 (exit code: ${code})`);
    info('可能原因：');
    info('  1. Docker Desktop 未启动');
    info('  2. 网络问题无法拉取镜像');
    info('  3. 端口被占用');
  }
}

async function cmdStart() {
  info('启动 Skynet Docker 服务...');
  if (!exists(path.join(SERVER_DIR, 'dist/lua'))) {
    warn('Lua 文件未编译，正在编译...');
    const buildSuccess = await cmdBuildTS();
    if (!buildSuccess) {
      error('编译失败，停止启动');
      return;
    }
  }
  const code = await exec('docker', ['compose', '-f', 'compose.yml', 'up', '-d', 'skynet'], { cwd: DOCKER_DIR });
  if (code === 0) {
    success('服务已启动');
  } else {
    error(`Docker 启动失败 (exit code: ${code})`);
  }
}

async function cmdStop() {
  info('停止 Docker 服务...');
  await exec('docker', ['compose', 'down'], { cwd: DOCKER_DIR });
  success('服务已停止');
}

async function cmdRestart() {
  info('重启 Docker 服务...');
  await exec('docker', ['compose', 'restart', 'skynet'], { cwd: DOCKER_DIR });
  success('服务已重启');
}

async function cmdStatus() {
  info('Docker 服务状态:');
  await exec('docker', ['compose', 'ps', 'skynet'], { cwd: DOCKER_DIR });
  
  log('\n容器状态:');
  const output = execOutput('docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"', { cwd: DOCKER_DIR });
  const lines = output.split('\n').filter(l => l.includes('tslua'));
  if (lines.length > 0) {
    lines.forEach(l => log(l));
  } else {
    warn('没有运行中的 tslua 容器');
  }
}

async function cmdLogs() {
  info('查看日志 (按 Ctrl+C 退出)...');
  await exec('docker', ['compose', 'logs', '--tail=50', '-f', 'skynet'], { cwd: DOCKER_DIR });
}

async function cmdBuildTS(): Promise<boolean> {
  info('编译 TypeScript → Lua...');
  // 检查依赖（可能在根目录或 server 目录）
  const rootTstlPath = path.join(PROJECT_ROOT, 'node_modules/.bin/tstl');
  const serverTstlPath = path.join(SERVER_DIR_CFG, 'node_modules/.bin/tstl');
  const hasTstl = exists(rootTstlPath) || exists(rootTstlPath + '.cmd') || 
                  exists(serverTstlPath) || exists(serverTstlPath + '.cmd');
  if (!hasTstl) {
    error('缺少依赖，请先安装: npm install');
    return false;
  }
  
  const code = await exec('npx', ['tstl', '--project', 'config/tsconfig.lua.json'], { cwd: SERVER_DIR_CFG });
  if (code === 0) {
    success('编译完成 → dist/lua/');
    // 自动复制到 docker/lua/ 目录
    await copyLuaToDocker();
    return true;
  } else {
    error('编译失败');
    return false;
  }
}

async function copyLuaToDocker() {
  info('复制 Lua 文件到 docker/lua/...');
  const sourceDir = SOURCE_LUA_DIR;
  const targetDir = TARGET_LUA_DIR;
  
  if (!exists(sourceDir)) {
    warn('源目录不存在: dist/lua/');
    return;
  }
  
  try {
    // 清空目标目录（避免旧文件残留）
    if (exists(targetDir)) {
      fs.rmSync(targetDir, { recursive: true, force: true });
    }
    fs.mkdirSync(targetDir, { recursive: true });
    
    // 使用 Node.js 递归复制（跨平台）
    copyDirSync(sourceDir, targetDir);
    
    // 统计文件数
    const countFiles = (dir: string): number => {
      let count = 0;
      const entries = fs.readdirSync(dir, { withFileTypes: true });
      for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
          count += countFiles(fullPath);
        } else {
          count++;
        }
      }
      return count;
    };
    
    const fileCount = countFiles(targetDir);
    success(`已复制 ${fileCount} 个文件到 docker/lua/`);
  } catch (e) {
    warn(`复制失败: ${e}`);
  }
}

async function cmdBuildAll() {
  info('完整构建 (Proto + Tables + TS)...');
  // Proto
  info('编译 protobuf...');
  await exec('npm', ['run', 'build'], { cwd: path.join(PROJECT_ROOT, 'protocols') });
  // Tables
  info('编译 Luban 配置表...');
  await exec('npm', ['run', 'build'], { cwd: path.join(PROJECT_ROOT, 'tables') });
  // TS
  await cmdBuildTS();
  success('完整构建完成');
}

async function cmdClean() {
  info('清理构建产物...');
  const distLua = path.join(SERVER_DIR, 'dist/lua');
  if (exists(distLua)) {
    fs.rmSync(distLua, { recursive: true, force: true });
  }
  success('清理完成');
}

async function cmdDev() {
  info('启动 Node.js 开发模式...');
  await exec('npx', ['ts-node', 'src/app/bootstrap-node.ts'], { cwd: SERVER_DIR });
}

async function cmdSetup() {
  info('初始化项目环境...');
  
  // 创建目录
  const dirs = ['dist/lua', 'logs', 'tmp'];
  dirs.forEach(dir => {
    const fullPath = path.join(SERVER_DIR, dir);
    if (!exists(fullPath)) {
      fs.mkdirSync(fullPath, { recursive: true });
      info(`创建目录: ${dir}`);
    }
  });
  
  // 检查 npm
  try {
    execSync('npm --version', { stdio: 'ignore' });
  } catch {
    error('未找到 npm，请先安装 Node.js');
    return;
  }
  
  // 安装依赖
  if (!exists(path.join(SERVER_DIR, 'node_modules'))) {
    info('安装 npm 依赖...');
    await exec('npm', ['install'], { cwd: SERVER_DIR });
  }
  
  // 检查 Docker
  const dockerVersion = execOutput('docker --version');
  if (dockerVersion) {
    info(`Docker 已安装: ${dockerVersion}`);
  } else {
    warn('未找到 Docker，Docker 功能将不可用');
  }
  
  success('项目初始化完成!');
  info('下一步:');
  info('  开发模式: npm run dev');
  info('  Docker模式: npm run server:start');
}

async function cmdHotfix() {
  info('热更新服务代码...');
  await cmdBuildTS();
  // 复制到容器
  const container = execOutput('docker ps --format "{{.Names}}" | findstr "tslua-skynet"') || 
                    execOutput('docker ps --format "{{.Names}}" | grep "tslua-skynet"');
  if (container) {
    info(`部署到容器: ${container}`);
    await exec('docker', ['cp', 'dist/lua/.', `${container}:/skynet/service-ts/`], { cwd: SERVER_DIR });
    success('热更新完成');
  } else {
    warn('容器未运行，跳过部署');
  }
}

// 主函数
async function main() {
  const args = process.argv.slice(2);
  const cmd = args[0] || 'menu';
  
  if (cmd === 'help' || cmd === '-h' || cmd === '--help') {
    log(c.cyan('TS-Skynet 跨平台 CLI 工具\n'));
    log('用法: npm run cli -- <命令>\n');
    log('命令:');
    Object.entries(commands).forEach(([name, { desc }]) => {
      log(`  ${c.green(name.padEnd(12))} ${desc}`);
    });
    log('\n示例:');
    log(`  ${c.cyan('npm run cli')}                    # 显示交互式菜单`);
    log(`  ${c.cyan('npm run cli -- quick')}           # 一键启动`);
    log(`  ${c.cyan('npm run cli -- status')}          # 查看状态`);
    log(`  ${c.cyan('npm run cli -- build:ts')}        # 编译 TS→Lua`);
    return;
  }
  
  const command = commands[cmd];
  if (command) {
    try {
      await command.fn();
    } catch (e) {
      error(`命令执行失败: ${e}`);
      process.exit(1);
    }
  } else {
    error(`未知命令: ${cmd}`);
    log(`运行 "npm run cli -- help" 查看帮助`);
    process.exit(1);
  }
}

main();
