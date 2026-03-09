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
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["20"] = 20,["21"] = 20,["22"] = 20,["23"] = 20,["24"] = 20,["25"] = 20,["26"] = 20,["27"] = 20,["28"] = 20,["29"] = 20,["30"] = 20,["31"] = 20,["32"] = 20,["33"] = 20,["34"] = 20,["35"] = 20,["36"] = 20,["37"] = 20,["38"] = 20,["39"] = 43,["40"] = 45,["41"] = 46,["42"] = 46,["43"] = 46,["44"] = 46,["45"] = 46,["46"] = 46,["47"] = 46,["48"] = 46,["49"] = 46,["50"] = 46,["51"] = 46,["52"] = 45,["53"] = 49,["54"] = 49,["55"] = 49,["57"] = 50,["58"] = 51,["59"] = 54,["60"] = 53,["61"] = 57,["64"] = 65,["67"] = 61,["68"] = 62,["69"] = 63,["75"] = 57,["76"] = 70,["77"] = 71,["79"] = 72,["83"] = 75,["84"] = 76,["86"] = 77,["90"] = 80,["91"] = 81,["93"] = 81,["95"] = 81,["96"] = 83,["98"] = 84,["102"] = 87,["103"] = 70,["104"] = 90,["105"] = 91,["107"] = 92,["111"] = 95,["112"] = 96,["114"] = 97,["118"] = 100,["119"] = 101,["121"] = 101,["123"] = 101,["124"] = 103,["126"] = 104,["130"] = 107,["131"] = 90,["132"] = 110,["133"] = 111,["135"] = 112,["139"] = 115,["140"] = 116,["142"] = 117,["146"] = 120,["147"] = 121,["149"] = 121,["151"] = 121,["152"] = 123,["154"] = 124,["158"] = 127,["159"] = 110,["160"] = 130,["161"] = 130,["162"] = 130,["164"] = 131,["165"] = 132,["166"] = 134,["167"] = 141,["168"] = 130,["169"] = 144,["170"] = 145,["171"] = 146,["172"] = 148,["174"] = 149,["175"] = 149,["176"] = 149,["177"] = 149,["181"] = 152,["182"] = 154,["183"] = 144});
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
            local protoModule = ____require(nil, "../../protos/proto")
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
