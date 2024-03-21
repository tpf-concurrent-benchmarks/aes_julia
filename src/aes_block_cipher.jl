include("constants.jl")
using .constants

include("aes_key/aes_key.jl")
using .new_direct

struct AESBlockCipher
    expanded_key::AESKey
    inv_expanded_key::AESKey
end

function new(cipher_key::Vector{UInt8})
    expanded_key = new_direct.new_direct(cipher_key)
    inv_expanded_key = new_direct.new_inverse(cipher_key)

    return AESBlockCipher(expanded_key, inv_expanded_key)
end