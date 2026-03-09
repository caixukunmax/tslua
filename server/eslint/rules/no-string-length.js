/**
 * ESLint Rule: no-string-length
 *
 * 禁止使用 str.length（错误级别）
 * 原因：在 Lua 中 #str 返回字节数，而 JavaScript 返回字符数
 *       对于 UTF-8 多字节字符，结果不同
 *
 * ❌ 禁止：
 *   str.length
 *   '你好'.length
 *
 * ✅ 替代方案：
 *   String.length(str)
 *   utf8.len(str)
 */

module.exports = {
  meta: {
    type: 'problem',
    docs: {
      description: 'Disallow str.length in TS-Skynet (byte vs char difference)',
      category: 'Possible Errors',
      recommended: 'error',
    },
    fixable: null,
    schema: [],
    messages: {
      stringLength:
        'str.length 在 Lua 中返回字节数而非字符数。' +
        '对于 UTF-8 多字节字符结果不同。' +
        '请使用 String.length(str) 或 utf8.len(str) 获取字符数。',
    },
  },

  create(context) {
    return {
      MemberExpression(node) {
        // 检测 .length 属性访问
        if (
          node.property.type === 'Identifier' &&
          node.property.name === 'length' &&
          !node.computed
        ) {
          // 检查对象是否可能是字符串
          const objectNode = node.object;

          // 字面量字符串 - 直接报告
          if (objectNode.type === 'Literal' && typeof objectNode.value === 'string') {
            context.report({
              node,
              messageId: 'stringLength',
            });
            return;
          }

          // 模板字符串 - 直接报告
          if (objectNode.type === 'TemplateLiteral') {
            context.report({
              node,
              messageId: 'stringLength',
            });
            return;
          }

          // 变量或表达式 - 尝试获取 TypeScript 类型信息
          if (
            objectNode.type === 'Identifier' ||
            objectNode.type === 'MemberExpression' ||
            objectNode.type === 'CallExpression'
          ) {
            // 尝试获取类型信息
            const parserServices = context.parserServices;
            if (parserServices && parserServices.program && parserServices.esTreeNodeToTSNodeMap) {
              const checker = parserServices.program.getTypeChecker();
              const tsNode = parserServices.esTreeNodeToTSNodeMap.get(objectNode);
              if (tsNode) {
                const type = checker.getTypeAtLocation(tsNode);
                const typeString = checker.typeToString(type);
                
                // 只在确定是 string 类型时才报告
                if (typeString === 'string' || type.flags === 2 /* String */) {
                  context.report({
                    node,
                    messageId: 'stringLength',
                  });
                }
              }
            }
            // 没有 TypeScript 类型信息时不报告（避免误报 Array.length）
          }
        }
      },
    };
  },
};
