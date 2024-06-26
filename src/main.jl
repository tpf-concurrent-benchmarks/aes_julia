include("aes_block_cipher/aes_key/aes_key.jl")
using .aes_key

include("config.jl")
using .config

include("aes_cipher.jl")
using .aes_cipher

include("StatsLogger.jl")
using .StatsLogger

# using Pkg
# Pkg.add("ProfileView")
# using ProfileView


function run_cipher()
    env_variables = config.read_config()
    StatsLogger.initialize(env_variables["LOGGER_IP"],
        parse(Int, env_variables["LOGGER_PORT"]), env_variables["LOGGER_PREFIX"]
    )
    start = time()

    cipher_key = aes_key.CipherKey((0x2b, 0x7e, 0x15, 0x16,
                                    0x28, 0xae, 0xd2, 0xa6,
                                    0xab, 0xf7, 0x15, 0x88,
                                    0x09, 0xcf, 0x4f, 0x3c)
                                   )
    cipher_stack = aes_cipher.new_cipher_stack(
        env_variables["PLAIN_TEXT"], env_variables["ENCRYPTED_TEXT"],
        env_variables["DECRYPTED_TEXT"], cipher_key,
        parse(Int, env_variables["BUFFER_SIZE"]), parse(Int, env_variables["N_THREADS"]),
        parse(Int, env_variables["TASK_PER_THREAD"])
    )
    for i in 1:parse(Int, env_variables["REPEAT"])
        # VSCodeServer.@profview aes_cipher.cipher(cipher_stack)
        aes_cipher.cipher(cipher_stack)
        aes_cipher.flush_cipher(cipher_stack)

        aes_cipher.decipher(cipher_stack)
        aes_cipher.flush_decipher(cipher_stack)

        aes_cipher.reset_files(cipher_stack)
    end

    aes_cipher.delete_cipher_stack(cipher_stack)

    StatsLogger.gauge("completion_time", time() - start)
    
    # ProfileView.view(; C=true)
end

run_cipher()