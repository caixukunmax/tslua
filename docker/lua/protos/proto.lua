local ____lualib = require("lualib_bundle")
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__New = ____lualib.__TS__New
local __TS__SourceMapTraceBack = ____lualib.__TS__SourceMapTraceBack
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["10"] = 8,["11"] = 8,["12"] = 8,["13"] = 8,["14"] = 8,["15"] = 8,["16"] = 8,["17"] = 8,["18"] = 8,["19"] = 8,["20"] = 8,["21"] = 134,["22"] = 135,["23"] = 134,["24"] = 138,["25"] = 139,["26"] = 141,["27"] = 142,["28"] = 139,["29"] = 138,["30"] = 147,["31"] = 148,["32"] = 149,["33"] = 147,["34"] = 154,["35"] = 155,["36"] = 155,["37"] = 157,["38"] = 158,["39"] = 159,["40"] = 159,["41"] = 159,["42"] = 159,["43"] = 159,["44"] = 159,["45"] = 159,["46"] = 157,["47"] = 157,["48"] = 157,["49"] = 155,["50"] = 154,["51"] = 164,["52"] = 165,["53"] = 165,["54"] = 165,["55"] = 165,["56"] = 164,["57"] = 171,["58"] = 171,["59"] = 171,["60"] = 171,["61"] = 164,["62"] = 177,["63"] = 177,["64"] = 177,["65"] = 177,["66"] = 164,["67"] = 183,["68"] = 183,["69"] = 183,["70"] = 183,["71"] = 164,["72"] = 189,["73"] = 189,["74"] = 189,["75"] = 189,["76"] = 164,["77"] = 195,["78"] = 195,["79"] = 195,["80"] = 195,["81"] = 164,["82"] = 201,["83"] = 201,["84"] = 201,["85"] = 201,["86"] = 164,["87"] = 207,["88"] = 207,["89"] = 207,["90"] = 207,["91"] = 164,["92"] = 212,["93"] = 212,["94"] = 212,["95"] = 212,["96"] = 164,["97"] = 154,["98"] = 219,["99"] = 220,["100"] = 220,["101"] = 220,["102"] = 220,["103"] = 219,["104"] = 226,["105"] = 226,["106"] = 226,["107"] = 226,["108"] = 219,["109"] = 232,["110"] = 232,["111"] = 232,["112"] = 232,["113"] = 219,["114"] = 238,["115"] = 238,["116"] = 238,["117"] = 238,["118"] = 219,["119"] = 244,["120"] = 244,["121"] = 244,["122"] = 244,["123"] = 219,["124"] = 154,["125"] = 251,["126"] = 252,["127"] = 252,["128"] = 252,["129"] = 252,["130"] = 251,["131"] = 258,["132"] = 258,["133"] = 258,["134"] = 258,["135"] = 251,["136"] = 264,["137"] = 264,["138"] = 264,["139"] = 264,["140"] = 251,["141"] = 270,["142"] = 270,["143"] = 270,["144"] = 270,["145"] = 251,["146"] = 276,["147"] = 277,["148"] = 278,["149"] = 278,["150"] = 278,["151"] = 278,["152"] = 278,["153"] = 276,["154"] = 276,["155"] = 276,["156"] = 251,["157"] = 154,["158"] = 154,["159"] = 287,["160"] = 287,["161"] = 287,["162"] = 287,["163"] = 287,["164"] = 287,["165"] = 287,["166"] = 287,["167"] = 287,["168"] = 287,["169"] = 287,["170"] = 287,["171"] = 287,["172"] = 287,["173"] = 287,["174"] = 287,["175"] = 287,["176"] = 287,["177"] = 287,["178"] = 309,["179"] = 309,["180"] = 309,["181"] = 309,["182"] = 309,["183"] = 309,["184"] = 309,["185"] = 309,["186"] = 309,["187"] = 309,["188"] = 309,["189"] = 309,["190"] = 309,["191"] = 309,["192"] = 309,["193"] = 309,["194"] = 309,["195"] = 309,["196"] = 309,["197"] = 332});
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
