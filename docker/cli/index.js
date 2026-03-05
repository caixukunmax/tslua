#!/usr/bin/env node
/**
 * TS-Skynet Docker 远程管理工具 - 简化版
 * 不依赖外部 UI 库，使用 Node.js 内置模块
 */

const readline = require('readline');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// 清屏函数
function clearScreen() {
  console.clear();
}

// 颜色输出
const c = {
  cyan: (s) => `\x1b[36m${s}\x1b[0m`,
  green: (s) => `\x1b[32m${s}\x1b[0m`,
  red: (s) => `\x1b[31m${s}\x1b[0m`,
  yellow: (s) => `\x1b[33m${s}\x1b[0m`,
  gray: (s) => `\x1b[90m${s}\x1b[0m`,
  white: (s) => `\x1b[37m${s}\x1b[0m`,
};

// 配置文件
const CONFIG_PATH = path.join(__dirname, 'config.json');
const defaultConfig = {
  remote: {
    host: '10.0.0.169',
    port: 22,
    username: 'root',
    privateKey: '~/.ssh/id_rsa',
  },
  docker: {
    containerName: 'tslua-skynet',
    imageName: 'tslua-skynet-runtime',
    remoteLuaPath: '/skynet/lua',
    localLuaPath: '../lua'  // 相对于 cli 目录，或外部传入
  }
};

function loadConfig() {
  try {
    if (fs.existsSync(CONFIG_PATH)) {
      return JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf-8'));
    }
  } catch (e) {}
  return { ...defaultConfig };
}

function saveConfig(config) {
  fs.writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2));
}

// 执行命令
function exec(cmd, cwd) {
  return new Promise((resolve, reject) => {
    const child = spawn(cmd, { shell: true, cwd, stdio: 'pipe' });
    let stdout = '', stderr = '';
    child.stdout.on('data', d => stdout += d);
    child.stderr.on('data', d => stderr += d);
    child.on('close', code => {
      if (code === 0) resolve(stdout.trim());
      else reject(stderr.trim() || `Exit code ${code}`);
    });
  });
}

// Docker 管理器
class DockerManager {
  constructor(config) {
    this.config = config;
  }

  sshPrefix() {
    const { host, port, username, privateKey } = this.config.remote;
    let cmd = `ssh -p ${port} `;
    if (privateKey) cmd += `-i ${privateKey} `;
    cmd += `${username}@${host}`;
    return cmd;
  }

  async checkStatus() {
    const cmd = `${this.sshPrefix()} "docker ps --filter \\"name=${this.config.docker.containerName}\\" --format \\"{{.Status}}\\""`;
    try {
      const result = await exec(cmd);
      return result || 'stopped';
    } catch (e) {
      return 'error';
    }
  }

  async start() {
    const cmd = `${this.sshPrefix()} "docker start ${this.config.docker.containerName}"`;
    return exec(cmd);
  }

  async stop() {
    const cmd = `${this.sshPrefix()} "docker stop ${this.config.docker.containerName}"`;
    return exec(cmd);
  }

  async restart() {
    const cmd = `${this.sshPrefix()} "docker restart ${this.config.docker.containerName}"`;
    return exec(cmd);
  }

  async logs(tail = 30) {
    const cmd = `${this.sshPrefix()} "docker logs --tail=${tail} ${this.config.docker.containerName}"`;
    return exec(cmd);
  }

  async syncCode() {
    const { localLuaPath, containerName, remoteLuaPath } = this.config.docker;
    const { host, port, username, privateKey } = this.config.remote;
    
    const localFullPath = path.resolve(__dirname, localLuaPath);
    const remoteTmp = `/tmp/tslua-sync-${Date.now()}`;
    
    // SCP 到远程
    let scpCmd = `scp -P ${port} `;
    if (privateKey) scpCmd += `-i ${privateKey} `;
    scpCmd += `-r "${localFullPath}"/* ${username}@${host}:${remoteTmp}/`;
    
    await exec(scpCmd);
    
    // 复制到容器
    const dockerCpCmd = `${this.sshPrefix()} "docker cp ${remoteTmp}/. ${containerName}:${remoteLuaPath}/ && rm -rf ${remoteTmp}"`;
    return exec(dockerCpCmd);
  }
}

