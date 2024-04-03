using Distributed

addprocs(4)

@everywhere include("aes_block_cipher/constants.jl")
@everywhere using .constants

@everywhere include("aes_block_cipher/aes_key/aes_key.jl")
@everywhere using .aes_key

@everywhere include("aes_block_cipher/state.jl")
@everywhere using .state

@everywhere include("aes_block_cipher/aes_block_cipher.jl")
@everywhere using .aes_block_cipher


@everywhere include("config.jl")
@everywhere using .config

@everywhere include("utils/chunk_reader.jl")
@everywhere using .chunk_reader

@everywhere include("utils/chunk_writer.jl")
@everywhere using .chunk_reader

@everywhere include("aes_cipher.jl")
@everywhere using .aes_cipher

BUFFER_SIZE = 10000000

function run_cipher(buffer_size::Int)
    env_variables = config.read_config()
    cipher_key = aes_key.CipherKey((0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c))
    @time cipher_stack = aes_cipher.new_cipher_stack(env_variables["PLAIN_TEXT"], env_variables["ENCRYPTED_TEXT"], env_variables["DECRYPTED_TEXT"], cipher_key, buffer_size, parse(Int, env_variables["N_THREADS"]))
    for i in 1:parse(Int, env_variables["REPEAT"])
        @time aes_cipher.cipher(cipher_stack)
        aes_cipher.flush_cipher(cipher_stack)

        @time aes_cipher.decipher(cipher_stack)
        aes_cipher.flush_decipher(cipher_stack)

        aes_cipher.reset_files(cipher_stack)
    end

    aes_cipher.delete_cipher_stack(cipher_stack)
end

run_cipher(BUFFER_SIZE)