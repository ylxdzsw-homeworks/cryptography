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
global nodekey = ""
global indexkey = "very secret key"
indexurl(x...) = join(["http://localhost:12000", x...], '/')
path(x) = "build/$APPID/$x"
"" |> path |> mkpath

const db = h5open(path("db.h5"), isfile(path("db.h5")) ? "r+" : "w")

authheader() = let
    timestamp = @sprintf("%x", UInt64(now()))
    Dict(
        "X-Auth-Token"     => gentoken(timestamp, nodekey),
        "X-Auth-Node"      => ADDRESS,
        "X-Auth-Timestamp" => timestamp
    )
end

include("root.jl")

@async run(Server(root), host=ip"0.0.0.0", port=APPID)

isinteractive() || wait()
