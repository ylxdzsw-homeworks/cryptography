# 2016.3.25 ylxdzsw@gmail.com

Base.endof{T<:Unsigned}(x::T) = T.size

Base.getindex(x::Unsigned, i::Integer) = (x >> (i-1)*8) % UInt8
Base.getindex(x::Unsigned, r::UnitRange{Int64}) = [x[i] for i in r]
Base.getindex(x::Unsigned, ::Colon) = x[1:end]

Base.convert{T<:Unsigned}(::Type{T}, x::Vector{UInt8}) = begin
    assert(T.size == length(x))
    res = T(0)
    for i in reverse(x)
        res |= i
        res <<= 8
    end
    res
end
