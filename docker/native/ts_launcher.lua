-- =============================================================================
-- TS-Skynet 子服务启动入口
-- 职责：
-- 1. 注入全局对象（console、process、global 等）
-- 2. 初始化 TS Runtime
-- 3. 加载指定的 TS 服务模块
-- =============================================================================

local skynet = require "skynet"
local arg = ...

-- 1. 注入全局对象
require "global"
require "process"
require "console"

-- 2. 初始化 TS Runtime
local interfaces = require "framework.core.interfaces"
local adapter = require "framework.runtime.skynet-adapter"
interfaces.setRuntime(adapter.createSkynetRuntime())

-- 3. 加载 TS 服务模块
-- TS 模块顶层会调用 runtime.service.start(...)
skynet.error("TS Launcher loading service: " .. tostring(arg))
require(arg)
