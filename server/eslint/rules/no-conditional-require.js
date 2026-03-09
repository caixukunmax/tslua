/**
 * ESLint Rule: no-conditional-require
 *
 * 检测条件语句中的 require（警告级别）
 * 原因：TSTL 会把所有条件分支中的模块都打包进去，无法实现真正的懒加载
 *
 * ⚠️ 这是警告级别，不是错误
 * - 静态路径的条件 require 可以工作
 * - 但会被打包，无法节省资源
 */

module.exports = {
  meta: {
    type: 'suggestion',  // 建议级别，不是问题
    docs: {
      description: 'Warn against conditional require() in TS-Skynet',
      category: 'Best Practices',
      recommended: 'warn',
    },
    fixable: null,
    schema: [],
    messages: {
      conditionalRequire:
        '条件语句中的 require() 会被 TSTL 全部打包，无法实现懒加载。' +
        '如果目的是减少资源占用，请改用静态导入 + 配置映射的方式。'
    },
  },

  create(context) {
    /**
     * 检查是否在条件语句中
     */
    function isInConditional(node) {
      let current = node.parent;
      
      while (current) {
        if (
          current.type === 'IfStatement' ||
          current.type === 'ConditionalExpression' ||
          current.type === 'SwitchCase' ||
          current.type === 'WhileStatement' ||
          current.type === 'DoWhileStatement' ||
          current.type === 'ForStatement'
        ) {
          return true;
        }
        
        // 检查是否在条件语句的分支中（consequent 或 alternate）
        if (
          current.parent &&
          (current.parent.type === 'IfStatement' ||
           current.parent.type === 'ConditionalExpression')
        ) {
          const parent = current.parent;
          if (parent.consequent === current || parent.alternate === current) {
            return true;
          }
        }
        
        current = current.parent;
      }
      
      return false;
    }

    /**
     * 检查是否是 require 调用
     */
    function isRequireCall(node) {
      return (
        node.type === 'CallExpression' &&
        node.callee.type === 'Identifier' &&
        node.callee.name === 'require'
      );
    }

    return {
      CallExpression(node) {
        // 只检测 require 调用
        if (!isRequireCall(node)) {
          return;
        }

        // 检查是否在条件语句中
        if (isInConditional(node)) {
          context.report({
            node,
            messageId: 'conditionalRequire',
          });
        }
      }
    };
  },
};
