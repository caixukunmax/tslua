--[[
    热更新工具
    用于热更新 TS 编译的 Lua 服务模块
]]

local skynet = require "skynet"

local M = {}

-- 清除模块缓存
function M.clear_module(module_name)
    skynet.error("Clearing module cache: " .. module_name)
    package.loaded[module_name] = nil
end

-- 热更新指定模块
function M.reload_module(module_name)
    skynet.error("Reloading module: " .. module_name)
    
    -- 清除缓存
    M.clear_module(module_name)
    
    -- 重新加载
    local ok, result = pcall(require, module_name)
    if not ok then
        skynet.error("Failed to reload module: " .. result)
        return false, result
    end
    
    skynet.error("Module reloaded successfully: " .. module_name)
    return true, result
end

-- 热更新服务逻辑层
function M.hotfix_service(service_address, logic_module)
    skynet.error(string.format("Hotfixing service %s with module %s", service_address, logic_module))
    
    -- 1. 清除逻辑模块缓存
    M.clear_module(logic_module)
    
    -- 2. 通知服务执行热更新
    local ok, result = pcall(skynet.call, service_address, "lua", "hotfix")
    
    if not ok then
        skynet.error("Hotfix failed: " .. tostring(result))
        return false
    end
    
    skynet.error("Hotfix completed successfully")
    return true
end

-- 批量热更新多个服务
function M.hotfix_services(service_list, logic_module)
    local success_count = 0
    local fail_count = 0
    
    for _, service_addr in ipairs(service_list) do
        local ok = M.hotfix_service(service_addr, logic_module)
        if ok then
            success_count = success_count + 1
        else
            fail_count = fail_count + 1
        end
    end
    
    skynet.error(string.format("Hotfix result: %d success, %d failed", success_count, fail_count))
    return success_count, fail_count
end

return M
