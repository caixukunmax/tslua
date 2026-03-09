local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["6"] = 201,["7"] = 202,["8"] = 203,["11"] = 210,["12"] = 211,["14"] = 216,["15"] = 218,["16"] = 219,["17"] = 220,["18"] = 221,["19"] = 222,["20"] = 223,["21"] = 224,["22"] = 216});
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
