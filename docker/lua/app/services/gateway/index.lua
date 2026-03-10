local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["10"] = 7,["11"] = 7,["12"] = 8,["13"] = 8,["14"] = 9,["15"] = 9,["16"] = 10,["17"] = 10,["18"] = 10,["19"] = 16,["20"] = 19,["22"] = 24,["25"] = 25,["26"] = 26,["29"] = 27,["30"] = 28,["31"] = 31,["32"] = 32,["33"] = 32,["34"] = 32,["35"] = 32,["36"] = 32,["37"] = 37,["38"] = 38,["40"] = 40,["45"] = 45,["48"] = 46,["49"] = 47,["50"] = 50,["51"] = 51,["52"] = 55,["54"] = 58,["58"] = 62,["61"] = 63,["62"] = 64,["63"] = 65,["67"] = 69,["70"] = 70,["71"] = 71,["72"] = 72,["76"] = 76,["79"] = 77,["80"] = 78,["84"] = 82,["87"] = 83,["88"] = 84,["89"] = 85,["93"] = 89,["96"] = 90,["97"] = 91,["98"] = 92,["102"] = 96,["105"] = 97,["106"] = 98,["111"] = 103,["112"] = 104,["116"] = 24,["118"] = 111,["120"] = 112,["121"] = 113,["125"] = 119,["126"] = 120,["127"] = 123,["128"] = 123,["129"] = 123,["130"] = 123,["131"] = 128,["132"] = 129,["134"] = 117,["137"] = 131,["139"] = 117,["141"] = 111,["143"] = 138,["145"] = 139,["146"] = 140,["150"] = 146,["151"] = 146,["152"] = 146,["153"] = 148,["154"] = 149,["155"] = 150,["156"] = 153,["157"] = 154,["158"] = 154,["159"] = 154,["160"] = 154,["161"] = 154,["162"] = 154,["163"] = 154,["164"] = 159,["166"] = 161,["169"] = 144,["172"] = 164,["173"] = 165,["174"] = 165,["175"] = 165,["176"] = 165,["178"] = 144,["180"] = 138,["181"] = 172,["182"] = 173,["183"] = 174,["184"] = 177,["185"] = 177,["186"] = 177,["187"] = 177,["189"] = 178,["191"] = 182,["192"] = 183,["193"] = 184,["194"] = 185,["196"] = 187,["199"] = 180,["202"] = 190,["203"] = 191,["204"] = 191,["205"] = 191,["206"] = 191,["208"] = 180,["210"] = 177,["211"] = 177,["212"] = 195,["213"] = 196,["214"] = 200,["215"] = 200,["217"] = 201,["218"] = 202,["219"] = 203,["221"] = 200,["222"] = 205,["223"] = 172});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
local ____data = require("app.services.gateway.data")
local ConnectionData = ____data.ConnectionData
local ____logic = require("app.services.gateway.logic")
local GatewayLogic = ____logic.GatewayLogic
local ____protos = require("protos.index")
local MessageId = ____protos.MessageId
local proto = ____protos.proto
local data = __TS__New(ConnectionData)
local logic = __TS__New(GatewayLogic, data)
--- 命令分发处理
local function handleCommand(cmd, args)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        repeat
            local ____switch3 = cmd
            local ____cond3 = ____switch3 == "connect"
            if ____cond3 then
                do
                    local clientInfo = table.unpack(args, 1, 1)
                    local connId = __TS__AwaitSkynet(logic:handleConnect(clientInfo))
                    if runtime.codec then
                        local response = proto.gateway.ConnectResponse.create({
                            success = connId > 0,
                            message = connId > 0 and "Connected successfully" or "Connection failed",
                            sessionId = connId > 0 and "session_" .. tostring(connId) or nil
                        })
                        local encoded = runtime.codec:encode("gateway.ConnectResponse", response)
                        runtime.network:ret(connId, encoded)
                    else
                        runtime.network:ret(connId)
                    end
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "disconnect"
            if ____cond3 then
                do
                    local connId, reason = table.unpack(args, 1, 2)
                    local success = __TS__AwaitSkynet(logic:handleDisconnect(connId))
                    if runtime.codec and success then
                        local notify = proto.gateway.DisconnectNotify.create({reason = reason or "user_disconnect"})
                        runtime.logger:info("Disconnect notify: " .. notify.reason)
                    end
                    runtime.network:ret(success)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "forward"
            if ____cond3 then
                do
                    local connId, message = table.unpack(args, 1, 2)
                    local success = __TS__AwaitSkynet(logic:handleForward(connId, message))
                    runtime.network:ret(success)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "bind_user"
            if ____cond3 then
                do
                    local connId, userId = table.unpack(args, 1, 2)
                    local success = __TS__AwaitSkynet(logic:handleBindUser(connId, userId))
                    runtime.network:ret(success)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "online_count"
            if ____cond3 then
                do
                    local count = logic:getOnlineCount()
                    runtime.network:ret(count)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "broadcast"
            if ____cond3 then
                do
                    local message = table.unpack(args, 1, 1)
                    __TS__AwaitSkynet(logic:broadcast(message))
                    runtime.network:ret(true)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "kick"
            if ____cond3 then
                do
                    local connId, reason = table.unpack(args, 1, 2)
                    local success = __TS__AwaitSkynet(logic:kickConnection(connId, reason or "kicked"))
                    runtime.network:ret(success)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "get_state"
            if ____cond3 then
                do
                    local state = data:exportState()
                    runtime.network:ret(state)
                    break
                end
            end
            do
                runtime.logger:warn("Unknown command: " .. cmd)
                runtime.network:ret(false, "Unknown command")
            end
        until true
    end)
