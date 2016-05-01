genid() = @sprintf("%x", rand(UInt64))

@resource files <: root let
    :mixin => [defaultmixin]

    :POST | json => let
        for i in 1:65535
            id = genid()
            if !exists(db, id)
                db["$(id)/name"] = req[:body]["filename"]
                return Dict(:id => id)
            end
        end
        error("no id avaliable")
    end
end
