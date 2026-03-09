/**
 * ESLint Plugin: tslua
 * 
 * TS-Skynet 项目自定义 ESLint 规则
 */

const noAsyncInServiceStart = require('./rules/no-async-in-service-start');
const noPromiseThen = require('./rules/no-promise-then');
const noDynamicRequire = require('./rules/no-dynamic-require');
const noConditionalRequire = require('./rules/no-conditional-require');
const noAdvancedRegex = require('./rules/no-advanced-regex');
const noStrictNullCompare = require('./rules/no-strict-null-compare');
const noImplicitNullCheck = require('./rules/no-implicit-null-check');
const noFloatingPointCompare = require('./rules/no-floating-point-compare');
const noBigint = require('./rules/no-bigint');
const noStringLength = require('./rules/no-string-length');
const noNanMapKey = require('./rules/no-nan-map-key');

module.exports = {
  rules: {
    'no-async-in-service-start': noAsyncInServiceStart,
    'no-promise-then': noPromiseThen,
    'no-dynamic-require': noDynamicRequire,
    'no-conditional-require': noConditionalRequire,
    'no-advanced-regex': noAdvancedRegex,
    'no-strict-null-compare': noStrictNullCompare,
    'no-implicit-null-check': noImplicitNullCheck,
    'no-floating-point-compare': noFloatingPointCompare,
    'no-bigint': noBigint,
    'no-string-length': noStringLength,
    'no-nan-map-key': noNanMapKey,
  },
  configs: {
    recommended: {
      plugins: ['tslua'],
      rules: {
        'tslua/no-async-in-service-start': 'error',
        'tslua/no-promise-then': 'error',
        'tslua/no-dynamic-require': 'error',
        'tslua/no-bigint': 'error',
        'tslua/no-string-length': 'error',
        'tslua/no-nan-map-key': 'error',
        'tslua/no-conditional-require': 'warn',
        'tslua/no-advanced-regex': 'warn',
        'tslua/no-strict-null-compare': 'warn',
        'tslua/no-implicit-null-check': 'warn',
        'tslua/no-floating-point-compare': 'warn',
      }
    }
  }
};
