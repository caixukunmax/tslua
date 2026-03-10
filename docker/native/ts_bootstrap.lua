-- =============================================================================
-- TS-Skynet 主服务启动入口
-- 职责：
-- 1. 注入全局对象（console、process、global、Date 等）
-- 2. 初始化 TS Runtime
-- 3. 应用 Skynet 协程补丁
-- 4. 加载 TS 主模块
-- =============================================================================

local skynet = require "skynet"

-- 1. 注入全局对象
require "global"
require "process"
require "console"
require "date"
require "string"

-- 2. 初始化 TS Runtime
local interfaces = require "framework.core.interfaces"
local adapter = require "framework.runtime.skynet-adapter"
interfaces.setRuntime(adapter.createSkynetRuntime())

-- 3. 应用 Skynet 协程补丁（必须在加载业务模块之前）
-- 将 TSTL 的 __TS__AsyncAwaiter 和 __TS__Await 替换为 Skynet 兼容版本
require "async_skynet"

-- 4. 加载 TS main 模块
-- TS 模块顶层会调用 runtime.service.start(...)
skynet.error("========================================")
skynet.error("  TS Main loading...")
skynet.error("========================================")
require("app.main")
