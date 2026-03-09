-- =============================================================================
-- Console 全局对象注入
-- 为 Skynet 环境提供 Node.js 风格的 console API
-- =============================================================================

local skynet = require "skynet"

-- 格式化参数
local function formatArgs(...)
    local args = { ... }
    if #args == 0 then
        return ""
    end
    
    local parts = {}
    for i, v in ipairs(args) do
        local t = type(v)
        if t == "table" then
            -- 简单的 table 序列化
            local ok, result = pcall(function()
                return table.concat({
                    "{",
                    (function()
                        local items = {}
                        for k, val in pairs(v) do
                            local keyStr = type(k) == "string" and k or tostring(k)
                            local valStr = type(val) == "string" and ("\"" .. val .. "\"") or tostring(val)
                            table.insert(items, keyStr .. "=" .. valStr)
                        end
                        return table.concat(items, ", ")
                    end)(),
                    "}"
                })
            end)
            parts[i] = ok and result or tostring(v)
        elseif t == "string" then
            parts[i] = v
        elseif t == "nil" then
            parts[i] = "nil"
        elseif t == "boolean" then
            parts[i] = v and "true" or "false"
        else
            parts[i] = tostring(v)
        end
    end
    
    return " " .. table.concat(parts, " ")
end

-- Console 对象
console = {
    log = function(_, ...)
        skynet.error("[LOG]" .. formatArgs(...))
    end,
    
    info = function(_, ...)
        skynet.error("[INFO]" .. formatArgs(...))
    end,
    
    debug = function(_, ...)
        skynet.error("[DEBUG]" .. formatArgs(...))
    end,
    
    warn = function(_, ...)
        skynet.error("[WARN]" .. formatArgs(...))
    end,
    
    error = function(_, ...)
        skynet.error("[ERROR]" .. formatArgs(...))
    end,
    
    trace = function(_, ...)
        skynet.error("[TRACE] " .. debug.traceback("", 2) .. formatArgs(...))
    end,
    
    -- time/timeEnd 用于性能测量
    _timers = {},
    time = function(_, label)
        label = label or "default"
        console._timers[label] = skynet.now()
    end,
    
    timeEnd = function(_, label)
        label = label or "default"
        local start = console._timers[label]
        if start then
            local elapsed = skynet.now() - start
            skynet.error(string.format("[TIME] %s: %.2fms", label, elapsed * 10))
            console._timers[label] = nil
        else
            skynet.error("[TIME] Timer '" .. label .. "' not found")
        end
    end,
}

-- 让 console:log() 语法正常工作（Lua 的 : 语法糖需要）
setmetatable(console, { __index = console })
