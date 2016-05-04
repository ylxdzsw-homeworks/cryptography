@resource shares <: root let
    :mixin => [defaultmixin]

    "注册分享文件到索引节点"
    :POST | json => begin
        file = File(req[:body]["name"], req[:body]["hash"])
        file = db[:files][file] = get(db[:files], file, file)
        file.origins[req[:body]["node"]] = req[:body]["id"]
        200
    end

    "获得所有分享文件的信息"
    :GET | json => begin
        values(db[:files]) |> collect
    end
end
