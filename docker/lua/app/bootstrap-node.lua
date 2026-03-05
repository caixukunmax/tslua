local ____lualib = require("lualib_bundle")
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 5,["6"] = 5,["7"] = 6,["8"] = 6,["9"] = 12,["10"] = 13,["11"] = 14,["12"] = 9,["13"] = 16,["14"] = 17,["15"] = 18});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local setRuntime = ____interfaces.setRuntime
local ____node_2Dadapter = require("framework.runtime.node-adapter")
local createNodeRuntime = ____node_2Dadapter.createNodeRuntime
require("app.services.gateway.index")
require("app.services.login.index")
require("app.services.game.index")
setRuntime(createNodeRuntime())
console:log("========================================")
console:log("  Game Server Starting (Node.js Mode)  ")
console:log("========================================")
return ____exports
