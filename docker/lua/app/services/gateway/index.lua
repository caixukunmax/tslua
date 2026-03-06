local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__Promise = ____lualib.__TS__Promise
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["10"] = 7,["11"] = 7,["12"] = 8,["13"] = 8,["14"] = 9,["15"] = 9,["16"] = 10,["17"] = 10,["18"] = 10,["19"] = 15,["20"] = 18,["22"] = 23,["25"] = 24,["26"] = 25,["29"] = 26,["30"] = 27,["31"] = 30,["32"] = 31,["33"] = 31,["34"] = 31,["35"] = 31,["36"] = 31,["37"] = 36,["38"] = 37,["40"] = 39,["45"] = 44,["48"] = 45,["49"] = 46,["50"] = 49,["51"] = 50,["52"] = 54,["54"] = 57,["58"] = 61,["61"] = 62,["62"] = 63,["63"] = 64,["67"] = 68,["70"] = 69,["71"] = 70,["72"] = 71,["76"] = 75,["79"] = 76,["80"] = 77,["84"] = 81,["87"] = 82,["88"] = 83,["89"] = 84,["93"] = 88,["96"] = 89,["97"] = 90,["98"] = 91,["102"] = 95,["105"] = 96,["106"] = 97,["111"] = 102,["112"] = 103,["116"] = 23,["118"] = 110,["120"] = 111,["121"] = 112,["125"] = 118,["126"] = 119,["127"] = 122,["128"] = 122,["129"] = 122,["130"] = 122,["131"] = 127,["132"] = 128,["134"] = 116,["137"] = 130,["139"] = 116,["141"] = 110,["143"] = 137,["145"] = 138,["146"] = 139,["150"] = 145,["151"] = 145,["152"] = 145,["153"] = 147,["154"] = 148,["155"] = 149,["156"] = 152,["157"] = 153,["158"] = 153,["159"] = 153,["160"] = 153,["161"] = 153,["162"] = 153,["163"] = 153,["164"] = 158,["166"] = 160,["169"] = 143,["172"] = 163,["173"] = 164,["174"] = 164,["175"] = 164,["176"] = 164,["178"] = 143,["180"] = 137,["181"] = 171,["182"] = 172,["183"] = 173,["184"] = 176,["185"] = 176,["186"] = 176,["187"] = 176,["188"] = 177,["189"] = 180,["192"] = 180,["194"] = 182,["195"] = 183,["196"] = 184,["197"] = 185,["199"] = 187,["202"] = 180,["203"] = 180,["204"] = 190,["205"] = 191,["206"] = 191,["207"] = 191,["208"] = 191,["209"] = 180,["210"] = 176,["211"] = 176,["212"] = 195,["213"] = 196,["214"] = 200,["215"] = 200,["216"] = 201,["219"] = 201,["220"] = 202,["221"] = 203,["222"] = 201,["224"] = 200,["225"] = 206,["226"] = 171});
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
            runtime.logger:debug((("Gateway received command: " .. cmd) .. " from ") .. source)
            local ____self_1 = __TS__Promise.resolve()
            ____self_1["then"](
                ____self_1,
                function()
                    return __TS__AsyncAwaiter(function(____awaiter_resolve)
                        if cmd == "heartbeat" and __TS__InstanceOf(args[1], Uint8Array) then
                            __TS__Await(handleHeartbeat(args[1]))
                        elseif cmd == "forward_login" and __TS__InstanceOf(args[1], Uint8Array) then
                            __TS__Await(forwardToLogin(args[1]))
                        else
                            __TS__Await(handleCommand(cmd, args))
                        end
                    end)
                end
            ):catch(function(____, ____error)
                runtime.logger:error(("Command " .. cmd) .. " failed:", ____error)
                runtime.network:ret(
                    false,
                    tostring(____error)
                )
            end)
        end
    )
    runtime.logger:info("=== Gateway Service Ready ===")
    runtime.logger:info("Connections: " .. tostring(data:getCount()))
    local keepAlive
    keepAlive = function()
        local ____self_2 = runtime.timer:sleep(30000)
        ____self_2["then"](
            ____self_2,
            function()
                runtime.logger:debug("[Gateway] Keep alive, connections: " .. tostring(data:getCount()))
                keepAlive()
            end
        )
    end
    keepAlive()
end)
return ____exports
