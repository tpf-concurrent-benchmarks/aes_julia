module aes_key

include("../constants.jl")
using .constants

include("../state.jl")
using .state

const AESKey = Vector{Word}

const CipherKey = NTuple{4 * N_K, UInt8}


function new_direct(cipher_key::CipherKey)
    aes_key = zeros(Word, N_B * (N_R + 1))
    return expand_key(cipher_key, aes_key)
end

function new_inverse(cipher_key::CipherKey)
    aes_key = zeros(Word, N_B * (N_R + 1))
    return inv_expand_key(cipher_key, aes_key)
end

function rot_word(word::Word)
    return (word << 8) | (word >> 24)
end

function get_byte_from_word(word::Word, pos::UInt)
    if pos > 3
        throw(ArgumentError("pos must be less than 4"))
    end

    return (word >> (8 * pos)) & 0xFF
end

function expand_key(cipher_key::CipherKey, aes_key::AESKey)
    temp::Word = aes_key[N_K]
    i::UInt8 = 1
    while i <= N_K
        aes_key[i] = big_endian_to_native(cipher_key[(4 * (i - 1) + 1):(4 * i)])#Word(cipher_key[(4 * (i - 1) + 1):(4 * i)] |> be32)
        i += 1
    end
    i = N_K + 1

    while i <= N_B * (N_R + 1)
        temp = aes_key[i - 1]
        if i % N_K == 1
            temp = sub_word(rot_word(temp)) ⊻ R_CON[i ÷ N_K]
        end

        aes_key[i] = aes_key[i - N_K] ⊻ temp
        i += 1
    end
    return aes_key
end

function inv_expand_key(cipher_key::CipherKey, dw::AESKey)
    aes_key = expand_key(cipher_key, dw)

    for round in 1:N_R-1
        # Extract the words for the current round
        round_words = dw[round * N_B + 1 : (round + 1) * N_B]

        # Compute new words using inv_mix_columns_words function
        new_words = inv_mix_columns_words(round_words)

        # Update dw with the new words
        dw[round * N_B + 1 : (round + 1) * N_B] = new_words
    end
    return dw
end

function inv_mix_columns_words(words::Vector{Word})
    _state = state.new_from_words(words)
    state.inv_mix_columns(_state)
    columns = [big_endian_to_native_bytes(col[1], col[2], col[3], col[4]) for col in eachcol(_state)]
    return columns
end

function big_endian_to_native_bytes(byte1::UInt8, byte2, byte3, byte4)::UInt32
    # Concatenate the bytes into a big-endian 32-bit integer
    # WARNING: this should be the other way around to produce a big endian
    # But I dont know why it works like this, it may be just in my machine
    # for reference the machine where this worked was little endian
    big_endian_uint32 = (UInt32(byte4) << 24) | (UInt32(byte3) << 16) | (UInt32(byte2) << 8) | UInt32(byte1)
    # Convert the big-endian integer to the system's native endianness
    return ntoh(big_endian_uint32)
end

function big_endian_to_native(endian_tuple::Tuple{UInt8,UInt8,UInt8,UInt8})::UInt32
    # Unpack the tuple into individual bytes
    byte1, byte2, byte3, byte4 = endian_tuple
    return big_endian_to_native_bytes(byte1, byte2, byte3, byte4)
end

function get_byte(uint32_value::UInt32, byte_index::UInt8)::UInt8
    if byte_index < 0 || byte_index > 3
        throw(ArgumentError("Byte index must be in the range 0-3"))
    end
    byte_shift = 8 * byte_index
    byte_mask = UInt32(0xFF) << byte_shift
    return (uint32_value & byte_mask) >> byte_shift
end

function apply_s_box(value::UInt8)::UInt8
    pos_x = Int(value >> 4)
    pos_y = Int(value & 0x0F) + 1
    S_BOX[pos_x * 16 + pos_y]
end

function sub_word(word::UInt32)::UInt32
    result = 0

    for i::UInt8 in 0:3
        byte = get_byte(word, i)
        new_byte = apply_s_box(byte)
        result |= UInt32(new_byte) << (8 * i)
    end
    
    return result
end

end # module aes_key