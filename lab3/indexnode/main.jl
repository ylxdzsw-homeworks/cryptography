using Restful
using HttpServer

include("../lib/index.jl")
using Lib

include("root.jl")

@async run(Server(root_I), host=ip"0.0.0.0", port=10086)

isinteractive() || wait()
