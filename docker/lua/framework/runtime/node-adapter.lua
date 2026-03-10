local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__Promise = ____lualib.__TS__Promise
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local Map = ____lualib.Map
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["12"] = 14,["13"] = 14,["15"] = 19,["16"] = 19,["17"] = 19,["19"] = 19,["20"] = 20,["21"] = 21,["22"] = 20,["23"] = 24,["24"] = 25,["25"] = 24,["26"] = 28,["27"] = 29,["28"] = 28,["29"] = 32,["30"] = 33,["31"] = 32,["33"] = 40,["34"] = 40,["35"] = 40,["37"] = 40,["38"] = 41,["39"] = 42,["40"] = 42,["41"] = 42,["42"] = 42,["43"] = 41,["44"] = 45,["45"] = 46,["46"] = 45,["47"] = 49,["51"] = 50,["52"] = 50,["53"] = 50,["54"] = 50,["55"] = 50,["56"] = 50,["57"] = 50,["60"] = 49,["61"] = 53,["62"] = 54,["63"] = 53,["64"] = 60,["65"] = 61,["66"] = 61,["67"] = 62,["68"] = 64,["69"] = 65,["70"] = 66,["71"] = 65,["73"] = 61,["74"] = 61,["75"] = 61,["76"] = 60,["77"] = 75,["78"] = 76,["79"] = 77,["80"] = 78,["81"] = 79,["82"] = 80,["83"] = 79,["85"] = 76,["86"] = 75,["89"] = 91,["90"] = 91,["91"] = 91,["93"] = 92,["94"] = 93,["95"] = 94,["96"] = 91,["97"] = 96,["98"] = 96,["99"] = 98,["100"] = 96,["101"] = 101,["102"] = 101,["106"] = 103,["107"] = 103,["108"] = 103,["109"] = 104,["110"] = 104,["111"] = 104,["112"] = 104,["113"] = 105,["114"] = 107,["115"] = 107,["116"] = 107,["117"] = 107,["118"] = 110,["119"] = 110,["120"] = 111,["121"] = 112,["122"] = 113,["123"] = 114,["125"] = 110,["126"] = 110,["127"] = 110,["128"] = 103,["129"] = 103,["132"] = 101,["133"] = 120,["134"] = 121,["135"] = 122,["136"] = 120,["137"] = 125,["138"] = 125,["139"] = 126,["140"] = 125,["142"] = 133,["143"] = 133,["144"] = 133,["146"] = 134,["147"] = 133,["148"] = 136,["149"] = 137,["150"] = 139,["153"] = 141,["155"] = 140,["158"] = 143,["160"] = 140,["162"] = 139,["163"] = 136,["164"] = 148,["165"] = 149,["166"] = 148,["167"] = 154,["168"] = 154,["170"] = 156,["171"] = 157,["172"] = 158,["174"] = 154,["175"] = 161,["176"] = 162,["177"] = 161,["178"] = 165,["179"] = 166,["180"] = 165,["181"] = 169,["182"] = 170,["183"] = 169,["185"] = 177,["186"] = 178,["189"] = 183,["192"] = 181,["198"] = 186,["199"] = 186,["200"] = 186,["201"] = 186,["202"] = 186,["203"] = 186,["204"] = 186,["205"] = 177});
local ____exports = {}
local ____node_2Dpb_2Dcodec = require("framework.runtime.node-pb-codec")
local NodePbCodec = ____node_2Dpb_2Dcodec.NodePbCodec
--- Node.js 日志实现
____exports.NodeLogger = __TS__Class()
local NodeLogger = ____exports.NodeLogger
NodeLogger.name = "NodeLogger"
function NodeLogger.prototype.____constructor(self)
end
function NodeLogger.prototype.debug(self, message, ...)
    console:debug("[DEBUG] " .. message, ...)
end
function NodeLogger.prototype.info(self, message, ...)
    console:info("[INFO] " .. message, ...)
end
function NodeLogger.prototype.warn(self, message, ...)
    console:warn("[WARN] " .. message, ...)
end
function NodeLogger.prototype.error(self, message, ...)
    console:error("[ERROR] " .. message, ...)
end
--- Node.js 定时器实现
____exports.NodeTimer = __TS__Class()
local NodeTimer = ____exports.NodeTimer
NodeTimer.name = "NodeTimer"
function NodeTimer.prototype.____constructor(self)
end
function NodeTimer.prototype.setTimeout(self, ms, callback)
    return global:setTimeout(
        function() return callback() end,
        ms
    )
end
function NodeTimer.prototype.clearTimeout(self, handle)
    global:clearTimeout(handle)
end
function NodeTimer.prototype.sleep(self, ms)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        return ____awaiter_resolve(
            nil,
            __TS__New(
                __TS__Promise,
                function(____, resolve) return global:setTimeout(
                    function() return resolve(nil) end,
                    ms
                ) end
            )
        )
    end)
