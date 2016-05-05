@resource nodes <: root let
    :mixin => [defaultmixin]

    "获得所有在线节点列表"
    :GET | json => begin
        [x for (x,y) in filter(db[:nodes]) do x,y !isempty(y) end]
    end
end

include("nodes/node.jl")
