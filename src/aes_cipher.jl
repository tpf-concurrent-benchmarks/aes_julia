module aes_cipher
using Base.Threads

include("aes_block_cipher/aes_block_cipher.jl")
using .aes_block_cipher

include("utils/chunk_reader.jl")
using .chunk_reader

include("utils/chunk_writer.jl")
using .chunk_writer

include("aes_block_cipher/aes_key/aes_key.jl")
using .aes_key

function cipher_blocks(blocks::Vector{Vector{UInt8}}, block_cipher::AESBlockCipher)
    results = similar(blocks) #maybe optimize by reusing these vector between funtions
    #also maybe check if creating an array of expanded keys is faster
    @threads for i in eachindex(blocks)
        @inbounds results[i] = aes_block_cipher.cipher_block(block_cipher.expanded_key, blocks[i])
    end
    results
end

function cipher(input_path::String, output_path::String, cipher_key::CipherKey)
    block_cipher = aes_block_cipher.new(cipher_key)
    reader = chunk_reader.ChunkReader(input_path, 16, true)
    writer = chunk_writer.ChunkWriter(output_path, false)
    buffer = [fill(UInt8(0), 16) for i in 1:2]
    while true
        chunks_filled = chunk_reader.read_chunks(reader, 2, buffer)
        if chunks_filled == 1
            break
        end
        # for i in 1:2
        #     println(buffer[i])
        # end
        results = cipher_blocks(buffer, block_cipher)
        # for i in 1:2
        #     println(results[i])
        # end
        chunk_writer.write_chunks(writer, results)
    end
    close(reader.input)
    close(writer.output)
end

function decipher_blocks(blocks::Vector{Vector{UInt8}}, block_cipher::AESBlockCipher)
    results = similar(blocks)
    @threads for i in eachindex(blocks)
        @inbounds results[i] = aes_block_cipher.inv_cipher_block(block_cipher.inv_expanded_key, blocks[i])
    end
    results
end

function decipher(input_path::String, output_path::String, cipher_key::CipherKey)
    block_cipher = aes_block_cipher.new(cipher_key)
    reader = chunk_reader.ChunkReader(input_path, 16, false)
    writer = chunk_writer.ChunkWriter(output_path, true)
    buffer = [fill(UInt8(0), 16) for i in 1:2]
    while true
        chunks_filled = chunk_reader.read_chunks(reader, 2, buffer)
        if chunks_filled == 1
            break
        end
        # println(buffer)
        results = decipher_blocks(buffer, block_cipher)
        chunk_writer.write_chunks(writer, results)
    end
    close(reader.input)
    close(writer.output)
end

end