end
function NodeTimer.prototype.now(self)
    return math.floor(Date:now() / 1000)
end
function NodeTimer.prototype.safeTimeout(self, callback, ms)
    global:setTimeout(
        function()
            local result = callback()
            if result and type(result.catch) == "function" then
                result:catch(function(____, err)
                    console:error("[safeTimeout] Error:", err)
                end)
            end
        end,
        ms or 0
    )
end
function NodeTimer.prototype.safeImmediate(self, callback)
    global:setImmediate(function()
        local result = callback()
        if result and type(result.catch) == "function" then
            result:catch(function(____, err)
                console:error("[safeImmediate] Error:", err)
            end)
        end
    end)
end
--- Node.js 网络实现
-- 这里使用简单的事件模拟，实际应用可以使用 Socket.IO 或其他 RPC 框架
____exports.NodeNetwork = __TS__Class()
local NodeNetwork = ____exports.NodeNetwork
NodeNetwork.name = "NodeNetwork"
function NodeNetwork.prototype.____constructor(self)
    self.handlers = __TS__New(Map)
    self.sessionId = 1
    self.pendingCalls = __TS__New(Map)
end
function NodeNetwork.prototype.send(self, address, messageType, ...)
    local args = {...}
    console:log((("[NodeNetwork] SEND to " .. address) .. ", type: ") .. messageType, args)
end
function NodeNetwork.prototype.call(self, address, messageType, ...)
    local args = {...}
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        return ____awaiter_resolve(
            nil,
            __TS__New(
                __TS__Promise,
                function(____, resolve, reject)
                    local ____self_0, ____sessionId_1 = self, "sessionId"
                    local ____self_sessionId_2 = ____self_0[____sessionId_1]
                    ____self_0[____sessionId_1] = ____self_sessionId_2 + 1
                    local session = ____self_sessionId_2
                    self.pendingCalls:set(session, {resolve = resolve, reject = reject})
                    console:log(
                        (((("[NodeNetwork] CALL to " .. address) .. ", type: ") .. messageType) .. ", session: ") .. tostring(session),
                        args
                    )
                    global:setTimeout(
                        function()
                            local pending = self.pendingCalls:get(session)
                            if pending then
                                self.pendingCalls:delete(session)
                                pending:resolve({success = true, data = "mock response"})
                            end
                        end,
                        100
                    )
                end
            )
        )
    end)
end
function NodeNetwork.prototype.dispatch(self, messageType, handler)
    self.handlers:set(messageType, handler)
    console:log("[NodeNetwork] Registered handler for " .. messageType)
end
function NodeNetwork.prototype.ret(self, ...)
    local args = {...}
    console:log("[NodeNetwork] RET", args)
end
--- Node.js 服务实现
____exports.NodeService = __TS__Class()
local NodeService = ____exports.NodeService
NodeService.name = "NodeService"
function NodeService.prototype.____constructor(self)
    self.serviceId = "node-service-" .. tostring(Date:now())
end
function NodeService.prototype.start(self, callback)
    console:log("[NodeService] Starting service " .. self.serviceId)
    global:setImmediate(function()
        return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
            local ____try = __TS__AsyncAwaiterSkynet(function()
                __TS__AwaitSkynet(callback())
            end)
            __TS__AwaitSkynet(____try.catch(
                ____try,
                function(____, ____error)
                    console:error("[NodeService] Service start error:", ____error)
                end
            ))
        end)
    end)
end
function NodeService.prototype.exit(self)
    console:log("[NodeService] Exiting service " .. self.serviceId)
end
function NodeService.prototype.newService(self, name, ...)
    local args = {...}
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        local address = (("node-service-" .. name) .. "-") .. tostring(Date:now())
        console:log("[NodeService] Creating new service: " .. name, args)
        return ____awaiter_resolve(nil, address)
    end)
end
function NodeService.prototype.self(self)
    return self.serviceId
end
function NodeService.prototype.getenv(self, key)
    return process.env[key]
end
function NodeService.prototype.setenv(self, key, value)
    process.env[key] = value
end
--- 创建 Node.js 运行时
function ____exports.createNodeRuntime()
    local codec
    do
        local function ____catch(____error)
            console:warn("[NodeRuntime] PbCodec not available:", ____error)
        end
        local ____try, ____hasReturned = pcall(function()
            codec = __TS__New(NodePbCodec)
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
    return {
        logger = __TS__New(____exports.NodeLogger),
        timer = __TS__New(____exports.NodeTimer),
        network = __TS__New(____exports.NodeNetwork),
        service = __TS__New(____exports.NodeService),
        codec = codec
    }
end
return ____exports
