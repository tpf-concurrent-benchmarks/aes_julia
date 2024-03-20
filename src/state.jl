module state

include("constants.jl")
using .constants
#make state a reference to matrix type
const State = Matrix{UInt8}

function new_from_data_in(data_in::Vector{UInt8})
    state::State = reshape(data_in, 4, Int(N_B))
    return state
end

function new_from_words(words::Vector{Word})
    #this function sets the numbers in big endian
    _state = zeros(UInt8, length(words), 4)  # Preallocate matrix
    
    for (i, word) in enumerate(words)
        byte1 = UInt8(word & 0xFF)
        byte2 = UInt8((word >> 8) & 0xFF)
        byte3 = UInt8((word >> 16) & 0xFF)
        byte4 = UInt8((word >> 24) & 0xFF)
        # Fill the matrix row-wise
        _state[i, :] .= [byte4, byte3, byte2, byte1]
    end
    
    return _state
end

function set_data_out(_state::State)
    return reshape(_state, 1, Int(4 * N_B))
end

function sub_bytes(_state::State)
    return apply_substitution(_state, S_BOX)
end

function inv_sub_bytes(_state::State)
    return apply_substitution(_state, INV_S_BOX)
end

function apply_substitution(_state::State, sub_box::Vector{UInt8})
    return map((value) -> sub_box[Int(value) + 1], _state)
end

end