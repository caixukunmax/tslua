local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["12"] = 13,["13"] = 13,["14"] = 13,["16"] = 14,["17"] = 15,["18"] = 13,["19"] = 20,["20"] = 21,["21"] = 21,["22"] = 21,["23"] = 21,["24"] = 22,["25"] = 22,["26"] = 22,["27"] = 22,["28"] = 22,["29"] = 22,["30"] = 22,["31"] = 29,["32"] = 30,["33"] = 20,["34"] = 36,["35"] = 37,["36"] = 36,["37"] = 43,["38"] = 44,["39"] = 43,["40"] = 50,["41"] = 51,["42"] = 52,["43"] = 53,["46"] = 56,["47"] = 50,["48"] = 62,["49"] = 63,["50"] = 62,["51"] = 69,["52"] = 70,["53"] = 69,["54"] = 76,["55"] = 77,["56"] = 78,["57"] = 79,["59"] = 81,["60"] = 82,["61"] = 76,["62"] = 88,["63"] = 89,["64"] = 90,["65"] = 90,["66"] = 90,["67"] = 91,["68"] = 92,["69"] = 93,["72"] = 96,["73"] = 88,["74"] = 102,["75"] = 103,["76"] = 102,["77"] = 109,["78"] = 110,["79"] = 110,["80"] = 110,["81"] = 110,["82"] = 109,["83"] = 119,["84"] = 120,["85"] = 121,["87"] = 123,["88"] = 124,["90"] = 119});
local ____exports = {}
--- 会话数据存储
-- 这个类不会被热更新，确保数据持久性
____exports.SessionData = __TS__Class()
local SessionData = ____exports.SessionData
SessionData.name = "SessionData"
function SessionData.prototype.____constructor(self)
    self.sessions = __TS__New(Map)
    self.nextUserId = 1
end
function SessionData.prototype.addSession(self, username, token, loginTime)
    local ____self_0, ____nextUserId_1 = self, "nextUserId"
    local ____self_nextUserId_2 = ____self_0[____nextUserId_1]
    ____self_0[____nextUserId_1] = ____self_nextUserId_2 + 1
    local userId = ____self_nextUserId_2
    local session = {
        userId = userId,
        username = username,
        token = token,
        loginTime = loginTime,
        lastActivityTime = loginTime
    }
    self.sessions:set(userId, session)
    return session
end
function SessionData.prototype.removeSession(self, userId)
    return self.sessions:delete(userId)
end
function SessionData.prototype.getSession(self, userId)
    return self.sessions:get(userId)
end
function SessionData.prototype.findSessionByToken(self, token)
    for ____, session in __TS__Iterator(self.sessions:values()) do
        if session.token == token then
            return session
        end
    end
    return nil
end
function SessionData.prototype.getAllSessions(self)
    return __TS__ArrayFrom(self.sessions:values())
end
function SessionData.prototype.getCount(self)
    return self.sessions.size
end
function SessionData.prototype.updateActivity(self, userId, time)
    local session = self.sessions:get(userId)
    if session == nil then
        return false
    end
    session.lastActivityTime = time
    return true
end
function SessionData.prototype.cleanExpiredSessions(self, currentTime, expireTime)
    local cleanedCount = 0
    for ____, ____value in __TS__Iterator(self.sessions:entries()) do
        local userId = ____value[1]
        local session = ____value[2]
        if currentTime - session.loginTime > expireTime then
            self.sessions:delete(userId)
            cleanedCount = cleanedCount + 1
        end
    end
    return cleanedCount
end
function SessionData.prototype.clear(self)
    self.sessions:clear()
end
function SessionData.prototype.exportState(self)
    return {
        sessions = __TS__ArrayFrom(self.sessions:entries()),
        nextUserId = self.nextUserId
    }
end
function SessionData.prototype.importState(self, state)
    if state.sessions ~= nil then
        self.sessions = __TS__New(Map, state.sessions)
    end
    if state.nextUserId ~= nil then
        self.nextUserId = state.nextUserId
    end
end
return ____exports
