using Restful
using Restful: json, cors
using HDF5
using HttpServer
import JSON
import Requests: get, post, put, delete, options, readall

include("../lib/index.jl")
using Lib

const APPID = parse(Int, ARGS[1])
const ADDRESS = "localhost:$APPID"
indexurl(x...) = join(["http://localhost:12000", x...], '/')
path(x) = "build/$APPID/$x"
"" |> path |> mkpath

const db = h5open(path("db.h5"), isfile(path("db.h5")) ? "r+" : "w")

include("root.jl")

@async run(Server(root), host=ip"0.0.0.0", port=APPID)

isinteractive() || wait()
