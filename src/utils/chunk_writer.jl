module chunk_writer
using Base.Iterators: partition

mutable struct ChunkWriter
    output::IO
    write_function::Function
end
export ChunkWriter

function ChunkWriter(path::String, remove_padding::Bool)::ChunkWriter
    if remove_padding
        return ChunkWriter(open(path, "w"), write_chunk_without_padding)
    end
    return ChunkWriter(open(path, "w"), write)
end

function write_chunks(writer::ChunkWriter, chunks::Vector{Vector{UInt8}},
                    chunks_amount::Int)
    for i in 1:chunks_amount
        write_chunk(writer, chunks[i])
    end
end

function write_chunk(writer::ChunkWriter, chunk::Vector{UInt8})
    bytes_written = writer.write_function(writer.output, chunk)
    while bytes_written < 16
        n = writer.write_function(writer.output, chunk[bytes_written+1:end])
        bytes_written += n
    end
end

function write_chunk_without_padding(output::IO, chunk::Vector{UInt8})::Int
    padding_pos = findfirst(==(0), chunk)
    if padding_pos === nothing
        return write(output, chunk)
    end
    padding_pos -= 1
    n = write(output, chunk[1:padding_pos])
    if padding_pos <= n
        return 16
    end
    return n
end

end
