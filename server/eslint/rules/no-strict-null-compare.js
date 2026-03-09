/**
 * ESLint Rule: no-strict-null-compare
 *
 * 检测严格空值比较（警告级别）
 * 原因：Lua 的 nil 与 JavaScript 的 undefined/null 不同
 *       使用 == null 可以在 TSTL 编译后正确处理
 *
 * ⚠️ 这是警告级别，不是错误
 * - 严格比较在某些场景下可能是故意的
 * - 但通常 == null 更安全
 *
 * ❌ 不推荐：
 *   if (obj.foo === undefined) { }
 *   if (obj.foo === null) { }
 *
 * ✅ 推荐：
 *   if (obj.foo == null) { }  // 匹配 undefined, null, nil
 */

module.exports = {
  meta: {
    type: 'suggestion',
    docs: {
      description: 'Warn against strict undefined/null comparison in TS-Skynet',
      category: 'Best Practices',
      recommended: 'warn',
    },
    fixable: null,
    schema: [],
    messages: {
      strictUndefined:
        '使用 `=== undefined` 在 Lua 中可能不匹配 nil。' +
        '推荐使用 `== null` 兼容两种环境。',
      strictNull:
        '使用 `=== null` 在 Lua 中可能不匹配 nil。' +
        '推荐使用 `== null` 兼容 undefined、null 和 nil。',
    },
  },

  create(context) {
    return {
      BinaryExpression(node) {
        // 只检查 === 和 !==
        if (node.operator !== '===' && node.operator !== '!==') {
          return;
        }

        // 检查是否与 undefined 比较
        if (
          node.right.type === 'Identifier' &&
          node.right.name === 'undefined'
        ) {
          context.report({
            node,
            messageId: 'strictUndefined',
          });
          return;
        }

        if (
          node.left.type === 'Identifier' &&
          node.left.name === 'undefined'
        ) {
          context.report({
            node,
            messageId: 'strictUndefined',
          });
          return;
        }

        // 检查是否与 null 比较
        if (
          node.right.type === 'Literal' &&
          node.right.value === null
        ) {
          context.report({
            node,
            messageId: 'strictNull',
          });
          return;
        }

        if (
          node.left.type === 'Literal' &&
          node.left.value === null
        ) {
          context.report({
            node,
            messageId: 'strictNull',
          });
        }
      },
    };
  },
};
