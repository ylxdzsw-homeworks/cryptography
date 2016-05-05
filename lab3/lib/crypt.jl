export encrypt, decrypt, gentoken

function encrypt(data::Vector{UInt8}, key::AbstractString)
    key = key |> hash |> PC1 |> split_shift_concat |> PC2

    len = length(data)

    input = IOBuffer([data;repeat(UInt8[0], outer=[7-(len-1)%8])])
    result = IOBuffer()
    write(result, len)
    while !eof(input)
        m = read(input, UInt64) |> BitVector
        c = des(m, key) |> UInt64
        write(result, c)
    end
    result.data
end

function decrypt(data::Vector{UInt8}, key::AbstractString)
    key = key |> hash |> PC1 |> split_shift_concat |> PC2 |> reverse

    input = IOBuffer(data)
    result = IOBuffer()

    len = read(input, Int)

    while !eof(input)
        c = read(input, UInt64) |> BitVector
        m = des(c, key) |> UInt64
        write(result, m)
    end

    result.data[1:len]
end

function gentoken(timestamp, nodekey)
    @sprintf("%x", hash(timestamp, hash(nodekey)))
end
