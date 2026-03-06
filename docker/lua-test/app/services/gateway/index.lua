local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 7,["10"] = 7,["11"] = 8,["12"] = 8,["13"] = 9,["14"] = 9,["15"] = 10,["16"] = 10,["17"] = 10,["18"] = 15,["19"] = 18,["21"] = 23,["24"] = 24,["25"] = 25,["28"] = 26,["29"] = 27,["30"] = 30,["31"] = 31,["32"] = 31,["33"] = 31,["34"] = 31,["35"] = 31,["36"] = 36,["37"] = 37,["39"] = 39,["44"] = 44,["47"] = 45,["48"] = 46,["49"] = 49,["50"] = 50,["51"] = 54,["53"] = 57,["57"] = 61,["60"] = 62,["61"] = 63,["62"] = 64,["66"] = 68,["69"] = 69,["70"] = 70,["71"] = 71,["75"] = 75,["78"] = 76,["79"] = 77,["83"] = 81,["86"] = 82,["87"] = 83,["88"] = 84,["92"] = 88,["95"] = 89,["96"] = 90,["97"] = 91,["101"] = 95,["104"] = 96,["105"] = 97,["110"] = 102,["111"] = 103,["115"] = 23,["117"] = 110,["119"] = 111,["120"] = 112,["124"] = 118,["125"] = 119,["126"] = 122,["127"] = 122,["128"] = 122,["129"] = 122,["130"] = 127,["131"] = 128,["133"] = 116,["136"] = 130,["138"] = 116,["140"] = 110,["142"] = 137,["144"] = 138,["145"] = 139,["149"] = 145,["150"] = 145,["151"] = 145,["152"] = 147,["153"] = 148,["154"] = 149,["155"] = 152,["156"] = 153,["157"] = 153,["158"] = 153,["159"] = 153,["160"] = 153,["161"] = 153,["162"] = 153,["163"] = 158,["165"] = 160,["168"] = 143,["171"] = 163,["172"] = 164,["173"] = 164,["174"] = 164,["175"] = 164,["177"] = 143,["179"] = 137,["180"] = 169,["182"] = 170,["183"] = 171,["184"] = 174,["185"] = 174,["186"] = 174,["187"] = 174,["189"] = 175,["191"] = 179,["192"] = 180,["193"] = 181,["194"] = 182,["196"] = 184,["199"] = 177,["202"] = 187,["203"] = 188,["204"] = 188,["205"] = 188,["206"] = 188,["208"] = 177,["210"] = 174,["211"] = 174,["212"] = 192,["213"] = 193,["215"] = 169});
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
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
    end)
end)
return ____exports
