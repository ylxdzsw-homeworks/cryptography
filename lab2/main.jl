# 2016.3.25 ylxdzsw@gmail.com

# 所有位的索引都是从右往左数(从低位往高位数)

include("bytes.jl")
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
permutate on origin 64bit key, reducing it to 56bit by discarding the parity bits.

@param origin 64bit key
@return 56bit key schedule (a UInt64 start with 0x00)
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
    result = zero(UInt64)

end
