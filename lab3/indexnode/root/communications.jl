gentoken() = begin
    @sprintf("%x", hash("this is the token"))
end

@resource communications <: root let
    :mixin => [defaultmixin]

    "获取某文件持有者的联系方式和通信暗号"
    :POST | json => begin
        file = File(req[:body]["name"], req[:body]["hash"])
        if file in keys(db[:files])
            file = db[:files][file]
            for (k,v) in file.origins
                if db[:nodes][k]
                    return Dict(:node=>k, :id=>v, :token=>gentoken())
                end
            end
            503
        else
            404
        end
    end
end
