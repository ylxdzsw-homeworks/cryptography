using Restful
using HttpServer

include("../lib/index.jl")
using Lib

const APPID = parse(Int, ARGS[1])
path(x) = "build/$APPID/$x"
"" |> path |> mkpath

include("root.jl")

@async run(Server(root_I), host=ip"0.0.0.0", port=APPID)

isinteractive() || wait()
