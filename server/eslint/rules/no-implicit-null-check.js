/**
 * ESLint Rule: no-implicit-null-check
 *
 * 检测隐式空值判断（警告级别）
 * 原因：JavaScript 中 if (obj.foo) 会匹配 falsy 值 (0, '', false, null, undefined)
 *       Lua 中 if obj.foo then 只匹配 nil 和 false
 *       行为差异可能导致跨环境 bug
 *
 * ⚠️ 这是警告级别，不是错误
 * - 某些简单场景下隐式判断是可读的
 * - 但涉及可能为空的值时，显式检查更安全
 *
 * ❌ 不推荐（可能有问题）：
 *   if (obj.foo) { }           // 0, '', false 也会被过滤
 *   if (!obj.foo) { }          // 同上
 *   if (obj.foo && bar) { }    // 链式判断可能有歧义
 *
 * ✅ 推荐（明确意图）：
 *   if (obj.foo != null) { }   // 明确检查 null/undefined
 *   if (obj.foo !== undefined) { } // 明确检查 undefined
 *   if (obj.foo === true) { }  // 明确检查布尔值
 *   if (typeof obj.foo === 'boolean') { } // 类型检查
 */

module.exports = {
  meta: {
    type: 'suggestion',
    docs: {
      description: 'Warn against implicit null/undefined checks in TS-Skynet',
      category: 'Best Practices',
      recommended: 'warn',
    },
    fixable: null,
    schema: [],
    messages: {
      implicitCheck:
        '使用 `if ({{name}})` 进行隐式空值判断可能在跨环境时有行为差异。' +
        '推荐使用 `{{name}} != null` 或 `{{name}} !== undefined` 进行显式检查。' +
        '注意：隐式判断会同时过滤 0、空字符串、false 等 falsy 值。',
    },
  },

  create(context) {
    /**
     * 检查节点是否是可能为空的对象属性访问
     */
    function isPotentiallyNullOrUndefined(node) {
      // 成员表达式：obj.foo, obj.bar.baz
      if (node.type === 'MemberExpression') {
        return true;
      }
      
      // 可选链：obj?.foo
      if (node.type === 'ChainExpression') {
        return true;
      }
      
      // 标识符：foo (可能是函数返回值或变量)
      if (node.type === 'Identifier') {
        return true;
      }
      
      return false;
    }

    /**
     * 检查是否是简单的 falsy 值判断（排除字面量）
     */
    function isFalsyCheckWithoutLiteral(node) {
      // 排除明确的字面量比较
      if (node.type === 'Literal') {
        return false;
      }
      
      // 排除二元表达式（如 a === b）
      if (node.type === 'BinaryExpression') {
        return false;
      }
      
      // 排除逻辑运算符（如 a || b, a && b）
      if (node.type === 'LogicalExpression') {
        return false;
      }
      
      // 排除一元运算符（如 !a, typeof a）
      if (node.type === 'UnaryExpression') {
        return false;
      }
      
      return isPotentiallyNullOrUndefined(node);
    }

    return {
      // 检测 if 语句
      IfStatement(node) {
        const test = node.test;
        
        // 检查 if (expr) 形式
        if (isFalsyCheckWithoutLiteral(test)) {
          context.report({
            node: test,
            messageId: 'implicitCheck',
            data: {
              name: context.sourceCode.getText(test),
            },
          });
        }
        
        // 检查 if (!(expr)) 形式
        if (
          test.type === 'UnaryExpression' &&
          test.operator === '!' &&
          isFalsyCheckWithoutLiteral(test.argument)
        ) {
          context.report({
            node: test.argument,
            messageId: 'implicitCheck',
            data: {
              name: context.sourceCode.getText(test.argument),
            },
          });
        }
      },

      // 检测三元表达式
      ConditionalExpression(node) {
        const test = node.test;
        
        if (isFalsyCheckWithoutLiteral(test)) {
          context.report({
            node: test,
            messageId: 'implicitCheck',
            data: {
              name: context.sourceCode.getText(test),
            },
          });
        }
      },

      // 检测逻辑与的左侧（常见于短路求值）
      LogicalExpression(node) {
        if (node.operator === '&&') {
          const left = node.left;
          
          // 检查 expr && ... 形式
          if (isFalsyCheckWithoutLiteral(left)) {
            context.report({
              node: left,
              messageId: 'implicitCheck',
              data: {
                name: context.sourceCode.getText(left),
              },
            });
          }
        }
        
        // 不检查 || ，因为通常用于提供默认值
      },
    };
  },
};
