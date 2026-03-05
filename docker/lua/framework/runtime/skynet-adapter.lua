local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__Promise = ____lualib.__TS__Promise
local __TS__ArrayJoin = ____lualib.__TS__ArrayJoin
local __TS__New = ____lualib.__TS__New
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["12"] = 21,["13"] = 21,["16"] = 11,["18"] = 28,["19"] = 28,["20"] = 28,["22"] = 28,["23"] = 29,["24"] = 29,["25"] = 30,["26"] = 29,["27"] = 33,["28"] = 33,["29"] = 34,["30"] = 33,["31"] = 37,["32"] = 37,["33"] = 38,["34"] = 37,["35"] = 41,["36"] = 41,["37"] = 42,["38"] = 41,["39"] = 45,["40"] = 46,["41"] = 46,["43"] = 48,["44"] = 48,["45"] = 48,["46"] = 48,["47"] = 49,["48"] = 50,["50"] = 52,["51"] = 48,["52"] = 48,["53"] = 48,["54"] = 48,["55"] = 45,["58"] = 61,["59"] = 61,["60"] = 61,["62"] = 61,["63"] = 62,["64"] = 63,["65"] = 64,["66"] = 65,["67"] = 62,["68"] = 68,["69"] = 68,["70"] = 73,["72"] = 74,["73"] = 76,["75"] = 73,["76"] = 79,["77"] = 80,["78"] = 79,["80"] = 87,["81"] = 87,["82"] = 87,["84"] = 87,["85"] = 88,["86"] = 89,["87"] = 88,["88"] = 92,["89"] = 92,["91"] = 95,["92"] = 95,["93"] = 95,["94"] = 95,["95"] = 95,["96"] = 96,["98"] = 92,["99"] = 99,["100"] = 100,["101"] = 100,["102"] = 100,["103"] = 102,["104"] = 102,["105"] = 102,["106"] = 102,["107"] = 102,["108"] = 103,["109"] = 105,["112"] = 105,["113"] = 105,["114"] = 105,["115"] = 108,["116"] = 105,["118"] = 100,["119"] = 100,["120"] = 99,["121"] = 114,["122"] = 115,["123"] = 114,["125"] = 122,["126"] = 122,["127"] = 122,["129"] = 122,["130"] = 123,["131"] = 124,["132"] = 125,["133"] = 126,["134"] = 128,["135"] = 129,["136"] = 128,["138"] = 124,["139"] = 123,["140"] = 135,["141"] = 136,["142"] = 135,["143"] = 139,["144"] = 139,["145"] = 141,["146"] = 142,["147"] = 144,["148"] = 139,["149"] = 147,["150"] = 148,["151"] = 147,["152"] = 151,["153"] = 152,["154"] = 151,["155"] = 155,["156"] = 156,["157"] = 155,["159"] = 163,["160"] = 164,["163"] = 169,["166"] = 167,["172"] = 172,["173"] = 172,["174"] = 172,["175"] = 172,["176"] = 172,["177"] = 172,["178"] = 172,["179"] = 163});
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
function SkynetTimer.prototype.clearTimeout(self, handle)
end
function SkynetTimer.prototype.sleep(self, ms)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local centiseconds = math.floor(ms / 10)
        skynet.sleep(centiseconds)
    end)
end
function SkynetTimer.prototype.now(self)
    return skynet.time()
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
                local ____self_0 = result
                ____self_0["then"](
                    ____self_0,
                    function()
                    end
                ):catch(function(____, err)
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
        local result = callback()
        if result and type(result["then"]) == "function" then
            result:catch(function(____, err)
                skynet.error("Service start error: " .. tostring(err))
            end)
        end
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
