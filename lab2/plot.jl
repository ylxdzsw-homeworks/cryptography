include("main.jl")

using Gadfly
set_default_plot_size(12cm, 12cm)

key = keygen("Zhang ShiWei");
key = PC1(key);
K = split_shift_concat(key);
K = PC2(K);

encrypt_bmp("enlightened.bmp", K, group_method=:ecb);
encrypt_bmp("enlightened.bmp", K, group_method=:cbc);

# 雪崩
m1, m2 = random_diff();
showbits(BitVector[m1, m2]); showbits(m1$m2)

M1, M2 = [], [];
encrypt(m1, K, report=x->push!(M1, x));
encrypt(m2, K, report=x->push!(M2, x));
showbits(BitVector[M1[i]$M2[i] for i in 1:16]); showruler()

temp(sb) = begin
    diffbits = zeros(Int, 16)
    for i in 1:256
        m1, m2 = random_diff()
        M1, M2 = [], []
        encrypt(m1, K, s=sb, report=x->push!(M1, x));
        encrypt(m2, K, s=sb, report=x->push!(M2, x));
        for j in 1:16
            diffbits[j] += M1[j] $ M2[j] |> sum
        end
    end
    plot(x = collect(1:16), y = diffbits,
         Geom.point, Scale.x_discrete, Geom.smooth(method=:loess,smoothing=0.65),
         Guide.xlabel("rounds of encrypt"), Guide.ylabel("# of different bits"),
         Guide.title("different bits in 256 times encryption"))
end
temp(s_box)
temp(s_boxify(linear))
temp(s_boxify(random))
temp(s_boxify(custom))

# 完整性
temp(sb) = begin
    mask = one(UInt64) << rand(0:63) # random fixed bit
    pos = zeros(Int, 64)
    for i in 1:256
        m = rand(UInt64) | mask |> BitVector
        pos += encrypt(m, K, s=sb)
    end
    plot(x = collect(1:64), y = pos, Geom.bar, Guide.xticks(ticks=collect(0:8:65)),
         Guide.xlabel("bit position"), Guide.ylabel("times of '1'"),
         Guide.title("times of '1' at different bit position"))
end
temp(s_box)
temp(s_boxify(linear))
temp(s_boxify(random))
temp(s_boxify(custom))

# 差分分析
temp(f, name) = begin
    table = dc(f)
    table[1] = 0x06 # for better plotting experience
    set_default_plot_size(24cm, 8cm)
    plot(x = repeat(collect(0:63), outer=[16]), Guide.xlabel("Δx"),
         y = repeat(collect(0:15), inner=[64]), Guide.ylabel("Δy"),
         color = table, Geom.rectbin, Scale.x_discrete, Scale.y_discrete,
         Guide.title("Differential Distribution of $name"))
end
temp(s4, "S-box 4")
temp(linear(4), "Linear S-box")
temp(random(4), "Random S-box")
temp(custom(4), "My S-box")
