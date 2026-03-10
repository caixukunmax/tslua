local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__New = ____lualib.__TS__New
local __TS__Promise = ____lualib.__TS__Promise
local __TS__AsyncAwaiterSkynet = ____lualib.__TS__AsyncAwaiterSkynet
local __TS__Await = ____lualib.__TS__Await
local __TS__AwaitSkynet = ____lualib.__TS__AwaitSkynet
local __TS__setTimeoutSkynet = ____lualib.__TS__setTimeoutSkynet
local __TS__setImmediateSkynet = ____lualib.__TS__setImmediateSkynet
local __TS__clearTimeoutSkynet = ____lualib.__TS__clearTimeoutSkynet
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["17"] = 23,["18"] = 23,["19"] = 23,["20"] = 29,["21"] = 24,["22"] = 27,["25"] = 36,["28"] = 31,["29"] = 31,["30"] = 31,["31"] = 31,["37"] = 29,["38"] = 40,["39"] = 41,["42"] = 42,["43"] = 43,["44"] = 44,["45"] = 40,["46"] = 47,["47"] = 48,["50"] = 49,["51"] = 50,["52"] = 51,["53"] = 47,["54"] = 54,["55"] = 55,["56"] = 55,["57"] = 55,["58"] = 55,["59"] = 55,["60"] = 55,["61"] = 55,["62"] = 56,["65"] = 58,["68"] = 62,["71"] = 64,["75"] = 55,["76"] = 55,["77"] = 70,["78"] = 54,["79"] = 73,["80"] = 74,["81"] = 74,["82"] = 74,["83"] = 75,["84"] = 76,["85"] = 77,["88"] = 82,["91"] = 79,["92"] = 80,["99"] = 85,["101"] = 75,["102"] = 88,["103"] = 89,["104"] = 75,["105"] = 75,["106"] = 93,["107"] = 94,["108"] = 94,["110"] = 96,["111"] = 97,["113"] = 99,["116"] = 74,["117"] = 74,["118"] = 73,["119"] = 105,["120"] = 106,["121"] = 106,["122"] = 106,["123"] = 107,["124"] = 108,["125"] = 109,["126"] = 107,["127"] = 111,["130"] = 116,["133"] = 113,["134"] = 114,["140"] = 107,["141"] = 107,["142"] = 121,["143"] = 122,["144"] = 122,["146"] = 124,["147"] = 125,["149"] = 127,["152"] = 106,["153"] = 106,["154"] = 105,["155"] = 133,["156"] = 134,["157"] = 134,["158"] = 134,["159"] = 134,["160"] = 133,["161"] = 137,["162"] = 138,["163"] = 138,["164"] = 138,["165"] = 138,["166"] = 137,["167"] = 141,["168"] = 142,["169"] = 142,["170"] = 142,["171"] = 143,["172"] = 144,["173"] = 146,["174"] = 147,["177"] = 151,["178"] = 151,["179"] = 151,["180"] = 153,["183"] = 155,["184"] = 156,["185"] = 157,["186"] = 158,["187"] = 159,["190"] = 154,["193"] = 162,["195"] = 154,["197"] = 153,["198"] = 151,["199"] = 151,["200"] = 142,["201"] = 142,["202"] = 141,["206"] = 175,["207"] = 178,["208"] = 178,["209"] = 178,["212"] = 183,["215"] = 180,["216"] = 181,["222"] = 178,["223"] = 178,["224"] = 175,["227"] = 192,["228"] = 195,["229"] = 197,["230"] = 197,["231"] = 197,["232"] = 197,["234"] = 201,["235"] = 201,["236"] = 201,["237"] = 204,["238"] = 201,["239"] = 201,["241"] = 192});
local ____exports = {}
--- Skynet 环境下的 Promise 实现
-- 这个实现会被 TSTL 使用，用于将 async/await 转换为 Lua 协程
____exports.SkynetPromise = __TS__Class()
local SkynetPromise = ____exports.SkynetPromise
SkynetPromise.name = "SkynetPromise"
function SkynetPromise.prototype.____constructor(self, executor)
    self.state = "pending"
    self.callbacks = {}
    do
        local function ____catch(____error)
            self:reject(____error)
        end
        local ____try, ____hasReturned = pcall(function()
            executor(
                function(value) return self:resolve(value) end,
                function(____error) return self:reject(____error) end
            )
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function SkynetPromise.prototype.resolve(self, value)
    if self.state ~= "pending" then
        return
    end
    self.state = "fulfilled"
    self.value = value
    self:executeCallbacks()
end
function SkynetPromise.prototype.reject(self, ____error)
    if self.state ~= "pending" then
        return
    end
    self.state = "rejected"
    self.error = ____error
    self:executeCallbacks()
end
function SkynetPromise.prototype.executeCallbacks(self)
    __TS__ArrayForEach(
        self.callbacks,
        function(____, ____bindingPattern0)
            local onRejected
            local onFulfilled
            onFulfilled = ____bindingPattern0.onFulfilled
            onRejected = ____bindingPattern0.onRejected
            if self.state == "fulfilled" and onFulfilled then
                do
                    pcall(function()
                        onFulfilled(nil, self.value)
                    end)
                end
            elseif self.state == "rejected" and onRejected then
                do
                    pcall(function()
                        onRejected(nil, self.error)
                    end)
                end
            end
        end
    )
    self.callbacks = {}
end
SkynetPromise.prototype["then"] = function(self, onFulfilled)
    return __TS__New(
        ____exports.SkynetPromise,
        function(resolve, reject)
            local callback = {
                onFulfilled = function(value)
                    if onFulfilled then
                        do
                            local function ____catch(____error)
                                reject(____error)
                            end
                            local ____try, ____hasReturned = pcall(function()
                                local result = onFulfilled(value)
                                resolve(result)
                            end)
                            if not ____try then
                                ____catch(____hasReturned)
                            end
                        end
                    else
                        resolve(value)
                    end
                end,
                onRejected = function(____error)
                    reject(____error)
                end
            }
            if self.state == "pending" then
                local ____self_callbacks_0 = self.callbacks
                ____self_callbacks_0[#____self_callbacks_0 + 1] = callback
            else
                if self.state == "fulfilled" then
                    callback.onFulfilled(self.value)
                else
                    callback.onRejected(self.error)
                end
            end
        end
    )
end
function SkynetPromise.prototype.catch(self, onRejected)
    return __TS__New(
        ____exports.SkynetPromise,
        function(resolve, reject)
            local callback = {
                onFulfilled = function(value)
                    resolve(value)
                end,
                onRejected = function(____error)
                    do
                        local function ____catch(err)
                            reject(err)
                        end
                        local ____try, ____hasReturned = pcall(function()
                            local result = onRejected(____error)
                            resolve(result)
                        end)
                        if not ____try then
                            ____catch(____hasReturned)
                        end
                    end
                end
            }
            if self.state == "pending" then
                local ____self_callbacks_1 = self.callbacks
                ____self_callbacks_1[#____self_callbacks_1 + 1] = callback
            else
                if self.state == "fulfilled" then
                    callback.onFulfilled(self.value)
                else
                    callback.onRejected(self.error)
                end
            end
        end
    )
end
function SkynetPromise.resolve(self, value)
    return __TS__New(
        ____exports.SkynetPromise,
        function(resolve) return resolve(value) end
    )
end
function SkynetPromise.reject(self, ____error)
    return __TS__New(
        ____exports.SkynetPromise,
        function(_, reject) return reject(____error) end
    )
end
function SkynetPromise.all(self, promises)
    return __TS__New(
        ____exports.SkynetPromise,
        function(resolve, reject)
            local results = {}
            local completed = 0
            if #promises == 0 then
                resolve(results)
                return
            end
            __TS__ArrayForEach(
                promises,
                function(____, promise, index)
                    (function()
                        return __TS__AsyncAwaiterSkynet(function(____awaiter_resolve)
                            local ____try = __TS__AsyncAwaiterSkynet(function()
                                local value = __TS__AwaitSkynet(promise)
                                results[index + 1] = value
                                completed = completed + 1
                                if completed == #promises then
                                    resolve(results)
                                end
                            end)
                            __TS__AwaitSkynet(____try.catch(
                                ____try,
                                function(____, ____error)
                                    reject(____error)
                                end
                            ))
                        end)
                    end)()
                end
            )
        end
    )
end
--- 包装 Skynet 的协程操作
-- 当业务代码使用 await 时，底层会调用 skynet.call 等阻塞操作
-- TSTL 会自动处理协程的 yield 和 resume
function ____exports.wrapSkynetCoroutine(fn)
    return __TS__New(
        ____exports.SkynetPromise,
        function(resolve, reject)
            do
                local function ____catch(____error)
                    reject(____error)
                end
                local ____try, ____hasReturned = pcall(function()
                    local result = fn()
                    resolve(result)
                end)
                if not ____try then
                    ____catch(____hasReturned)
                end
            end
        end
    )
end
--- 异步睡眠辅助函数
-- 在两个环境下都能正确工作
function ____exports.sleep(ms)
    if type(setTimeout) ~= "nil" then
        return __TS__New(
            __TS__Promise,
            function(____, resolve) return __TS__SetTimeoutSkynet(resolve, ms) end
        )
    else
        return __TS__New(
            ____exports.SkynetPromise,
            function(resolve)
                resolve()
            end
        )
    end
end
return ____exports
