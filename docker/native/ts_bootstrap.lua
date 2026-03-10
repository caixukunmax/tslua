-- =============================================================================
-- TS-Skynet 主服务启动入口
-- 职责：
-- 1. 注入全局对象（console、process、global、Date 等）
-- 2. 初始化 TS Runtime
-- 3. 加载 TS 主模块
-- =============================================================================

local skynet = require "skynet"

-- 注入 skynet 到全局（供 TSTL 编译的 lualib_bundle 使用）
_G.skynet = skynet

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

-- 3. 加载 TS main 模块
-- TS 模块顶层会调用 runtime.service.start(...)
-- 注意：Skynet 协程兼容性已内置到 TSTL (skynetCompat: true)
skynet.error("========================================")
skynet.error("  TS Main loading...")
skynet.error("========================================")
require("app.main")
