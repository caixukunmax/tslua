local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__Promise = ____lualib.__TS__Promise
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local Map = ____lualib.Map
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["11"] = 14,["12"] = 14,["14"] = 19,["15"] = 19,["16"] = 19,["18"] = 19,["19"] = 20,["20"] = 21,["21"] = 20,["22"] = 24,["23"] = 25,["24"] = 24,["25"] = 28,["26"] = 29,["27"] = 28,["28"] = 32,["29"] = 33,["30"] = 32,["32"] = 40,["33"] = 40,["34"] = 40,["36"] = 40,["37"] = 41,["38"] = 42,["39"] = 42,["40"] = 42,["41"] = 42,["42"] = 41,["43"] = 45,["44"] = 46,["45"] = 45,["46"] = 49,["50"] = 50,["51"] = 50,["52"] = 50,["53"] = 50,["54"] = 50,["55"] = 50,["56"] = 50,["59"] = 49,["60"] = 53,["61"] = 54,["62"] = 53,["63"] = 60,["64"] = 61,["65"] = 61,["66"] = 62,["67"] = 64,["68"] = 65,["69"] = 66,["70"] = 65,["72"] = 61,["73"] = 61,["74"] = 61,["75"] = 60,["76"] = 75,["77"] = 76,["78"] = 77,["79"] = 78,["80"] = 79,["81"] = 80,["82"] = 79,["84"] = 76,["85"] = 75,["88"] = 91,["89"] = 91,["90"] = 91,["92"] = 92,["93"] = 93,["94"] = 94,["95"] = 91,["96"] = 96,["97"] = 96,["98"] = 98,["99"] = 96,["100"] = 101,["101"] = 101,["105"] = 103,["106"] = 103,["107"] = 103,["108"] = 104,["109"] = 104,["110"] = 104,["111"] = 104,["112"] = 105,["113"] = 107,["114"] = 107,["115"] = 107,["116"] = 107,["117"] = 110,["118"] = 110,["119"] = 111,["120"] = 112,["121"] = 113,["122"] = 114,["124"] = 110,["125"] = 110,["126"] = 110,["127"] = 103,["128"] = 103,["131"] = 101,["132"] = 120,["133"] = 121,["134"] = 122,["135"] = 120,["136"] = 125,["137"] = 125,["138"] = 126,["139"] = 125,["141"] = 133,["142"] = 133,["143"] = 133,["145"] = 134,["146"] = 133,["147"] = 136,["148"] = 137,["149"] = 139,["152"] = 141,["154"] = 140,["157"] = 143,["159"] = 140,["161"] = 139,["162"] = 136,["163"] = 148,["164"] = 149,["165"] = 148,["166"] = 154,["167"] = 154,["169"] = 156,["170"] = 157,["171"] = 158,["173"] = 154,["174"] = 161,["175"] = 162,["176"] = 161,["177"] = 165,["178"] = 166,["179"] = 165,["180"] = 169,["181"] = 170,["182"] = 169,["184"] = 177,["185"] = 178,["188"] = 183,["191"] = 181,["197"] = 186,["198"] = 186,["199"] = 186,["200"] = 186,["201"] = 186,["202"] = 186,["203"] = 186,["204"] = 177});
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
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
        return __TS__AsyncAwaiter(function(____awaiter_resolve)
            local ____try = __TS__AsyncAwaiter(function()
                __TS__Await(callback())
            end)
            __TS__Await(____try.catch(
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
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
