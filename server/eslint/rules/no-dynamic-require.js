/**
 * ESLint Rule: no-dynamic-require
 *
 * 禁止使用动态路径的 require
 * 原因：TSTL 在编译时静态解析 require，动态路径会导致运行时找不到模块
 *
 * ❌ 禁止：
 *   require(`./services/${serviceName}`)
 *   require(someVariable)
 *
 * ✅ 替代方案：静态导入 + 映射表
 *   import { GatewayService } from './services/gateway';
 *   const serviceMap = { gateway: GatewayService };
 *   const Service = serviceMap[serviceName];
 */

module.exports = {
  meta: {
    type: 'problem',
    docs: {
      description: 'Disallow dynamic require() in TS-Skynet',
      category: 'Possible Errors',
      recommended: 'error',
    },
    fixable: null,
    schema: [],
    messages: {
      noDynamicRequire:
        '禁止使用动态路径的 require()。' +
        'TSTL 编译时无法解析动态路径，会导致运行时找不到模块。' +
        '请使用静态导入 + 映射表替代：import { X } from "./path"; const map = { x: X };'
    },
  },

  create(context) {
    /**
     * 检查 require 参数是否是动态的
     */
    function isDynamicRequire(node) {
      // require() 调用
      if (node.callee.type !== 'Identifier' || node.callee.name !== 'require') {
        return false;
      }

      const args = node.arguments;
      if (args.length === 0) {
        return false;
      }

      const firstArg = args[0];

      // 动态情况：
      // 1. 变量: require(someVar)
      // 2. 模板字符串: require(`./${path}`)
      // 3. 字符串拼接: require('./' + name)
      // 4. 函数调用: require(getPath())
      
      if (firstArg.type === 'Identifier') {
        return true;  // 变量
      }

      if (firstArg.type === 'TemplateLiteral') {
        // 检查是否有插值表达式
        if (firstArg.expressions && firstArg.expressions.length > 0) {
          return true;
        }
      }

      if (firstArg.type === 'BinaryExpression') {
        // 字符串拼接
        if (firstArg.operator === '+') {
          return true;
        }
      }

      if (firstArg.type === 'CallExpression') {
        return true;  // 函数调用返回路径
      }

      return false;
    }

    return {
      CallExpression(node) {
        if (isDynamicRequire(node)) {
          context.report({
            node,
            messageId: 'noDynamicRequire',
          });
        }
      }
    };
  },
};