end
--- 处理客户端心跳（演示 protobuf 解包）
local function handleHeartbeat(packetData)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        if not runtime.codec then
            runtime.logger:warn("Codec not available for heartbeat")
            return ____awaiter_resolve(nil)
        end
        local ____try = __TS__AsyncAwaiterSkynet(function()
            local heartbeat = runtime.codec:decode("gateway.HeartbeatRequest", packetData)
            local clientTime = heartbeat.clientTime
            local response = proto.gateway.HeartbeatResponse.create({
                serverTime = runtime.timer:now(),
                clientTime = clientTime
            })
            local encoded = runtime.codec:encode("gateway.HeartbeatResponse", response)
            runtime.network:ret(encoded)
        end)
        __TS__AwaitSkynet(____try.catch(
            ____try,
            function(____, ____error)
                runtime.logger:error("Heartbeat error:", ____error)
            end
        ))
    end)
end
--- 转发消息到登录服务（演示服务间 protobuf 通信）
local function forwardToLogin(packetData)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        if not runtime.codec then
            runtime.network:ret(false, "Codec not available")
            return ____awaiter_resolve(nil)
        end
        local ____try = __TS__AsyncAwaiterSkynet(function()
            local ____temp_0 = runtime.codec:unpack(packetData)
            local msgId = ____temp_0.msgId
            local message = ____temp_0.message
            if msgId == MessageId.LOGIN_REQ then
                local loginReq = message
                runtime.logger:info("Forwarding login request: " .. loginReq.username)
                local loginService = __TS__AwaitSkynet(runtime.service:newService("login"))
                local response = __TS__AwaitSkynet(runtime.network:call(
                    loginService,
                    "lua",
                    "login",
                    loginReq.username,
                    loginReq.password
                ))
                runtime.network:ret(response)
            else
                runtime.network:ret(false, "Unknown message type")
            end
        end)
        __TS__AwaitSkynet(____try.catch(
            ____try,
            function(____, ____error)
                runtime.logger:error("Forward error:", ____error)
                runtime.network:ret(
                    false,
                    tostring(____error)
                )
            end
        ))
    end)
end
runtime.service:start(function()
    runtime.logger:info("=== Gateway Service Starting ===")
    runtime.logger:info("Service address: " .. runtime.service:self())
    runtime.network:dispatch(
        "lua",
        function(session, source, cmd, ...)
            local args = {...}
            return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
                runtime.logger:debug((("Gateway received command: " .. cmd) .. " from ") .. source)
                local ____try = __TS__AsyncAwaiterSkynet(function()
                    if cmd == "heartbeat" and __TS__InstanceOf(args[1], Uint8Array) then
                        __TS__AwaitSkynet(handleHeartbeat(args[1]))
                    elseif cmd == "forward_login" and __TS__InstanceOf(args[1], Uint8Array) then
                        __TS__AwaitSkynet(forwardToLogin(args[1]))
                    else
                        __TS__AwaitSkynet(handleCommand(cmd, args))
                    end
                end)
                __TS__AwaitSkynet(____try.catch(
                    ____try,
                    function(____, ____error)
                        runtime.logger:error(("Command " .. cmd) .. " failed:", ____error)
                        runtime.network:ret(
                            false,
                            tostring(____error)
                        )
                    end
                ))
            end)
        end
    )
    runtime.logger:info("=== Gateway Service Ready ===")
    runtime.logger:info("Connections: " .. tostring(data:getCount()))
    local keepAlive
    keepAlive = function()
        return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
            __TS__AwaitSkynet(runtime.timer:sleep(30000))
            runtime.logger:debug("[Gateway] Keep alive, connections: " .. tostring(data:getCount()))
            keepAlive()
        end)
    end
    keepAlive()
end)
return ____exports
