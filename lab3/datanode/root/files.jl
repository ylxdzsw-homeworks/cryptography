genid() = @sprintf("%x", rand(UInt64))

download(name::AbstractString, hash::ASCIIString, id::ASCIIString) = begin
    session = post(indexurl("communications"), json=Dict(
        "name" => name, "hash" => hash
    )) |> readall |> JSON.parse

    @assert session != nothing

    data = get("http://$(session["node"])/blobs/$(session["id"])",
                query=Dict("token"=>session["token"])).data

    data = decrypt(data, session["token"])

    @assert @sprintf("%x", Base.hash(data)) == hash

    open(path(id), "w") do f
        write(f, data)
    end
end

@resource files <: root let
    :mixin => [defaultmixin]

    """
    申请一个新的文件id,
    如果提供hash值，则自动去索引节点下载,
    否则需要使用`PUT /blob/id`上传
    """
    :POST | json => begin
        for i in 1:65535
            id::ASCIIString = genid()
            if !exists(db, id)
                db["$(id)/name"] = req[:body]["name"]
                if "hash" in keys(req[:body])
                    db["$(id)/hash"] = req[:body]["hash"]
                    download(req[:body]["name"], req[:body]["hash"], id)
                end
                return Dict(:id => id)
            end
        end
        error("no id avaliable")
    end

    "获得节点上所有文件的信息"
    :GET | json => begin
        read(db)
    end
end
