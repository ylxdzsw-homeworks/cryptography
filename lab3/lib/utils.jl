export unsub, add

unsub{T}(x::SubString{T}) = T(x)

add(i) = x -> x + i
