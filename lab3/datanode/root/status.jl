@resource status <: root let
    :mixin => [defaultmixin]

    :GET | json => begin
        r = get(indexurl("nodes",replace(ADDRESS, ":", "%2A")))
        online = r.status == 200 && JSON.parse(readall(r))["online"]
        Dict(:online=>online)
    end
end
