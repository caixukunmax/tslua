local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["11"] = 13,["12"] = 13,["13"] = 13,["15"] = 14,["16"] = 13,["17"] = 19,["18"] = 20,["19"] = 20,["20"] = 20,["21"] = 20,["22"] = 20,["23"] = 20,["24"] = 20,["25"] = 27,["26"] = 28,["27"] = 19,["28"] = 34,["29"] = 35,["30"] = 34,["31"] = 41,["32"] = 42,["33"] = 41,["34"] = 48,["35"] = 49,["36"] = 50,["37"] = 51,["39"] = 54,["40"] = 55,["42"] = 57,["43"] = 58,["45"] = 60,["46"] = 61,["48"] = 64,["49"] = 48,["50"] = 70,["51"] = 71,["52"] = 70,["53"] = 77,["54"] = 78,["55"] = 77,["56"] = 84,["57"] = 85,["58"] = 84,["59"] = 91,["60"] = 92,["61"] = 91,["62"] = 98,["63"] = 99,["64"] = 98,["65"] = 107,["66"] = 108,["67"] = 109,["69"] = 107});
local ____exports = {}
--- 玩家数据存储
-- 这个类不会被热更新，确保数据持久性
____exports.PlayerData = __TS__Class()
local PlayerData = ____exports.PlayerData
PlayerData.name = "PlayerData"
function PlayerData.prototype.____constructor(self)
    self.players = __TS__New(Map)
end
function PlayerData.prototype.addPlayer(self, userId, enterTime)
    local player = {
        userId = userId,
        level = 1,
        exp = 0,
        gold = 100,
        enterTime = enterTime
    }
    self.players:set(userId, player)
    return player
end
function PlayerData.prototype.removePlayer(self, userId)
    return self.players:delete(userId)
end
function PlayerData.prototype.getPlayer(self, userId)
    return self.players:get(userId)
end
function PlayerData.prototype.updatePlayer(self, userId, update)
    local player = self.players:get(userId)
    if player == nil then
        return false
    end
    if update.level ~= nil then
        player.level = update.level
    end
    if update.exp ~= nil then
        player.exp = update.exp
    end
    if update.gold ~= nil then
        player.gold = update.gold
    end
    return true
end
function PlayerData.prototype.getAllPlayers(self)
    return __TS__ArrayFrom(self.players:values())
end
function PlayerData.prototype.getCount(self)
    return self.players.size
end
function PlayerData.prototype.hasPlayer(self, userId)
    return self.players:has(userId)
end
function PlayerData.prototype.clear(self)
    self.players:clear()
end
function PlayerData.prototype.exportState(self)
    return {players = __TS__ArrayFrom(self.players:entries())}
end
function PlayerData.prototype.importState(self, state)
    if state.players ~= nil then
        self.players = __TS__New(Map, state.players)
    end
end
return ____exports
