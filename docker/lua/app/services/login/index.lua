local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 7,["9"] = 7,["10"] = 8,["11"] = 8,["12"] = 9,["13"] = 9,["14"] = 10,["15"] = 10,["16"] = 15,["17"] = 18,["18"] = 21,["20"] = 26,["21"] = 27,["22"] = 28,["23"] = 29,["24"] = 30,["25"] = 31,["26"] = 31,["27"] = 31,["28"] = 31,["29"] = 31,["30"] = 30,["31"] = 39,["32"] = 27,["33"] = 26,["36"] = 47,["39"] = 48,["40"] = 49,["43"] = 50,["44"] = 51,["45"] = 54,["46"] = 55,["47"] = 56,["48"] = 57,["50"] = 60,["55"] = 65,["58"] = 66,["59"] = 67,["60"] = 68,["64"] = 72,["67"] = 73,["68"] = 74,["69"] = 75,["73"] = 79,["76"] = 80,["77"] = 81,["78"] = 82,["82"] = 86,["85"] = 87,["86"] = 88,["90"] = 92,["93"] = 93,["94"] = 94,["99"] = 99,["100"] = 100,["104"] = 47,["106"] = 107,["107"] = 108,["108"] = 109,["109"] = 111,["111"] = 112,["113"] = 111,["114"] = 115,["115"] = 118,["116"] = 118,["117"] = 119,["120"] = 119,["121"] = 120,["122"] = 120,["123"] = 119,["125"] = 118,["126"] = 124,["127"] = 107,["128"] = 128,["130"] = 129,["131"] = 130,["132"] = 133,["133"] = 133,["134"] = 133,["135"] = 133,["137"] = 134,["139"] = 137,["141"] = 136,["144"] = 139,["145"] = 140,["146"] = 140,["147"] = 140,["148"] = 140,["149"] = 140,["151"] = 136,["153"] = 133,["154"] = 133,["155"] = 145,["156"] = 147,["157"] = 148,["159"] = 128});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
local ____data = require("app.services.login.data")
local SessionData = ____data.SessionData
local ____logic = require("app.services.login.logic")
local LoginLogic = ____logic.LoginLogic
local ____protos = require("protos.index")
local proto = ____protos.proto
local data = __TS__New(SessionData)
local logic = __TS__New(LoginLogic, data)
local cleanupTimer = nil
--- 构建 proto 格式的登录响应
local function buildProtoLoginResponse(response)
    local ____proto_login_LoginResponse_create_5 = proto.login.LoginResponse.create
    local ____temp_2 = response.success and proto.common.ErrorCode.SUCCESS or proto.common.ErrorCode.UNAUTHORIZED
    local ____temp_3 = response.error or ""
    local ____temp_4 = response.user and ({
        userId = response.user.userId,
        username = response.user.username,
        loginTime = response.user.loginTime,
        level = 1,
        exp = 0
    }) or nil
    local ____opt_0 = response.user
    return ____proto_login_LoginResponse_create_5({code = ____temp_2, message = ____temp_3, user = ____temp_4, token = ____opt_0 and ____opt_0.token})
end
--- 命令分发处理
-- 支持 proto 序列化
local function handleCommand(cmd, args)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        repeat
            local ____switch4 = cmd
            local ____cond4 = ____switch4 == "login"
            if ____cond4 then
                do
                    local username, password = table.unpack(args, 1, 2)
                    local response = __TS__Await(logic:handleLogin({username = username, password = password}))
                    if runtime.codec then
                        local protoResponse = buildProtoLoginResponse(response)
                        local encoded = runtime.codec:encode("login.LoginResponse", protoResponse)
                        runtime.network:ret(true, encoded)
                    else
                        runtime.network:ret(response.success, response.user, response.error)
                    end
                    break
                end
            end
            ____cond4 = ____cond4 or ____switch4 == "logout"
            if ____cond4 then
                do
                    local userId = table.unpack(args, 1, 1)
                    local success = __TS__Await(logic:handleLogout(userId))
                    runtime.network:ret(success)
                    break
                end
            end
            ____cond4 = ____cond4 or ____switch4 == "getUserInfo"
            if ____cond4 then
                do
                    local userId = table.unpack(args, 1, 1)
                    local user = logic:getUserInfo(userId)
                    runtime.network:ret(user)
                    break
                end
            end
            ____cond4 = ____cond4 or ____switch4 == "validateToken"
            if ____cond4 then
                do
                    local token = table.unpack(args, 1, 1)
                    local session = logic:validateToken(token)
                    runtime.network:ret(session)
                    break
                end
            end
            ____cond4 = ____cond4 or ____switch4 == "getOnlineCount"
            if ____cond4 then
                do
                    local count = logic:getOnlineCount()
                    runtime.network:ret(count)
                    break
                end
            end
            ____cond4 = ____cond4 or ____switch4 == "get_state"
            if ____cond4 then
                do
                    local state = data:exportState()
                    runtime.network:ret(state)
                    break
                end
            end
            do
                runtime.logger:warn("Unknown command: " .. cmd)
                runtime.network:ret(false, nil, "Unknown command")
            end
        until true
    end)
end
--- 启动会话清理定时器
local function startSessionCleaner()
    local cleanupInterval = 60000
    local expireTime = 3600000
    local function cleanup()
        return __TS__AsyncAwaiter(function(____awaiter_resolve)
            __TS__Await(logic:cleanExpiredSessions(expireTime))
        end)
    end
    runtime.logger:info("Session cleaner started")
    local runCleanup
    runCleanup = function()
        local ____self_7 = cleanup()
        ____self_7["then"](
            ____self_7,
            function()
                local ____self_6 = runtime.timer:sleep(cleanupInterval)
                ____self_6["then"](____self_6, runCleanup)
            end
        )
    end
    runCleanup()
end
runtime.service:start(function()
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info("=== Login Service Starting ===")
        runtime.logger:info("Service address: " .. runtime.service:self())
        runtime.network:dispatch(
            "lua",
            function(session, source, cmd, ...)
                local args = {...}
                return __TS__AsyncAwaiter(function(____awaiter_resolve)
                    runtime.logger:debug((("Login received command: " .. cmd) .. " from ") .. source)
                    local ____try = __TS__AsyncAwaiter(function()
                        __TS__Await(handleCommand(cmd, args))
                    end)
                    __TS__Await(____try.catch(
                        ____try,
                        function(____, ____error)
                            runtime.logger:error(("Command " .. cmd) .. " failed:", ____error)
                            runtime.network:ret(
                                false,
                                nil,
                                tostring(____error)
                            )
                        end
                    ))
                end)
            end
        )
        startSessionCleaner()
        runtime.logger:info("=== Login Service Ready ===")
        runtime.logger:info("Sessions: " .. tostring(data:getCount()))
    end)
end)
return ____exports
