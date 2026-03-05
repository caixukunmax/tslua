local ____lualib = require("lualib_bundle")
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__New = ____lualib.__TS__New
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["10"] = 8,["11"] = 8,["12"] = 8,["13"] = 8,["14"] = 8,["15"] = 8,["16"] = 8,["17"] = 8,["18"] = 8,["19"] = 8,["20"] = 8,["21"] = 133,["22"] = 134,["23"] = 133,["24"] = 137,["25"] = 138,["26"] = 140,["27"] = 141,["28"] = 138,["29"] = 137,["30"] = 146,["31"] = 147,["32"] = 148,["33"] = 146,["34"] = 153,["35"] = 154,["36"] = 154,["37"] = 156,["38"] = 157,["39"] = 158,["40"] = 158,["41"] = 158,["42"] = 158,["43"] = 158,["44"] = 158,["45"] = 158,["46"] = 156,["47"] = 156,["48"] = 156,["49"] = 154,["50"] = 153,["51"] = 163,["52"] = 164,["53"] = 164,["54"] = 164,["55"] = 164,["56"] = 163,["57"] = 170,["58"] = 170,["59"] = 170,["60"] = 170,["61"] = 163,["62"] = 176,["63"] = 176,["64"] = 176,["65"] = 176,["66"] = 163,["67"] = 182,["68"] = 182,["69"] = 182,["70"] = 182,["71"] = 163,["72"] = 188,["73"] = 188,["74"] = 188,["75"] = 188,["76"] = 163,["77"] = 194,["78"] = 194,["79"] = 194,["80"] = 194,["81"] = 163,["82"] = 200,["83"] = 200,["84"] = 200,["85"] = 200,["86"] = 163,["87"] = 206,["88"] = 206,["89"] = 206,["90"] = 206,["91"] = 163,["92"] = 211,["93"] = 211,["94"] = 211,["95"] = 211,["96"] = 163,["97"] = 153,["98"] = 218,["99"] = 219,["100"] = 219,["101"] = 219,["102"] = 219,["103"] = 218,["104"] = 225,["105"] = 225,["106"] = 225,["107"] = 225,["108"] = 218,["109"] = 231,["110"] = 231,["111"] = 231,["112"] = 231,["113"] = 218,["114"] = 237,["115"] = 237,["116"] = 237,["117"] = 237,["118"] = 218,["119"] = 243,["120"] = 243,["121"] = 243,["122"] = 243,["123"] = 218,["124"] = 153,["125"] = 250,["126"] = 251,["127"] = 251,["128"] = 251,["129"] = 251,["130"] = 250,["131"] = 257,["132"] = 257,["133"] = 257,["134"] = 257,["135"] = 250,["136"] = 263,["137"] = 263,["138"] = 263,["139"] = 263,["140"] = 250,["141"] = 269,["142"] = 269,["143"] = 269,["144"] = 269,["145"] = 250,["146"] = 275,["147"] = 276,["148"] = 277,["149"] = 277,["150"] = 277,["151"] = 277,["152"] = 277,["153"] = 275,["154"] = 275,["155"] = 275,["156"] = 250,["157"] = 153,["158"] = 153,["159"] = 286,["160"] = 286,["161"] = 286,["162"] = 286,["163"] = 286,["164"] = 286,["165"] = 286,["166"] = 286,["167"] = 286,["168"] = 286,["169"] = 286,["170"] = 286,["171"] = 286,["172"] = 286,["173"] = 286,["174"] = 286,["175"] = 286,["176"] = 286,["177"] = 286,["178"] = 308,["179"] = 308,["180"] = 308,["181"] = 308,["182"] = 308,["183"] = 308,["184"] = 308,["185"] = 308,["186"] = 308,["187"] = 308,["188"] = 308,["189"] = 308,["190"] = 308,["191"] = 308,["192"] = 308,["193"] = 308,["194"] = 308,["195"] = 308,["196"] = 308,["197"] = 331});
local ____exports = {}
--- Protocol Buffers 简化实现
-- Node.js 环境使用 JSON 序列化作为 fallback
-- Skynet 环境使用 lua-protobuf
____exports.ErrorCode = {
    SUCCESS = 0,
    UNKNOWN_ERROR = 1,
    INVALID_REQUEST = 2,
    UNAUTHORIZED = 3,
    FORBIDDEN = 4,
    NOT_FOUND = 5,
    TIMEOUT = 6,
    INTERNAL_ERROR = 7,
    SERVICE_UNAVAILABLE = 8
}
local function createMessage(defaults, init)
    return __TS__ObjectAssign({}, defaults, init)
