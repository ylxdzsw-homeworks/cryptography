# 2016.3.25 ylxdzsw@gmail.com

Base.convert{T<:Unsigned}(::Type{T}, x::BitVector) = begin
    assert(T.size * 8 >= length(x))
    [j*2^(i-1) for (i,j) in enumerate(reverse(x))] |> sum |> T
end
Base.convert{T<:Unsigned}(::Type{BitVector}, x::T) = begin
    len = T.size * 8 - 1
    [x << i >> len for i in 0:len] |> BitVector
end

macro bit_str(t) :(collect($t) .== '1') end

"""
将一个bitarray压缩成合适的Integer
"""
function compact(x::BitVector)
    candidates = [UInt8, UInt16, UInt32, UInt64, UInt128]
    p = findfirst(c->c.size*8 >= length(x), candidates)
    assert(p > 0)
    candidates[p](x)
end

"""
打印bit串
"""
showbits(x::BitVector) = [i?'1':'0' for i in x] |> ASCIIString |> println
showbits(x::Unsigned)  = x |> bits |> println
showbits(x::Vector{BitVector}) = begin
    showruler();
    for i in x showbits(i) end
end
showruler(x::Integer=8) = begin
    for i in 1:x print("-------+") end
    println()
end

"""
用给定的置换矩阵置换bit串
"""
permute{T<:Integer}(x::BitVector, p::Array{T}) = [x[i] for i in p] |> BitVector
permute{T<:Integer}(x::Unsigned, p::Array{T}) = permute(BitVector(x), p)

"""
切分bit串
"""
Base.split(x::BitVector, p::OrdinalRange) = BitVector[x[i:j] for (i,j) in zip(p, p+step(p)-1)]
Base.split(x::BitVector) = let center = Int(length(x)/2); (x[1:center], x[center+1:end]) end

