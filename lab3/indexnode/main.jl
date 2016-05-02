using Restful
using Restful: json
using HttpServer

include("../lib/index.jl")
using Lib

include("model.jl")

const db = Dict(
    :files => Dict{File, File}(),
    :nodes => Dict{AbstractString, Bool}()
)

include("root.jl")

@async run(Server(root), host=ip"0.0.0.0", port=12000)

isinteractive() || wait()
