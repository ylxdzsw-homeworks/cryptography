julia indexnode/main.jl &
sleep 5
julia datanode/main.jl 12001 &
julia datanode/main.jl 12002 &
julia datanode/main.jl 12003 &
wait
