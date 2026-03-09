local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 7,["10"] = 7,["11"] = 8,["12"] = 8,["13"] = 9,["14"] = 9,["15"] = 10,["16"] = 10,["17"] = 10,["18"] = 16,["19"] = 19,["21"] = 24,["24"] = 25,["25"] = 26,["28"] = 27,["29"] = 28,["30"] = 31,["31"] = 32,["32"] = 32,["33"] = 32,["34"] = 32,["35"] = 32,["36"] = 37,["37"] = 38,["39"] = 40,["44"] = 45,["47"] = 46,["48"] = 47,["49"] = 50,["50"] = 51,["51"] = 55,["53"] = 58,["57"] = 62,["60"] = 63,["61"] = 64,["62"] = 65,["66"] = 69,["69"] = 70,["70"] = 71,["71"] = 72,["75"] = 76,["78"] = 77,["79"] = 78,["83"] = 82,["86"] = 83,["87"] = 84,["88"] = 85,["92"] = 89,["95"] = 90,["96"] = 91,["97"] = 92,["101"] = 96,["104"] = 97,["105"] = 98,["110"] = 103,["111"] = 104,["115"] = 24,["117"] = 111,["119"] = 112,["120"] = 113,["124"] = 119,["125"] = 120,["126"] = 123,["127"] = 123,["128"] = 123,["129"] = 123,["130"] = 128,["131"] = 129,["133"] = 117,["136"] = 131,["138"] = 117,["140"] = 111,["142"] = 138,["144"] = 139,["145"] = 140,["149"] = 146,["150"] = 146,["151"] = 146,["152"] = 148,["153"] = 149,["154"] = 150,["155"] = 153,["156"] = 154,["157"] = 154,["158"] = 154,["159"] = 154,["160"] = 154,["161"] = 154,["162"] = 154,["163"] = 159,["165"] = 161,["168"] = 144,["171"] = 164,["172"] = 165,["173"] = 165,["174"] = 165,["175"] = 165,["177"] = 144,["179"] = 138,["180"] = 172,["181"] = 173,["182"] = 174,["183"] = 177,["184"] = 177,["185"] = 177,["186"] = 177,["188"] = 178,["190"] = 182,["191"] = 183,["192"] = 184,["193"] = 185,["195"] = 187,["198"] = 180,["201"] = 190,["202"] = 191,["203"] = 191,["204"] = 191,["205"] = 191,["207"] = 180,["209"] = 177,["210"] = 177,["211"] = 195,["212"] = 196,["213"] = 200,["214"] = 200,["216"] = 201,["217"] = 202,["218"] = 203,["220"] = 200,["221"] = 205,["222"] = 172});
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        repeat
            local ____switch3 = cmd
            local ____cond3 = ____switch3 == "connect"
            if ____cond3 then
                do
                    local clientInfo = table.unpack(args, 1, 1)
                    local connId = __TS__Await(logic:handleConnect(clientInfo))
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
                    local success = __TS__Await(logic:handleDisconnect(connId))
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
                    local success = __TS__Await(logic:handleForward(connId, message))
                    runtime.network:ret(success)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "bind_user"
            if ____cond3 then
                do
                    local connId, userId = table.unpack(args, 1, 2)
                    local success = __TS__Await(logic:handleBindUser(connId, userId))
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
                    __TS__Await(logic:broadcast(message))
                    runtime.network:ret(true)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "kick"
            if ____cond3 then
                do
                    local connId, reason = table.unpack(args, 1, 2)
                    local success = __TS__Await(logic:kickConnection(connId, reason or "kicked"))
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        if not runtime.codec then
            runtime.logger:warn("Codec not available for heartbeat")
            return ____awaiter_resolve(nil)
        end
        local ____try = __TS__AsyncAwaiter(function()
            local heartbeat = runtime.codec:decode("gateway.HeartbeatRequest", packetData)
            local clientTime = heartbeat.clientTime
            local response = proto.gateway.HeartbeatResponse.create({
                serverTime = runtime.timer:now(),
                clientTime = clientTime
            })
            local encoded = runtime.codec:encode("gateway.HeartbeatResponse", response)
            runtime.network:ret(encoded)
        end)
        __TS__Await(____try.catch(
            ____try,
            function(____, ____error)
                runtime.logger:error("Heartbeat error:", ____error)
            end
        ))
    end)
end
--- 转发消息到登录服务（演示服务间 protobuf 通信）
local function forwardToLogin(packetData)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        if not runtime.codec then
            runtime.network:ret(false, "Codec not available")
            return ____awaiter_resolve(nil)
        end
        local ____try = __TS__AsyncAwaiter(function()
            local ____temp_0 = runtime.codec:unpack(packetData)
            local msgId = ____temp_0.msgId
            local message = ____temp_0.message
            if msgId == MessageId.LOGIN_REQ then
                local loginReq = message
                runtime.logger:info("Forwarding login request: " .. loginReq.username)
                local loginService = __TS__Await(runtime.service:newService("login"))
                local response = __TS__Await(runtime.network:call(
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
        __TS__Await(____try.catch(
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
            return __TS__AsyncAwaiter(function(____awaiter_resolve)
                runtime.logger:debug((("Gateway received command: " .. cmd) .. " from ") .. source)
                local ____try = __TS__AsyncAwaiter(function()
                    if cmd == "heartbeat" and __TS__InstanceOf(args[1], Uint8Array) then
                        __TS__Await(handleHeartbeat(args[1]))
                    elseif cmd == "forward_login" and __TS__InstanceOf(args[1], Uint8Array) then
                        __TS__Await(forwardToLogin(args[1]))
                    else
                        __TS__Await(handleCommand(cmd, args))
                    end
                end)
                __TS__Await(____try.catch(
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
        return __TS__AsyncAwaiter(function(____awaiter_resolve)
            __TS__Await(runtime.timer:sleep(30000))
            runtime.logger:debug("[Gateway] Keep alive, connections: " .. tostring(data:getCount()))
            keepAlive()
        end)
    end
    keepAlive()
end)
return ____exports
