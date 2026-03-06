local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__NumberToString = ____lualib.__TS__NumberToString
local __TS__StringSubstring = ____lualib.__TS__StringSubstring
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["10"] = 7,["11"] = 7,["14"] = 15,["15"] = 15,["16"] = 15,["17"] = 16,["18"] = 16,["19"] = 16,["20"] = 21,["22"] = 22,["24"] = 26,["25"] = 29,["26"] = 30,["28"] = 36,["29"] = 37,["31"] = 44,["32"] = 45,["33"] = 46,["34"] = 48,["35"] = 51,["36"] = 58,["38"] = 24,["41"] = 63,["44"] = 64,["45"] = 64,["46"] = 64,["47"] = 64,["50"] = 24,["52"] = 21,["53"] = 74,["55"] = 75,["56"] = 77,["57"] = 78,["58"] = 79,["59"] = 80,["61"] = 83,["62"] = 84,["63"] = 85,["65"] = 88,["67"] = 74,["68"] = 94,["69"] = 95,["70"] = 96,["71"] = 97,["73"] = 100,["74"] = 94,["75"] = 111,["76"] = 112,["77"] = 111,["78"] = 118,["79"] = 119,["80"] = 118,["81"] = 125,["82"] = 126,["83"] = 125,["84"] = 132,["86"] = 133,["87"] = 134,["88"] = 136,["89"] = 137,["91"] = 140,["93"] = 132,["94"] = 146,["95"] = 147,["96"] = 148,["97"] = 148,["98"] = 148,["99"] = 148,["100"] = 148,["101"] = 148,["102"] = 148,["103"] = 146});
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info("Login attempt: " .. request.username)
        local ____try = __TS__AsyncAwaiter(function()
            __TS__Await(runtime.timer:sleep(100))
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
        __TS__Await(____try.catch(
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
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
