# Define the State type
struct State
    data::Matrix{Int}
end

function my_circshift!(A::AbstractVector, n::Integer)
    n = mod(n, 4)
    if n == 0
        return A
    end
    B = similar(A)
    for i in 1:4
        j = i + n
        if j > 4
            j -= 4
        end
        B[j] = A[i]
    end
    copy!(A, B)
    return A
end

function my_circshift_1!(A::Any)
    temp_2::UInt8 = A[2]
    temp_4::UInt8 = A[4]
    A[2] = A[3]
    A[4] = A[1]
    A[3] = temp_4
    A[1] = temp_2
end

function my_circshift_2!(A::Any)
    temp_1::UInt8 = A[1]
    temp_2::UInt8 = A[2]
    A[1] = A[3]
    A[2] = A[4]
    A[3] = temp_1
    A[4] = temp_2
end

function my_circshift_3!(A::Any)
    temp_2::UInt8 = A[2]
    temp_4::UInt8 = A[4]
    A[2] = A[1]
    A[4] = A[3]
    A[1] = temp_4
    A[3] = temp_2
end

# Define the function shift_rows
function shift_rows_cool(_state::State)
    col = @view _state.data[2, :]
    my_circshift_1!(col)
    col = @view _state.data[3, :]
    my_circshift_2!(col)
    col = @view _state.data[4, :]
    my_circshift_3!(col)
end

# Define the function shift_rows
function shift_rows(_state::State)
    for i in 2:4
        col = @view _state.data[i, :] 
        circshift!(col, i-1)
    end
end

function inv_shift_rows_cool(_state::State)
    col = @view _state.data[2, :]
    my_circshift_3!(col)
    col = @view _state.data[3, :]
    my_circshift_2!(col)
    col = @view _state.data[4, :]
    my_circshift_1!(col)
end

function inv_shift_rows(_state::State)
    for i in 2:4
        col = @view _state.data[i, :] #this access way is slow, TODO try to find a faster way accessing it [:, i]
        circshift!(col, -i+1)
    end
end

# Function to create a State object with index values
function create_index_matrix()
    data = [1 2 3 4;
            5 6 7 8;
            9 10 11 12;
            13 14 15 16]
    return State(data)
end

# Function to print the matrix
function print_matrix(state::State)
    println("Matrix: ")
    for i in 1:4
        for j in 1:4
            print(state.data[i, j])
            print(" ")
        end
        print("\n")
    end
end

# Test the shift_rows function
state = create_index_matrix()
println("Original Matrix: \n")
print_matrix(state)
@time inv_shift_rows(state)
println("\nMatrix after shifting rows:")
print_matrix(state)

# Test the shift_rows function
state = create_index_matrix()
println("Original Matrix: \n")
print_matrix(state)
@time inv_shift_rows_cool(state)
println("\nMatrix after shifting rows:")
print_matrix(state)