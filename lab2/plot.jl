include("main.jl")

key = keygen("Zhang ShiWei");
key = PC1(key);
K = split_shift_concat(key);
K = PC2(K);

t = keygen("fukc") |> BitVector
c = encrypt(t,K)
m = decrypt(c, K)

showruler(); showbits(t); showbits(c); showbits(m)
