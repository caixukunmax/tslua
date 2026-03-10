local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 7,["10"] = 7,["11"] = 8,["12"] = 8,["13"] = 9,["14"] = 9,["15"] = 11,["16"] = 11,["17"] = 17,["18"] = 20,["20"] = 25,["21"] = 26,["22"] = 27,["23"] = 28,["24"] = 29,["25"] = 30,["26"] = 30,["27"] = 30,["28"] = 30,["29"] = 30,["30"] = 29,["31"] = 38,["32"] = 26,["33"] = 25,["36"] = 46,["39"] = 47,["40"] = 48,["43"] = 49,["44"] = 50,["45"] = 53,["46"] = 54,["47"] = 55,["48"] = 56,["50"] = 59,["55"] = 64,["58"] = 65,["59"] = 66,["60"] = 67,["64"] = 71,["67"] = 72,["68"] = 73,["69"] = 74,["73"] = 78,["76"] = 79,["77"] = 80,["78"] = 81,["82"] = 85,["85"] = 86,["86"] = 87,["90"] = 91,["93"] = 92,["94"] = 93,["99"] = 98,["100"] = 99,["104"] = 46,["106"] = 106,["108"] = 107,["109"] = 108,["110"] = 110,["112"] = 111,["114"] = 110,["115"] = 114,["116"] = 117,["117"] = 118,["118"] = 119,["121"] = 106,["122"] = 125,["123"] = 126,["124"] = 127,["125"] = 130,["126"] = 130,["127"] = 130,["128"] = 130,["130"] = 131,["132"] = 134,["134"] = 133,["137"] = 136,["138"] = 137,["139"] = 137,["140"] = 137,["141"] = 137,["142"] = 137,["144"] = 133,["146"] = 130,["147"] = 130,["148"] = 142,["149"] = 144,["150"] = 145,["151"] = 148,["152"] = 148,["154"] = 149,["155"] = 150,["156"] = 151,["158"] = 148,["159"] = 153,["160"] = 125});
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
