local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 7,["9"] = 7,["10"] = 8,["11"] = 8,["12"] = 9,["13"] = 9,["14"] = 10,["15"] = 10,["16"] = 14,["17"] = 17,["19"] = 22,["22"] = 23,["23"] = 24,["26"] = 25,["27"] = 26,["28"] = 29,["29"] = 30,["30"] = 30,["31"] = 32,["32"] = 32,["33"] = 32,["34"] = 32,["35"] = 32,["36"] = 32,["37"] = 30,["38"] = 30,["39"] = 40,["40"] = 41,["42"] = 43,["47"] = 48,["50"] = 49,["51"] = 50,["52"] = 51,["56"] = 55,["59"] = 56,["60"] = 57,["61"] = 60,["62"] = 61,["63"] = 61,["64"] = 61,["65"] = 61,["66"] = 61,["67"] = 61,["68"] = 61,["69"] = 68,["70"] = 69,["72"] = 71,["77"] = 76,["80"] = 77,["81"] = 78,["82"] = 79,["86"] = 83,["89"] = 84,["90"] = 85,["94"] = 89,["97"] = 90,["98"] = 91,["102"] = 95,["105"] = 96,["106"] = 97,["111"] = 102,["112"] = 103,["116"] = 22,["117"] = 108,["119"] = 109,["120"] = 110,["121"] = 113,["122"] = 113,["123"] = 113,["124"] = 113,["126"] = 114,["128"] = 117,["130"] = 116,["133"] = 119,["134"] = 120,["135"] = 120,["136"] = 120,["137"] = 120,["139"] = 116,["141"] = 113,["142"] = 113,["143"] = 124,["144"] = 125,["146"] = 108});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
local ____data = require("app.services.game.data")
local PlayerData = ____data.PlayerData
local ____logic = require("app.services.game.logic")
local GameLogic = ____logic.GameLogic
local ____protos = require("protos.index")
local proto = ____protos.proto
local data = __TS__New(PlayerData)
local logic = __TS__New(GameLogic, data)
--- 命令分发处理
local function handleCommand(cmd, args)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        repeat
            local ____switch3 = cmd
            local ____cond3 = ____switch3 == "enterGame"
            if ____cond3 then
                do
                    local userId = table.unpack(args, 1, 1)
                    local player = __TS__Await(logic:handleEnterGame(userId))
                    if runtime.codec and player then
                        local response = proto.game.EnterGameResponse.create({
                            success = true,
                            playerInfo = {
                                userId = player.userId,
                                username = "Player_" .. tostring(player.userId),
                                level = player.level,
                                exp = player.exp,
                                gold = player.gold
                            }
                        })
                        local encoded = runtime.codec:encode("game.EnterGameResponse", response)
                        runtime.network:ret(true, encoded)
                    else
                        runtime.network:ret(player ~= nil)
                    end
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "leaveGame"
            if ____cond3 then
                do
                    local userId = table.unpack(args, 1, 1)
                    local success = __TS__Await(logic:handleLeaveGame(userId))
                    runtime.network:ret(success)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "getPlayerInfo"
            if ____cond3 then
                do
                    local userId = table.unpack(args, 1, 1)
                    local player = logic:getPlayerInfo(userId)
                    if runtime.codec and player then
                        local playerInfo = proto.game.PlayerInfo.create({
                            userId = player.userId,
                            username = "Player_" .. tostring(player.userId),
                            level = player.level,
                            exp = player.exp,
                            gold = player.gold
                        })
                        local encoded = runtime.codec:encode("game.PlayerInfo", playerInfo)
                        runtime.network:ret(true, encoded)
                    else
                        runtime.network:ret(player)
                    end
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "updatePlayer"
            if ____cond3 then
                do
                    local userId, update = table.unpack(args, 1, 2)
                    local success = __TS__Await(logic:updatePlayer(userId, update))
                    runtime.network:ret(success)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "getOnlineCount"
            if ____cond3 then
                do
                    local count = logic:getOnlineCount()
                    runtime.network:ret(count)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "getAllPlayers"
            if ____cond3 then
                do
                    local players = logic:getAllPlayers()
                    runtime.network:ret(players)
                    break
                end
            end
            ____cond3 = ____cond3 or ____switch3 == "get_state"
            if ____cond3 then
                do
                    local state = data:exportState()
                    runtime.network:ret(state)
                    break
                end
            end
            do
                runtime.logger:warn("Unknown command: " .. cmd)
                runtime.network:ret(false, "Unknown command")
            end
        until true
    end)
end
runtime.service:start(function()
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info("=== Game Service Starting ===")
        runtime.logger:info("Service address: " .. runtime.service:self())
        runtime.network:dispatch(
            "lua",
            function(session, source, cmd, ...)
                local args = {...}
                return __TS__AsyncAwaiter(function(____awaiter_resolve)
                    runtime.logger:debug((("Game received command: " .. cmd) .. " from ") .. source)
                    local ____try = __TS__AsyncAwaiter(function()
                        __TS__Await(handleCommand(cmd, args))
                    end)
                    __TS__Await(____try.catch(
                        ____try,
                        function(____, ____error)
                            runtime.logger:error(("Command " .. cmd) .. " failed:", ____error)
                            runtime.network:ret(
                                false,
                                tostring(____error)
                            )
                        end
                    ))
                end)
            end
        )
        runtime.logger:info("=== Game Service Ready ===")
        runtime.logger:info("Online players: " .. tostring(data:getCount()))
    end)
end)
return ____exports
