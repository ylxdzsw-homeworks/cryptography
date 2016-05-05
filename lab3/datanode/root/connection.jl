@resource connection <: root let
    :mixin => [defaultmixin]

    :PUT => begin
        r = put(indexurl("nodes",replace(ADDRESS, ":", "%2A"))) |> readall |> JSON.parse
        global nodekey = r["nodekey"]
        200
    end

    :DELETE => begin
        delete(indexurl("nodes",replace(ADDRESS, ":", "%2A"))).status
    end
end
