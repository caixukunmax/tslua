local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 7,["9"] = 7,["12"] = 15,["13"] = 15,["14"] = 15,["15"] = 16,["16"] = 16,["17"] = 16,["18"] = 22,["20"] = 23,["21"] = 26,["22"] = 27,["25"] = 28,["28"] = 32,["29"] = 35,["30"] = 35,["31"] = 35,["32"] = 35,["33"] = 36,["34"] = 38,["36"] = 22,["37"] = 44,["39"] = 45,["40"] = 47,["41"] = 48,["42"] = 49,["43"] = 50,["45"] = 54,["46"] = 56,["47"] = 57,["48"] = 58,["50"] = 61,["52"] = 44,["53"] = 67,["54"] = 68,["55"] = 67,["56"] = 74,["58"] = 75,["59"] = 77,["60"] = 78,["61"] = 78,["62"] = 78,["63"] = 78,["65"] = 80,["67"] = 83,["69"] = 74,["70"] = 89,["71"] = 90,["72"] = 89,["73"] = 96,["74"] = 97,["75"] = 96,["76"] = 103,["78"] = 105,["79"] = 106,["81"] = 103,["82"] = 112,["84"] = 113,["85"] = 114,["86"] = 115,["90"] = 118,["93"] = 112,["94"] = 127,["96"] = 128,["97"] = 129,["98"] = 130,["100"] = 133,["101"] = 134,["102"] = 136,["103"] = 138,["104"] = 139,["106"] = 142,["108"] = 145,["110"] = 127,["111"] = 151,["113"] = 152,["114"] = 153,["115"] = 154,["119"] = 157,["122"] = 151});
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info(("User " .. tostring(userId)) .. " entering game")
        if self.data:hasPlayer(userId) then
            runtime.logger:warn(("User " .. tostring(userId)) .. " already in game")
            return ____awaiter_resolve(
                nil,
                self.data:getPlayer(userId) or nil
            )
        end
        __TS__Await(runtime.timer:sleep(50))
        local player = self.data:addPlayer(
            userId,
            runtime.timer:now()
        )
        runtime.logger:info(("User " .. tostring(userId)) .. " entered game successfully")
        return ____awaiter_resolve(nil, player)
    end)
end
function GameLogic.prototype.handleLeaveGame(self, userId)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info(("User " .. tostring(userId)) .. " leaving game")
        local player = self.data:getPlayer(userId)
        if player == nil then
            runtime.logger:warn(("Player " .. tostring(userId)) .. " not found")
            return ____awaiter_resolve(nil, false)
        end
        __TS__Await(self:savePlayerData(player))
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
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
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:debug("Saving player data for userId: " .. tostring(player.userId))
        __TS__Await(runtime.timer:sleep(10))
    end)
end
function GameLogic.prototype.levelUp(self, userId)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local player = self.data:getPlayer(userId)
        if player == nil then
            return ____awaiter_resolve(nil, false)
        end
        return ____awaiter_resolve(
            nil,
            __TS__Await(self:updatePlayer(userId, {level = player.level + 1, exp = 0}))
        )
    end)
end
function GameLogic.prototype.addExp(self, userId, expAmount)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local player = self.data:getPlayer(userId)
        if player == nil then
            return ____awaiter_resolve(nil, false)
        end
        local newExp = player.exp + expAmount
        local expToLevel = 100 * player.level
        if newExp >= expToLevel then
            __TS__Await(self:levelUp(userId))
            runtime.logger:info((("Player " .. tostring(userId)) .. " leveled up to ") .. tostring(player.level + 1))
        else
            __TS__Await(self:updatePlayer(userId, {exp = newExp}))
        end
        return ____awaiter_resolve(nil, true)
    end)
end
function GameLogic.prototype.addGold(self, userId, goldAmount)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local player = self.data:getPlayer(userId)
        if player == nil then
            return ____awaiter_resolve(nil, false)
        end
        return ____awaiter_resolve(
            nil,
            __TS__Await(self:updatePlayer(userId, {gold = player.gold + goldAmount}))
        )
    end)
end
return ____exports
