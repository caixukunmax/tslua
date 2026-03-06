module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: [
    '@typescript-eslint',
    'tslua'  // 自定义插件
  ],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
  ],
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
    project: './tsconfig.json',
  },
  rules: {
    // TypeScript 推荐规则
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    
    // TS-Skynet 核心规则
    'tslua/no-async-in-service-start': 'error',  // 禁止在 service.start 中使用 async
  },
  settings: {
    // 导入自定义规则
    'import/resolver': {
      node: {
        paths: ['.']
      }
    }
  }
};
