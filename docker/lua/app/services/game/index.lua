local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 7,["10"] = 7,["11"] = 8,["12"] = 8,["13"] = 9,["14"] = 9,["15"] = 11,["16"] = 11,["17"] = 11,["18"] = 15,["19"] = 18,["21"] = 23,["24"] = 24,["25"] = 25,["28"] = 26,["29"] = 27,["30"] = 30,["31"] = 31,["32"] = 31,["33"] = 31,["34"] = 34,["35"] = 34,["36"] = 34,["37"] = 34,["38"] = 34,["39"] = 34,["40"] = 31,["41"] = 31,["42"] = 42,["43"] = 43,["45"] = 45,["50"] = 50,["53"] = 51,["54"] = 52,["55"] = 53,["59"] = 57,["62"] = 58,["63"] = 59,["64"] = 62,["65"] = 63,["66"] = 63,["67"] = 63,["68"] = 63,["69"] = 63,["70"] = 63,["71"] = 63,["72"] = 70,["73"] = 71,["75"] = 73,["80"] = 78,["83"] = 79,["84"] = 80,["85"] = 81,["89"] = 85,["92"] = 86,["93"] = 87,["97"] = 91,["100"] = 92,["101"] = 93,["105"] = 97,["108"] = 98,["109"] = 99,["114"] = 104,["115"] = 105,["119"] = 23,["120"] = 111,["121"] = 112,["122"] = 113,["123"] = 116,["124"] = 116,["125"] = 116,["126"] = 116,["128"] = 117,["130"] = 120,["132"] = 119,["135"] = 122,["136"] = 123,["137"] = 123,["138"] = 123,["139"] = 123,["141"] = 119,["143"] = 116,["144"] = 116,["145"] = 127,["146"] = 128,["147"] = 131,["148"] = 131,["150"] = 132,["151"] = 133,["152"] = 134,["154"] = 131,["155"] = 136,["156"] = 111});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
local ____data = require("app.services.game.data")
local PlayerData = ____data.PlayerData
local ____logic = require("app.services.game.logic")
local GameLogic = ____logic.GameLogic
local ____protos = require("protos.index")
local proto = ____protos.proto
local ErrorCode = ____protos.ErrorCode
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
                            code = ErrorCode.SUCCESS,
                            message = "Enter game success",
                            player = {
                                userId = player.userId,
                                level = player.level,
                                exp = player.exp,
                                gold = player.gold,
                                enterTime = Date:now()
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
                            level = player.level,
                            exp = player.exp,
                            gold = player.gold,
                            enterTime = Date:now()
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
