pdf(next, r::Resource, req, id) = begin
    res = next(req, id) |> Response
    res.headers["Content-Type"] = "application/pdf"
    res
end

@resource blob <: blobs let
    :mixin => [defaultmixin]
    :route => "*"

    :PUT => begin
        open(path(id), "w") do f
            f.write(req[:body])
        end
        db[id]["hash"] = hash(req[:body])
        Dict(:id=>id, read(db[id])...)
    end

    :GET | pdf => begin
        if isfile(path(id))
            open(path(id), "r") do f
                readbytes(f)
            end
        else
            404
        end
    end
end
