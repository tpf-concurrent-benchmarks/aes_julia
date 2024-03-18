module state

include("constants.jl")
using .constants
#make state a reference to matrix type
const State = Matrix{UInt8}

function new_from_data_in(data_in::Vector{UInt8})
    state::State = reshape(data_in, 4, Int(N_B))
    return state
end

end