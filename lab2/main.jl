# 2016.3.25 ylxdzsw@gmail.com

# NOTE: 所有位的索引都是从右往左数(从低位往高位数)

include("tools.jl")

"""
generate key from a specific string

1. xor all chars in the string
2. generate a random 64bit, using the result in 1. as the seed

@param any non-empty ascii string
@return 64bit key with parity bits (parity not actually implemented yet)
"""
function keygen(x::ASCIIString)
    reduce($, collect(UInt8, x)) |> srand # set seed using the string
    rand(UInt64)
end

"""
permute on origin 64bit key, reducing it to 56bit by discarding the parity bits.
"""
function PC1(x::UInt64)
    magic_matrix = [
        57 49 41 33 25 17  9
         1 58 50 42 34 26 18
        10  2 59 51 43 35 27
        19 11  3 60 52 44 36
        63 55 47 39 31 23 15
         7 62 54 46 38 30 22
        14  6 61 53 45 37 29
        21 13  5 28 20 12  4
    ]
    permute(x, magic_matrix)
end

"""
split 56bit key to 2 28bit keys
perform 16 rounds shifts on them
then concat them
"""
function split_shift_concat(key::BitVector)
    L = Vector{BitVector}(17)
    R = Vector{BitVector}(17)
    rol(x) = (x << 1) | (x >> 27)
    nshift = [1 1 2 2 2 2 2 2 1 2 2 2 2 2 2 1]
    L[1] = key[1:28]
    R[1] = key[29:56]
    for i in 1:16
        L[i+1] = rol(nshift[i]==2 ? rol(L[i]) : L[i])
        R[i+1] = rol(nshift[i]==2 ? rol(R[i]) : R[i])
    end
    BitVector[[L[i];R[i]] for i in 2:17]
end

"""
permute on shifted keys of everyround
yields 16 final keys
"""
function PC2(x::Vector{BitVector})
    magic_matrix = [
        14 17 11 24  1  5
         3 28 15  6 21 10
        23 19 12  4 26  8
        16  7 27 20 13  2
        41 52 31 37 47 55
        30 40 51 45 33 48
        44 49 39 56 34 53
        46 42 50 36 29 32
    ]
    map(x->permute(x, magic_matrix), x)
end
