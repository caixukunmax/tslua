#!/usr/bin/env tsx
/**
 * =============================================================================
 * Protocol Buffers 编译脚本
 * 功能：编译 .proto 文件生成 Lua 描述文件和 TypeScript 代码
 * 特点：跨平台支持（Windows/Linux/Mac）
 * =============================================================================
 */

import path from 'path';
import fs from 'fs';
import { execSync, spawnSync } from 'child_process';
import { globSync } from 'glob';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);

// =============================================================================
// 类型定义
// =============================================================================
interface ProtoConfig {
  proto_dirs: string[];
  output_lua: string[];
  output_ts: string[];
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
  // 获取脚本所在目录
  const scriptDir = path.dirname(__filename);
  const baseDir = path.resolve(scriptDir, '..');

  // 加载配置文件
  const configPath = path.join(baseDir, 'proto.config.json');
  if (!fs.existsSync(configPath)) {
    error(`Config file not found: ${configPath}`);
    process.exit(1);
  }

  const config: ProtoConfig = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
  info(`Loaded config: ${configPath}`);

  console.log('');
  console.log('========================================');
  console.log('  Compiling Protocol Buffers');
  console.log('========================================');
  console.log('');

  // 收集所有 proto 文件
  const allProtoFiles: string[] = [];

  for (const protoDir of config.proto_dirs) {
    const fullDir = path.resolve(baseDir, protoDir);
    if (!fs.existsSync(fullDir)) {
      warn(`Proto directory not found: ${fullDir}`);
      continue;
    }

    info(`Scanning proto directory: ${protoDir}`);
    const protoFiles = globSync('**/*.proto', { cwd: fullDir }).sort();

    for (const file of protoFiles) {
      allProtoFiles.push(path.join(fullDir, file));
    }
  }

  if (allProtoFiles.length === 0) {
    error('No .proto files found in configured directories');
    process.exit(1);
  }

  info(`Found ${allProtoFiles.length} proto files:`);
  for (const file of allProtoFiles) {
    console.log(`  - ${path.basename(file)}`);
  }
  console.log('');

  // 查找 protoc 命令
  let protocCmd: string | null = null;
  try {
    // 先检查系统 PATH 中的 protoc
    execSync('protoc --version', { stdio: 'ignore' });
    protocCmd = 'protoc';
  } catch {
    // 检查 node_modules 中的 protoc
    const localProtoc = path.join(baseDir, 'node_modules', '.bin', 'protoc');
    if (fs.existsSync(localProtoc)) {
      protocCmd = localProtoc;
    } else {
      warn('protoc not found, skipping .desc generation');
    }
  }

  // 生成 Lua 描述文件
  if (protocCmd) {
    console.log('----------------------------------------');
    info('Generating Lua descriptor files...');
    console.log('----------------------------------------');

    for (const luaDir of config.output_lua) {
      const fullLuaDir = path.resolve(baseDir, luaDir);
      fs.mkdirSync(fullLuaDir, { recursive: true });
      info(`Output directory: ${luaDir}`);

      for (const protoFile of allProtoFiles) {
        const filename = path.basename(protoFile, '.proto');
        const protoPath = path.dirname(protoFile);
        const outFile = path.join(fullLuaDir, `${filename}_pb.desc`);

        try {
          execSync(
            `"${protocCmd}" --proto_path="${protoPath}" --descriptor_set_out="${outFile}" --include_imports "${protoFile}"`,
            { stdio: 'ignore' }
          );
          success(`${luaDir}/${filename}.desc`);
        } catch {
          warn(`${luaDir}/${filename}.desc (failed)`);
        }
      }
    }
    console.log('');
  } else {
    warn('Skipping .desc generation (protoc not available)');
    console.log('');
  }

  // 生成 TypeScript 代码
  console.log('----------------------------------------');
  info('Generating TypeScript files...');
  console.log('----------------------------------------');

  // 创建输出目录
  for (const tsDir of config.output_ts) {
    const fullTsDir = path.resolve(baseDir, tsDir);
    fs.mkdirSync(fullTsDir, { recursive: true });
    info(`Output directory: ${tsDir}`);
  }

  const firstTsDir = path.resolve(baseDir, config.output_ts[0]);

  // 检查 protobufjs-cli
  let hasPbjs = false;
  try {
    execSync('npm list pbjs', { stdio: 'ignore', cwd: baseDir });
    hasPbjs = true;
  } catch {
    try {
      execSync('npm list -g pbjs', { stdio: 'ignore' });
      hasPbjs = true;
    } catch {
      hasPbjs = false;
    }
  }

  if (hasPbjs) {
    // 生成静态模块
    try {
      const protoJsPath = path.join(firstTsDir, 'proto.js');
      const args = ['pbjs', '-t', 'static-module', '-w', 'commonjs', '-o', protoJsPath, ...allProtoFiles];
      const result = spawnSync('npx', args, { stdio: 'ignore', cwd: baseDir });

      if (result.status === 0) {
        success('proto.js');
      } else {
        warn('proto.js (failed, using handwritten version)');
      }
    } catch {
      warn('proto.js (failed, using handwritten version)');
    }

    // 生成类型定义
    const protoJsPath = path.join(firstTsDir, 'proto.js');
    if (fs.existsSync(protoJsPath)) {
      try {
        const protoDtsPath = path.join(firstTsDir, 'proto.d.ts');
        const args = ['pbts', '-o', protoDtsPath, protoJsPath];
        const result = spawnSync('npx', args, { stdio: 'ignore', cwd: baseDir });

        if (result.status === 0) {
          success('proto.d.ts');
        } else {
          warn('proto.d.ts (failed)');
        }
      } catch {
        warn('proto.d.ts (failed)');
      }
    }
  } else {
    warn('protobufjs-cli not installed, skipping auto-generation');
    info('Using handwritten proto.ts');
  }

  console.log('');
  console.log('========================================');
  success('Protocol compilation complete!');
  console.log('========================================');
  console.log('');
  console.log('Output:');
  for (const luaDir of config.output_lua) {
    console.log(`  Lua descriptors: ${luaDir}/*.desc`);
  }
  for (const tsDir of config.output_ts) {
    console.log(`  TypeScript: ${tsDir}/proto.{ts,js,d.ts}`);
  }
  console.log('');
}

// 运行主函数
main();
