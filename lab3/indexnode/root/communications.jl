@resource communications <: root let
    :mixin => [defaultmixin]
    :onhandle => [auth]

    "获取某文件持有者的联系方式和通信暗号"
    :POST | json => begin
        file = File(req[:body]["name"], req[:body]["hash"])
        if file in keys(db[:files])
            file = db[:files][file]
            for (k,v) in file.origins
                nodekey = db[:nodes][k]
                if !isempty(nodekey)
                    timestamp = @sprintf("%x", UInt64(now()))
                    return Dict(:node=>k, :id=>v, :timestamp=>timestamp,
                                :token=>gentoken(timestamp, nodekey))
                end
            end
            503
        else
            404
        end
    end
end
