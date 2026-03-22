local ____lualib = require("lualib_bundle")
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__New = ____lualib.__TS__New
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["7"] = 16,["8"] = 16,["9"] = 19,["10"] = 19,["11"] = 22,["12"] = 22,["14"] = 8,["15"] = 8,["18"] = 11,["19"] = 11,["22"] = 14,["23"] = 14,["25"] = 25,["26"] = 26,["27"] = 25,["28"] = 30,["29"] = 31,["30"] = 31,["31"] = 33,["32"] = 35,["33"] = 35,["34"] = 35,["35"] = 35,["36"] = 35,["37"] = 35,["38"] = 35,["39"] = 31,["40"] = 37,["41"] = 39,["42"] = 39,["43"] = 39,["44"] = 39,["45"] = 39,["46"] = 39,["47"] = 31,["48"] = 30,["49"] = 42,["50"] = 43,["51"] = 45,["52"] = 45,["53"] = 45,["54"] = 45,["55"] = 45,["56"] = 42,["57"] = 42,["58"] = 42,["59"] = 42,["60"] = 42,["61"] = 42,["62"] = 42,["63"] = 42,["64"] = 42,["65"] = 42,["66"] = 42,["67"] = 42,["68"] = 42,["69"] = 42,["70"] = 42,["71"] = 42,["72"] = 30,["73"] = 108,["74"] = 108,["75"] = 108,["76"] = 108,["77"] = 118,["78"] = 120,["79"] = 120,["80"] = 120,["81"] = 120,["82"] = 120,["83"] = 108,["84"] = 108,["85"] = 108,["86"] = 108,["87"] = 30,["88"] = 135,["89"] = 135,["90"] = 135,["91"] = 144,["92"] = 146,["93"] = 146,["94"] = 146,["95"] = 146,["96"] = 146,["97"] = 135,["98"] = 135,["99"] = 135,["100"] = 135,["101"] = 135,["102"] = 135,["103"] = 135,["104"] = 30,["105"] = 30,["106"] = 30,["107"] = 178});
local ____exports = {}
local ____common = require("protos.common")
local ErrorCode = ____common.ErrorCode
local ____gateway = require("protos.gateway")
local MessageType = ____gateway.MessageType
local ____message_id = require("protos.message_id")
local MessageId = ____message_id.MessageId
do
    local ____common = require("protos.common")
    ____exports.ErrorCode = ____common.ErrorCode
end
do
    local ____gateway = require("protos.gateway")
    ____exports.MessageType = ____gateway.MessageType
end
do
    local ____message_id = require("protos.message_id")
    ____exports.MessageId = ____message_id.MessageId
end
local function createMessage(defaults, init)
    return __TS__ObjectAssign({}, defaults, init)
end
____exports.proto = {
    common = {
        ErrorCode = ErrorCode,
        Packet = {create = function(init) return createMessage(
            {
                msgId = 0,
                session = 0,
                data = __TS__New(Uint8Array, 0),
                timestamp = 0
            },
            init
        ) end},
        Response = {create = function(init) return createMessage(
            {
                code = ErrorCode.SUCCESS,
                message = "",
                data = __TS__New(Uint8Array, 0)
            },
            init
        ) end}
    },
    game = {
        PlayerInfo = {create = function(init) return createMessage({
            userId = 0,
            level = 0,
            exp = 0,
            gold = 0,
            enterTime = 0
        }, init) end},
        EnterGameRequest = {create = function(init) return createMessage({userId = 0, token = ""}, init) end},
        EnterGameResponse = {create = function(init) return createMessage({code = ErrorCode.SUCCESS, message = "", player = nil}, init) end},
        LeaveGameRequest = {create = function(init) return createMessage({userId = 0}, init) end},
        LeaveGameResponse = {create = function(init) return createMessage({code = ErrorCode.SUCCESS, message = ""}, init) end},
        GetPlayerInfoRequest = {create = function(init) return createMessage({userId = 0}, init) end},
        GetPlayerInfoResponse = {create = function(init) return createMessage({code = ErrorCode.SUCCESS, message = "", player = nil}, init) end},
        PlayerUpdate = {create = function(init) return createMessage({level = 0, exp = 0, gold = 0}, init) end},
        UpdatePlayerRequest = {create = function(init) return createMessage({userId = 0, update = nil}, init) end},
        UpdatePlayerResponse = {create = function(init) return createMessage({code = ErrorCode.SUCCESS, message = "", player = nil}, init) end},
        GetOnlinePlayersRequest = {create = function(init) return createMessage({}, init) end},
        GetOnlinePlayersResponse = {create = function(init) return createMessage({count = 0, players = {}}, init) end},
        AddExpRequest = {create = function(init) return createMessage({userId = 0, expAmount = 0}, init) end},
        AddExpResponse = {create = function(init) return createMessage({code = ErrorCode.SUCCESS, message = "", levelUp = false}, init) end},
        AddGoldRequest = {create = function(init) return createMessage({userId = 0, goldAmount = 0}, init) end},
        AddGoldResponse = {create = function(init) return createMessage({code = ErrorCode.SUCCESS, message = "", player = nil}, init) end}
    },
    gateway = {
        MessageType = MessageType,
        HeartbeatRequest = {create = function(init) return createMessage({clientTime = 0}, init) end},
        HeartbeatResponse = {create = function(init) return createMessage({serverTime = 0, onlineCount = 0}, init) end},
        ClientInfo = {create = function(init) return createMessage({
            ip = "",
            port = 0,
            version = "",
            platform = "",
            deviceId = ""
        }, init) end},
        ConnectRequest = {create = function(init) return createMessage({token = ""}, init) end},
        ConnectResponse = {create = function(init) return createMessage({code = ErrorCode.SUCCESS, message = "", connId = 0, serverTime = 0}, init) end},
        DisconnectNotify = {create = function(init) return createMessage({connId = 0, reason = ""}, init) end}
    },
    login = {
        LoginRequest = {create = function(init) return createMessage({username = "", password = "", deviceId = "", platform = ""}, init) end},
        LoginResponse = {create = function(init) return createMessage({code = ErrorCode.SUCCESS, message = "", token = ""}, init) end},
        UserInfo = {create = function(init) return createMessage({
            userId = 0,
            username = "",
            loginTime = 0,
            level = 0,
            exp = 0
        }, init) end},
        LogoutRequest = {create = function(init) return createMessage({userId = 0}, init) end},
        LogoutResponse = {create = function(init) return createMessage({code = ErrorCode.SUCCESS, message = ""}, init) end},
        ValidateTokenRequest = {create = function(init) return createMessage({token = ""}, init) end},
        ValidateTokenResponse = {create = function(init) return createMessage({code = ErrorCode.SUCCESS, message = "", userId = 0, valid = false}, init) end},
        GetOnlineCountRequest = {create = function(init) return createMessage({}, init) end},
        GetOnlineCountResponse = {create = function(init) return createMessage({count = 0}, init) end}
    },
    message_id = {MessageId = MessageId}
}
____exports.default = ____exports.proto
return ____exports
