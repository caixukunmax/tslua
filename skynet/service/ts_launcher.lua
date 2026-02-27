local skynet = require "skynet"
local arg = ...

-- 1. 初始化 TS Runtime
local interfaces = require "framework.core.interfaces"
local adapter = require "framework.runtime.skynet-adapter"
interfaces.setRuntime(adapter.createSkynetRuntime())

-- 2. 加载 TS 服务模块
-- TS 模块顶层会调用 runtime.service.start(...)
skynet.error("TS Launcher loading service: " .. tostring(arg))
require(arg)
