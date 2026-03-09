local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 7,["9"] = 7,["10"] = 8,["11"] = 8,["12"] = 9,["13"] = 9,["14"] = 11,["15"] = 11,["16"] = 17,["17"] = 20,["19"] = 25,["20"] = 26,["21"] = 27,["22"] = 28,["23"] = 29,["24"] = 30,["25"] = 30,["26"] = 30,["27"] = 30,["28"] = 30,["29"] = 29,["30"] = 38,["31"] = 26,["32"] = 25,["35"] = 46,["38"] = 47,["39"] = 48,["42"] = 49,["43"] = 50,["44"] = 53,["45"] = 54,["46"] = 55,["47"] = 56,["49"] = 59,["54"] = 64,["57"] = 65,["58"] = 66,["59"] = 67,["63"] = 71,["66"] = 72,["67"] = 73,["68"] = 74,["72"] = 78,["75"] = 79,["76"] = 80,["77"] = 81,["81"] = 85,["84"] = 86,["85"] = 87,["89"] = 91,["92"] = 92,["93"] = 93,["98"] = 98,["99"] = 99,["103"] = 46,["105"] = 106,["107"] = 107,["108"] = 108,["109"] = 110,["111"] = 111,["113"] = 110,["114"] = 114,["115"] = 117,["116"] = 118,["117"] = 119,["120"] = 106,["121"] = 125,["122"] = 126,["123"] = 127,["124"] = 130,["125"] = 130,["126"] = 130,["127"] = 130,["129"] = 131,["131"] = 134,["133"] = 133,["136"] = 136,["137"] = 137,["138"] = 137,["139"] = 137,["140"] = 137,["141"] = 137,["143"] = 133,["145"] = 130,["146"] = 130,["147"] = 142,["148"] = 144,["149"] = 145,["150"] = 148,["151"] = 148,["153"] = 149,["154"] = 150,["155"] = 151,["157"] = 148,["158"] = 153,["159"] = 125});
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local cleanupInterval = 60000
        local expireTime = 3600000
        local function cleanup()
            return __TS__AsyncAwaiter(function(____awaiter_resolve)
                __TS__Await(logic:cleanExpiredSessions(expireTime))
            end)
        end
        runtime.logger:info("Session cleaner started")
        while true do
            __TS__Await(cleanup())
            __TS__Await(runtime.timer:sleep(cleanupInterval))
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
    local keepAlive
    keepAlive = function()
        return __TS__AsyncAwaiter(function(____awaiter_resolve)
            __TS__Await(runtime.timer:sleep(30000))
            runtime.logger:debug("[Login] Keep alive, sessions: " .. tostring(data:getCount()))
            keepAlive()
        end)
    end
    keepAlive()
end)
return ____exports
