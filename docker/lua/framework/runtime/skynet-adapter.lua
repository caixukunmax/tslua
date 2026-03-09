local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__Promise = ____lualib.__TS__Promise
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__ArrayJoin = ____lualib.__TS__ArrayJoin
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["12"] = 21,["13"] = 21,["16"] = 11,["18"] = 28,["19"] = 28,["20"] = 28,["22"] = 28,["23"] = 29,["24"] = 29,["25"] = 30,["26"] = 29,["27"] = 33,["28"] = 33,["29"] = 34,["30"] = 33,["31"] = 37,["32"] = 37,["33"] = 38,["34"] = 37,["35"] = 41,["36"] = 41,["37"] = 42,["38"] = 41,["39"] = 45,["40"] = 46,["41"] = 46,["43"] = 48,["44"] = 48,["45"] = 48,["46"] = 48,["47"] = 49,["48"] = 50,["50"] = 52,["51"] = 48,["52"] = 48,["53"] = 48,["54"] = 48,["55"] = 45,["58"] = 61,["59"] = 61,["60"] = 61,["62"] = 61,["63"] = 62,["64"] = 63,["65"] = 64,["66"] = 65,["67"] = 62,["68"] = 68,["69"] = 68,["70"] = 73,["71"] = 76,["72"] = 76,["73"] = 76,["74"] = 77,["75"] = 78,["76"] = 78,["77"] = 78,["78"] = 79,["79"] = 78,["80"] = 78,["81"] = 76,["82"] = 76,["83"] = 73,["84"] = 84,["85"] = 85,["86"] = 84,["87"] = 92,["88"] = 93,["89"] = 94,["90"] = 94,["91"] = 94,["92"] = 96,["93"] = 97,["94"] = 99,["95"] = 100,["96"] = 101,["97"] = 100,["99"] = 96,["100"] = 94,["101"] = 94,["102"] = 92,["103"] = 111,["104"] = 112,["105"] = 111,["107"] = 119,["108"] = 119,["109"] = 119,["111"] = 119,["112"] = 120,["113"] = 121,["114"] = 120,["115"] = 124,["116"] = 124,["118"] = 127,["119"] = 127,["120"] = 127,["121"] = 127,["122"] = 127,["123"] = 128,["125"] = 124,["126"] = 131,["127"] = 132,["128"] = 132,["129"] = 132,["130"] = 133,["131"] = 133,["132"] = 133,["133"] = 133,["134"] = 133,["135"] = 136,["136"] = 137,["137"] = 138,["138"] = 137,["140"] = 132,["141"] = 132,["142"] = 131,["143"] = 144,["144"] = 145,["145"] = 144,["147"] = 152,["148"] = 152,["149"] = 152,["151"] = 152,["152"] = 153,["153"] = 154,["154"] = 157,["155"] = 158,["156"] = 159,["157"] = 160,["158"] = 161,["159"] = 160,["161"] = 157,["162"] = 154,["163"] = 153,["164"] = 168,["165"] = 169,["166"] = 168,["167"] = 172,["168"] = 172,["169"] = 174,["170"] = 175,["171"] = 177,["172"] = 172,["173"] = 180,["174"] = 181,["175"] = 180,["176"] = 184,["177"] = 185,["178"] = 184,["179"] = 188,["180"] = 189,["181"] = 188,["183"] = 196,["184"] = 197,["187"] = 202,["190"] = 200,["196"] = 205,["197"] = 205,["198"] = 205,["199"] = 205,["200"] = 205,["201"] = 205,["202"] = 205,["203"] = 196});
local ____exports = {}
local ____skynet_2Dpb_2Dcodec = require("framework.runtime.skynet-pb-codec")
local SkynetPbCodec = ____skynet_2Dpb_2Dcodec.SkynetPbCodec
---
-- @noSelfInFile
local skynet = _G.require("skynet")
--- Skynet 日志实现
____exports.SkynetLogger = __TS__Class()
local SkynetLogger = ____exports.SkynetLogger
SkynetLogger.name = "SkynetLogger"
function SkynetLogger.prototype.____constructor(self)
end
function SkynetLogger.prototype.debug(self, message, ...)
    local args = {...}
    skynet.error((("[DEBUG] " .. message) .. " ") .. self:formatArgs(args))
end
function SkynetLogger.prototype.info(self, message, ...)
    local args = {...}
    skynet.error((("[INFO] " .. message) .. " ") .. self:formatArgs(args))
end
function SkynetLogger.prototype.warn(self, message, ...)
    local args = {...}
    skynet.error((("[WARN] " .. message) .. " ") .. self:formatArgs(args))
end
function SkynetLogger.prototype.error(self, message, ...)
    local args = {...}
    skynet.error((("[ERROR] " .. message) .. " ") .. self:formatArgs(args))
