local ____lualib = require("lualib_bundle")
local __TS__ParseInt = ____lualib.__TS__ParseInt
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__Class = ____lualib.__TS__Class
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["15"] = 14,["16"] = 18,["17"] = 20,["18"] = 22,["19"] = 22,["20"] = 22,["21"] = 22,["22"] = 23,["23"] = 25,["26"] = 31,["27"] = 31,["28"] = 31,["29"] = 31,["30"] = 31,["31"] = 31,["32"] = 31,["33"] = 31,["34"] = 31,["35"] = 31,["36"] = 31,["37"] = 31,["38"] = 31,["39"] = 31,["40"] = 31,["41"] = 31,["42"] = 31,["43"] = 31,["44"] = 31,["45"] = 54,["46"] = 55,["47"] = 55,["48"] = 55,["49"] = 56,["51"] = 59,["52"] = 59,["53"] = 59,["55"] = 60,["56"] = 61,["57"] = 64,["58"] = 63,["59"] = 67,["60"] = 69,["61"] = 70,["64"] = 75,["65"] = 78,["66"] = 78,["67"] = 78,["68"] = 78,["69"] = 78,["70"] = 78,["71"] = 78,["72"] = 86,["73"] = 87,["74"] = 89,["75"] = 90,["76"] = 93,["77"] = 95,["78"] = 98,["79"] = 99,["80"] = 100,["82"] = 102,["85"] = 105,["88"] = 109,["89"] = 110,["90"] = 67,["91"] = 113,["92"] = 114,["94"] = 115,["98"] = 119,["99"] = 120,["101"] = 121,["105"] = 124,["106"] = 113,["107"] = 127,["108"] = 128,["110"] = 129,["114"] = 132,["115"] = 133,["117"] = 134,["121"] = 136,["122"] = 127,["123"] = 139,["124"] = 141,["125"] = 142,["126"] = 139,["127"] = 145,["128"] = 145,["129"] = 145,["131"] = 146,["133"] = 147,["137"] = 149,["138"] = 150,["139"] = 152,["140"] = 159,["141"] = 145,["142"] = 162,["143"] = 163,["145"] = 164,["149"] = 166,["150"] = 167,["151"] = 169,["153"] = 170,["154"] = 170,["155"] = 170,["156"] = 170,["160"] = 173,["161"] = 175,["162"] = 162});
local ____exports = {}
local skynet = _G.require("skynet")
local pb
local protoc
local hasPb = _G.pcall(function()
    pb = _G.require("pb")
    protoc = _G.require("protoc")
end)
if not hasPb then
    _G.print("[WARN] lua-protobuf not found, pb codec disabled")
end
--- 消息类型映射表
local MSG_ID_TO_NAME = {
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
local MSG_NAME_TO_ID = {}
for ____, ____value in ipairs(__TS__ObjectEntries(MSG_ID_TO_NAME)) do
    local idStr = ____value[1]
    local name = ____value[2]
    MSG_NAME_TO_ID[name] = __TS__ParseInt(idStr)
end
____exports.SkynetPbCodec = __TS__Class()
local SkynetPbCodec = ____exports.SkynetPbCodec
SkynetPbCodec.name = "SkynetPbCodec"
function SkynetPbCodec.prototype.____constructor(self)
    self.initialized = false
    self.protoRoot = ""
    self:initProto()
end
function SkynetPbCodec.prototype.initProto(self)
    if not hasPb then
        skynet.error("[SkynetPbCodec] Protobuf library not available, codec disabled")
        return
    end
    self.protoRoot = "./lua/protos"
    local protoFiles = {
        "common_pb.desc",
        "login_pb.desc",
        "game_pb.desc",
        "gateway_pb.desc",
        "message_id_pb.desc"
    }
    for ____, file in ipairs(protoFiles) do
        local filepath = (self.protoRoot .. "/") .. file
        local f = _G.io.open(filepath, "rb")
        if f then
            local readFile = _G.load("local f = ...; local data = f:read(\"*all\"); f:close(); return data")
            local data = readFile(f)
            local ok = pb.load(data)
            if ok then
                skynet.error("[SkynetPbCodec] Loaded " .. file)
            else
                skynet.error("[SkynetPbCodec] Failed to load " .. file)
            end
        else
            skynet.error("[SkynetPbCodec] Proto file not found: " .. filepath)
        end
    end
    self.initialized = hasPb
    skynet.error("[SkynetPbCodec] Initialized")
end
function SkynetPbCodec.prototype.encode(self, messageType, message)
    if not hasPb then
        error(
            __TS__New(Error, "[SkynetPbCodec] Protobuf not available"),
            0
        )
    end
    local encoded = pb.encode(messageType, message)
    if not encoded then
        error(
            __TS__New(Error, "[SkynetPbCodec] Failed to encode " .. messageType),
            0
        )
    end
    return encoded
end
function SkynetPbCodec.prototype.decode(self, messageType, data)
    if not hasPb then
        error(
            __TS__New(Error, "[SkynetPbCodec] Protobuf not available"),
            0
        )
    end
    local decoded = pb.decode(messageType, data)
    if not decoded then
        error(
            __TS__New(Error, "[SkynetPbCodec] Failed to decode " .. messageType),
            0
        )
    end
    return decoded
end
function SkynetPbCodec.prototype.create(self, messageType, init)
    local result = init or ({})
    return result
end
function SkynetPbCodec.prototype.pack(self, msgId, messageType, message, session)
    if session == nil then
        session = 0
    end
    if not hasPb then
        error(
            __TS__New(Error, "[SkynetPbCodec] Protobuf not available"),
            0
        )
    end
    local payload = self:encode(messageType, message)
    local timestamp = skynet.time()
    local packet = {msgId = msgId, session = session, data = payload, timestamp = timestamp}
    return self:encode("common.Packet", packet)
end
function SkynetPbCodec.prototype.unpack(self, data)
    if not hasPb then
        error(
            __TS__New(Error, "[SkynetPbCodec] Protobuf not available"),
            0
        )
    end
    local packet = self:decode("common.Packet", data)
    local messageType = MSG_ID_TO_NAME[packet.msgId]
    if not messageType then
        error(
            __TS__New(
                Error,
                "[SkynetPbCodec] Unknown msgId: " .. tostring(packet.msgId)
            ),
            0
        )
    end
    local message = self:decode(messageType, packet.data)
    return {msgId = packet.msgId, messageType = messageType, message = message, session = packet.session}
end
return ____exports
