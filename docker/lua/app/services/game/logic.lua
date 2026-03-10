local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 7,["10"] = 7,["13"] = 15,["14"] = 15,["15"] = 15,["16"] = 16,["17"] = 16,["18"] = 16,["19"] = 22,["21"] = 23,["22"] = 26,["23"] = 27,["26"] = 28,["29"] = 32,["30"] = 35,["31"] = 35,["32"] = 35,["33"] = 35,["34"] = 36,["35"] = 38,["37"] = 22,["38"] = 44,["40"] = 45,["41"] = 47,["42"] = 48,["43"] = 49,["44"] = 50,["46"] = 54,["47"] = 56,["48"] = 57,["49"] = 58,["51"] = 61,["53"] = 44,["54"] = 67,["55"] = 68,["56"] = 67,["57"] = 74,["59"] = 75,["60"] = 77,["61"] = 78,["62"] = 78,["63"] = 78,["64"] = 78,["66"] = 80,["68"] = 83,["70"] = 74,["71"] = 89,["72"] = 90,["73"] = 89,["74"] = 96,["75"] = 97,["76"] = 96,["77"] = 103,["79"] = 105,["80"] = 106,["82"] = 103,["83"] = 112,["85"] = 113,["86"] = 114,["87"] = 115,["91"] = 118,["94"] = 112,["95"] = 127,["97"] = 128,["98"] = 129,["99"] = 130,["101"] = 133,["102"] = 134,["103"] = 136,["104"] = 138,["105"] = 139,["107"] = 142,["109"] = 145,["111"] = 127,["112"] = 151,["114"] = 152,["115"] = 153,["116"] = 154,["120"] = 157,["123"] = 151});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
--- 游戏业务逻辑
-- 这个类可以被热更新，不持有任何状态
____exports.GameLogic = __TS__Class()
local GameLogic = ____exports.GameLogic
GameLogic.name = "GameLogic"
function GameLogic.prototype.____constructor(self, data)
    self.data = data
end
function GameLogic.prototype.handleEnterGame(self, userId)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        runtime.logger:info(("User " .. tostring(userId)) .. " entering game")
        if self.data:hasPlayer(userId) then
            runtime.logger:warn(("User " .. tostring(userId)) .. " already in game")
            return ____awaiter_resolve(
                nil,
                self.data:getPlayer(userId) or nil
            )
        end
        __TS__AwaitSkynet(runtime.timer:sleep(50))
        local player = self.data:addPlayer(
            userId,
            runtime.timer:now()
        )
        runtime.logger:info(("User " .. tostring(userId)) .. " entered game successfully")
        return ____awaiter_resolve(nil, player)
    end)
end
function GameLogic.prototype.handleLeaveGame(self, userId)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        runtime.logger:info(("User " .. tostring(userId)) .. " leaving game")
        local player = self.data:getPlayer(userId)
        if player == nil then
            runtime.logger:warn(("Player " .. tostring(userId)) .. " not found")
            return ____awaiter_resolve(nil, false)
        end
        __TS__AwaitSkynet(self:savePlayerData(player))
        local success = self.data:removePlayer(userId)
        if success then
            runtime.logger:info(("User " .. tostring(userId)) .. " left game")
        end
        return ____awaiter_resolve(nil, success)
    end)
end
function GameLogic.prototype.getPlayerInfo(self, userId)
    return self.data:getPlayer(userId)
end
function GameLogic.prototype.updatePlayer(self, userId, update)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        local success = self.data:updatePlayer(userId, update)
        if success then
            runtime.logger:debug(
                ("Player " .. tostring(userId)) .. " updated:",
                update
            )
        else
            runtime.logger:warn("Failed to update player " .. tostring(userId))
        end
        return ____awaiter_resolve(nil, success)
    end)
end
function GameLogic.prototype.getAllPlayers(self)
    return self.data:getAllPlayers()
end
function GameLogic.prototype.getOnlineCount(self)
    return self.data:getCount()
end
function GameLogic.prototype.savePlayerData(self, player)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        runtime.logger:debug("Saving player data for userId: " .. tostring(player.userId))
        __TS__AwaitSkynet(runtime.timer:sleep(10))
    end)
end
function GameLogic.prototype.levelUp(self, userId)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        local player = self.data:getPlayer(userId)
        if player == nil then
            return ____awaiter_resolve(nil, false)
        end
        return ____awaiter_resolve(
            nil,
            __TS__AwaitSkynet(self:updatePlayer(userId, {level = player.level + 1, exp = 0}))
        )
    end)
end
function GameLogic.prototype.addExp(self, userId, expAmount)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        local player = self.data:getPlayer(userId)
        if player == nil then
            return ____awaiter_resolve(nil, false)
        end
        local newExp = player.exp + expAmount
        local expToLevel = 100 * player.level
        if newExp >= expToLevel then
            __TS__AwaitSkynet(self:levelUp(userId))
            runtime.logger:info((("Player " .. tostring(userId)) .. " leveled up to ") .. tostring(player.level + 1))
        else
            __TS__AwaitSkynet(self:updatePlayer(userId, {exp = newExp}))
        end
        return ____awaiter_resolve(nil, true)
    end)
end
function GameLogic.prototype.addGold(self, userId, goldAmount)
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        local player = self.data:getPlayer(userId)
        if player == nil then
            return ____awaiter_resolve(nil, false)
        end
        return ____awaiter_resolve(
            nil,
            __TS__AwaitSkynet(self:updatePlayer(userId, {gold = player.gold + goldAmount}))
        )
    end)
end
return ____exports
