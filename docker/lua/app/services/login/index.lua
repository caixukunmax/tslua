local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 7,["10"] = 7,["11"] = 8,["12"] = 8,["13"] = 9,["14"] = 9,["15"] = 11,["16"] = 11,["17"] = 11,["18"] = 17,["19"] = 20,["21"] = 25,["22"] = 26,["23"] = 27,["24"] = 28,["25"] = 29,["26"] = 30,["27"] = 30,["28"] = 30,["29"] = 30,["30"] = 30,["31"] = 29,["32"] = 38,["33"] = 26,["34"] = 25,["37"] = 46,["40"] = 47,["41"] = 48,["44"] = 49,["45"] = 50,["46"] = 53,["47"] = 54,["48"] = 55,["49"] = 56,["51"] = 59,["56"] = 64,["59"] = 65,["60"] = 66,["61"] = 67,["65"] = 71,["68"] = 72,["69"] = 73,["70"] = 74,["74"] = 78,["77"] = 79,["78"] = 80,["79"] = 81,["83"] = 85,["86"] = 86,["87"] = 87,["91"] = 91,["94"] = 92,["95"] = 93,["100"] = 98,["101"] = 99,["105"] = 46,["107"] = 106,["109"] = 107,["110"] = 108,["111"] = 110,["113"] = 111,["115"] = 110,["116"] = 114,["117"] = 117,["118"] = 118,["119"] = 119,["122"] = 106,["123"] = 125,["124"] = 126,["125"] = 127,["126"] = 130,["127"] = 130,["128"] = 130,["129"] = 130,["131"] = 131,["133"] = 134,["135"] = 133,["138"] = 136,["139"] = 137,["140"] = 137,["141"] = 137,["142"] = 137,["143"] = 137,["145"] = 133,["147"] = 130,["148"] = 130,["149"] = 142,["150"] = 144,["151"] = 145,["152"] = 148,["153"] = 148,["155"] = 149,["156"] = 150,["157"] = 151,["159"] = 148,["160"] = 153,["161"] = 125});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
local ____data = require("app.services.login.data")
local SessionData = ____data.SessionData
local ____logic = require("app.services.login.logic")
local LoginLogic = ____logic.LoginLogic
local ____protos = require("protos.index")
local proto = ____protos.proto
local ErrorCode = ____protos.ErrorCode
local data = __TS__New(SessionData)
local logic = __TS__New(LoginLogic, data)
--- 构建 proto 格式的登录响应
local function buildProtoLoginResponse(response)
    local ____proto_login_LoginResponse_create_5 = proto.login.LoginResponse.create
    local ____temp_2 = response.success and ErrorCode.SUCCESS or ErrorCode.UNAUTHORIZED
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
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        repeat
            local ____switch4 = cmd
            local ____cond4 = ____switch4 == "login"
            if ____cond4 then
                do
                    local username, password = table.unpack(args, 1, 2)
                    local response = __TS__AwaitSkynet(logic:handleLogin({username = username, password = password}))
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
                    local success = __TS__AwaitSkynet(logic:handleLogout(userId))
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
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        local cleanupInterval = 60000
        local expireTime = 3600000
        local function cleanup()
            return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
                __TS__AwaitSkynet(logic:cleanExpiredSessions(expireTime))
            end)
        end
        runtime.logger:info("Session cleaner started")
        while true do
            __TS__AwaitSkynet(cleanup())
            __TS__AwaitSkynet(runtime.timer:sleep(cleanupInterval))
        end
    end)
end
runtime.service:start(function()
    runtime.logger:info("=== Login Service Starting ===")
    runtime.logger:info("Service address: " .. runtime.service:self())
    runtime.network:dispatch(
        "lua",
        function(session, source, cmd, ...)
            local args = {...}
            return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
                runtime.logger:debug((("Login received command: " .. cmd) .. " from ") .. source)
                local ____try = __TS__AsyncAwaiterSkynet(function()
                    __TS__AwaitSkynet(handleCommand(cmd, args))
                end)
                __TS__AwaitSkynet(____try.catch(
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
    local keepAlive
    keepAlive = function()
        return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
            __TS__AwaitSkynet(runtime.timer:sleep(30000))
            runtime.logger:debug("[Login] Keep alive, sessions: " .. tostring(data:getCount()))
            keepAlive()
        end)
    end
    keepAlive()
end)
return ____exports
