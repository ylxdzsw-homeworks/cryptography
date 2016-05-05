using Restful
using Restful: json
using HttpServer

include("../lib/index.jl")
using Lib

include("model.jl")

const db = Dict(
    :users => ["very secret key"],
    :files => Dict{File, File}(),
    :nodes => Dict{AbstractString, ASCIIString}()
)

auth(r::Resource, req, id) = let
    token     = req[:headers]["X-Auth-Token"]
    node      = req[:headers]["X-Auth-Node"]
    timestamp = req[:headers]["X-Auth-Timestamp"]

    if token == gentoken(timestamp, db[:nodes][node])
        nothing
    else
        Response(403)
    end
end

include("root.jl")

@async run(Server(root), host=ip"0.0.0.0", port=12000)

isinteractive() || wait()