end
local function createEncoder(message)
    return {finish = function()
        local json = JSON:stringify(message)
        return __TS__New(TextEncoder):encode(json)
    end}
end
local function createDecoder(data)
    local json = __TS__New(TextDecoder):decode(data)
    return JSON:parse(json)
end
____exports.proto = {
    common = {
        ErrorCode = ____exports.ErrorCode,
        Packet = {
            create = function(init) return createMessage(
                {
                    msgId = 0,
                    session = 0,
                    data = __TS__New(Uint8Array),
                    timestamp = 0
                },
                init
            ) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        }
    },
    login = {
        LoginRequest = {
            create = function(init) return createMessage({username = "", password = "", deviceId = "", platform = ""}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        LoginResponse = {
            create = function(init) return createMessage({code = 0, message = "", user = nil, token = ""}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        UserInfo = {
            create = function(init) return createMessage({userId = 0, username = "", loginTime = 0}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        LogoutRequest = {
            create = function(init) return createMessage({userId = 0}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        LogoutResponse = {
            create = function(init) return createMessage({code = 0, message = ""}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        ValidateTokenRequest = {
            create = function(init) return createMessage({token = ""}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        ValidateTokenResponse = {
            create = function(init) return createMessage({code = 0, message = "", userId = 0, valid = false}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        GetOnlineCountRequest = {
            create = function() return {} end,
            encode = function() return createEncoder({}) end,
            decode = function() return {} end
        },
        GetOnlineCountResponse = {
            create = function(init) return createMessage({count = 0}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        }
    },
    gateway = {
        HeartbeatRequest = {
            create = function(init) return createMessage({clientTime = 0}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        HeartbeatResponse = {
            create = function(init) return createMessage({serverTime = 0, clientTime = 0}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        ConnectRequest = {
            create = function(init) return createMessage({token = "", deviceId = "", platform = ""}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        ConnectResponse = {
            create = function(init) return createMessage({success = false, message = "", sessionId = ""}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        DisconnectNotify = {
            create = function(init) return createMessage({reason = ""}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        }
    },
    game = {
        EnterGameRequest = {
            create = function(init) return createMessage({userId = 0}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        EnterGameResponse = {
            create = function(init) return createMessage({success = false, playerInfo = nil}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        LeaveGameRequest = {
            create = function(init) return createMessage({userId = 0}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        LeaveGameResponse = {
            create = function(init) return createMessage({success = false}, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        },
        PlayerInfo = {
            create = function(init) return createMessage({
                userId = 0,
                username = "",
                level = 0,
                exp = 0,
                gold = 0
            }, init) end,
            encode = function(message) return createEncoder(message) end,
            decode = function(data) return createDecoder(data) end
        }
    }
}
____exports.MessageId = {
    HEARTBEAT_REQ = 100,
    HEARTBEAT_RESP = 101,
    CONNECT_REQ = 102,
    CONNECT_RESP = 103,
    DISCONNECT_NOTIFY = 104,
    LOGIN_REQ = 200,
    LOGIN_RESP = 201,
    LOGOUT_REQ = 202,
    LOGOUT_RESP = 203,
    VALIDATE_TOKEN_REQ = 204,
    VALIDATE_TOKEN_RESP = 205,
    GET_ONLINE_COUNT_REQ = 206,
    GET_ONLINE_COUNT_RESP = 207,
    ENTER_GAME_REQ = 300,
    ENTER_GAME_RESP = 301,
    LEAVE_GAME_REQ = 302,
    LEAVE_GAME_RESP = 303
}
____exports.MessageTypes = {
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
____exports.default = ____exports.proto
return ____exports
