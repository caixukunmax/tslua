/**
 * ESLint Rule: no-floating-point-compare
 *
 * 检测浮点数直接比较（警告级别）
 * 原因：JavaScript 和 Lua 都有浮点数精度问题
 *       但 TSTL 编译后的行为可能有细微差异
 *
 * ⚠️ 这是警告级别，不是错误
 * - 某些场景下直接比较是可以的（如整数）
 * - 但涉及小数时需要特别小心
 *
 * ❌ 不推荐：
 *   if (a === b) { }           // 浮点数可能因精度问题不相等
 *   if (x > 0.1) { }           // 0.1 + 0.2 !== 0.3
 *
 * ✅ 推荐：
 *   if (Math.abs(a - b) < EPSILON) { }  // 使用误差范围
 *   if (a.toFixed(2) === b.toFixed(2)) { } // 固定精度比较
 */

module.exports = {
  meta: {
    type: 'suggestion',
    docs: {
      description: 'Warn against direct floating point comparison in TS-Skynet',
      category: 'Possible Errors',
      recommended: 'warn',
    },
    fixable: null,
    schema: [],
    messages: {
      floatCompare:
        '直接比较浮点数可能在跨环境时有精度问题。' +
        '推荐使用误差范围比较：`Math.abs(a - b) < EPSILON`。' +
        '注意：0.1 + 0.2 !== 0.3 在两种环境中都成立。',
    },
  },

  create(context) {
    /**
     * 检查节点是否是浮点数字面量
     */
    function isFloatLiteral(node) {
      return node.type === 'Literal' && 
             typeof node.value === 'number' && 
             !Number.isInteger(node.value);
    }

    /**
     * 检查节点是否可能是浮点数变量
     */
    function isPotentiallyFloat(node) {
      // 除法运算通常产生浮点数
      if (node.type === 'BinaryExpression' && node.operator === '/') {
        return true;
      }
      
      // Math 函数通常返回浮点数
      if (node.type === 'CallExpression' && 
          node.callee.type === 'MemberExpression' &&
          node.callee.object.name === 'Math') {
        const methods = ['random', 'sin', 'cos', 'tan', 'log', 'exp', 'sqrt', 'pow'];
        if (methods.includes(node.callee.property.name)) {
          return true;
        }
      }
      
      return false;
    }

    return {
      // 检测二元表达式
      BinaryExpression(node) {
        const operators = ['===', '!==', '==', '!=', '<', '>', '<=', '>='];
        
        if (!operators.includes(node.operator)) {
          return;
        }

        // 检查是否有浮点数字面量
        if (isFloatLiteral(node.left) || isFloatLiteral(node.right)) {
          context.report({
            node,
            messageId: 'floatCompare',
          });
          return;
        }

        // 检查是否有可能是浮点数的表达式
        if (isPotentiallyFloat(node.left) || isPotentiallyFloat(node.right)) {
          context.report({
            node,
            messageId: 'floatCompare',
          });
        }
      },
    };
  },
};
