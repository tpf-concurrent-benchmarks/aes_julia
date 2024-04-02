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

struct CipherStack
    block_cipher::AESBlockCipher
    reader_cipher::ChunkReader
    writer_cipher::ChunkWriter
    reader_decipher::ChunkReader
    writer_decipher::ChunkWriter
    buffer::Vector{Vector{UInt8}}
    buffer_size::Int
    results::Vector{Vector{UInt8}}
end

function new_cipher_stack(input_path::String, encrypted_path::String, decrypted_path::String, cipher_key::CipherKey, buffer_size::Int)
    block_cipher = aes_block_cipher.new(cipher_key)
    reader_cipher = chunk_reader.ChunkReader(input_path, 16, true)
    reader_decipher = chunk_reader.ChunkReader(encrypted_path, 16, false)
    writer_cipher = chunk_writer.ChunkWriter(encrypted_path, false)
    writer_decipher = chunk_writer.ChunkWriter(decrypted_path, true)
    buffer = [Vector{UInt8}(undef, 16) for i in 1:buffer_size]
    results = similar(buffer)
    CipherStack(block_cipher, reader_cipher, writer_cipher, reader_decipher, writer_decipher, buffer, buffer_size, results)
end

function reset_files(cipher_stack::CipherStack)
    seekstart(cipher_stack.reader_cipher.input)
    seekstart(cipher_stack.writer_cipher.output)
    seekstart(cipher_stack.reader_decipher.input)
    seekstart(cipher_stack.writer_decipher.output)
end

function flush_cipher(cipher_stack::CipherStack)
    flush(cipher_stack.writer_cipher.output)    
end

function flush_decipher(cipher_stack::CipherStack)
    flush(cipher_stack.writer_decipher.output)
end

function delete_cipher_stack(cipher_stack::CipherStack)
    close(cipher_stack.reader_cipher.input)
    close(cipher_stack.writer_cipher.output)
    close(cipher_stack.reader_decipher.input)
    close(cipher_stack.writer_decipher.output)
end

function cipher_blocks(blocks::Vector{Vector{UInt8}}, results::Vector{Vector{UInt8}}, expanded_key::AESKey)
    #also maybe check if creating an array of expanded keys is faster
    @threads for i in eachindex(blocks)
        @inbounds results[i] = aes_block_cipher.cipher_block(expanded_key, blocks[i])
    end
end

function cipher(cipher_stack::CipherStack)
    expanded_key = cipher_stack.block_cipher.expanded_key

    reader = cipher_stack.reader_cipher
    writer = cipher_stack.writer_cipher

    buffer = cipher_stack.buffer
    results = cipher_stack.results
    buffer_size = cipher_stack.buffer_size
    
    while true
        chunks_filled = chunk_reader.read_chunks(reader, buffer_size, buffer)
        if chunks_filled == 0
            break
        end

        cipher_blocks(buffer[1:chunks_filled], results, expanded_key)

        chunk_writer.write_chunks(writer, results[1:chunks_filled])
    end
end

function decipher_blocks(blocks::Vector{Vector{UInt8}}, results::Vector{Vector{UInt8}}, inv_expanded_key::AESKey)
    @threads for i in eachindex(blocks)
        @inbounds results[i] = aes_block_cipher.inv_cipher_block(inv_expanded_key, blocks[i])
    end
end

function decipher(cipher_stack::CipherStack)
    inv_expanded_key = cipher_stack.block_cipher.inv_expanded_key

    reader = cipher_stack.reader_decipher
    writer = cipher_stack.writer_decipher

    buffer = cipher_stack.buffer
    results = cipher_stack.results
    buffer_size = cipher_stack.buffer_size

    while true
        chunks_filled = chunk_reader.read_chunks(reader, buffer_size, buffer)
        if chunks_filled == 0
            break
        end

        decipher_blocks(buffer[1:chunks_filled], results, inv_expanded_key)

        chunk_writer.write_chunks(writer, results[1:chunks_filled])
    end
end


end