local ____lualib = require("lualib_bundle")
local __TS__ParseInt = ____lualib.__TS__ParseInt
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ObjectFromEntries = ____lualib.__TS__ObjectFromEntries
local __TS__Class = ____lualib.__TS__Class
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["20"] = 19,["21"] = 19,["22"] = 19,["23"] = 19,["24"] = 19,["25"] = 19,["26"] = 19,["27"] = 19,["28"] = 19,["29"] = 19,["30"] = 19,["31"] = 19,["32"] = 19,["33"] = 19,["34"] = 19,["35"] = 19,["36"] = 19,["37"] = 19,["38"] = 19,["39"] = 42,["40"] = 43,["41"] = 44,["42"] = 44,["43"] = 44,["44"] = 44,["45"] = 44,["46"] = 44,["47"] = 44,["48"] = 44,["49"] = 44,["50"] = 44,["51"] = 44,["52"] = 43,["53"] = 47,["54"] = 47,["55"] = 47,["57"] = 48,["58"] = 49,["59"] = 52,["60"] = 51,["61"] = 55,["64"] = 63,["67"] = 58,["68"] = 59,["69"] = 60,["70"] = 61,["76"] = 55,["77"] = 68,["78"] = 69,["80"] = 70,["84"] = 73,["85"] = 74,["87"] = 75,["91"] = 78,["92"] = 79,["94"] = 79,["96"] = 79,["97"] = 81,["99"] = 82,["103"] = 85,["104"] = 68,["105"] = 88,["106"] = 89,["108"] = 90,["112"] = 93,["113"] = 94,["115"] = 95,["119"] = 98,["120"] = 99,["122"] = 99,["124"] = 99,["125"] = 101,["127"] = 102,["131"] = 105,["132"] = 88,["133"] = 108,["134"] = 109,["136"] = 110,["140"] = 113,["141"] = 114,["143"] = 115,["147"] = 118,["148"] = 119,["150"] = 119,["152"] = 119,["153"] = 121,["155"] = 122,["159"] = 125,["160"] = 108,["161"] = 128,["162"] = 128,["163"] = 128,["165"] = 129,["166"] = 130,["167"] = 132,["168"] = 139,["169"] = 128,["170"] = 142,["171"] = 143,["172"] = 144,["173"] = 146,["175"] = 147,["176"] = 147,["177"] = 147,["178"] = 147,["182"] = 150,["183"] = 152,["184"] = 142});
local ____exports = {}
--- 消息类型映射表
-- 从 proto 生成的代码中获取
local MESSAGE_TYPE_MAP = {
    [100] = "gateway.HeartbeatRequest",
    [101] = "gateway.HeartbeatResponse",
    [102] = "gateway.ConnectRequest",
    [103] = "gateway.ConnectResponse",
    [104] = "gateway.DisconnectNotify",
    [200] = "login.LoginRequest",
    [201] = "login.LoginResponse",
    [202] = "login.LogoutRequest",
    [203] = "login.LogoutResponse",
    [204] = "login.ValidateTokenRequest",
    [205] = "login.ValidateTokenResponse",
    [206] = "login.GetOnlineCountRequest",
    [207] = "login.GetOnlineCountResponse",
    [300] = "game.EnterGameRequest",
    [301] = "game.EnterGameResponse",
    [302] = "game.LeaveGameRequest",
    [303] = "game.LeaveGameResponse"
}
local MSG_ID_TO_NAME = MESSAGE_TYPE_MAP
local MSG_NAME_TO_ID = __TS__ObjectFromEntries(__TS__ArrayMap(
    __TS__ObjectEntries(MESSAGE_TYPE_MAP),
    function(____, ____bindingPattern0)
        local name
        local id
        id = ____bindingPattern0[1]
        name = ____bindingPattern0[2]
        return {
            name,
            __TS__ParseInt(id)
        }
    end
))
____exports.NodePbCodec = __TS__Class()
local NodePbCodec = ____exports.NodePbCodec
NodePbCodec.name = "NodePbCodec"
function NodePbCodec.prototype.____constructor(self)
    self.proto = nil
    self.root = nil
    self:initProto()
