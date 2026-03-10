-- =============================================================================
-- TS-Skynet Async 协程补丁
-- 职责：将 TSTL 的 __TS__AsyncAwaiter 和 __TS__Await 替换为 Skynet 兼容版本
-- 原理：修改 package.loaded["lualib_bundle"] 中的函数，使后续 require 获取修改后的版本
-- =============================================================================

local skynet = require "skynet"

-- 获取原始 lualib_bundle（应该已经被加载）
local lualib = package.loaded["lualib_bundle"]
if not lualib then
    -- 如果还没加载，先加载它
    lualib = require "lualib_bundle"
end

-- 保存原始实现（备用）
local _origAsyncAwaiter = lualib.__TS__AsyncAwaiter
local _origAwait = lualib.__TS__Await
local __TS__New = lualib.__TS__New
local __TS__Promise = lualib.__TS__Promise

-- 使用 Lua 原生协程 API（Skynet 环境中仍然可用）
local cocreate = coroutine.create
local coresume = coroutine.resume
local costatus = coroutine.status
local coyield = coroutine.yield

-- =============================================================================
-- Skynet 兼容的 __TS__AsyncAwaiter
-- 
-- 核心改动：
-- 1. 使用 skynet.fork 包装整个 Promise 执行过程
-- 2. 确保协程在 Skynet 消息循环中运行
-- 3. 保持原始的 yield/resume 语义
-- =============================================================================

function lualib.__TS__AsyncAwaiter(generator)
    return __TS__New(
        __TS__Promise,
        function(____, resolve, reject)
            local fulfilled, step, resolved, asyncCoroutine
            
            function fulfilled(self, value)
                local success, resultOrError = coresume(asyncCoroutine, value)
                if success then
                    return step(resultOrError)
                end
                return reject(nil, resultOrError)
            end
            
            function step(result)
                if resolved then
                    return
                end
                if costatus(asyncCoroutine) == "dead" then
                    return resolve(nil, result)
                end
                return __TS__Promise.resolve(result):addCallbacks(fulfilled, reject)
            end
            
            resolved = false
            
            -- 关键改动：使用 skynet.fork 创建协程
            -- 这确保协程在 Skynet 的调度环境中运行
            skynet.fork(function()
                asyncCoroutine = cocreate(generator)
                local success, resultOrError = coresume(
                    asyncCoroutine,
                    function(____, v)
                        resolved = true
                        return __TS__Promise.resolve(v):addCallbacks(resolve, reject)
                    end
                )
                if success then
                    step(resultOrError)
                else
                    reject(nil, resultOrError)
                end
            end)
        end
    )
end

-- =============================================================================
-- __TS__Await 保持不变
-- 
-- coroutine.yield 在 Skynet 环境中仍然可用
-- 关键是协程必须由 skynet.fork 创建的外层协程管理
-- =============================================================================

function lualib.__TS__Await(thing)
    return coyield(thing)
end

-- =============================================================================
-- 调试日志
-- =============================================================================
skynet.error("[async_skynet] __TS__AsyncAwaiter patched for Skynet compatibility")
