-- =============================================================================
-- String 全局对象注入
-- 为 Skynet 环境提供 UTF-8 兼容的 String API
-- =============================================================================

-- 保存原始 string 表
local _string = string

-- String 对象
local String = {}
String.__index = String

-- String.length - 获取字符数（UTF-8 兼容）
-- 注意：JavaScript 的 str.length 返回字符数，Lua 的 #str 返回字节数
function String.length(str)
    if type(str) ~= "string" then
        return 0
    end
    -- 使用 utf8.len 获取字符数
    local len = utf8.len(str)
    return len or #str
end

-- String.charAt - 获取指定位置的字符
function String.charAt(str, index)
    if type(str) ~= "string" then
        return ""
    end
    if index < 0 or index >= String.length(str) then
        return ""
    end
    -- utf8.char 在 Lua 5.4 中不存在，需要手动处理
    local pos = 1
    for i = 1, index do
        pos = utf8.offset(str, 2, pos)
        if not pos then
            return ""
        end
    end
    local endPos = utf8.offset(str, 2, pos)
    if endPos then
        return string.sub(str, pos, endPos - 1)
    else
        return string.sub(str, pos)
    end
end

-- String.charCodeAt - 获取指定位置字符的 Unicode 码点
function String.charCodeAt(str, index)
    local char = String.charAt(str, index)
    if char == "" then
        return nil
    end
    return utf8.codepoint(char)
end

-- String.substring - 提取子字符串（字符索引）
function String.substring(str, startIdx, endIdx)
    if type(str) ~= "string" then
        return ""
    end
    local len = String.length(str)
    startIdx = startIdx or 0
    endIdx = endIdx or len
    
    if startIdx < 0 then startIdx = 0 end
    if endIdx < 0 then endIdx = 0 end
    if startIdx > endIdx then
        startIdx, endIdx = endIdx, startIdx
    end
    if startIdx >= len then return "" end
    if endIdx > len then endIdx = len end
    
    -- 转换字符索引为字节索引
    local startPos = utf8.offset(str, startIdx + 1)
    local endPos = utf8.offset(str, endIdx + 1)
    
    if not startPos then return "" end
    if endPos then
        return string.sub(str, startPos, endPos - 1)
    else
        return string.sub(str, startPos)
    end
end

-- String.indexOf - 查找子字符串位置
function String.indexOf(str, searchStr, fromIndex)
    if type(str) ~= "string" or type(searchStr) ~= "string" then
        return -1
    end
    fromIndex = fromIndex or 0
    
    -- 在字节层面查找
    local startByte = 1
    if fromIndex > 0 then
        startByte = utf8.offset(str, fromIndex + 1) or 1
    end
    
    local foundStart, foundEnd = string.find(str, searchStr, startByte, true)
    if not foundStart then
        return -1
    end
    
    -- 将字节位置转换为字符位置
    local charPos = utf8.len(string.sub(str, 1, foundStart - 1)) or 0
    return charPos
end

-- String.split - 分割字符串
function String.split(str, separator)
    if type(str) ~= "string" then
        return {}
    end
    separator = separator or ""
    
    if separator == "" then
        -- 分割为单个字符
        local result = {}
        for _, code in utf8.codes(str) do
            table.insert(result, utf8.char(code))
        end
        return result
    end
    
    local result = {}
    local start = 1
    while true do
        local foundStart, foundEnd = string.find(str, separator, start, true)
        if not foundStart then
            table.insert(result, string.sub(str, start))
            break
        end
        table.insert(result, string.sub(str, start, foundStart - 1))
        start = foundEnd + 1
    end
    return result
end

-- String.trim - 去除首尾空白
function String.trim(str)
    if type(str) ~= "string" then
        return ""
    end
    return string.gsub(str, "^[%s﻿]*(.-)[%s﻿]*$", "%1")
end

-- String.includes - 检查是否包含子字符串
function String.includes(str, searchStr, fromIndex)
    if type(str) ~= "string" or type(searchStr) ~= "string" then
        return false
    end
    return String.indexOf(str, searchStr, fromIndex) >= 0
end

-- String.startsWith - 检查是否以指定字符串开头
function String.startsWith(str, searchStr, position)
    if type(str) ~= "string" or type(searchStr) ~= "string" then
        return false
    end
    position = position or 0
    
    local startByte = 1
    if position > 0 then
        startByte = utf8.offset(str, position + 1) or 1
    end
    
    local sub = string.sub(str, startByte, startByte + #searchStr - 1)
    return sub == searchStr
end

-- String.endsWith - 检查是否以指定字符串结尾
function String.endsWith(str, searchStr, endPosition)
    if type(str) ~= "string" or type(searchStr) ~= "string" then
        return false
    end
    endPosition = endPosition or #str
    
    local sub = string.sub(str, endPosition - #searchStr + 1, endPosition)
    return sub == searchStr
end

-- String.repeatStr - 重复字符串（repeat 是 Lua 保留字）
function String.repeatStr(str, count)
    if type(str) ~= "string" then
        return ""
    end
    if count <= 0 then
        return ""
    end
    return string.rep(str, count)
end

-- String.replace - 替换字符串
function String.replace(str, search, replace)
    if type(str) ~= "string" then
        return ""
    end
    local result = string.gsub(str, search, replace, 1)
    return result
end

-- String.toLowerCase - 转小写
function String.toLowerCase(str)
    if type(str) ~= "string" then
        return ""
    end
    return string.lower(str)
end

-- String.toUpperCase - 转大写
function String.toUpperCase(str)
    if type(str) ~= "string" then
        return ""
    end
    return string.upper(str)
end

-- 注入全局
_G.String = String

-- 注意：TSTL 编译 str.length 会变成 #str（字节数）
-- 如果需要字符数，请使用 String.length(str) 或 utf8.len(str)
