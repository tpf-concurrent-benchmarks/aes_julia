module state

include("constants.jl")
using .constants


#make state a reference to matrix type
const State = Matrix{UInt8}
export State

#WARNING: all posible @inbounds have been tested
# dont waste time attempting to add more

function new_from_data_in_with_state(data_in::Vector{UInt8}, _state::State)
    inds = axes(_state, 1)
    for col = inds, row = inds
        @inbounds  _state[row, col] = data_in[((col-1) * 4) + row]
    end
end

function from_32_to_8(word::Word)::Tuple{UInt8, UInt8, UInt8, UInt8}
    byte1 = UInt8(word & 0xFF)
    byte2 = UInt8((word >> 8) & 0xFF)
    byte3 = UInt8((word >> 16) & 0xFF)
    byte4 = UInt8((word >> 24) & 0xFF)
    return byte1, byte2, byte3, byte4
end

function new_from_words(words::Vector{Word})::State
    #this function sets the numbers in big endian
    _state = zeros(UInt8, length(words), 4)  # Preallocate matrix
    
    for (i, word) in enumerate(words)
        byte1, byte2, byte3, byte4 = from_32_to_8(word)
        _state[:, i] .= [byte4, byte3, byte2, byte1]
    end
    
    return _state
end

#julia convert 4 by 4 matrix into 16 element vector in place
function set_data_out(_state::State, data_out::Vector{UInt8})
    inds = axes(_state, 1)
    for col = inds, row = inds
        @inbounds data_out[((col-1) * 4) + row] = _state[row, col]
    end
end

function sub_bytes(_state::State)
    apply_substitution(_state, S_BOX)
end

function inv_sub_bytes(_state::State)
    apply_substitution(_state, INV_S_BOX)
end

function apply_substitution(_state::State, sub_box::Vector{UInt8})
    map!((value) -> sub_box[Int(value) + 1], _state, _state)
end

function my_circshift_1!(A::SubArray{UInt8})
    temp_2::UInt8 = A[2]
    temp_4::UInt8 = A[4]
    A[2] = A[3]
    A[4] = A[1]
    A[3] = temp_4
    A[1] = temp_2
end

function my_circshift_2!(A::SubArray{UInt8})
    temp_1::UInt8 = A[1]
    temp_2::UInt8 = A[2]
    A[1] = A[3]
    A[2] = A[4]
    A[3] = temp_1
    A[4] = temp_2
end

function my_circshift_3!(A::SubArray{UInt8})
    temp_2::UInt8 = A[2]
    temp_4::UInt8 = A[4]
    A[2] = A[1]
    A[4] = A[3]
    A[1] = temp_4
    A[3] = temp_2
end

function shift_rows(_state::State)
    col = @view _state[2, :]
    my_circshift_1!(col)
    col = @view _state[3, :]
    my_circshift_2!(col)
    col = @view _state[4, :]
    my_circshift_3!(col)
end

function inv_shift_rows(_state::State)
    col = @view _state[2, :]
    my_circshift_3!(col)
    col = @view _state[3, :]
    my_circshift_2!(col)
    col = @view _state[4, :]
    my_circshift_1!(col)
end

# function shift_rows(_state::State)
#     for i in 2:4
#         col = @view _state[i, :] #this access way is slow, TODO try to find a faster way accessing it [:, i]
#         circshift!(col, i-1)
#     end
# end

# function inv_shift_rows(_state::State)
#     for i in 2:4
#         col = @view _state[i, :] #this access way is slow, TODO try to find a faster way accessing it [:, i]
#         circshift!(col, -i+1)
#     end
# end

function add_round_key(_state::State, round_key::SubArray{Word})
    for i in 1:N_B
        @inbounds byte1, byte2, byte3, byte4 = from_32_to_8(round_key[i])
        _state[1, i] ⊻= byte4
        _state[2, i] ⊻= byte3
        _state[3, i] ⊻= byte2
        _state[4, i] ⊻= byte1
    end
end

function mix_columns(_state::State)
    for i in 1:N_B
        @inbounds col = @view _state[:, i]
        mix_column(col)
    end
end

function inv_mix_columns(_state::State)
    for i in 1:N_B
        @inbounds col = @view _state[:, i]
        inv_mix_column(col)
    end
end

function mix_column(col::SubArray{UInt8})
    @inbounds begin
        a, b, c, d = col[1], col[2], col[3], col[4]
        
        col[1] = galois_double(reinterpret(Int8, a ⊻ b)) ⊻ b ⊻ c ⊻ d
        col[2] = galois_double(reinterpret(Int8, b ⊻ c)) ⊻ c ⊻ d ⊻ a
        col[3] = galois_double(reinterpret(Int8, c ⊻ d)) ⊻ d ⊻ a ⊻ b
        col[4] = galois_double(reinterpret(Int8, d ⊻ a)) ⊻ a ⊻ b ⊻ c
    end
end

function inv_mix_column(col::SubArray{UInt8})
    @inbounds begin
        a, b, c, d = col[1], col[2], col[3], col[4]
        
        x = galois_double(reinterpret(Int8, a ⊻ b ⊻ c ⊻ d))
        y = galois_double(reinterpret(Int8, x ⊻ a ⊻ c))
        z = galois_double(reinterpret(Int8, x ⊻ b ⊻ d))
        
        col[1] = galois_double(reinterpret(Int8, y ⊻ a ⊻ b)) ⊻ b ⊻ c ⊻ d
        col[2] = galois_double(reinterpret(Int8, z ⊻ b ⊻ c)) ⊻ c ⊻ d ⊻ a
        col[3] = galois_double(reinterpret(Int8, y ⊻ c ⊻ d)) ⊻ d ⊻ a ⊻ b
        col[4] = galois_double(reinterpret(Int8, z ⊻ d ⊻ a)) ⊻ a ⊻ b ⊻ c
    end
end

function galois_double(a::Int8)::UInt8
    result = (a << 1) & 0xFF
    if a < 0
        result ⊻= 0x1b
    end
    return result
end

end