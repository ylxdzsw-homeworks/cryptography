export unsub, add

unsub{T}(x::SubString{T}) = T(x)
unsub(x::AbstractString) = x

add(i) = x -> x + i

gt(i) = x -> x > i

not(f) = (x...) -> !f(x...)

equals(i) = x -> isequal(x, i)
