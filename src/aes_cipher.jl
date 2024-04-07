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
    buffers::Vector{Vector{Vector{UInt8}}}
    buffer_size::Int
    n_threads::Int
    buffer_amount::Int
end

function new_cipher_stack(input_path::String, encrypted_path::String, decrypted_path::String, cipher_key::CipherKey, buffer_size::Int, n_threads::Int)
    buffer_amount = n_threads * 1
    block_cipher = aes_block_cipher.new(cipher_key)
    reader_cipher = chunk_reader.ChunkReader(input_path, 16, true)
    reader_decipher = chunk_reader.ChunkReader(encrypted_path, 16, false)
    writer_cipher = chunk_writer.ChunkWriter(encrypted_path, false)
    writer_decipher = chunk_writer.ChunkWriter(decrypted_path, true)
    buffers = Vector{Vector{Vector{UInt8}}}(undef, buffer_amount)
    for i in 1:buffer_amount
        buffers[i] = [Vector{UInt8}(undef, 16) for i in 1:buffer_size]
    end
    CipherStack(block_cipher, reader_cipher, writer_cipher, reader_decipher, writer_decipher, buffers, buffer_size, n_threads, buffer_amount)
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

function cipher_blocks(blocks::Vector{Vector{Vector{UInt8}}}, buffers_filled::Int, chunks_filled::Vector{Int}, expanded_key::AESKey)
    @sync for i in 1:buffers_filled
        @spawn aes_block_cipher.cipher_blocks(blocks[i][1:chunks_filled[i]], expanded_key, chunks_filled[i])
    end
end

function process_cipher_blocks(cipher_stack::CipherStack)::Bool
    #this function reads the file a buffer_amount times and then spawns the threads to process input
    buffers_filled = 0
    buffers = cipher_stack.buffers
    buffer_size = cipher_stack.buffer_size
    buffer_amount = cipher_stack.buffer_amount
    reader = cipher_stack.reader_cipher
    writer = cipher_stack.writer_cipher

    chunks_filled_array = Vector{Int}(undef, buffer_amount)
    eof_flag::Bool = false
    for i in 1:buffer_amount
        chunks_filled = chunk_reader.read_chunks(reader, buffer_size, buffers[i])
        buffers_filled += 1
        chunks_filled_array[i] = chunks_filled
        if chunks_filled == 0
            eof_flag = true
            break
        end
    end

    cipher_blocks(buffers, buffers_filled, chunks_filled_array, cipher_stack.block_cipher.expanded_key)

    for i in 1:buffers_filled
        chunk_writer.write_chunks(writer, buffers[i][1:chunks_filled_array[i]], chunks_filled_array[i])
    end

    return eof_flag
end

function cipher(cipher_stack::CipherStack)
    while !process_cipher_blocks(cipher_stack)
    end
end

function decipher_blocks(blocks::Vector{Vector{Vector{UInt8}}}, buffers_filled::Int, chunks_filled::Vector{Int}, inv_expanded_key::AESKey)
    @sync for i in 1:buffers_filled
        @spawn aes_block_cipher.inv_cipher_blocks(blocks[i][1:chunks_filled[i]], inv_expanded_key, chunks_filled[i])
    end
end

function process_decipher_blocks(cipher_stack::CipherStack)::Bool
    buffers_filled = 0
    buffers = cipher_stack.buffers
    buffer_size = cipher_stack.buffer_size
    buffer_amount = cipher_stack.buffer_amount
    reader = cipher_stack.reader_decipher
    writer = cipher_stack.writer_decipher

    chunks_filled_array = Vector{Int}(undef, buffer_amount)
    eof_flag::Bool = false
    for i in 1:buffer_amount
        chunks_filled = chunk_reader.read_chunks(reader, buffer_size, buffers[i])
        buffers_filled += 1
        chunks_filled_array[i] = chunks_filled
        if chunks_filled == 0
            eof_flag = true
            break
        end
    end

    decipher_blocks(buffers, buffers_filled, chunks_filled_array, cipher_stack.block_cipher.inv_expanded_key)

    for i in 1:buffers_filled
        chunk_writer.write_chunks(writer, buffers[i][1:chunks_filled_array[i]], chunks_filled_array[i])
    end

    return eof_flag

end

function decipher(cipher_stack::CipherStack)
    while !process_decipher_blocks(cipher_stack)
    end
end


end