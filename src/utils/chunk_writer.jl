module chunk_writer
using Base.Iterators: partition

mutable struct ChunkWriter
    output::IO
    write_function::Function
end

function ChunkWriter(path::String, remove_padding::Bool)
    if remove_padding
        return ChunkWriter(open(path, "w"), write_chunk_without_padding)
    end
    return ChunkWriter(open(path, "w"), write)
end

function write_chunks(writer::ChunkWriter, chunks::Vector{Vector{UInt8}})
    for i in 1:length(chunks)
        write_chunk(writer, chunks[i])
    end
end

function write_chunk(writer::ChunkWriter, chunk::Vector{UInt8})
    bytes_written = 0
    while bytes_written < length(chunk)
        n = writer.write_function(writer.output, chunk[bytes_written+1:end])
        bytes_written += n
    end
end

function write_chunk_without_padding(output::IO, chunk::Vector{UInt8})
    println("writing chunk without padding")
    padding_pos = findfirst(==(0), chunk)
    if padding_pos === nothing
        padding_pos = length(chunk)
    else
        padding_pos -= 1
    end
    n = write(output, chunk[1:padding_pos])
    println("padding_pos: ", padding_pos)
    println("n: ", n)
    if padding_pos <= n
        return length(chunk)
    end
    return write(output, chunk[1:padding_pos])
end

end
