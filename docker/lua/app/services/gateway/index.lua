local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["10"] = 7,["11"] = 7,["12"] = 8,["13"] = 8,["14"] = 9,["15"] = 9,["16"] = 10,["17"] = 10,["18"] = 10,["19"] = 10,["20"] = 16,["21"] = 19,["23"] = 24,["26"] = 25,["27"] = 26,["30"] = 27,["31"] = 28,["32"] = 31,["33"] = 32,["34"] = 32,["35"] = 32,["36"] = 32,["37"] = 32,["38"] = 32,["39"] = 38,["40"] = 39,["42"] = 41,["47"] = 46,["50"] = 47,["51"] = 48,["52"] = 51,["53"] = 52,["54"] = 56,["56"] = 59,["60"] = 63,["63"] = 64,["64"] = 65,["65"] = 66,["69"] = 70,["72"] = 71,["73"] = 72,["74"] = 73,["78"] = 77,["81"] = 78,["82"] = 79,["86"] = 83,["89"] = 84,["90"] = 85,["91"] = 86,["95"] = 90,["98"] = 91,["99"] = 92,["100"] = 93,["104"] = 97,["107"] = 98,["108"] = 99,["113"] = 104,["114"] = 105,["118"] = 24,["120"] = 112,["122"] = 113,["123"] = 114,["127"] = 120,["128"] = 121,["129"] = 124,["130"] = 124,["131"] = 124,["132"] = 124,["133"] = 129,["134"] = 130,["136"] = 118,["139"] = 132,["141"] = 118,["143"] = 112,["145"] = 139,["147"] = 140,["148"] = 141,["152"] = 147,["153"] = 147,["154"] = 147,["155"] = 149,["156"] = 150,["157"] = 151,["158"] = 154,["159"] = 155,["160"] = 155,["161"] = 155,["162"] = 155,["163"] = 155,["164"] = 155,["165"] = 155,["166"] = 160,["168"] = 162,["171"] = 145,["174"] = 165,["175"] = 166,["176"] = 166,["177"] = 166,["178"] = 166,["180"] = 145,["182"] = 139,["183"] = 173,["184"] = 174,["185"] = 175,["186"] = 178,["187"] = 178,["188"] = 178,["189"] = 178,["191"] = 179,["193"] = 183,["194"] = 184,["195"] = 185,["196"] = 186,["198"] = 188,["201"] = 181,["204"] = 191,["205"] = 192,["206"] = 192,["207"] = 192,["208"] = 192,["210"] = 181,["212"] = 178,["213"] = 178,["214"] = 196,["215"] = 197,["216"] = 201,["217"] = 201,["219"] = 202,["220"] = 203,["221"] = 204,["223"] = 201,["224"] = 206,["225"] = 173});
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
local ErrorCode = ____protos.ErrorCode
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
                            code = connId > 0 and ErrorCode.SUCCESS or ErrorCode.INTERNAL_ERROR,
                            message = connId > 0 and "Connected successfully" or "Connection failed",
                            connId = connId,
                            serverTime = Date:now()
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
                onlineCount = logic:getOnlineCount()
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
            if msgId == MessageId.LOGIN_LOGIN_REQ then
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
