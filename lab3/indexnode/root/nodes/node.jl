@resource node <: nodes let
    :mixin => [defaultmixin]
    :route => "*"

    "查询节点是否在线"
    :GET | json => let
        id = replace(id, "%2A", ":")
        id in keys(db[:nodes]) || return 404

        Dict(:online=>db[:nodes][id])
    end

    "节点上线"
    :PUT => let
        id = replace(id, "%2A", ":")
        db[:nodes][id] = true
        200
    end

    "节点下线"
    :DELETE => let
        id = replace(id, "%2A", ":")
        id in keys(db[:nodes]) || return 404

        db[:nodes][id] = false
        200
    end
end
