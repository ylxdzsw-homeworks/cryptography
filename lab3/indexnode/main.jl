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

include("root.jl")

@async run(Server(root), host=ip"0.0.0.0", port=12000)

isinteractive() || wait()
