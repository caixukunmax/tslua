local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 46,["7"] = 48,["8"] = 50,["9"] = 52,["10"] = 54,["11"] = 56});
local ____exports = {}
--- 消息类型枚举
____exports.MessageType = ____exports.MessageType or ({})
____exports.MessageType.HEARTBEAT = "heartbeat"
____exports.MessageType.CHAT = "chat"
____exports.MessageType.GAME = "game"
____exports.MessageType.SYSTEM = "system"
____exports.MessageType.NOTIFICATION = "notification"
return ____exports
