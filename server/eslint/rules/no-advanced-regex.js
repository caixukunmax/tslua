/**
 * ESLint Rule: no-advanced-regex
 *
 * 检测 Lua pattern 不支持的高级正则特性（警告级别）
 * 原因：Lua 使用 pattern matching，不是完整正则表达式
 *
 * ⚠️ 这是警告级别，不是错误
 * - 某些特性可能被 TSTL polyfill 支持
 * - 但行为可能与 JavaScript 不同
 *
 * 检测的特性：
 * - Lookbehind: (?<=...) (?<!...)
 * - Lookahead: (?=...) (?!...)
 * - 反向引用: \1 \2 等
 * - 命名捕获组: (?<name>...)
 * - 非贪婪量词边界情况
 */

module.exports = {
  meta: {
    type: 'suggestion',
    docs: {
      description: 'Warn against advanced regex features in TS-Skynet',
      category: 'Best Practices',
      recommended: 'warn',
    },
    fixable: null,
    schema: [],
    messages: {
      lookbehind:
        'Lookbehind (?<=...) 或 (?<!...) 在 Lua pattern 中不支持，' +
        '请使用简单 pattern + 代码解析替代。',
      lookahead:
        'Lookahead (?=...) 或 (?!...) 在 Lua pattern 中支持有限，' +
        '请验证行为或使用代码解析替代。',
      backreference:
        '反向引用 \\1, \\2 等在 Lua pattern 中支持有限，' +
        '请验证行为或重构正则。',
      namedGroup:
        '命名捕获组 (?<name>...) 在 Lua pattern 中不支持，' +
        '请使用普通捕获组 (...) 替代。',
    },
  },

  create(context) {
    /**
     * 检查正则表达式内容
     */
    function checkRegex(pattern, node) {
      const messages = [];

      // Lookbehind: (?<=...) 或 (?<!...)
      if (/\(\?<[=!]/.test(pattern)) {
        messages.push({ messageId: 'lookbehind' });
      }

      // Lookahead: (?=...) 或 (?!...)
      if (/\(\?[=!][^)]*\)/.test(pattern)) {
        messages.push({ messageId: 'lookahead' });
      }

      // 反向引用: \1, \2, \3 等（但不是 \d \w 等）
      if (/\\[1-9]/.test(pattern)) {
        messages.push({ messageId: 'backreference' });
      }

      // 命名捕获组: (?<name>...)
      if (/\(\?<[a-zA-Z][a-zA-Z0-9]*>/.test(pattern)) {
        messages.push({ messageId: 'namedGroup' });
      }

      return messages;
    }

    return {
      // 检测正则字面量: /pattern/flags
      Literal(node) {
        if (node.regex) {
          const messages = checkRegex(node.regex.pattern, node);
          for (const msg of messages) {
            context.report({
              node,
              messageId: msg.messageId,
            });
          }
        }
      },

      // 检测 RegExp 构造函数: new RegExp('pattern')
      NewExpression(node) {
        if (
          node.callee.type === 'Identifier' &&
          node.callee.name === 'RegExp' &&
          node.arguments.length > 0 &&
          node.arguments[0].type === 'Literal' &&
          typeof node.arguments[0].value === 'string'
        ) {
          const messages = checkRegex(node.arguments[0].value, node);
          for (const msg of messages) {
            context.report({
              node,
              messageId: msg.messageId,
            });
          }
        }
      },

      // 检测 RegExp 调用: RegExp('pattern')
      CallExpression(node) {
        if (
          node.callee.type === 'Identifier' &&
          node.callee.name === 'RegExp' &&
          node.arguments.length > 0 &&
          node.arguments[0].type === 'Literal' &&
          typeof node.arguments[0].value === 'string'
        ) {
          const messages = checkRegex(node.arguments[0].value, node);
          for (const msg of messages) {
            context.report({
              node,
              messageId: msg.messageId,
            });
          }
        }
      },
    };
  },
};
