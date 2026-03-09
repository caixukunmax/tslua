-- =============================================================================
-- Date 全局对象注入
-- 为 Skynet 环境提供基础的 Date API
-- =============================================================================

local skynet = require "skynet"

-- 获取当前时间戳（毫秒）
-- Skynet 的 skynet.time() 返回秒级时间戳（带小数）
local function now()
    return math.floor(skynet.time() * 1000)
end

-- 获取时间戳的日期表（UTC）
local function getUTCDate(timestamp)
    return os.date("!*t", math.floor(timestamp / 1000))
end

-- 获取时间戳的日期表（本地）
local function getLocalDate(timestamp)
    return os.date("*t", math.floor(timestamp / 1000))
end

-- 格式化时间为 ISO 8601 字符串 (YYYY-MM-DDTHH:mm:ss.sssZ)
local function toISOString(timestamp)
    local ts = math.floor(timestamp / 1000)
    local ms = timestamp % 1000
    local date = getUTCDate(timestamp)
    
    return string.format("%04d-%02d-%02dT%02d:%02d:%02d.%03dZ",
        date.year, date.month, date.day,
        date.hour, date.min, date.sec, ms)
end

-- 获取时区偏移（分钟）
local function getTimezoneOffset(timestamp)
    local ts = math.floor(timestamp / 1000)
    local utc = os.date("!*t", ts)
    local localTime = os.date("*t", ts)
    
    local utcSec = utc.hour * 3600 + utc.min * 60
    local localSec = localTime.hour * 3600 + localTime.min * 60
    local offset = (localSec - utcSec) / 60
    
    if localTime.day ~= utc.day then
        if localTime.day > utc.day or (localTime.day == 1 and utc.day > 1) then
            offset = offset + 1440
        else
            offset = offset - 1440
        end
    end
    
    return offset
end

-- Date.UTC(year, month[, day[, hour[, minute[, second[, millisecond]]]])
-- 返回 UTC 时间戳（毫秒）
local function UTC(year, month, day, hour, min, sec, ms)
    month = (month or 1) - 1  -- JavaScript month 是 0-11
    day = day or 1
    hour = hour or 0
    min = min or 0
    sec = sec or 0
    ms = ms or 0
    
    -- 使用 os.time 计算 UTC 时间戳
    local t = {
        year = year,
        month = month + 1,
        day = day,
        hour = hour,
        min = min,
        sec = sec,
        isdst = false
    }
    local ts = os.time(t)
    return ts * 1000 + ms
end

-- Date.parse(dateString)
-- 解析日期字符串，返回时间戳（毫秒）
-- 支持格式：ISO 8601、RFC 2822 简化版
local function parse(dateString)
    if type(dateString) ~= "string" then
        return nil
    end
    
    -- ISO 8601: YYYY-MM-DDTHH:mm:ss.sssZ
    local year, month, day, hour, min, sec, ms = dateString:match(
        "^(%d%d%d%d)%-(%d%d)%-(%d%d)[T ](%d%d):(%d%d):(%d%d)%.?(%d*)Z?$"
    )
    
    if year then
        month = tonumber(month)
        day = tonumber(day)
        hour = tonumber(hour)
        min = tonumber(min)
        sec = tonumber(sec)
        ms = tonumber(ms) or 0
        if #ms < 3 then ms = ms * math.pow(10, 3 - #ms) end
        
        local t = {
            year = tonumber(year),
            month = month,
            day = day,
            hour = hour,
            min = min,
            sec = sec,
            isdst = false
        }
        return os.time(t) * 1000 + ms
    end
    
    -- 简化格式：YYYY-MM-DD
    year, month, day = dateString:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
    if year then
        local t = {
            year = tonumber(year),
            month = tonumber(month),
            day = tonumber(day),
            hour = 0,
            min = 0,
            sec = 0,
            isdst = false
        }
        return os.time(t) * 1000
    end
    
    return nil
end

-- Date 对象
local Date = {}
Date.__index = Date

-- 构造函数
function Date:__call(timestamp)
    local obj = {
        _timestamp = timestamp or now()
    }
    setmetatable(obj, Date)
    return obj
end

-- 静态方法
Date.now = now
Date.UTC = UTC
Date.parse = parse

-- ============================================
-- 实例方法 - UTC 版本
-- ============================================

function Date:getTime()
    return self._timestamp
end

function Date:getUTCFullYear()
    return getUTCDate(self._timestamp).year
end

function Date:getUTCMonth()
    return getUTCDate(self._timestamp).month - 1  -- JS: 0-11
end

function Date:getUTCDate()
    return getUTCDate(self._timestamp).day
end

function Date:getUTCDay()
    return getUTCDate(self._timestamp).wday - 1  -- Lua: 1-7 (周日=1), JS: 0-6 (周日=0)
end

function Date:getUTCHours()
    return getUTCDate(self._timestamp).hour
end

function Date:getUTCMinutes()
    return getUTCDate(self._timestamp).min
end

function Date:getUTCSeconds()
    return getUTCDate(self._timestamp).sec
end

function Date:getUTCMilliseconds()
    return self._timestamp % 1000
end

-- ============================================
-- 实例方法 - 本地时间版本
-- ============================================

function Date:getFullYear()
    return getLocalDate(self._timestamp).year
end

function Date:getMonth()
    return getLocalDate(self._timestamp).month - 1  -- JS: 0-11
end

function Date:getDate()
    return getLocalDate(self._timestamp).day
end

function Date:getDay()
    return getLocalDate(self._timestamp).wday - 1
end

function Date:getHours()
    return getLocalDate(self._timestamp).hour
end

function Date:getMinutes()
    return getLocalDate(self._timestamp).min
end

function Date:getSeconds()
    return getLocalDate(self._timestamp).sec
end

function Date:getMilliseconds()
    return self._timestamp % 1000
end

function Date:toISOString()
    return toISOString(self._timestamp)
end

function Date:getTimezoneOffset()
    return getTimezoneOffset(self._timestamp)
end

-- 设置元表支持 Date() 和 Date.now() 两种调用方式
setmetatable(Date, Date)

-- 注入全局
_G.Date = Date
