using Restful
using HDF5
using HttpServer

include("../lib/index.jl")
using Lib

const APPID = parse(Int, ARGS[1])
path(x) = "build/$APPID/$x"
"" |> path |> mkpath

const db = h5open(path("db.h5"), isfile(path("db.h5")) ? "r+" : "w")

include("root.jl")

@async run(Server(root), host=ip"0.0.0.0", port=APPID)

isinteractive() || wait()
