@resource root let
    :mixin => [defaultmixin]
    :onreturn => [cors]
end

include("root/files.jl")
include("root/blobs.jl")
include("root/ping.jl")
include("root/connection.jl")
