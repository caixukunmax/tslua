local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__New = ____lualib.__TS__New
local __TS__Promise = ____lualib.__TS__Promise
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["13"] = 23,["14"] = 23,["15"] = 23,["16"] = 29,["17"] = 24,["18"] = 27,["21"] = 36,["24"] = 31,["25"] = 31,["26"] = 31,["27"] = 31,["33"] = 29,["34"] = 40,["35"] = 41,["38"] = 42,["39"] = 43,["40"] = 44,["41"] = 40,["42"] = 47,["43"] = 48,["46"] = 49,["47"] = 50,["48"] = 51,["49"] = 47,["50"] = 54,["51"] = 55,["52"] = 55,["53"] = 55,["54"] = 55,["55"] = 55,["56"] = 55,["57"] = 55,["58"] = 56,["61"] = 58,["64"] = 62,["67"] = 64,["71"] = 55,["72"] = 55,["73"] = 70,["74"] = 54,["75"] = 73,["76"] = 74,["77"] = 74,["78"] = 74,["79"] = 75,["80"] = 76,["81"] = 77,["84"] = 82,["87"] = 79,["88"] = 80,["95"] = 85,["97"] = 75,["98"] = 88,["99"] = 89,["100"] = 75,["101"] = 75,["102"] = 93,["103"] = 94,["104"] = 94,["106"] = 96,["107"] = 97,["109"] = 99,["112"] = 74,["113"] = 74,["114"] = 73,["115"] = 105,["116"] = 106,["117"] = 106,["118"] = 106,["119"] = 107,["120"] = 108,["121"] = 109,["122"] = 107,["123"] = 111,["126"] = 116,["129"] = 113,["130"] = 114,["136"] = 107,["137"] = 107,["138"] = 121,["139"] = 122,["140"] = 122,["142"] = 124,["143"] = 125,["145"] = 127,["148"] = 106,["149"] = 106,["150"] = 105,["151"] = 133,["152"] = 134,["153"] = 134,["154"] = 134,["155"] = 134,["156"] = 133,["157"] = 137,["158"] = 138,["159"] = 138,["160"] = 138,["161"] = 138,["162"] = 137,["163"] = 141,["164"] = 142,["165"] = 142,["166"] = 142,["167"] = 143,["168"] = 144,["169"] = 146,["170"] = 147,["173"] = 151,["174"] = 151,["175"] = 151,["176"] = 153,["179"] = 155,["180"] = 156,["181"] = 157,["182"] = 158,["183"] = 159,["186"] = 154,["189"] = 162,["191"] = 154,["193"] = 153,["194"] = 151,["195"] = 151,["196"] = 142,["197"] = 142,["198"] = 141,["202"] = 175,["203"] = 178,["204"] = 178,["205"] = 178,["208"] = 183,["211"] = 180,["212"] = 181,["218"] = 178,["219"] = 178,["220"] = 175,["223"] = 192,["224"] = 195,["225"] = 197,["226"] = 197,["227"] = 197,["228"] = 197,["230"] = 201,["231"] = 201,["232"] = 201,["233"] = 204,["234"] = 201,["235"] = 201,["237"] = 192});
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
                        return __TS__AsyncAwaiter(function(____awaiter_resolve)
                            local ____try = __TS__AsyncAwaiter(function()
                                local value = __TS__Await(promise)
                                results[index + 1] = value
                                completed = completed + 1
                                if completed == #promises then
                                    resolve(results)
                                end
                            end)
                            __TS__Await(____try.catch(
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
            function(____, resolve) return runtime.timer.safeTimeout(resolve, ms) end
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
