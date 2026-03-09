import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import tsluaPlugin from './eslint/index.js';

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ['src/**/*.ts'],
    plugins: {
      tslua: tsluaPlugin
    },
    rules: {
      // TypeScript 推荐规则
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      // any 类型在框架底层是必要的（泛型、回调等），关闭警告
      '@typescript-eslint/no-explicit-any': 'off',

      // TS-Skynet 核心规则
      'tslua/no-async-in-service-start': 'error',
      'tslua/no-promise-then': 'error',  // 禁止使用 Promise.then()
      'tslua/no-dynamic-require': 'error', // 禁止动态路径 require()
      'tslua/no-bigint': 'error', // 禁止 BigInt（Lua 不支持）
      'tslua/no-string-length': 'error', // 禁止 str.length（字节 vs 字符）
      'tslua/no-nan-map-key': 'error', // 禁止 NaN 作为 Map 键
      'tslua/no-conditional-require': 'warn', // 警告：条件 require（可用但不推荐）
      'tslua/no-advanced-regex': 'warn', // 警告：高级正则特性（Lua pattern 有限）
      'tslua/no-strict-null-compare': 'warn', // 警告：严格空值比较
      'tslua/no-implicit-null-check': 'warn', // 警告：隐式空值判断
      'tslua/no-floating-point-compare': 'warn', // 警告：浮点数直接比较
    },
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        project: './config/tsconfig.json',
      },
    },
  },
];