end
function SkynetLogger.prototype.formatArgs(self, args)
    if #args == 0 then
        return ""
    end
    return table.concat(
        __TS__ArrayMap(
            args,
            function(____, arg)
                if type(arg) == "table" then
                    return JSON:stringify(arg)
                end
                return tostring(arg)
            end
        ),
        " "
    )
end
--- Skynet 定时器实现
-- 注意：Skynet 使用厘秒（1/100秒）作为时间单位
____exports.SkynetTimer = __TS__Class()
local SkynetTimer = ____exports.SkynetTimer
SkynetTimer.name = "SkynetTimer"
function SkynetTimer.prototype.____constructor(self)
end
function SkynetTimer.prototype.setTimeout(self, ms, callback)
    local centiseconds = math.floor(ms / 10)
    skynet.timeout(centiseconds, callback)
    return centiseconds
end
function SkynetTimer.prototype.clearTimeout(self, _handle)
end
function SkynetTimer.prototype.sleep(self, ms)
    return __TS__New(
        __TS__Promise,
        function(____, resolve)
            local centiseconds = math.floor(ms / 10)
            skynet.timeout(
                centiseconds,
                function()
                    resolve(nil)
                end
            )
        end
    )
end
function SkynetTimer.prototype.now(self)
    return skynet.time()
end
function SkynetTimer.prototype.safeTimeout(self, callback, ms)
    local centiseconds = math.floor((ms or 0) / 10)
    skynet.timeout(
        centiseconds,
        function()
            skynet.fork(function()
                local result = callback()
                if result and type(result["then"]) == "function" then
                    result:catch(function(____, err)
                        skynet.error("[safeTimeout] Error: " .. tostring(err))
                    end)
                end
            end)
        end
    )
end
function SkynetTimer.prototype.safeImmediate(self, callback)
    self:safeTimeout(callback, 0)
end
--- Skynet 网络实现
____exports.SkynetNetwork = __TS__Class()
local SkynetNetwork = ____exports.SkynetNetwork
SkynetNetwork.name = "SkynetNetwork"
function SkynetNetwork.prototype.____constructor(self)
end
function SkynetNetwork.prototype.send(self, address, messageType, ...)
    skynet.send(address, messageType, ...)
end
function SkynetNetwork.prototype.call(self, address, messageType, ...)
    local args = {...}
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local result = skynet.call(
            address,
            messageType,
            table.unpack(args)
        )
        return ____awaiter_resolve(nil, result)
    end)
end
function SkynetNetwork.prototype.dispatch(self, messageType, handler)
    skynet.dispatch(
        messageType,
        function(session, source, ...)
            local result = handler(
                session,
                tostring(source),
                ...
            )
            if result and type(result["then"]) == "function" then
                result:catch(function(____, err)
                    skynet.error("Dispatch error: " .. tostring(err))
                end)
            end
        end
    )
end
function SkynetNetwork.prototype.ret(self, ...)
    skynet.retpack(...)
end
--- Skynet 服务实现
____exports.SkynetService = __TS__Class()
local SkynetService = ____exports.SkynetService
SkynetService.name = "SkynetService"
function SkynetService.prototype.____constructor(self)
end
function SkynetService.prototype.start(self, callback)
    skynet.start(function()
        skynet.fork(function()
            local result = callback()
            if result and type(result["then"]) == "function" then
                result:catch(function(____, err)
                    skynet.error("Service start error: " .. tostring(err))
                end)
            end
        end)
    end)
end
function SkynetService.prototype.exit(self)
    skynet.exit()
end
function SkynetService.prototype.newService(self, name, ...)
    local args = {...}
    local fullCommand = #args > 0 and (name .. " ") .. __TS__ArrayJoin(args, " ") or name
    local address = skynet.newservice(fullCommand)
    return __TS__Promise.resolve(tostring(address))
end
function SkynetService.prototype.self(self)
    return skynet.self()
end
function SkynetService.prototype.getenv(self, key)
    return skynet.getenv(key)
end
function SkynetService.prototype.setenv(self, key, value)
    skynet.setenv(key, value)
end
--- 创建 Skynet 运行时
function ____exports.createSkynetRuntime()
    local codec
    do
        local function ____catch(____error)
            skynet.error("[SkynetRuntime] PbCodec not available:", ____error)
        end
        local ____try, ____hasReturned = pcall(function()
            codec = __TS__New(SkynetPbCodec)
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
    return {
        logger = __TS__New(____exports.SkynetLogger),
        timer = __TS__New(____exports.SkynetTimer),
        network = __TS__New(____exports.SkynetNetwork),
        service = __TS__New(____exports.SkynetService),
        codec = codec
    }
end
return ____exports
