include("aes_block_cipher/constants.jl")
using .constants

include("aes_block_cipher/aes_key/aes_key.jl")
using .aes_key

include("aes_block_cipher/state.jl")
using .state

include("aes_block_cipher/aes_block_cipher.jl")
using .aes_block_cipher


include("config.jl")
using .config

include("utils/chunk_reader.jl")
using .chunk_reader

include("utils/chunk_writer.jl")
using .chunk_reader

include("aes_cipher.jl")
using .aes_cipher

BUFFER_SIZE = 10000000

function run_cipher()
    env_variables = config.read_config()
    cipher_key = aes_key.CipherKey((0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c))
    cipher_stack = aes_cipher.new_cipher_stack(env_variables["PLAIN_TEXT"], env_variables["ENCRYPTED_TEXT"], env_variables["DECRYPTED_TEXT"], cipher_key, BUFFER_SIZE)
    for i in 1:parse(Int, env_variables["REPEAT"])
        aes_cipher.cipher(cipher_stack)

        aes_cipher.decipher(cipher_stack)
    end
end

@time run_cipher()