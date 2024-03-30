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
using Random


# my_tuple::NTuple{16, UInt8} = (0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c)
# cipher_key = aes_key.CipherKey(my_tuple)
# block_cipher = aes_block_cipher.new(cipher_key)
# for i in 1:10000000
#     data_in = rand(UInt8, 16)
#     data_out = aes_block_cipher.cipher_block(block_cipher.inv_expanded_key, data_in)
# end

chunk = chunk_reader.ChunkReader("./test.txt", Int(4 * N_B), true)
buffer::Vector{Vector{UInt8}} = [fill(UInt8(0), 16) for i in 1:2]
# @time chunk_reader.read_chunks(chunk, 2, buffer)
# println(buffer)
chunk_reader.read_chunks(chunk, 2, buffer)
# println(buffer)
writer = chunk_writer.ChunkWriter("./test2.txt", true)

chunk_writer.write_chunks(writer, buffer)

println("finished")

# Example usage:
# env_variables = config.read_config()
# println(env_variables["N_THREADS"])