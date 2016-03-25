# 2016.3.25 ylxdzsw@gmail.com

Base.convert{T<:Unsigned}(::Type{T}, x::BitVector) = [j*2^(i-1) for (i,j) in enumerate(x)] |> sum |> T
Base.convert{T<:Unsigned}(::Type{BitVector}, x::T) = let
    len = T.size * 8
    [x << (len-i) >> (len-1) for i in 1:len] |> BitVector
end

"""
将一个bitarray压缩成合适的Intenger
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
showbits(x::BitVector) = (x |> compact |> bits |> reverse)[1:length(x)] |> println
showbits(x::Unsigned)  = x |> bits |> reverse |> println

"""
用给定的置换矩阵置换bit串
"""
permute{T<:Integer}(x::BitVector, p::Array{T}) = [x[i] for i in p] |> BitVector
permute{T<:Integer}(x::Unsigned, p::Array{T}) = permute(BitVector(x), p)
