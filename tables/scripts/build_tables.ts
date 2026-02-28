#!/usr/bin/env tsx
/**
 * =============================================================================
 * Luban 配置表编译脚本
 * 功能：从 Excel 生成 Lua 配置代码和 JSON 数据
 * 特点：跨平台支持（Windows/Linux/Mac）
 * =============================================================================
 */

import path from 'path';
import fs from 'fs';
import { spawnSync } from 'child_process';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);

// =============================================================================
// 类型定义
// =============================================================================
interface LubanConfig {
  luban_dll: string;
  input: {
    data_dir: string;
    define_dir: string;
    config_file: string;
  };
  output: {
    code_dir: string;
    data_dir: string;
    targets: Array<{
      name: string;
      code_type: string;
      data_type: string;
      enabled: boolean;
    }>;
  };
  luban_args: {
    l10n_text_provider_file: string;
  };
}

// =============================================================================
// 配置加载
// =============================================================================
const BASE_DIR = path.resolve(path.dirname(__filename), '..');
const CONFIG_FILE = path.join(BASE_DIR, 'luban.config.json');

function loadConfig(): LubanConfig {
  if (!fs.existsSync(CONFIG_FILE)) {
    console.error(`配置文件不存在：${CONFIG_FILE}`);
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf-8'));
}

// =============================================================================
// 工具函数
// =============================================================================
const colors = {
  reset: '\x1b[0m',
  blue: '\x1b[34m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
};

function info(msg: string): void {
  console.log(`${colors.blue}[INFO]${colors.reset} ${msg}`);
}

function success(msg: string): void {
  console.log(`${colors.green}[SUCCESS]${colors.reset} ${msg}`);
}

function warn(msg: string): void {
  console.log(`${colors.yellow}[WARN]${colors.reset} ${msg}`);
}

function error(msg: string): void {
  console.error(`${colors.red}[ERROR]${colors.reset} ${msg}`);
}

// =============================================================================
// 主逻辑
// =============================================================================
function main(): void {
  // 加载配置
  const config = loadConfig();
  info(`Loaded config: ${CONFIG_FILE}`);

  console.log('');
  console.log('========================================');
  console.log('  Compiling Luban Configuration Tables');
  console.log('========================================');
  console.log('');

  // 解析路径
  const LUBAN_DLL = path.join(BASE_DIR, config.luban_dll);
  const CONFIG_PATH = path.join(BASE_DIR, config.input.config_file);
  const OUTPUT_CODE_DIR = path.resolve(BASE_DIR, config.output.code_dir);
  const OUTPUT_DATA_DIR = path.resolve(BASE_DIR, config.output.data_dir);

  console.log(`Luban DLL:      ${LUBAN_DLL}`);
  console.log(`Config file:    ${CONFIG_PATH}`);
  console.log(`Output code:    ${OUTPUT_CODE_DIR}`);
  console.log(`Output data:    ${OUTPUT_DATA_DIR}`);
  console.log('');

  // 检查 Luban DLL
  if (!fs.existsSync(LUBAN_DLL)) {
    error(`Luban.dll not found: ${LUBAN_DLL}`);
    console.log('');
    console.log('请确保 Luban 工具已下载到 tables/tools/luban/Luban/ 目录');
    console.log('');
    process.exit(1);
  }

  // 检查 dotnet 命令
  let dotnetCmd: string;
  try {
    const result = spawnSync('dotnet', ['--version'], { stdio: 'ignore' });
    if (result.status === 0) {
      dotnetCmd = 'dotnet';
    } else {
      throw new Error('dotnet not available');
    }
  } catch {
    error('dotnet not found');
    console.log('');
    console.log('Luban 需要 .NET SDK 才能运行。');
    console.log('');
    console.log('安装 .NET SDK:');
    console.log('  Ubuntu/Debian: sudo apt-get install dotnet-sdk-8.0');
    console.log('  CentOS/RHEL:   sudo yum install dotnet-sdk-8.0');
    console.log('  macOS:         brew install --cask dotnet-sdk');
    console.log('  Windows:       访问 https://dotnet.microsoft.com/download');
    console.log('');
    process.exit(1);
  }

  // 检查配置文件
  if (!fs.existsSync(CONFIG_PATH)) {
    error(`luban.conf not found: ${CONFIG_PATH}`);
    process.exit(1);
  }

  // 创建输出目录
  fs.mkdirSync(OUTPUT_CODE_DIR, { recursive: true });
  fs.mkdirSync(OUTPUT_DATA_DIR, { recursive: true });

  console.log('----------------------------------------');
  info('Generating Lua code and JSON data...');
  console.log('----------------------------------------');

  // 构建命令参数
  const args = [
    LUBAN_DLL,
    '-t', 'all',
    '-c', 'lua-lua',
    '-d', 'lua',
    '-f',
    '--conf', CONFIG_PATH,
    '-x', `outputCodeDir=${OUTPUT_CODE_DIR}`,
    '-x', `outputDataDir=${OUTPUT_DATA_DIR}`,
    '-x', `l10n.textProviderFile=${config.luban_args.l10n_text_provider_file}`,
  ];

  try {
    const result = spawnSync(dotnetCmd, args, {
      stdio: 'inherit',
      cwd: BASE_DIR,
    });

    if (result.status === 0) {
      console.log('');
      success(`Lua code and JSON data generated: ${OUTPUT_CODE_DIR}`);
    } else {
      error('Failed to generate Luban output');
      process.exit(1);
    }
  } catch (err) {
    error(`Failed to run Luban: ${err}`);
    process.exit(1);
  }

  console.log('');
  console.log('========================================');
  success('Luban compilation complete!');
  console.log('========================================');
  console.log('');
}

// 运行主函数
main();
