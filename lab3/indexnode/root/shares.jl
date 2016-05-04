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
        [Dict(:name=>x.name, :hash=>x.hash, :nodes=>sum(map(x->get(db[:nodes],x,false), keys(x.origins))))
            for x in values(db[:files])]
    end
end
