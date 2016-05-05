@resource connection <: root let
    :mixin => [defaultmixin]

    :PUT => begin
        timestamp = @sprintf("%x", UInt64(now()))
        token = gentoken(timestamp, indexkey)
        r = put(indexurl("nodes",replace(ADDRESS, ":", "%2A")),
                json=Dict("timestamp"=>timestamp,
                          "token"=>token)) |> readall |> JSON.parse
        global nodekey = r["nodekey"]
        200
    end

    :DELETE => begin
        delete(indexurl("nodes",replace(ADDRESS, ":", "%2A"))).status
    end
end
