local ____lualib = require("lualib_bundle")
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["9"] = 8,["10"] = 8,["12"] = 22,["14"] = 31,["16"] = 32,["17"] = 33,["18"] = 34,["19"] = 35,["20"] = 37,["21"] = 39,["22"] = 40,["24"] = 42,["25"] = 42,["27"] = 44,["28"] = 47,["29"] = 49,["30"] = 49,["31"] = 49,["32"] = 49,["33"] = 54,["34"] = 57,["36"] = 43,["39"] = 59,["40"] = 60,["42"] = 43,["43"] = 42,["47"] = 65,["48"] = 66,["49"] = 67,["50"] = 68,["51"] = 70,["52"] = 70,["53"] = 70,["54"] = 70,["55"] = 70,["56"] = 70,["57"] = 70,["58"] = 71,["59"] = 70,["60"] = 70,["61"] = 74,["62"] = 75,["63"] = 76,["65"] = 31,["67"] = 82,["69"] = 83,["70"] = 84,["71"] = 85,["72"] = 86,["74"] = 82,["75"] = 91,["76"] = 93,["77"] = 94,["78"] = 95,["79"] = 93,["80"] = 99,["81"] = 99,["83"] = 100,["84"] = 101,["85"] = 102,["87"] = 99,["88"] = 104,["89"] = 91});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
--- 游戏服务配置列表
local serviceConfigs = {{name = "gateway", path = "app/services/gateway/index", count = 1}, {name = "login", path = "app/services/login/index", count = 1}, {name = "game", path = "app/services/game/index", count = 2}}
--- 启动所有服务
local function startAllServices()
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        local rt = runtime
        rt.logger:info("========================================")
        rt.logger:info("    Game Server Bootstrap Starting     ")
        rt.logger:info("========================================")
        local startedServices = {}
        for ____, config in ipairs(serviceConfigs) do
            local count = config.count or 1
            do
                local i = 0
                while i < count do
                    local ____try = __TS__AsyncAwaiterSkynet(function()
                        rt.logger:info(((((("Starting service: " .. config.name) .. " (") .. tostring(i + 1)) .. "/") .. tostring(count)) .. ")...")
                        local address = __TS__AwaitSkynet(rt.service:newService("ts_launcher", config.path))
                        startedServices[#startedServices + 1] = {
                            name = (config.name .. "-") .. tostring(i + 1),
                            address = address
                        }
                        rt.logger:info((((("✓ Service " .. config.name) .. "-") .. tostring(i + 1)) .. " started: ") .. address)
                        __TS__AwaitSkynet(rt.timer:sleep(100))
                    end)
                    __TS__AwaitSkynet(____try.catch(
                        ____try,
                        function(____, ____error)
                            rt.logger:error(("✗ Failed to start service " .. config.name) .. ":", ____error)
                            error(____error, 0)
                        end
                    ))
                    i = i + 1
                end
            end
        end
        rt.logger:info("========================================")
        rt.logger:info("    All Services Started Successfully  ")
        rt.logger:info("========================================")
        rt.logger:info("Started services:")
        __TS__ArrayForEach(
            startedServices,
            function(____, ____bindingPattern0)
                local address
                local name
                name = ____bindingPattern0.name
                address = ____bindingPattern0.address
                rt.logger:info((("  - " .. name) .. ": ") .. address)
            end
        )
        rt.logger:info("========================================")
        rt.logger:info("    Game Server Ready!                 ")
        rt.logger:info("========================================")
    end)
end
--- 启动所有服务（引导函数）
local function bootstrap()
    return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
        __TS__AwaitSkynet(startAllServices())
        runtime.logger:info("========================================")
        runtime.logger:info("    Bootstrap completed                 ")
        runtime.logger:info("========================================")
    end)
end
runtime.service:start(function()
    bootstrap():catch(function(____, ____error)
        runtime.logger:error("Bootstrap failed:", ____error)
        runtime.service:exit()
    end)
    local keepAlive
    keepAlive = function()
        return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
            __TS__AwaitSkynet(runtime.timer:sleep(60000))
            runtime.logger:debug("[Main] Keep alive")
            keepAlive()
        end)
    end
    keepAlive()
end)
return ____exports
