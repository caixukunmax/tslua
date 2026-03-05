local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__New = ____lualib.__TS__New
local __TS__Promise = ____lualib.__TS__Promise
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["11"] = 23,["12"] = 23,["13"] = 23,["14"] = 29,["15"] = 24,["16"] = 27,["19"] = 36,["22"] = 31,["23"] = 31,["24"] = 31,["25"] = 31,["31"] = 29,["32"] = 40,["33"] = 41,["36"] = 42,["37"] = 43,["38"] = 44,["39"] = 40,["40"] = 47,["41"] = 48,["44"] = 49,["45"] = 50,["46"] = 51,["47"] = 47,["48"] = 54,["49"] = 55,["50"] = 55,["51"] = 55,["52"] = 55,["53"] = 55,["54"] = 55,["55"] = 55,["56"] = 56,["59"] = 58,["62"] = 62,["65"] = 64,["69"] = 55,["70"] = 55,["71"] = 70,["72"] = 54,["73"] = 73,["74"] = 74,["75"] = 74,["76"] = 74,["77"] = 75,["78"] = 76,["79"] = 77,["82"] = 82,["85"] = 79,["86"] = 80,["93"] = 85,["95"] = 75,["96"] = 88,["97"] = 89,["98"] = 75,["99"] = 75,["100"] = 93,["101"] = 94,["102"] = 94,["104"] = 96,["105"] = 97,["107"] = 99,["110"] = 74,["111"] = 74,["112"] = 73,["113"] = 105,["114"] = 106,["115"] = 106,["116"] = 106,["117"] = 107,["118"] = 108,["119"] = 109,["120"] = 107,["121"] = 111,["124"] = 116,["127"] = 113,["128"] = 114,["134"] = 107,["135"] = 107,["136"] = 121,["137"] = 122,["138"] = 122,["140"] = 124,["141"] = 125,["143"] = 127,["146"] = 106,["147"] = 106,["148"] = 105,["149"] = 133,["150"] = 134,["151"] = 134,["152"] = 134,["153"] = 134,["154"] = 133,["155"] = 137,["156"] = 138,["157"] = 138,["158"] = 138,["159"] = 138,["160"] = 137,["161"] = 141,["162"] = 142,["163"] = 142,["164"] = 142,["165"] = 143,["166"] = 144,["167"] = 146,["168"] = 147,["171"] = 151,["172"] = 151,["173"] = 151,["174"] = 152,["175"] = 153,["176"] = 154,["177"] = 155,["178"] = 156,["179"] = 157,["181"] = 152,["182"] = 160,["183"] = 161,["184"] = 152,["185"] = 152,["186"] = 151,["187"] = 151,["188"] = 142,["189"] = 142,["190"] = 141,["194"] = 174,["195"] = 177,["196"] = 177,["197"] = 177,["200"] = 182,["203"] = 179,["204"] = 180,["210"] = 177,["211"] = 177,["212"] = 174,["215"] = 191,["216"] = 194,["217"] = 196,["218"] = 196,["219"] = 196,["220"] = 196,["222"] = 200,["223"] = 200,["224"] = 200,["225"] = 203,["226"] = 200,["227"] = 200,["229"] = 191});
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
                    promise["then"](
                        function(value)
                            results[index + 1] = value
                            completed = completed + 1
                            if completed == #promises then
                                resolve(results)
                            end
                        end,
                        function(____error)
                            reject(____error)
                        end
                    )
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
            function(____, resolve) return setTimeout(nil, resolve, ms) end
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
