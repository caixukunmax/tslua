local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__StringPadStart = ____lualib.__TS__StringPadStart
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__Promise = ____lualib.__TS__Promise
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__ArrayJoin = ____lualib.__TS__ArrayJoin
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["14"] = 21,["15"] = 21,["18"] = 11,["20"] = 28,["21"] = 28,["22"] = 28,["24"] = 29,["25"] = 28,["26"] = 31,["27"] = 31,["28"] = 32,["31"] = 33,["32"] = 31,["33"] = 36,["34"] = 36,["35"] = 37,["36"] = 36,["37"] = 40,["38"] = 40,["39"] = 41,["40"] = 40,["41"] = 44,["42"] = 44,["43"] = 45,["44"] = 44,["45"] = 48,["46"] = 49,["47"] = 50,["48"] = 50,["49"] = 50,["50"] = 50,["51"] = 50,["52"] = 50,["53"] = 50,["54"] = 50,["55"] = 50,["56"] = 50,["57"] = 50,["58"] = 50,["59"] = 50,["60"] = 48,["61"] = 53,["62"] = 54,["63"] = 54,["65"] = 56,["66"] = 56,["67"] = 56,["68"] = 56,["69"] = 57,["70"] = 58,["72"] = 60,["73"] = 56,["74"] = 56,["75"] = 56,["76"] = 56,["77"] = 53,["80"] = 69,["81"] = 69,["82"] = 69,["84"] = 69,["85"] = 70,["86"] = 71,["87"] = 72,["88"] = 73,["89"] = 70,["90"] = 76,["91"] = 76,["92"] = 81,["93"] = 84,["94"] = 84,["95"] = 84,["96"] = 85,["97"] = 86,["98"] = 86,["99"] = 86,["100"] = 87,["101"] = 86,["102"] = 86,["103"] = 84,["104"] = 84,["105"] = 81,["106"] = 92,["107"] = 93,["108"] = 92,["109"] = 100,["110"] = 101,["111"] = 102,["112"] = 102,["113"] = 102,["114"] = 104,["115"] = 105,["116"] = 107,["117"] = 108,["118"] = 109,["119"] = 108,["121"] = 104,["122"] = 102,["123"] = 102,["124"] = 100,["125"] = 119,["126"] = 120,["127"] = 119,["129"] = 127,["130"] = 127,["131"] = 127,["133"] = 127,["134"] = 128,["135"] = 129,["136"] = 128,["137"] = 132,["138"] = 132,["140"] = 135,["141"] = 135,["142"] = 135,["143"] = 135,["144"] = 135,["145"] = 136,["147"] = 132,["148"] = 139,["149"] = 140,["150"] = 140,["151"] = 140,["152"] = 141,["153"] = 141,["154"] = 141,["155"] = 141,["156"] = 141,["157"] = 144,["158"] = 145,["159"] = 146,["160"] = 145,["162"] = 140,["163"] = 140,["164"] = 139,["165"] = 152,["166"] = 153,["167"] = 152,["169"] = 160,["170"] = 160,["171"] = 160,["173"] = 160,["174"] = 161,["175"] = 162,["176"] = 165,["177"] = 166,["178"] = 167,["179"] = 168,["180"] = 169,["181"] = 168,["183"] = 165,["184"] = 162,["185"] = 161,["186"] = 176,["187"] = 177,["188"] = 176,["189"] = 180,["190"] = 180,["191"] = 182,["192"] = 183,["193"] = 185,["194"] = 180,["195"] = 188,["196"] = 189,["197"] = 188,["198"] = 192,["199"] = 193,["200"] = 192,["201"] = 196,["202"] = 197,["203"] = 196,["205"] = 204,["206"] = 205,["209"] = 210,["212"] = 208,["218"] = 213,["219"] = 213,["220"] = 213,["221"] = 213,["222"] = 213,["223"] = 213,["224"] = 213,["225"] = 204});
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
    self.logLevel = "info"
end
function SkynetLogger.prototype.debug(self, message, ...)
    local args = {...}
    if self.logLevel ~= "debug" then
        return
    end
    skynet.error((((("[DEBUG] " .. self:timestamp()) .. " ") .. message) .. " ") .. self:formatArgs(args))
end
function SkynetLogger.prototype.info(self, message, ...)
    local args = {...}
    skynet.error((((("[INFO] " .. self:timestamp()) .. " ") .. message) .. " ") .. self:formatArgs(args))
end
function SkynetLogger.prototype.warn(self, message, ...)
    local args = {...}
    skynet.error((((("[WARN] " .. self:timestamp()) .. " ") .. message) .. " ") .. self:formatArgs(args))
end
function SkynetLogger.prototype.error(self, message, ...)
    local args = {...}
    skynet.error((((("[ERROR] " .. self:timestamp()) .. " ") .. message) .. " ") .. self:formatArgs(args))
end
function SkynetLogger.prototype.timestamp(self)
    local now = __TS__New(Date)
    return (((__TS__StringPadStart(
        tostring(now:getHours()),
        2,
        "0"
    ) .. ":") .. __TS__StringPadStart(
        tostring(now:getMinutes()),
        2,
        "0"
    )) .. ":") .. __TS__StringPadStart(
        tostring(now:getSeconds()),
        2,
        "0"
    )
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
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
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
