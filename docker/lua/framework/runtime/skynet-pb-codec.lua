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
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["15"] = 14,["16"] = 18,["17"] = 20,["19"] = 25,["20"] = 25,["21"] = 25,["22"] = 25,["23"] = 25,["24"] = 25,["25"] = 25,["26"] = 25,["27"] = 25,["28"] = 25,["29"] = 25,["30"] = 25,["31"] = 25,["32"] = 25,["33"] = 25,["34"] = 25,["35"] = 25,["36"] = 25,["37"] = 25,["38"] = 48,["39"] = 49,["40"] = 49,["41"] = 49,["42"] = 50,["44"] = 53,["45"] = 53,["46"] = 53,["48"] = 54,["49"] = 55,["50"] = 58,["51"] = 57,["52"] = 61,["53"] = 63,["54"] = 64,["55"] = 67,["56"] = 67,["57"] = 67,["58"] = 67,["59"] = 67,["60"] = 67,["61"] = 67,["62"] = 75,["63"] = 76,["64"] = 78,["65"] = 79,["66"] = 81,["67"] = 83,["68"] = 86,["69"] = 87,["70"] = 88,["72"] = 90,["75"] = 93,["78"] = 97,["79"] = 98,["80"] = 61,["81"] = 101,["82"] = 104,["83"] = 105,["85"] = 106,["89"] = 109,["90"] = 101,["91"] = 112,["92"] = 114,["93"] = 115,["95"] = 116,["99"] = 118,["100"] = 112,["101"] = 121,["102"] = 124,["103"] = 125,["104"] = 121,["105"] = 128,["106"] = 128,["107"] = 128,["109"] = 129,["110"] = 130,["111"] = 132,["112"] = 139,["113"] = 128,["114"] = 142,["115"] = 143,["116"] = 144,["117"] = 146,["119"] = 147,["120"] = 147,["121"] = 147,["122"] = 147,["126"] = 150,["127"] = 152,["128"] = 142});
local ____exports = {}
local skynet = _G.require("skynet")
local pb = _G.require("pb")
local protoc = _G.require("protoc")
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
    local skynetRoot = skynet.getenv("skynet_root") or "./skynet"
    self.protoRoot = tostring(skynetRoot) .. "/service-ts/protos"
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
            local data = f.read(_G, "*all")
            f.close(_G)
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
    self.initialized = true
    skynet.error("[SkynetPbCodec] Initialized")
end
function SkynetPbCodec.prototype.encode(self, messageType, message)
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
    local payload = self:encode(messageType, message)
    local timestamp = skynet.time()
    local packet = {msgId = msgId, session = session, data = payload, timestamp = timestamp}
    return self:encode("common.Packet", packet)
end
function SkynetPbCodec.prototype.unpack(self, data)
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
