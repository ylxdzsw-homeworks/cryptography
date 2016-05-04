@resource remotes <: root let
    :mixin => [defaultmixin]

    "从索引节点获取网络中所有共享的文件"
    :GET => begin
        "shares" |> indexurl |> get |> readall
    end

    "向索引节点注册一个文件"
    :POST | json => let
        id = req[:body]["id"]
        file = db[id] |> read
        post(indexurl("shares"), json=Dict(
            "name" => file["name"],
            "hash" => file["hash"],
            "node" => ADDRESS,
            "id"   => id
        )).status
    end
end
