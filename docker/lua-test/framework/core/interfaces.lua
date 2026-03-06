local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 186,["7"] = 187,["8"] = 188,["11"] = 195,["12"] = 196,["14"] = 201,["15"] = 203,["16"] = 204,["17"] = 205,["18"] = 206,["19"] = 207,["20"] = 208,["21"] = 209,["22"] = 201});
local ____exports = {}
--- 运行时环境类型
____exports.RuntimeEnvironment = RuntimeEnvironment or ({})
____exports.RuntimeEnvironment.NODE = "node"
____exports.RuntimeEnvironment.SKYNET = "skynet"
--- 全局运行时实例
-- 注意：由于 TSTL 的模块缓存机制，需要使用可变对象
local _runtime = {}
____exports.runtime = _runtime
--- 设置运行时
function ____exports.setRuntime(rt)
    local r = _runtime
    r.logger = rt.logger
    r.timer = rt.timer
    r.network = rt.network
    r.service = rt.service
    r.database = rt.database
    r.codec = rt.codec
end
return ____exports