end
function NodePbCodec.prototype.initProto(self)
    do
        local function ____catch(____error)
            console:warn("[NodePbCodec] Failed to load proto module:", ____error)
        end
        local ____try, ____hasReturned = pcall(function()
            local protoPath = ____require:resolve("../../protos/proto.js")
            local protoModule = ____require(nil, protoPath)
            self.proto = protoModule.proto
            self.root = protoModule
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function NodePbCodec.prototype.encode(self, messageType, message)
    if not self.proto then
        error(
            __TS__New(Error, "[NodePbCodec] Proto module not loaded"),
            0
        )
    end
    local parts = __TS__StringSplit(messageType, ".")
    if #parts ~= 2 then
        error(
            __TS__New(Error, "[NodePbCodec] Invalid message type: " .. messageType),
            0
        )
    end
    local namespace, typeName = table.unpack(parts, 1, 2)
    local ____opt_0 = self.proto[namespace]
    if ____opt_0 ~= nil then
        ____opt_0 = ____opt_0[typeName]
    end
    local ____type = ____opt_0
    if not ____type then
        error(
            __TS__New(Error, "[NodePbCodec] Unknown message type: " .. messageType),
            0
        )
    end
    return ____type.encode(message).finish()
end
function NodePbCodec.prototype.decode(self, messageType, data)
    if not self.proto then
        error(
            __TS__New(Error, "[NodePbCodec] Proto module not loaded"),
            0
        )
    end
    local parts = __TS__StringSplit(messageType, ".")
    if #parts ~= 2 then
        error(
            __TS__New(Error, "[NodePbCodec] Invalid message type: " .. messageType),
            0
        )
    end
    local namespace, typeName = table.unpack(parts, 1, 2)
    local ____opt_2 = self.proto[namespace]
    if ____opt_2 ~= nil then
        ____opt_2 = ____opt_2[typeName]
    end
    local ____type = ____opt_2
    if not ____type then
        error(
            __TS__New(Error, "[NodePbCodec] Unknown message type: " .. messageType),
            0
        )
    end
    return ____type.decode(data)
end
function NodePbCodec.prototype.create(self, messageType, init)
    if not self.proto then
        error(
            __TS__New(Error, "[NodePbCodec] Proto module not loaded"),
            0
        )
    end
    local parts = __TS__StringSplit(messageType, ".")
    if #parts ~= 2 then
        error(
            __TS__New(Error, "[NodePbCodec] Invalid message type: " .. messageType),
            0
        )
    end
    local namespace, typeName = table.unpack(parts, 1, 2)
    local ____opt_4 = self.proto[namespace]
    if ____opt_4 ~= nil then
        ____opt_4 = ____opt_4[typeName]
    end
    local ____type = ____opt_4
    if not ____type then
        error(
            __TS__New(Error, "[NodePbCodec] Unknown message type: " .. messageType),
            0
        )
    end
    return ____type.create(init)
end
function NodePbCodec.prototype.pack(self, msgId, messageType, message, session)
    if session == nil then
        session = 0
    end
    local payload = self:encode(messageType, message)
    local timestamp = math.floor(Date:now() / 1000)
    local packet = self.proto.common.Packet.create({msgId = msgId, session = session, data = payload, timestamp = timestamp})
    return self.proto.common.Packet.encode(packet).finish()
end
function NodePbCodec.prototype.unpack(self, data)
    local packet = self.proto.common.Packet.decode(data)
    local messageType = MSG_ID_TO_NAME[packet.msgId]
    if not messageType then
        error(
            __TS__New(
                Error,
                "[NodePbCodec] Unknown msgId: " .. tostring(packet.msgId)
            ),
            0
        )
    end
    local message = self:decode(messageType, packet.data)
    return {msgId = packet.msgId, messageType = messageType, message = message, session = packet.session}
end
return ____exports
