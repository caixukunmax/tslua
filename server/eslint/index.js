/**
 * ESLint Plugin: tslua
 * 
 * TS-Skynet 项目自定义 ESLint 规则
 */

const noAsyncInServiceStart = require('./rules/no-async-in-service-start');

module.exports = {
  rules: {
    'no-async-in-service-start': noAsyncInServiceStart,
  },
  configs: {
    recommended: {
      plugins: ['tslua'],
      rules: {
        'tslua/no-async-in-service-start': 'error',
      }
    }
  }
};
