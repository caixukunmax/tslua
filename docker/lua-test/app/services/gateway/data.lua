local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["12"] = 15,["13"] = 15,["14"] = 15,["16"] = 16,["17"] = 17,["18"] = 15,["19"] = 22,["20"] = 23,["21"] = 23,["22"] = 23,["23"] = 23,["24"] = 24,["25"] = 30,["26"] = 31,["27"] = 22,["28"] = 37,["29"] = 38,["30"] = 37,["31"] = 44,["32"] = 45,["33"] = 44,["34"] = 51,["35"] = 52,["36"] = 51,["37"] = 58,["38"] = 59,["39"] = 58,["40"] = 65,["41"] = 66,["42"] = 67,["43"] = 68,["45"] = 70,["46"] = 71,["47"] = 65,["48"] = 77,["49"] = 78,["50"] = 79,["51"] = 80,["54"] = 83,["55"] = 77,["56"] = 89,["57"] = 90,["58"] = 89,["59"] = 96,["60"] = 97,["61"] = 97,["62"] = 97,["63"] = 97,["64"] = 96,["65"] = 106,["66"] = 107,["67"] = 108,["69"] = 110,["70"] = 111,["72"] = 106});
local ____exports = {}
--- 连接数据存储
-- 这个类不会被热更新，确保数据持久性
____exports.ConnectionData = __TS__Class()
local ConnectionData = ____exports.ConnectionData
ConnectionData.name = "ConnectionData"
function ConnectionData.prototype.____constructor(self)
    self.connections = __TS__New(Map)
    self.nextConnId = 1
end
function ConnectionData.prototype.addConnection(self, clientInfo, connectTime)
    local ____self_0, ____nextConnId_1 = self, "nextConnId"
    local ____self_nextConnId_2 = ____self_0[____nextConnId_1]
    ____self_0[____nextConnId_1] = ____self_nextConnId_2 + 1
    local connId = ____self_nextConnId_2
    local connection = {connId = connId, clientInfo = clientInfo, connectTime = connectTime, userId = nil}
    self.connections:set(connId, connection)
    return connection
end
function ConnectionData.prototype.removeConnection(self, connId)
    return self.connections:delete(connId)
end
function ConnectionData.prototype.getConnection(self, connId)
    return self.connections:get(connId)
end
function ConnectionData.prototype.getAllConnections(self)
    return __TS__ArrayFrom(self.connections:values())
end
function ConnectionData.prototype.getCount(self)
    return self.connections.size
end
function ConnectionData.prototype.bindUser(self, connId, userId)
    local conn = self.connections:get(connId)
    if not conn then
        return false
    end
    conn.userId = userId
    return true
end
function ConnectionData.prototype.findByUserId(self, userId)
    for ____, conn in __TS__Iterator(self.connections:values()) do
        if conn.userId == userId then
            return conn
        end
    end
    return nil
end
function ConnectionData.prototype.clear(self)
    self.connections:clear()
end
function ConnectionData.prototype.exportState(self)
    return {
        connections = __TS__ArrayFrom(self.connections:entries()),
        nextConnId = self.nextConnId
    }
end
function ConnectionData.prototype.importState(self, state)
    if state.connections ~= nil then
        self.connections = __TS__New(Map, state.connections)
    end
    if state.nextConnId ~= nil then
        self.nextConnId = state.nextConnId
    end
end
return ____exports
