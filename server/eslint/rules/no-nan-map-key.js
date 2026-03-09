/**
 * ESLint Rule: no-nan-map-key
 *
 * 禁止使用 NaN 作为 Map 键（错误级别）
 * 原因：Lua 的 table 不支持 NaN 作为键，会导致运行时错误或意外行为
 *
 * ❌ 禁止：
 *   map.set(NaN, value)
 *   new Map([[NaN, value]])
 *
 * ✅ 替代方案：
 *   使用特殊字符串如 'NaN' 或 '__NaN__' 作为键
 */

module.exports = {
  meta: {
    type: 'problem',
    docs: {
      description: 'Disallow NaN as Map key in TS-Skynet',
      category: 'Possible Errors',
      recommended: 'error',
    },
    fixable: null,
    schema: [],
    messages: {
      nanMapKey:
        '禁止使用 NaN 作为 Map 键。' +
        'Lua 的 table 不支持 NaN 作为键。' +
        '请使用特殊字符串如 "NaN" 或 "__NaN__" 替代。',
    },
  },

  create(context) {
    /**
     * 检查值是否是 NaN
     */
    function isNaNValue(node) {
      // NaN 标识符
      if (node.type === 'Identifier' && node.name === 'NaN') {
        return true;
      }
      // 0/0 表达式结果也是 NaN
      if (node.type === 'BinaryExpression' && node.operator === '/') {
        if (
          node.left.type === 'Literal' && node.left.value === 0 &&
          node.right.type === 'Literal' && node.right.value === 0
        ) {
          return true;
        }
      }
      // Number.NaN
      if (
        node.type === 'MemberExpression' &&
        node.object.type === 'Identifier' &&
        node.object.name === 'Number' &&
        node.property.type === 'Identifier' &&
        node.property.name === 'NaN'
      ) {
        return true;
      }
      return false;
    }

    /**
     * 检查是否是 Map 方法调用
     */
    function isMapSetCall(node) {
      if (node.callee.type !== 'MemberExpression') {
        return false;
      }
      const prop = node.callee.property;
      return prop.type === 'Identifier' && prop.name === 'set';
    }

    /**
     * 检查数组元素是否是 [NaN, value] 形式
     */
    function checkMapEntryArray(node) {
      if (node.type !== 'ArrayExpression' || node.elements.length < 2) {
        return;
      }
      const key = node.elements[0];
      if (key && isNaNValue(key)) {
        context.report({
          node,
          messageId: 'nanMapKey',
        });
      }
    }

    return {
      // 检测 map.set(NaN, ...)
      CallExpression(node) {
        if (!isMapSetCall(node)) {
          return;
        }
        if (node.arguments.length < 2) {
          return;
        }
        const key = node.arguments[0];
        if (isNaNValue(key)) {
          context.report({
            node,
            messageId: 'nanMapKey',
          });
        }
      },

      // 检测 new Map([[NaN, ...], ...])
      NewExpression(node) {
        if (
          node.callee.type !== 'Identifier' ||
          node.callee.name !== 'Map'
        ) {
          return;
        }
        if (node.arguments.length === 0) {
          return;
        }
        const entries = node.arguments[0];
        if (entries.type !== 'ArrayExpression') {
          return;
        }
        for (const element of entries.elements) {
          if (element) {
            checkMapEntryArray(element);
          }
        }
      },
    };
  },
};
