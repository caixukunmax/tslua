local ____lualib = require("lualib_bundle")
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local Map = ____lualib.Map
local Set = ____lualib.Set
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["11"] = 7,["12"] = 7,["13"] = 14,["15"] = 15,["16"] = 15,["18"] = 16,["19"] = 17,["20"] = 18,["22"] = 15,["23"] = 20,["25"] = 14,["26"] = 27,["28"] = 28,["29"] = 29,["30"] = 30,["32"] = 27,["33"] = 33,["34"] = 34,["35"] = 35,["36"] = 36,["37"] = 37,["38"] = 35,["39"] = 41,["41"] = 42,["42"] = 43,["43"] = 44,["46"] = 41,["47"] = 47,["48"] = 34,["49"] = 33,["50"] = 55,["51"] = 56,["52"] = 56,["53"] = 56,["56"] = 58,["57"] = 59,["58"] = 60,["60"] = 57,["63"] = 62,["64"] = 62,["65"] = 62,["66"] = 62,["68"] = 57,["70"] = 56,["71"] = 56,["72"] = 55,["73"] = 71,["75"] = 72,["76"] = 73,["77"] = 74,["79"] = 71,["80"] = 81,["81"] = 83,["82"] = 84,["83"] = 87,["84"] = 88,["85"] = 91,["86"] = 92,["87"] = 81,["88"] = 99,["89"] = 104,["90"] = 105,["91"] = 106,["92"] = 107,["93"] = 104,["94"] = 114,["95"] = 115,["96"] = 115,["97"] = 115,["98"] = 115,["99"] = 115,["100"] = 115,["101"] = 115,["102"] = 118,["103"] = 119,["104"] = 114,["105"] = 126,["106"] = 128,["107"] = 129,["108"] = 130,["109"] = 131,["110"] = 126,["111"] = 138,["112"] = 139,["113"] = 142,["114"] = 143,["116"] = 146,["117"] = 147,["118"] = 148,["120"] = 138,["121"] = 161,["122"] = 163,["123"] = 164,["124"] = 167,["125"] = 168,["126"] = 169,["127"] = 161,["128"] = 176,["129"] = 178,["130"] = 179,["131"] = 180,["132"] = 181,["133"] = 182,["134"] = 184,["135"] = 176,["136"] = 191,["137"] = 192,["138"] = 195,["139"] = 196,["140"] = 199,["141"] = 200,["142"] = 191,["143"] = 207,["144"] = 208,["145"] = 211,["146"] = 212,["147"] = 215,["148"] = 216,["149"] = 217,["150"] = 220,["151"] = 221,["152"] = 220,["153"] = 225,["154"] = 226,["155"] = 227,["156"] = 229,["157"] = 207,["158"] = 236,["160"] = 237,["162"] = 241,["163"] = 242,["164"] = 243,["165"] = 244,["166"] = 245,["167"] = 246,["168"] = 247,["169"] = 248,["170"] = 249,["171"] = 252,["172"] = 254,["174"] = 239,["177"] = 256,["179"] = 239,["181"] = 236});
local ____exports = {}
local ____interfaces = require("framework.core.interfaces")
local runtime = ____interfaces.runtime
function ____exports.testAsyncTimer()
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local keepAlive
        keepAlive = function()
            return __TS__AsyncAwaiter(function(____awaiter_resolve)
                __TS__Await(runtime.timer:sleep(5000))
                runtime.logger:debug("[Test] Keep alive with async/await")
                keepAlive()
            end)
        end
        keepAlive()
    end)
end
local function bootstrap()
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info("[Test] Bootstrap started")
        __TS__Await(runtime.timer:sleep(1000))
        runtime.logger:info("[Test] Bootstrap completed")
    end)
end
function ____exports.startService()
    runtime.service:start(function()
        bootstrap():catch(function(____, ____error)
            runtime.logger:error("[Test] Bootstrap failed:", ____error)
            runtime.service:exit()
        end)
        local function keepAlive()
            return __TS__AsyncAwaiter(function(____awaiter_resolve)
                while true do
                    __TS__Await(runtime.timer:sleep(60000))
                    runtime.logger:debug("[Main] Keep alive")
                end
            end)
        end
        keepAlive()
    end)