// 显示菜单
async function showMenu(manager, config) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  const ask = (q) => new Promise(resolve => rl.question(q, resolve));

  while (true) {
    clearScreen();
    const status = await manager.checkStatus();
    const statusColor = status.includes('Up') ? c.green : (status.includes('error') ? c.red : c.yellow);

    console.log(c.cyan('╔════════════════════════════════════════════════════════════╗'));
    console.log(c.cyan('║          ') + c.white('TS-Skynet Docker 远程管理器') + c.cyan('                   ║'));
    console.log(c.cyan('╠════════════════════════════════════════════════════════════╣'));
    console.log(c.cyan('║  ') + `服务器: ${c.yellow(config.remote.host)}` + c.cyan('').padEnd(38) + '║');
    console.log(c.cyan('║  ') + `容器: ${c.yellow(config.docker.containerName)}` + c.cyan('').padEnd(40) + '║');
    console.log(c.cyan('║  ') + `状态: ${statusColor(status)}` + c.cyan('').padEnd(46 - status.length) + '║');
    console.log(c.cyan('╠════════════════════════════════════════════════════════════╣'));
    console.log(c.cyan('║  ') + c.green('1.') + ' 启动容器          ' + c.green('5.') + ' 查看日志（实时）' + c.cyan('   ║'));
    console.log(c.cyan('║  ') + c.green('2.') + ' 停止容器          ' + c.green('6.') + ' 构建镜像' + c.cyan('           ║'));
    console.log(c.cyan('║  ') + c.green('3.') + ' 重启容器          ' + c.green('7.') + ' 进入容器 Shell' + c.cyan('     ║'));
    console.log(c.cyan('║  ') + c.green('4.') + c.yellow(' 同步代码 →') + '        ' + c.green('8.') + ' 执行自定义命令' + c.cyan('     ║'));
    console.log(c.cyan('╠════════════════════════════════════════════════════════════╣'));
    console.log(c.cyan('║  ') + c.gray('9. 编辑配置') + '            ' + c.gray('0. 退出') + c.cyan('                   ║'));
    console.log(c.cyan('╚════════════════════════════════════════════════════════════╝'));
    console.log();

    const choice = await ask(c.cyan('请选择操作: '));
    console.log();

    switch (choice.trim()) {
      case '1':
        console.log(c.yellow('正在启动容器...'));
        try {
          await manager.start();
          console.log(c.green('✓ 容器启动成功'));
        } catch (e) {
          console.log(c.red('✗ 启动失败:'), e.message);
        }
        break;

      case '2':
        console.log(c.yellow('正在停止容器...'));
        try {
          await manager.stop();
          console.log(c.green('✓ 容器停止成功'));
        } catch (e) {
          console.log(c.red('✗ 停止失败:'), e.message);
        }
        break;

      case '3':
        console.log(c.yellow('正在重启容器...'));
        try {
          await manager.restart();
          console.log(c.green('✓ 容器重启成功'));
        } catch (e) {
          console.log(c.red('✗ 重启失败:'), e.message);
        }
        break;

      case '4':
        console.log(c.yellow('正在同步代码到远程容器...'));
        console.log(c.gray('本地路径: ') + config.docker.localLuaPath);
        console.log(c.gray('远程路径: ') + config.docker.remoteLuaPath);
        try {
          await manager.syncCode();
          console.log(c.green('✓ 代码同步成功'));
        } catch (e) {
          console.log(c.red('✗ 同步失败:'), e.message);
          console.log(c.gray('提示: 请确保本地 Lua 文件已编译 (npm run build:ts)'));
        }
        break;

      case '5':
        console.log(c.yellow('获取最新日志...\n'));
        try {
          const logs = await manager.logs(50);
          console.log(c.gray('─'.repeat(60)));
          console.log(logs);
          console.log(c.gray('─'.repeat(60)));
        } catch (e) {
          console.log(c.red('✗ 获取日志失败:'), e.message);
        }
        break;

      case '6':
        console.log(c.yellow('构建镜像功能需要在远程服务器上执行'));
        console.log(c.gray('请使用 docker-deploy.ps1 或手动构建'));
        break;

      case '7':
        console.log(c.yellow('进入容器 Shell...'));
        rl.close();
        const sshCmd = `${manager.sshPrefix()} "docker exec -it ${config.docker.containerName} /bin/sh"`;
        require('child_process').spawnSync(sshCmd, { shell: true, stdio: 'inherit' });
        return;

      case '8':
        const cmd = await ask(c.cyan('输入要执行的命令: '));
        console.log(c.yellow(`执行: ${cmd}`));
        try {
          const result = await exec(`${manager.sshPrefix()} "${cmd}"`);
          console.log(result);
        } catch (e) {
          console.log(c.red('错误:'), e.message);
        }
        break;

      case '9':
        console.log(c.yellow('编辑配置文件...'));
        console.log(c.gray('配置文件路径: ') + CONFIG_PATH);
        const editor = process.env.EDITOR || 'notepad';
        require('child_process').spawnSync(editor, [CONFIG_PATH], { stdio: 'inherit' });
        break;

      case '0':
      case 'q':
        console.log(c.green('再见!'));
        rl.close();
        return;

      default:
        console.log(c.red('无效选择'));
    }

    console.log();
    await ask(c.gray('按回车继续...'));
  }
}

// 主函数
async function main() {
  const args = process.argv.slice(2);

  if (args.includes('--init')) {
    saveConfig(defaultConfig);
    console.log(c.green('✓ 配置文件已创建:'), CONFIG_PATH);
    console.log(c.gray('请编辑 config.json 配置远程服务器信息'));
    return;
  }

  if (args.includes('--help') || args.includes('-h')) {
    console.log(c.cyan('TS-Skynet Docker 远程管理工具\n'));
    console.log('用法: node simple.js [选项]\n');
    console.log('选项:');
    console.log('  --init     初始化配置文件');
    console.log('  --help     显示帮助');
    console.log('\n快捷键:');
    console.log('  1-8        执行对应操作');
    console.log('  9          编辑配置');
    console.log('  0/q        退出');
    return;
  }

  const config = loadConfig();
  const manager = new DockerManager(config);

  // 检查配置
  if (!fs.existsSync(CONFIG_PATH)) {
    console.log(c.yellow('首次使用，创建默认配置...'));
    saveConfig(defaultConfig);
    console.log(c.green('✓ 配置文件已创建:'), CONFIG_PATH);
    console.log(c.gray('请编辑 config.json 配置远程服务器信息'));
    console.log(c.gray('然后重新运行此工具'));
    return;
  }

  await showMenu(manager, config);
}

main().catch(console.error);
