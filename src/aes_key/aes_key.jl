module aes_key

include("../constants.jl")
using .constants

using Pkg
Pkg.add("StaticArrays")
using StaticArrays

struct AESKey
    data::SVector{N_B * (N_R + 1), Word}
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
end # module aes_key