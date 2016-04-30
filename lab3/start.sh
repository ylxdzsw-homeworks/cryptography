julia indexnode/main.jl &
sleep 5
julia datanode/main.jl 233 &
julia datanode/main.jl 123 &
julia datanode/main.jl 111 &
wait
