@resource root let
    :mixin => [defaultmixin]
end

include("root/shares.jl")
include("root/nodes.jl")
include("root/communications.jl")
