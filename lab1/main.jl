"""
从文件读取数据，清除掉所有非字母的字符(包括空格和标点)，并且将大写字母都转换成小写
"""
function read_data(path)
    dis = 'a' - 'A' # equals 32 in ascii
    open(path, "r") do f
        x = readall(f)
        x = map(x->'A'<=x<='Z'?x+dis:x, x) # 将大写字母转换成小写
        x = filter(x->'a'<=x<='z', x) # 清除所有标点符号和空格
        ASCIIString(x)
    end
end

"""
生成给定长度的随机密钥
"""
function keygen(length::Integer)
    UInt8[rand(1:26) for i in 1:length]
end

"""
打印密钥
"""
function showkey(x::Vector{UInt8})
    map(x->x+'a'-1, x) |> ASCIIString |> show
end

"""
使用给定密钥将明文转换成密文
"""
function encode(x::ASCIIString, key::Vector{UInt8})
    loopdown(x) = x > 'z' ? x - 26 : x
    shift(i) = x[i] + key[(i-1) % length(key) + 1]
    Char[i |> shift |> loopdown for i in eachindex(x)] |> ASCIIString
end

"""
使用给定密钥将密文转换成明文
"""
function decode(x::ASCIIString, key::Vector{UInt8})
    loopup(x) = x < 'a' ? x + 26 : x
    shift(i) = x[i] - key[(i-1) % length(key) + 1]
    Char[i |> shift |> loopup for i in eachindex(x)] |> ASCIIString
end

"""
统计各字母出现频率
"""
function frequency(x::ASCIIString, n::Integer=1, phase::Integer=1)
    dict = zeros(Int, 26)
    for i in phase:n:length(x)
        dict[x[i]-'a'+1] += 1
    end
    s = sum(dict)
    Float64[x/s for x in dict]
end

"""
打印频率
"""
function showfrequency(x::Array{Float64,1})
    for i in 'a':'z'
        @printf("%c: %.2f%%\n", i, x[i-'a'+1]*100)
    end
end

"""
计算重合指数
"""
function calcIC(x::Array{Float64,1})
    square(x) = x^2
    map(square, x) |> sum
end
