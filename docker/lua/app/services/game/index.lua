local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 7,["10"] = 7,["11"] = 8,["12"] = 8,["13"] = 9,["14"] = 9,["15"] = 11,["16"] = 11,["17"] = 15,["18"] = 18,["20"] = 23,["23"] = 24,["24"] = 25,["27"] = 26,["28"] = 27,["29"] = 30,["30"] = 31,["31"] = 31,["32"] = 33,["33"] = 33,["34"] = 33,["35"] = 33,["36"] = 33,["37"] = 33,["38"] = 31,["39"] = 31,["40"] = 41,["41"] = 42,["43"] = 44,["48"] = 49,["51"] = 50,["52"] = 51,["53"] = 52,["57"] = 56,["60"] = 57,["61"] = 58,["62"] = 61,["63"] = 62,["64"] = 62,["65"] = 62,["66"] = 62,["67"] = 62,["68"] = 62,["69"] = 62,["70"] = 69,["71"] = 70,["73"] = 72,["78"] = 77,["81"] = 78,["82"] = 79,["83"] = 80,["87"] = 84,["90"] = 85,["91"] = 86,["95"] = 90,["98"] = 91,["99"] = 92,["103"] = 96,["106"] = 97,["107"] = 98,["112"] = 103,["113"] = 104,["117"] = 23,["118"] = 110,["119"] = 111,["120"] = 112,["121"] = 115,["122"] = 115,["123"] = 115,["124"] = 115,["126"] = 116,["128"] = 119,["130"] = 118,["133"] = 121,["134"] = 122,["135"] = 122,["136"] = 122,["137"] = 122,["139"] = 118,["141"] = 115,["142"] = 115,["143"] = 126,["144"] = 127,["145"] = 130,["146"] = 130,["148"] = 131,["149"] = 132,["150"] = 133,["152"] = 130,["153"] = 135,["154"] = 110});
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
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        repeat
            local ____switch3 = cmd
            local ____cond3 = ____switch3 == "enterGame"
            if ____cond3 then
                do
                    local userId = table.unpack(args, 1, 1)
                    local player = __TS__AwaitSkynet(logic:handleEnterGame(userId))
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
                    local success = __TS__AwaitSkynet(logic:handleLeaveGame(userId))
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
                    local success = __TS__AwaitSkynet(logic:updatePlayer(userId, update))
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
    runtime.logger:info("=== Game Service Starting ===")
    runtime.logger:info("Service address: " .. runtime.service:self())
    runtime.network:dispatch(
        "lua",
        function(session, source, cmd, ...)
            local args = {...}
            return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
                runtime.logger:debug((("Game received command: " .. cmd) .. " from ") .. source)
                local ____try = __TS__AsyncAwaiterSkynet(function()
                    __TS__AwaitSkynet(handleCommand(cmd, args))
                end)
                __TS__AwaitSkynet(____try.catch(
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
    local keepAlive
    keepAlive = function()
        return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
            __TS__AwaitSkynet(runtime.timer:sleep(30000))
            runtime.logger:debug("[Game] Keep alive, players: " .. tostring(data:getCount()))
            keepAlive()
        end)
    end
    keepAlive()
end)
return ____exports
