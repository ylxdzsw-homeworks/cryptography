using Restful
using HttpServer

include("../lib/index.jl")
using Lib

APPID = parse(Int, ARGS[1])

include("root.jl")

@async run(Server(root_I), host=ip"0.0.0.0", port=APPID)

isinteractive() || wait()
