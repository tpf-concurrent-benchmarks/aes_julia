module chunk_reader
using Base.Iterators: partition

mutable struct ChunkReader
    input::IO
    chunk_size::Int
    with_padding::Bool
end

function ChunkReader(path::String, chunk_size::Int, with_padding::Bool)
    return ChunkReader(open(path), chunk_size, with_padding)
end

function read_chunks(reader::ChunkReader, chunks_amount::Int, buffer::Vector{Vector{UInt8}})
    chunks_filled = 1
    while chunks_filled <= chunks_amount
        chunk = buffer[chunks_filled]
        bytes_read = fill_chunk(reader, chunk)
        if bytes_read == 0
            return chunks_filled
        end
        chunks_filled += 1
        if bytes_read < reader.chunk_size
            return chunks_filled
        end
    end
    return chunks_filled
end

function fill_chunk(reader::ChunkReader, buffer::Vector{UInt8})
    bytes_read = 0
    while bytes_read < reader.chunk_size
        slice = @view buffer[(bytes_read+1):16]
        n = readbytes!(reader.input, slice, 16 - bytes_read)
        println(n)
        println(buffer)
        if n == 0
            if reader.with_padding
                apply_null_padding(reader.chunk_size - bytes_read, buffer)
            end
            return bytes_read
        end
        bytes_read += n
    end
    return bytes_read
end

function apply_null_padding(size::Int, buffer::Vector{UInt8})
    for i in size+1:length(buffer)
        buffer[i] = 0
    end
end

end