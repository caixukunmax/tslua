import * as ts from "typescript";
import * as lua from "../../LuaAST";
import { TransformationContext } from "../context";
import { LuaLibFeature, transformLuaLibFunction } from "../utils/lualib";
import { isNumberType } from "../utils/typescript";
import { transformArguments } from "../visitors/call";
import { transformStringConstructorCall } from "./string";

export function tryTransformBuiltinGlobalCall(
    context: TransformationContext,
    node: ts.CallExpression,
    expressionType: ts.Type
): lua.Expression | undefined {
    function getParameters() {
        const signature = context.checker.getResolvedSignature(node);
        return transformArguments(context, node.arguments, signature);
    }

    const name = expressionType.symbol.name;
    switch (name) {
        case "SymbolConstructor":
            return transformLuaLibFunction(context, LuaLibFeature.Symbol, node, ...getParameters());
        case "NumberConstructor":
            return transformLuaLibFunction(context, LuaLibFeature.Number, node, ...getParameters());
        case "StringConstructor":
            return transformStringConstructorCall(node, ...getParameters());
        case "isNaN":
        case "isFinite":
            const numberParameters = isNumberType(context, expressionType)
                ? getParameters()
                : [transformLuaLibFunction(context, LuaLibFeature.Number, undefined, ...getParameters())];

            return transformLuaLibFunction(
                context,
                name === "isNaN" ? LuaLibFeature.NumberIsNaN : LuaLibFeature.NumberIsFinite,
                node,
                ...numberParameters
            );
        case "parseFloat":
            return transformLuaLibFunction(context, LuaLibFeature.ParseFloat, node, ...getParameters());
        case "parseInt":
            return transformLuaLibFunction(context, LuaLibFeature.ParseInt, node, ...getParameters());
    }
}

/**
 * Transform setTimeout/setImmediate/clearTimeout calls when skynetCompat is enabled
 */
export function tryTransformTimerCall(
    context: TransformationContext,
    node: ts.CallExpression
): lua.Expression | undefined {
    // Only transform when skynetCompat is enabled
    if (!context.options.skynetCompat) {
        return undefined;
    }

    if (!ts.isIdentifier(node.expression)) {
        return undefined;
    }

    const name = node.expression.text;
    const signature = context.checker.getResolvedSignature(node);
    const parameters = transformArguments(context, node.arguments, signature);

    switch (name) {
        case "setTimeout":
            return transformLuaLibFunction(context, LuaLibFeature.SetTimeoutSkynet, node, ...parameters);
        case "setImmediate":
            // setImmediate is equivalent to setTimeout(callback, 0)
            return transformLuaLibFunction(context, LuaLibFeature.SetTimeoutSkynet, node, ...parameters);
        case "clearTimeout":
            // clearTimeout is a no-op in Skynet
            return transformLuaLibFunction(context, LuaLibFeature.SetTimeoutSkynet, node, ...parameters);
    }

    return undefined;
}
