include("main.jl")

key = keygen("Zhang ShiWei");
key = PC1(key);
K = split_shift_concat(key);

showbits(key); for i in 1:16 showbits(K[i]) end

K = PC2(K);

for i in 1:16 showbits(K[i]) end
