-- =============================================================================
-- Process 全局对象注入
-- 为 Skynet 环境提供 Node.js 风格的 process API
-- =============================================================================

local skynet = require "skynet"

process = {
    -- 环境变量访问
    env = setmetatable({}, {
        __index = function(_, key)
            return skynet.getenv(key)
        end,
        __newindex = function(_, key, value)
            if value == nil then
                -- Skynet 不支持删除，设为空字符串
                skynet.setenv(key, "")
            else
                skynet.setenv(key, tostring(value))
            end
        end,
    }),
    
    -- 退出进程
    exit = function(_, code)
        code = code or 0
        if code ~= 0 then
            skynet.error("[PROCESS] exit with code: " .. tostring(code))
        end
        skynet.exit()
    end,
    
    -- 下一个 tick（注意：回调不在协程中，不能使用 await）
    nextTick = function(_, callback)
        skynet.timeout(0, callback)
    end,
    
    -- 获取当前工作目录
    cwd = function()
        return skynet.getenv("WORKDIR") or "/skynet"
    end,
    
    -- 进程 ID（Skynet 中是服务地址）
    pid = function()
        return skynet.self()
    end,
    
    -- 平台信息
    platform = "linux",
    arch = "x64",
    
    -- 版本信息
    version = "Skynet-Lua-5.4",
    versions = {
        lua = "5.4",
        skynet = "1.0",
    },
}

-- 常用的 process.argv 模拟
process.argv = {
    "skynet",
    skynet.getenv("SKYNET_CONFIG") or "config",
}
