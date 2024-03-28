module config

function read_config()
    filename::AbstractString = ".env"
    env_dict = Dict{String, String}()
    try
        open(filename) do file
            for line in eachline(file)
                if !isempty(line) && !startswith(line, "#")
                    parts = split(line, "=")
                    key = strip(parts[1])
                    value = strip(parts[2])
                    env_dict[key] = value
                end
            end
        end
    catch err
        println("Error reading $filename file: $err")
    end
    return env_dict
end

end


