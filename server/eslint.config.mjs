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
      '@typescript-eslint/no-explicit-any': 'warn',
      
      // TS-Skynet 核心规则
      'tslua/no-async-in-service-start': 'error',
    },
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        project: './config/tsconfig.json',
      },
    },
  },
];
