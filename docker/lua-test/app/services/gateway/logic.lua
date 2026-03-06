local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 7,["9"] = 7,["12"] = 15,["13"] = 15,["14"] = 15,["15"] = 16,["16"] = 16,["17"] = 16,["18"] = 21,["20"] = 22,["21"] = 24,["22"] = 24,["23"] = 24,["24"] = 24,["25"] = 25,["26"] = 30,["28"] = 21,["29"] = 36,["31"] = 37,["32"] = 39,["33"] = 40,["34"] = 41,["35"] = 42,["37"] = 48,["38"] = 49,["39"] = 50,["41"] = 53,["43"] = 36,["44"] = 59,["46"] = 60,["47"] = 61,["48"] = 62,["49"] = 63,["51"] = 66,["52"] = 76,["54"] = 59,["55"] = 82,["57"] = 83,["58"] = 84,["59"] = 85,["61"] = 87,["63"] = 89,["65"] = 82,["66"] = 95,["67"] = 96,["68"] = 95,["69"] = 102,["70"] = 103,["71"] = 102,["72"] = 109,["73"] = 110,["74"] = 109,["75"] = 116,["77"] = 117,["78"] = 118,["79"] = 120,["81"] = 123,["83"] = 121,["86"] = 125,["87"] = 125,["88"] = 125,["89"] = 125,["91"] = 121,["94"] = 116,["95"] = 133,["97"] = 134,["98"] = 136,["99"] = 137,["100"] = 138,["104"] = 145,["107"] = 133});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
--- 网关业务逻辑
-- 这个类可以被热更新，不持有任何状态
____exports.GatewayLogic = __TS__Class()
local GatewayLogic = ____exports.GatewayLogic
GatewayLogic.name = "GatewayLogic"
function GatewayLogic.prototype.____constructor(self, data)
    self.data = data
end
function GatewayLogic.prototype.handleConnect(self, clientInfo)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info("Client connecting...")
        local connection = self.data:addConnection(
            clientInfo,
            runtime.timer:now()
        )
        runtime.logger:info("Client connected, connId: " .. tostring(connection.connId))
        return ____awaiter_resolve(nil, connection.connId)
    end)
end
function GatewayLogic.prototype.handleDisconnect(self, connId)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info("Client disconnecting, connId: " .. tostring(connId))
        local conn = self.data:getConnection(connId)
        if not conn then
            runtime.logger:warn(("Connection " .. tostring(connId)) .. " not found")
            return ____awaiter_resolve(nil, false)
        end
        local success = self.data:removeConnection(connId)
        if success then
            runtime.logger:info("Client disconnected, connId: " .. tostring(connId))
        end
        return ____awaiter_resolve(nil, success)
    end)
end
function GatewayLogic.prototype.handleForward(self, connId, message)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local conn = self.data:getConnection(connId)
        if not conn then
            runtime.logger:warn(("Connection " .. tostring(connId)) .. " not found")
            return ____awaiter_resolve(nil, false)
        end
        runtime.logger:debug("Forwarding message for connId: " .. tostring(connId))
        return ____awaiter_resolve(nil, true)
    end)
end
function GatewayLogic.prototype.handleBindUser(self, connId, userId)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local success = self.data:bindUser(connId, userId)
        if success then
            runtime.logger:info((("Bound userId " .. tostring(userId)) .. " to connId ") .. tostring(connId))
        else
            runtime.logger:warn((("Failed to bind userId " .. tostring(userId)) .. " to connId ") .. tostring(connId))
        end
        return ____awaiter_resolve(nil, success)
    end)
end
function GatewayLogic.prototype.getOnlineCount(self)
    return self.data:getCount()
end
function GatewayLogic.prototype.getAllConnections(self)
    return self.data:getAllConnections()
end
function GatewayLogic.prototype.findConnectionByUserId(self, userId)
    return self.data:findByUserId(userId)
end
function GatewayLogic.prototype.broadcast(self, message)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local connections = self.data:getAllConnections()
        runtime.logger:info(("Broadcasting message to " .. tostring(#connections)) .. " connections")
        for ____, conn in ipairs(connections) do
            local ____try = __TS__AsyncAwaiter(function()
                runtime.logger:debug("Broadcast to connId: " .. tostring(conn.connId))
            end)
            __TS__Await(____try.catch(
                ____try,
                function(____, ____error)
                    runtime.logger:error(
                        ("Failed to broadcast to connId " .. tostring(conn.connId)) .. ":",
                        ____error
                    )
                end
            ))
        end
    end)
end
function GatewayLogic.prototype.kickConnection(self, connId, reason)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info((("Kicking connId " .. tostring(connId)) .. ", reason: ") .. reason)
        local conn = self.data:getConnection(connId)
        if not conn then
            return ____awaiter_resolve(nil, false)
        end
        return ____awaiter_resolve(
            nil,
            __TS__Await(self:handleDisconnect(connId))
        )
    end)
end
return ____exports
