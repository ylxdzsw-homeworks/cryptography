using Gadfly
include("main.jl")

text = read_data("text.txt")
letters = ["$('a'-1+i)" for i in 1:26]

# 1. 英语明文字母频率统计
f = frequency(text)
set_default_plot_size(12cm, 8cm)
plot(x=letters, y=f, label=letters,
     Geom.bar, Geom.label(position=:above), Scale.x_discrete,
     Guide.xlabel("letter"), Guide.ylabel("frequency"),
     Guide.title("Letter Frequency of English"))

# 2. 不同密钥得到的密文字母频率统计
function temp(n)
    keys = [keygen(i) for i in [n,n,n,n]]
    ms   = [encode(text, key) for key in keys]
    keylabel(x) = @sprintf("\"%s\"", ASCIIString(map(x->x+'a'-1, x)))
    set_default_plot_size(24cm, 8cm)
    plot(x = repeat(letters, outer=[4]),
         y = [[frequency(i) for i in ms]...],
         xgroup = repeat([keylabel(i) for i in keys], inner=[26]),
         label  = repeat(letters, outer=[4]),
         Geom.subplot_grid(Geom.bar,
                           Geom.label(position=:above)),
         Scale.x_discrete,
         Guide.xlabel("key"),
         Guide.ylabel("frequency"),
         Guide.title("Letter Frequency of Different Keys")
    )
end
temp(4)
temp(16)

# 3. 不同密钥长度下的重合指数:
n = repeat([2^i for i in 0:8], inner=[8]) # 1,2,4,8,...,256每种长度实验8次
ICs = [encode(text, keygen(i)) |> frequency |> calcIC for i in n]
set_default_plot_size(8cm, 8cm)
plot(x = n, y = ICs,
     Geom.point, Scale.x_log2,
     Geom.smooth(method=:loess,smoothing=0.9),
     Guide.xlabel("key length"),Guide.ylabel("IC"),
     Guide.title("ICs of Different key length"))

# 4. 不同猜测密钥长度下的重合指数:
keys = [keygen(i) for i in 4:8]
ICs = [[[frequency(encode(text, key), i) |> calcIC for i in 3:9] for key in keys]...]
set_default_plot_size(18cm, 8cm)
plot(x = repeat([i for i in 3:9], outer=[5]), y = ICs,
     xgroup = repeat([length(key) for key in keys], inner=[7]),
     Scale.x_discrete,
     Geom.subplot_grid(Geom.bar),
     Guide.xlabel("key length"),Guide.ylabel("IC"),
     Guide.title("ICs of Different key length"))

# 5. 256次随机kasiski攻击:
actual = Array{Int,1}(256)
guess  = Array{Int,1}(256)
color  = Array{Any,1}(256)
for i in 1:256
    key = keygen(rand(2:8)) # 随机产生长度为2-8的密钥
    c = encode(text, key)
    actual[i] = key |> length
    guess[i]  = min(kasiski(c), 32) # 去除高于32的点以保证绘图效果
    color[i]  = actual[i] == guess[i] ? "right" : "wrong"
end
set_default_plot_size(8cm, 8cm)
plot(x = actual, y = guess,
     Geom.point,
     Guide.xlabel("actual"),Guide.ylabel("guess"),
     Guide.title("256 Times Random Kasiski Attack")
)
plot(x = actual, color = color, Geom.histogram,
     Guide.xlabel("length"),
     Guide.title("256 Times Random Kasiski Attack")
)
