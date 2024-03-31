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

env_variables = config.read_config()
cipher_key = aes_key.CipherKey((0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c))
aes_cipher.cipher(env_variables["DECRYPTED_TEXT"], env_variables["ENCRYPTED_TEXT"], cipher_key)




# using Base.Threads

# function thread_delay(a)
#     sleep(1/a)
#     a
# end
# function threaded_sqrt_array(A)
#     B = similar(A)
#     @threads for i in eachindex(A)
#         @inbounds B[i] = thread_delay(A[i])
#     end
#     B
# end
# #make a vector from 1 to 10 in float 64
# A::Vector{Float64} = 1:10
# println(threaded_sqrt_array(A))
# function sqrt_sum(A, chunk)
#     s = zero(eltype(A))
#     for i in chunk
#         @inbounds s += sqrt(A[i])
#     end
#     return s
# end

# function threaded_sqrt_sum_workaround(A)
#     chunks = Iterators.partition(eachindex(A), length(A) ÷ nthreads())
#     tasks = map(chunks) do chunk
#         @spawn sqrt_sum(A, chunk)
#     end
#     # s = mapreduce(fetch, +, tasks; init=zero(eltype(A)))
#     s = map(fetch, tasks)
#     return s
# end
# println(threaded_sqrt_sum_workaround(1:10))

# my_tuple::NTuple{16, UInt8} = (0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c)
# cipher_key = aes_key.CipherKey(my_tuple)
# block_cipher = aes_block_cipher.new(cipher_key)
# for i in 1:10000000
#     data_in = rand(UInt8, 16)
#     data_out = aes_block_cipher.cipher_block(block_cipher.inv_expanded_key, data_in)
# end

# chunk = chunk_reader.ChunkReader(env_variables["DECRYPTED_TEXT"], Int(4 * N_B), true)
# buffer::Vector{Vector{UInt8}} = [fill(UInt8(0), 16) for i in 1:2]
# # @time chunk_reader.read_chunks(chunk, 2, buffer)
# # println(buffer)
# chunk_reader.read_chunks(chunk, 2, buffer)
# # println(buffer)
# writer = chunk_writer.ChunkWriter(env_variables["ENCRYPTED_TEXT"], true)

# chunk_writer.write_chunks(writer, buffer)

# println("finished")

# Example usage:
# env_variables = config.read_config()
# println(env_variables["N_THREADS"])