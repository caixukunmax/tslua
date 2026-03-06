local ____lualib = require("lualib_bundle")
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["8"] = 8,["9"] = 8,["11"] = 22,["13"] = 31,["15"] = 32,["16"] = 33,["17"] = 34,["18"] = 35,["19"] = 37,["20"] = 39,["21"] = 40,["23"] = 42,["24"] = 42,["26"] = 44,["27"] = 47,["28"] = 49,["29"] = 49,["30"] = 49,["31"] = 49,["32"] = 54,["33"] = 57,["35"] = 43,["38"] = 59,["39"] = 60,["41"] = 43,["42"] = 42,["46"] = 65,["47"] = 66,["48"] = 67,["49"] = 68,["50"] = 70,["51"] = 70,["52"] = 70,["53"] = 70,["54"] = 70,["55"] = 70,["56"] = 70,["57"] = 71,["58"] = 70,["59"] = 70,["60"] = 74,["61"] = 75,["62"] = 76,["64"] = 31,["65"] = 79,["68"] = 81,["70"] = 80,["73"] = 83,["74"] = 84,["76"] = 80,["78"] = 79});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
--- 游戏服务配置列表
local serviceConfigs = {{name = "gateway", path = "app/services/gateway/index", count = 1}, {name = "login", path = "app/services/login/index", count = 1}, {name = "game", path = "app/services/game/index", count = 2}}
--- 启动所有服务
local function startAllServices()
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
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
                    local ____try = __TS__AsyncAwaiter(function()
                        rt.logger:info(((((("Starting service: " .. config.name) .. " (") .. tostring(i + 1)) .. "/") .. tostring(count)) .. ")...")
                        local address = __TS__Await(rt.service:newService("ts_launcher", config.path))
                        startedServices[#startedServices + 1] = {
                            name = (config.name .. "-") .. tostring(i + 1),
                            address = address
                        }
                        rt.logger:info((((("✓ Service " .. config.name) .. "-") .. tostring(i + 1)) .. " started: ") .. address)
                        __TS__Await(rt.timer:sleep(100))
                    end)
                    __TS__Await(____try.catch(
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
runtime.service:start(function()
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local ____try = __TS__AsyncAwaiter(function()
            __TS__Await(startAllServices())
        end)
        __TS__Await(____try.catch(
            ____try,
            function(____, ____error)
                runtime.logger:error("Bootstrap failed:", ____error)
                runtime.service:exit()
            end
        ))
    end)
end)
return ____exports
