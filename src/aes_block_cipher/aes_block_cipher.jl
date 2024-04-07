module aes_block_cipher

include("constants.jl")
using .constants

include("aes_key/aes_key.jl")
using .aes_key

include("state.jl")
using .state

struct AESBlockCipher
    expanded_key::AESKey
    inv_expanded_key::AESKey
end
export AESBlockCipher

function new(cipher_key::CipherKey)::AESBlockCipher
    expanded_key = aes_key.new_direct(cipher_key)
    inv_expanded_key = aes_key.new_inverse(cipher_key)

    return AESBlockCipher(expanded_key, inv_expanded_key)
end

function to_be_bytes(cypher_key::UInt128)::Vector{UInt8}
    cypher_key = hton(cypher_key)
    return reinterpret(UInt8, [uint128_integer])
end

function new_u128(cypher_key::UInt128)
    cypher_key = to_be_bytes(cypher_key)
    return new(cypher_key)
end

function cipher_blocks(blocks::Vector{Vector{UInt8}}, expanded_key::AESKey, blocks_size::Int)
    _state::State = zeros(UInt8, 4, 4)
    @simd for i in 1:blocks_size
        @inbounds cipher_block(expanded_key, blocks[i], _state)
    end
end

function cipher_block(expanded_key::AESKey, data_in::Vector{UInt8}, _state::State)

    state.new_from_data_in_with_state(data_in, _state)

    state.add_round_key(_state, expanded_key[1:N_B])
    for round in 1:N_R-1
        state.sub_bytes(_state)
        state.shift_rows(_state)
        state.mix_columns(_state)
        state.add_round_key(_state, expanded_key[(round*N_B)+1:((round+1)*N_B)])
    end
    state.sub_bytes(_state)
    state.shift_rows(_state)
    state.add_round_key(_state, expanded_key[(N_R*N_B)+1:((N_R+1)*N_B)])

    state.set_data_out(_state, data_in)
end

function inv_cipher_blocks(blocks::Vector{Vector{UInt8}}, inv_expanded_key::AESKey, blocks_size::Int)
    _state::State = zeros(UInt8, 4, 4)
    @simd for i in 1:blocks_size
        @inbounds inv_cipher_block(inv_expanded_key, blocks[i], _state)
    end
end

function inv_cipher_block(inv_expanded_key::AESKey, data_in::Vector{UInt8}, _state::State)

    state.new_from_data_in_with_state(data_in, _state)
    
    state.add_round_key(_state, inv_expanded_key[(N_R*N_B)+1:((N_R+1)*N_B)])
    
    for round in reverse(1:N_R-1)
        state.inv_sub_bytes(_state)
        state.inv_shift_rows(_state)
        state.inv_mix_columns(_state)
        state.add_round_key(_state, inv_expanded_key[(round*N_B)+1:((round+1)*N_B)])
    end
    state.inv_sub_bytes(_state)
    state.inv_shift_rows(_state)
    state.add_round_key(_state, inv_expanded_key[1:N_B])

    state.set_data_out(_state, data_in)
end

end