end
function ____exports.setupMessageHandler()
    runtime.network:dispatch(
        "lua",
        function(session, source, cmd, ...)
            return __TS__AsyncAwaiter(function(____awaiter_resolve)
                local ____try = __TS__AsyncAwaiter(function()
                    runtime.logger:debug("[Test] Received command: " .. tostring(cmd))
                    __TS__Await(runtime.timer:sleep(100))
                    runtime.network:ret({success = true, cmd = cmd})
                end)
                __TS__Await(____try.catch(
                    ____try,
                    function(____, ____error)
                        runtime.network:ret(
                            false,
                            tostring(____error)
                        )
                    end
                ))
            end)
        end
    )
end
function ____exports.testRuntimeAPI()
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info("[Test] Using runtime logger")
        __TS__Await(runtime.timer:sleep(1000))
        runtime.logger:debug("[Test] Timer sleep works")
    end)
end
function ____exports.testGlobalObjects()
    console:log("[Test] Console.log works")
    console:info("[Test] Console.info works")
    local nodeEnv = process.env.NODE_ENV
    runtime.logger:debug("[Test] Process env: " .. tostring(nodeEnv))
    global.testValue = 123
    runtime.logger:debug("[Test] Global value: " .. tostring(global.testValue))
end
local testModules = {gateway = "GatewayModule", login = "LoginModule"}
function ____exports.testStaticImport()
    local moduleName = "login"
    local module = testModules[moduleName]
    runtime.logger:debug("[Test] Static import: " .. module)
end
function ____exports.testArrayIndex()
    local arr = {
        1,
        2,
        3,
        4,
        5
    }
    local last = arr[#arr]
    runtime.logger:debug("[Test] Last element: " .. tostring(last))
end
function ____exports.testRegex()
    local emailPattern = nil
    local email = "test@example.com"
    local match = email:match(emailPattern)
    runtime.logger:debug("[Test] Regex match: " .. tostring(not not match))
end
function ____exports.testNullCheck()
    local obj = {}
    if obj.foo == nil then
        runtime.logger:debug("[Test] Value is null or undefined")
    end
    obj.foo = 42
    if obj.foo ~= nil then
        runtime.logger:debug("[Test] Value exists: " .. tostring(obj.foo))
    end
end
function ____exports.testDateAPI()
    local timestamp = Date:now()
    runtime.logger:debug("[Test] Current timestamp: " .. tostring(timestamp))
    local date = __TS__New(Date, timestamp)
    local isoString = date:toISOString()
    runtime.logger:debug("[Test] ISO string: " .. isoString)
end
function ____exports.testBitwise()
    local a = 1 & 3
    local b = 1 | 2
    local c = 1 ~ 3
    local d = 1 << 4
    local e = 16 >> 2
    runtime.logger:debug((((((((("[Test] Bitwise: " .. tostring(a)) .. ", ") .. tostring(b)) .. ", ") .. tostring(c)) .. ", ") .. tostring(d)) .. ", ") .. tostring(e))
end
function ____exports.testStringAPI()
    local str = "你好世界"
    local byteCount = #str
    runtime.logger:debug("[Test] String length (bytes): " .. tostring(byteCount))
    local charCount = #__TS__ArrayFrom(str)
    runtime.logger:debug("[Test] String length (chars): " .. tostring(charCount))
end
function ____exports.testMapSet()
    local map = __TS__New(Map)
    map:set("key", "value")
    map:set(123, "number key")
    local obj = {id = 1}
    map:set(obj, "object key")
    runtime.logger:debug("[Test] Map get object: " .. tostring(map:get(obj)))
    map:forEach(function(____, value, key)
        runtime.logger:debug((("[Test] Map entry: " .. tostring(key)) .. " => ") .. tostring(value))
    end)
    local set = __TS__New(Set)
    set:add(1)
    set:add(2)
    runtime.logger:debug("[Test] Set size: " .. tostring(set.size))
end
function ____exports.runAllTests()
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        runtime.logger:info("[Test] Starting all tests...")
        local ____try = __TS__AsyncAwaiter(function()
            ____exports.testGlobalObjects()
            ____exports.testStaticImport()
            ____exports.testArrayIndex()
            ____exports.testRegex()
            ____exports.testNullCheck()
            ____exports.testDateAPI()
            ____exports.testBitwise()
            ____exports.testStringAPI()
            ____exports.testMapSet()
            __TS__Await(____exports.testRuntimeAPI())
            runtime.logger:info("[Test] All tests completed successfully!")
        end)
        __TS__Await(____try.catch(
            ____try,
            function(____, ____error)
                runtime.logger:error("[Test] Test failed:", ____error)
            end
        ))
    end)
end
return ____exports
