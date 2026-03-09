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
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["15"] = 23,["16"] = 26,["17"] = 28,["18"] = 29,["19"] = 29,["20"] = 29,["21"] = 29,["22"] = 30,["23"] = 31,["26"] = 37,["27"] = 37,["28"] = 37,["29"] = 37,["30"] = 37,["31"] = 37,["32"] = 37,["33"] = 37,["34"] = 37,["35"] = 37,["36"] = 37,["37"] = 37,["38"] = 37,["39"] = 37,["40"] = 37,["41"] = 37,["42"] = 37,["43"] = 37,["44"] = 37,["45"] = 60,["46"] = 61,["47"] = 61,["48"] = 61,["49"] = 62,["51"] = 65,["52"] = 65,["53"] = 65,["55"] = 66,["56"] = 67,["57"] = 70,["58"] = 69,["59"] = 73,["60"] = 75,["61"] = 76,["64"] = 81,["65"] = 84,["66"] = 84,["67"] = 84,["68"] = 84,["69"] = 84,["70"] = 84,["71"] = 84,["72"] = 92,["73"] = 93,["74"] = 94,["75"] = 95,["76"] = 97,["77"] = 98,["78"] = 101,["79"] = 102,["80"] = 103,["82"] = 105,["85"] = 108,["88"] = 112,["89"] = 113,["90"] = 73,["91"] = 116,["92"] = 117,["94"] = 118,["98"] = 121,["99"] = 122,["101"] = 123,["105"] = 126,["106"] = 116,["107"] = 129,["108"] = 130,["110"] = 131,["114"] = 133,["115"] = 134,["117"] = 135,["121"] = 137,["122"] = 129,["123"] = 140,["124"] = 142,["125"] = 143,["126"] = 140,["127"] = 146,["128"] = 146,["129"] = 146,["131"] = 147,["133"] = 148,["137"] = 150,["138"] = 151,["139"] = 153,["140"] = 160,["141"] = 146,["142"] = 163,["143"] = 164,["145"] = 165,["149"] = 167,["150"] = 168,["151"] = 170,["153"] = 171,["154"] = 171,["155"] = 171,["156"] = 171,["160"] = 174,["161"] = 176,["162"] = 163});
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
