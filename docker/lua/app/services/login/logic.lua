local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__NumberToString = ____lualib.__TS__NumberToString
local __TS__StringSubstring = ____lualib.__TS__StringSubstring
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["11"] = 7,["12"] = 7,["15"] = 15,["16"] = 15,["17"] = 15,["18"] = 16,["19"] = 16,["20"] = 16,["21"] = 21,["23"] = 22,["25"] = 26,["26"] = 29,["27"] = 30,["29"] = 36,["30"] = 37,["32"] = 44,["33"] = 45,["34"] = 46,["35"] = 48,["36"] = 51,["37"] = 58,["39"] = 24,["42"] = 63,["45"] = 64,["46"] = 64,["47"] = 64,["48"] = 64,["51"] = 24,["53"] = 21,["54"] = 74,["56"] = 75,["57"] = 77,["58"] = 78,["59"] = 79,["60"] = 80,["62"] = 83,["63"] = 84,["64"] = 85,["66"] = 88,["68"] = 74,["69"] = 94,["70"] = 95,["71"] = 96,["72"] = 97,["74"] = 100,["75"] = 94,["76"] = 111,["77"] = 112,["78"] = 111,["79"] = 118,["80"] = 119,["81"] = 118,["82"] = 125,["83"] = 126,["84"] = 125,["85"] = 132,["87"] = 133,["88"] = 134,["89"] = 136,["90"] = 137,["92"] = 140,["94"] = 132,["95"] = 146,["96"] = 147,["97"] = 148,["98"] = 148,["99"] = 148,["100"] = 148,["101"] = 148,["102"] = 148,["103"] = 148,["104"] = 146});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
--- 登录业务逻辑
-- 这个类可以被热更新，不持有任何状态
____exports.LoginLogic = __TS__Class()
local LoginLogic = ____exports.LoginLogic
LoginLogic.name = "LoginLogic"
function LoginLogic.prototype.____constructor(self, data)
    self.data = data
end
function LoginLogic.prototype.handleLogin(self, request)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        runtime.logger:info("Login attempt: " .. request.username)
        local ____try = __TS__AsyncAwaiterSkynet(function()
            __TS__AwaitSkynet(runtime.timer:sleep(100))
            if not request.username or not request.password then
                return ____awaiter_resolve(nil, {success = false, error = "Username and password are required"})
            end
            if request.password ~= "password123" then
                return ____awaiter_resolve(nil, {success = false, error = "Invalid credentials"})
            end
            local token = self:generateToken(request.username)
            local loginTime = runtime.timer:now()
            local session = self.data:addSession(request.username, token, loginTime)
            runtime.logger:info((("User " .. session.username) .. " logged in successfully, userId: ") .. tostring(session.userId))
            local user = {userId = session.userId, username = session.username, token = session.token, loginTime = session.loginTime}
            return ____awaiter_resolve(nil, {success = true, user = user})
        end)
        __TS__AwaitSkynet(____try.catch(
            ____try,
            function(____, ____error)
                runtime.logger:error("Login error:", ____error)
                return ____awaiter_resolve(
                    nil,
                    {
                        success = false,
                        error = tostring(____error)
                    }
                )
            end
        ))
    end)
end
function LoginLogic.prototype.handleLogout(self, userId)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        runtime.logger:info("Logout userId: " .. tostring(userId))
        local session = self.data:getSession(userId)
        if session == nil then
            runtime.logger:warn(("User " .. tostring(userId)) .. " not found")
            return ____awaiter_resolve(nil, false)
        end
        local success = self.data:removeSession(userId)
        if success then
            runtime.logger:info(("User " .. session.username) .. " logged out")
        end
        return ____awaiter_resolve(nil, success)
    end)
end
function LoginLogic.prototype.getUserInfo(self, userId)
    local session = self.data:getSession(userId)
    if session == nil then
        return nil
    end
    return {userId = session.userId, username = session.username, token = session.token, loginTime = session.loginTime}
end
function LoginLogic.prototype.validateToken(self, token)
    return self.data:findSessionByToken(token)
end
function LoginLogic.prototype.getOnlineCount(self)
    return self.data:getCount()
end
function LoginLogic.prototype.getAllSessions(self)
    return self.data:getAllSessions()
end
function LoginLogic.prototype.cleanExpiredSessions(self, expireTime)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        local currentTime = runtime.timer:now()
        local cleanedCount = self.data:cleanExpiredSessions(currentTime, expireTime)
        if cleanedCount > 0 then
            runtime.logger:info(("Cleaned " .. tostring(cleanedCount)) .. " expired sessions")
        end
        return ____awaiter_resolve(nil, cleanedCount)
    end)
end
function LoginLogic.prototype.generateToken(self, username)
    local timestamp = runtime.timer:now()
    return (((username .. "_") .. tostring(timestamp)) .. "_") .. __TS__StringSubstring(
        __TS__NumberToString(
            math.random(),
            36
        ),
        7
    )
end
return ____exports
