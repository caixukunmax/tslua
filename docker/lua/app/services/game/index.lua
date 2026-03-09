local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 7,["9"] = 7,["10"] = 8,["11"] = 8,["12"] = 9,["13"] = 9,["14"] = 11,["15"] = 11,["16"] = 15,["17"] = 18,["19"] = 23,["22"] = 24,["23"] = 25,["26"] = 26,["27"] = 27,["28"] = 30,["29"] = 31,["30"] = 31,["31"] = 33,["32"] = 33,["33"] = 33,["34"] = 33,["35"] = 33,["36"] = 33,["37"] = 31,["38"] = 31,["39"] = 41,["40"] = 42,["42"] = 44,["47"] = 49,["50"] = 50,["51"] = 51,["52"] = 52,["56"] = 56,["59"] = 57,["60"] = 58,["61"] = 61,["62"] = 62,["63"] = 62,["64"] = 62,["65"] = 62,["66"] = 62,["67"] = 62,["68"] = 62,["69"] = 69,["70"] = 70,["72"] = 72,["77"] = 77,["80"] = 78,["81"] = 79,["82"] = 80,["86"] = 84,["89"] = 85,["90"] = 86,["94"] = 90,["97"] = 91,["98"] = 92,["102"] = 96,["105"] = 97,["106"] = 98,["111"] = 103,["112"] = 104,["116"] = 23,["117"] = 110,["118"] = 111,["119"] = 112,["120"] = 115,["121"] = 115,["122"] = 115,["123"] = 115,["125"] = 116,["127"] = 119,["129"] = 118,["132"] = 121,["133"] = 122,["134"] = 122,["135"] = 122,["136"] = 122,["138"] = 118,["140"] = 115,["141"] = 115,["142"] = 126,["143"] = 127,["144"] = 130,["145"] = 130,["147"] = 131,["148"] = 132,["149"] = 133,["151"] = 130,["152"] = 135,["153"] = 110});
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
    local keepAlive
    keepAlive = function()
        return __TS__AsyncAwaiter(function(____awaiter_resolve)
            __TS__Await(runtime.timer:sleep(30000))
            runtime.logger:debug("[Game] Keep alive, players: " .. tostring(data:getCount()))
            keepAlive()
        end)
    end
    keepAlive()
end)
return ____exports
