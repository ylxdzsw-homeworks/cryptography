@resource node <: nodes let
    :mixin => [defaultmixin]
    :route => "*"

    "查询节点是否在线"
    :GET | json => let
        id = replace(id, "%2A", ":")
        id in keys(db[:nodes]) || return 404

        Dict(:online=>!isempty(db[:nodes][id]))
    end

    "节点上线"
    :PUT | json => let
        token, timestamp = req[:body]["token"], req[:body]["timestamp"]
        any(db[:users]) do x
            token == gentoken(timestamp, x)
        end || return 403
        id = replace(id, "%2A", ":")
        nodekey = @sprintf("%x", rand(UInt64))
        db[:nodes][id] = nodekey
        Dict(:nodekey=>nodekey)
    end

    "节点下线"
    :DELETE => let
        id = replace(id, "%2A", ":")
        id in keys(db[:nodes]) || return 404

        db[:nodes][id] = ""
        200
    end
end
