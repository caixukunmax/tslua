local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 7,["10"] = 7,["13"] = 15,["14"] = 15,["15"] = 15,["16"] = 16,["17"] = 16,["18"] = 16,["19"] = 21,["21"] = 22,["22"] = 24,["23"] = 24,["24"] = 24,["25"] = 24,["26"] = 25,["27"] = 30,["29"] = 21,["30"] = 36,["32"] = 37,["33"] = 39,["34"] = 40,["35"] = 41,["36"] = 42,["38"] = 48,["39"] = 49,["40"] = 50,["42"] = 53,["44"] = 36,["45"] = 59,["47"] = 60,["48"] = 61,["49"] = 62,["50"] = 63,["52"] = 66,["53"] = 76,["55"] = 59,["56"] = 82,["58"] = 83,["59"] = 84,["60"] = 85,["62"] = 87,["64"] = 89,["66"] = 82,["67"] = 95,["68"] = 96,["69"] = 95,["70"] = 102,["71"] = 103,["72"] = 102,["73"] = 109,["74"] = 110,["75"] = 109,["76"] = 116,["78"] = 117,["79"] = 118,["80"] = 120,["82"] = 123,["84"] = 121,["87"] = 125,["88"] = 125,["89"] = 125,["90"] = 125,["92"] = 121,["95"] = 116,["96"] = 133,["98"] = 134,["99"] = 136,["100"] = 137,["101"] = 138,["105"] = 145,["108"] = 133});
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
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
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
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
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
function GatewayLogic.prototype.handleForward(self, connId, _message)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
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
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
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
function GatewayLogic.prototype.broadcast(self, _message)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        local connections = self.data:getAllConnections()
        runtime.logger:info(("Broadcasting message to " .. tostring(#connections)) .. " connections")
        for ____, conn in ipairs(connections) do
            local ____try = __TS__AsyncAwaiterSkynet(function()
                runtime.logger:debug("Broadcast to connId: " .. tostring(conn.connId))
            end)
            __TS__AwaitSkynet(____try.catch(
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
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        runtime.logger:info((("Kicking connId " .. tostring(connId)) .. ", reason: ") .. reason)
        local conn = self.data:getConnection(connId)
        if not conn then
            return ____awaiter_resolve(nil, false)
        end
        return ____awaiter_resolve(
            nil,
            __TS__AwaitSkynet(self:handleDisconnect(connId))
        )
    end)
end
return ____exports
