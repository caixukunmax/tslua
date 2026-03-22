local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 9,["7"] = 12,["8"] = 14,["9"] = 14,["10"] = 16,["11"] = 16,["12"] = 18,["13"] = 18,["14"] = 20,["15"] = 20,["16"] = 22,["17"] = 22,["18"] = 24,["19"] = 24,["20"] = 26,["21"] = 26,["22"] = 28,["23"] = 28,["24"] = 30,["25"] = 30,["26"] = 31,["27"] = 31});
local ____exports = {}
____exports.protobufPackage = "common"
--- 错误码定义
____exports.ErrorCode = ____exports.ErrorCode or ({})
____exports.ErrorCode.SUCCESS = 0
____exports.ErrorCode[____exports.ErrorCode.SUCCESS] = "SUCCESS"
____exports.ErrorCode.UNKNOWN_ERROR = 1
____exports.ErrorCode[____exports.ErrorCode.UNKNOWN_ERROR] = "UNKNOWN_ERROR"
____exports.ErrorCode.INVALID_REQUEST = 2
____exports.ErrorCode[____exports.ErrorCode.INVALID_REQUEST] = "INVALID_REQUEST"
____exports.ErrorCode.UNAUTHORIZED = 3
____exports.ErrorCode[____exports.ErrorCode.UNAUTHORIZED] = "UNAUTHORIZED"
____exports.ErrorCode.FORBIDDEN = 4
____exports.ErrorCode[____exports.ErrorCode.FORBIDDEN] = "FORBIDDEN"
____exports.ErrorCode.NOT_FOUND = 5
____exports.ErrorCode[____exports.ErrorCode.NOT_FOUND] = "NOT_FOUND"
____exports.ErrorCode.TIMEOUT = 6
____exports.ErrorCode[____exports.ErrorCode.TIMEOUT] = "TIMEOUT"
____exports.ErrorCode.INTERNAL_ERROR = 7
____exports.ErrorCode[____exports.ErrorCode.INTERNAL_ERROR] = "INTERNAL_ERROR"
____exports.ErrorCode.SERVICE_UNAVAILABLE = 8
____exports.ErrorCode[____exports.ErrorCode.SERVICE_UNAVAILABLE] = "SERVICE_UNAVAILABLE"
____exports.ErrorCode.UNRECOGNIZED = -1
____exports.ErrorCode[____exports.ErrorCode.UNRECOGNIZED] = "UNRECOGNIZED"
return ____exports
