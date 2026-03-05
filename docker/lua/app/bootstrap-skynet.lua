local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 6,["6"] = 6,["7"] = 7,["8"] = 7,["9"] = 10,["10"] = 13,["11"] = 14,["12"] = 15});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local setRuntime = ____interfaces.setRuntime
local ____skynet_2Dadapter = require("framework.runtime.skynet-adapter")
local createSkynetRuntime = ____skynet_2Dadapter.createSkynetRuntime
setRuntime(createSkynetRuntime())
____require(nil, "./services/gateway/index")
____require(nil, "./services/login/index")
____require(nil, "./services/game/index")
return ____exports
