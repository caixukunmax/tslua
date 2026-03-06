/**
 * ESLint Rule: no-async-in-service-start
 * 
 * 禁止在 runtime.service.start 回调中使用 async 函数
 * 原因：Skynet 的服务初始化机制要求同步完成
 */

module.exports = {
  meta: {
    type: 'problem',
    docs: {
      description: 'Disallow async functions in runtime.service.start callbacks',
      category: 'Possible Errors',
      recommended: true,
    },
    schema: [],
    messages: {
      noAsyncInStart: 
        "禁止在 runtime.service.start 回调中使用 async。" +
        "原因：Skynet 服务初始化需要同步完成，使用 async 会导致服务启动后立即退出。"
    },
  },

  create(context) {
    /**
     * 检查是否是 runtime.service.start 调用
     */
    function isRuntimeServiceStart(node) {
      if (node.type !== 'CallExpression') return false;
      
      const callee = node.callee;
      
      // 匹配：runtime.service.start(...)
      if (callee.type === 'MemberExpression' &&
          callee.object?.type === 'MemberExpression' &&
          callee.object.object?.name === 'runtime' &&
          callee.object.property?.name === 'service' &&
          callee.property?.name === 'start') {
        return true;
      }
      
      // 匹配：service.start(...)
      if (callee.type === 'MemberExpression' &&
          callee.object?.name === 'service' &&
          callee.property?.name === 'start') {
        return true;
      }
      
      return false;
    }

    /**
     * 检查回调是否是 async 函数
     */
    function checkAsyncCallback(node) {
      if (!node || !node.arguments || node.arguments.length === 0) return;
      
      const callback = node.arguments[0];
      
      // 检查 ArrowFunctionExpression
      if (callback.type === 'ArrowFunctionExpression' ||
          callback.type === 'FunctionExpression') {
        if (callback.async) {
          context.report({
            node: callback,
            messageId: 'noAsyncInStart'
          });
        }
      }
    }

    return {
      CallExpression(node) {
        if (isRuntimeServiceStart(node)) {
          checkAsyncCallback(node);
        }
      }
    };
  }
};
