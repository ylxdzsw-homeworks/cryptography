@resource connection <: root let
    :mixin => [defaultmixin]

    :PUT => begin
        put(indexurl("nodes",replace(ADDRESS, ":", "%2A"))) |> statuscode
    end

    :DELETE => begin
        delete(indexurl("nodes",replace(ADDRESS, ":", "%2A"))) |> statuscode
    end
end
