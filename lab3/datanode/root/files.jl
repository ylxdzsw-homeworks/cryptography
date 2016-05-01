genid() = @sprintf("%x", rand(UInt64))

@resource files <: root let
    :mixin => [defaultmixin]

    "申请一个新的文件id，接下来需要使用`PUT /blob/id`上传文件"
    :POST | json => begin
        for i in 1:65535
            id = genid()
            if !exists(db, id)
                db["$(id)/name"] = req[:body]["filename"]
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
