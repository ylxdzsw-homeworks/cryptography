# 2016.3.25 ylxdzsw@gmail.com

# NOTE: 所有位的索引都是从左往右数(从高位往低位数), 不足2的次方时在左边(高位)补0.

export encrypt, decrypt

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
    ]'
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
    L[1], R[1] = split(key)
    for i in 1:16
        L[i+1] = rol(nshift[i]==2 ? rol(L[i]) : L[i])
        R[i+1] = rol(nshift[i]==2 ? rol(R[i]) : R[i])
    end
    BitVector[[L[i];R[i]] for i in 2:17]
end

"""
permute on shifted keys of the 16 rounds
yield the final keys that is ready to xor the data
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
    ]'
    map(x->permute(x, magic_matrix), x)
end

"""
Initial Permutation, which is not necessary for the sake of securety and mainly for hardware implementation
"""
function IP(x::BitVector)
    magic_matrix = [
        58 50 42 34 26 18 10  2
        60 52 44 36 28 20 12  4
        62 54 46 38 30 22 14  6
        64 56 48 40 32 24 16  8
        57 49 41 33 25 17  9  1
        59 51 43 35 27 19 11  3
        61 53 45 37 29 21 13  5
        63 55 47 39 31 23 15  7
    ]'
    permute(x, magic_matrix)
end

"""
permute on half of data, expanding it to 48bit
"""
function expand(x::BitVector)
    magic_matrix = [
        32  1  2  3  4  5
         4  5  6  7  8  9
         8  9 10 11 12 13
        12 13 14 15 16 17
        16 17 18 19 20 21
        20 21 22 23 24 25
        24 25 26 27 28 29
        28 29 30 31 32  1
    ]'
    permute(x, magic_matrix)
end

"""
substitution 6bit to 4bit, irreversibly
"""
function s_box(x::Vector{BitVector})
    S = Vector{Matrix{UInt8}}(8)
    S[1] = UInt8[
        14  4 13  1  2 15 11  8  3 10  6 12  5  9  0  7
         0 15  7  4 14  2 13  1 10  6 12 11  9  5  3  8
         4  1 14  8 13  6  2 11 15 12  9  7  3 10  5  0
        15 12  8  2  4  9  1  7  5 11  3 14 10  0  6 13
    ]
    S[2] = UInt8[
        15  1  8 14  6 11  3  4  9  7  2 13 12  0  5 10
         3 13  4  7 15  2  8 14 12  0  1 10  6  9 11  5
         0 14  7 11 10  4 13  1  5  8 12  6  9  3  2 15
        13  8 10  1  3 15  4  2 11  6  7 12  0  5 14  9
    ]
    S[3] = UInt8[
        10  0  9 14  6  3 15  5  1 13 12  7 11  4  2  8
        13  7  0  9  3  4  6 10  2  8  5 14 12 11 15  1
        13  6  4  9  8 15  3  0 11  1  2 12  5 10 14  7
         1 10 13  0  6  9  8  7  4 15 14  3 11  5  2 12
    ]
    S[4] = UInt8[
         7 13 14  3  0  6  9 10  1  2  8  5 11 12  4 15
        13  8 11  5  6 15  0  3  4  7  2 12  1 10 14  9
        10  6  9  0 12 11  7 13 15  1  3 14  5  2  8  4
         3 15  0  6 10  1 13  8  9  4  5 11 12  7  2 14
    ]
    S[5] = UInt8[
         2 12  4  1  7 10 11  6  8  5  3 15 13  0 14  9
        14 11  2 12  4  7 13  1  5  0 15 10  3  9  8  6
         4  2  1 11 10 13  7  8 15  9 12  5  6  3  0 14
        11  8 12  7  1 14  2 13  6 15  0  9 10  4  5  3
    ]
    S[6] = UInt8[
        12  1 10 15  9  2  6  8  0 13  3  4 14  7  5 11
        10 15  4  2  7 12  9  5  6  1 13 14  0 11  3  8
         9 14 15  5  2  8 12  3  7  0  4 10  1 13 11  6
         4  3  2 12  9  5 15 10 11 14  1  7  6  0  8 13
    ]
    S[7] = UInt8[
         4 11  2 14 15  0  8 13  3 12  9  7  5 10  6  1
        13  0 11  7  4  9  1 10 14  3  5 12  2 15  8  6
         1  4 11 13 12  3  7 14 10 15  6  8  0  5  9  2
         6 11 13  8  1  4 10  7  9  5  0 15 14  2  3 12
    ]
    S[8] = UInt8[
        13  2  8  4  6 15 11  1 10  9  3 14  5  0 12  7
         1 15 13  8 10  3  7  4 12  5  6 11  0 14  9  2
         7 11  4  1  9 12 14  2  0  6 10 13 15  3  5  8
         2  1 14  7  4 10  8 13 15 12  9  0  3  5  6 11
    ]
    row(x) = x[[1,6]] |> compact
    col(x) = x[[2,3,4,5]] |> compact
    result = BitVector[S[k][row(v)+1,col(v)+1] for (k,v) in enumerate(x)]
    map(x->x[5:end], result)
end

"""
permute on the result of s_box
"""
function p_box(x::Vector{BitVector})
    magic_matrix = [
        16  7 20 21 29 12 28 17
         1 15 23 26  5 18 31 10
         2  8 24 14 32 27  3  9
        19 13 30  6 22 11  4 25
    ]'
    permute([x...;], magic_matrix)
end

"""
permute on the output of the final rounds
"""
function FP(x::BitVector)
    magic_matrix = [
        40  8 48 16 56 24 64 32
        39  7 47 15 55 23 63 31
        38  6 46 14 54 22 62 30
        37  5 45 13 53 21 61 29
        36  4 44 12 52 20 60 28
        35  3 43 11 51 19 59 27
        34  2 42 10 50 18 58 26
        33  1 41  9 49 17 57 25
    ]'
    permute(x, magic_matrix)
end

"""
encrypt 64 bit data
"""
function encrypt(x::BitVector, K::Vector{BitVector})
    x = IP(x)
    L = Vector{BitVector}(17)
    R = Vector{BitVector}(17)
    L[1], R[1] = split(x)
    for i in 1:16
        origin = expand(R[i]) $ K[i]
        target = split(origin, 1:6:48) |> s_box |> p_box
        R[i+1] = target $ L[i]
        L[i+1] = R[i]
    end
    FP([R[17];L[17]])
end

"""
a magic of DES is that descryption is just re-encrypt with reversed key!
"""
function decrypt(x::BitVector, K::Vector{BitVector}; keyargs...)
    encrypt(x, reverse(K); keyargs...)
end

