pdf(next, r::Resource, req, id) = begin
    res = next(req, id) |> Response
    res.headers["Content-Type"] = "application/pdf"
    res
end

@resource blob <: blobs let
    :mixin => [defaultmixin]
    :route => "*"

    :PUT => begin
        id = unsub(id)
        open(path(id), "w") do f
            write(f, req[:body])
        end
        db[id]["hash"] = @sprintf("%x", hash(req[:body]))
        200
    end

    :GET | pdf => begin
        if isfile(path(id))
            open(path(id), "r") do f
                if haskey(req[:query], "token")
                    token = req[:query]["token"]
                    if token == gentoken(req[:query]["timestamp"], nodekey)
                        encrypt(readbytes(f), token)
                    else
                        403
                    end
                else
                    readbytes(f) # this API only for client
                end
            end
        else
            404
        end
    end
end
