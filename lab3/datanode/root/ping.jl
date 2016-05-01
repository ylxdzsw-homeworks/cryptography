@resource ping <: root let
    :mixin => [defaultmixin]

    :GET => begin
        "pong"
    end
end
