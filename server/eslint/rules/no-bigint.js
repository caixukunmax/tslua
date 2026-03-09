/**
 * ESLint Rule: no-bigint
 *
 * 禁止使用 BigInt（错误级别）
 * 原因：Lua 没有原生 BigInt 支持，TSTL 无法编译
 *
 * ❌ 禁止：
 *   const big = 9007199254740993n;
 *   const big = BigInt(123);
 *   function foo(x: bigint) { }
 */

module.exports = {
  meta: {
    type: 'problem',
    docs: {
      description: 'Disallow BigInt in TS-Skynet',
      category: 'Possible Errors',
      recommended: 'error',
    },
    fixable: null,
    schema: [],
    messages: {
      bigintLiteral:
        'BigInt 字面量在 Lua 中不支持。' +
        '请使用字符串或分段处理大整数。',
      bigintType:
        'bigint 类型在 Lua 中不支持。' +
        '请使用 string 或自定义类型替代。',
      bigintCall:
        'BigInt() 构造函数在 Lua 中不支持。' +
        '请使用字符串处理大整数。',
    },
  },

  create(context) {
    return {
      // 检测 BigInt 字面量: 123n
      Literal(node) {
        if (node.bigint !== undefined) {
          context.report({
            node,
            messageId: 'bigintLiteral',
          });
        }
      },

      // 检测 BigInt 类型注解
      TSTypeReference(node) {
        if (
          node.typeName &&
          node.typeName.type === 'Identifier' &&
          node.typeName.name === 'bigint'
        ) {
          context.report({
            node,
            messageId: 'bigintType',
          });
        }
      },

      // 检测 BigInt 类型名
      TSBigIntKeyword(node) {
        context.report({
          node,
          messageId: 'bigintType',
        });
      },

      // 检测 BigInt() 调用
      CallExpression(node) {
        if (
          node.callee.type === 'Identifier' &&
          node.callee.name === 'BigInt'
        ) {
          context.report({
            node,
            messageId: 'bigintCall',
          });
        }
      },

      // 检测 new BigInt() 调用
      NewExpression(node) {
        if (
          node.callee.type === 'Identifier' &&
          node.callee.name === 'BigInt'
        ) {
          context.report({
            node,
            messageId: 'bigintCall',
          });
        }
      },
    };
  },
};
