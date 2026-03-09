/**
 * ESLint Rule: no-promise-then
 *
 * 禁止使用 Promise.then() 链式调用
 * 原因：在 Skynet 环境中，.then() 回调不在协程管理下，
 *       服务退出时会导致 "cannot resume dead coroutine" 错误
 *
 * 推荐写法：使用 async/await
 *   async function foo() {
 *     await promise;
 *     doSomething();
 *   }
 *
 * 豁免文件（框架底层）：
 * - framework/runtime/*.ts (Promise polyfill 实现)
 * - framework/core/interfaces.ts (接口定义)
 */

module.exports = {
  meta: {
    type: 'problem',
    docs: {
      description: 'Disallow Promise.then() chaining in TS-Skynet',
      category: 'Possible Errors',
      recommended: 'error',
    },
    fixable: null,
    schema: [],
    messages: {
      noThen:
        '禁止使用 Promise.then()。' +
        '在 Skynet 环境中，.then() 回调不在协程管理下，会导致服务退出时崩溃。' +
        '请使用 async/await：将函数改为 async，然后用 await 替代 .then()'
    },
  },

  create(context) {
    // 豁免文件路径（框架底层代码）
    const exemptPaths = [
      'framework/runtime/async-bridge.ts',
      'framework/runtime/skynet-adapter.ts',
      'framework/runtime/node-adapter.ts',
      'framework/core/interfaces.ts',
    ];

    // ESLint v10 Flat Config 使用 context.filename
    const fileName = context.filename || context.getFilename?.() || '';
    const isExempt = exemptPaths.some(path => fileName.includes(path));

    if (isExempt) {
      return {};
    }

    /**
     * 检查 MemberExpression 是否是 .then() 调用
     */
    function isThenCall(node) {
      return node.type === 'MemberExpression' &&
             node.property.type === 'Identifier' &&
             node.property.name === 'then';
    }

    return {
      CallExpression(node) {
        // 检测 .then() 调用
        if (isThenCall(node.callee)) {
          context.report({
            node,
            messageId: 'noThen',
          });
        }
      }
    };
  },
};
