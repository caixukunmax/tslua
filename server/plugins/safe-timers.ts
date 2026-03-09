/**
 * TSTL Plugin: Safe Timers
 * 
 * 将 setTimeout/setImmediate 转换为协程安全的实现
 * 
 * 转换规则：
 * setTimeout(callback, ms) -> runtime.timer.safeTimeout(callback, ms)
 * setImmediate(callback) -> runtime.timer.safeImmediate(callback)
 * 
 * runtime.timer.safeTimeout 内部会创建 Skynet 协程包装回调
 */

import * as ts from "typescript";
import * as tstl from "typescript-to-lua";

const SAFE_TIMEOUT_MODULE = "../framework/core/interfaces";

const plugin: tstl.Plugin = {
    beforeEmit(program: ts.Program, options: tstl.CompilerOptions, emitHost: tstl.EmitHost, result: tstl.EmitFile[]) {
        // 编译完成后可以在这里处理结果
    },

    // 使用 visitor 模式转换 AST
    visitors: {
        // 拦截函数调用
        [ts.SyntaxKind.CallExpression]: (node, context) => {
            const call = node as ts.CallExpression;
            const expression = call.expression;
            
            // 检查是否是 setTimeout 或 setImmediate
            let functionName: string | null = null;
            
            if (ts.isIdentifier(expression)) {
                const name = expression.text;
                if (name === "setTimeout" || name === "setImmediate") {
                    functionName = name;
                }
            }
            
            if (!functionName) {
                // 不是目标函数，继续默认处理
                return context.superTransformExpression(node);
            }

            // 获取参数
            const args = call.arguments;
            if (args.length === 0) {
                // 没有回调函数，报错或保持原样
                return context.superTransformExpression(node);
            }

            const callback = args[0];
            const delay = args[1];

            // 创建 import 语句（如果还没有的话）
            // 这里简化处理，假设 runtime 已经可用
            
            // 构建转换后的调用：
            // runtime.timer.safeTimeout(callback, ms)
            // 或
            // runtime.timer.safeImmediate(callback)
            
            const methodName = functionName === "setTimeout" 
                ? "safeTimeout" 
                : "safeImmediate";

            // 创建 runtime.timer.safeTimeout 表达式
            const runtimeAccess = ts.factory.createPropertyAccessExpression(
                ts.factory.createIdentifier("runtime"),
                "timer"
            );
            
            const methodAccess = ts.factory.createPropertyAccessExpression(
                runtimeAccess,
                methodName
            );

            // 构建新参数列表
            const newArgs = [callback];
            if (functionName === "setTimeout" && delay) {
                newArgs.push(delay);
            }

            // 创建新的调用表达式
            const newCall = ts.factory.createCallExpression(
                methodAccess,
                undefined,
                newArgs
            );

            // 转换新的调用
            return context.transformExpression(newCall);
        }
    }
};

export default plugin;
