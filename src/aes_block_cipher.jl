module aes_block_cipher

include("constants.jl")
using .constants

include("aes_key/aes_key.jl")
using .aes_key

struct AESBlockCipher
    expanded_key::AESKey
    inv_expanded_key::AESKey
end

function new(cipher_key::CipherKey)
    expanded_key = aes_key.new_direct(cipher_key)
    # print(cipher_key)
    inv_expanded_key = aes_key.new_inverse(cipher_key)

    return AESBlockCipher(expanded_key, inv_expanded_key)
end

end