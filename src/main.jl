include("constants.jl")
using .constants

include("aes_key/aes_key.jl")
using .aes_key

include("state.jl")
using .state

include("aes_block_cipher.jl")
using .aes_block_cipher

my_tuple::NTuple{16, UInt8} = (0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c)
cipher_key = aes_key.CipherKey(my_tuple)
block_cipher = aes_block_cipher.new(cipher_key)
data_in = [0x32, 0x43, 0xf6, 0xa8, 0x88, 0x5a, 0x30, 0x8d, 0x31, 0x31, 0x98, 0xa2, 0xe0, 0x37, 0x07, 0x34]
data_out = aes_block_cipher.inv_cipher_block(block_cipher.inv_expanded_key, data_in)
print(data_out)
print("\n")
# print(block_cipher.expanded_key)
# for i in 1:(4*11)
#     print(block_cipher.expanded_key[i], " ")
#     if i % 4 == 0
#         print("\n")
#     end
# end
# print("\n")
# print("\n")
# for i in 1:(4*11)
#     print(block_cipher.inv_expanded_key[i], " ")
#     if i % 4 == 0
#         print("\n")
#     end
# end
# word::Word = 0x12345678

# my_tuple::NTuple{16, UInt8} = (0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c)
# cipher_key = aes_key.CipherKey(my_tuple)
# key = aes_key.new_inverse(cipher_key)
# #print key with \n every 4 elements
# # print(key)
# for i in 1:(4*11)
#     print(key[i], " ")
#     if i % 4 == 0
#         print("\n")
#     end
# end

# my_array::Vector{UInt8} = [0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c]
# print(state.new_from_data_in(my_array))


# my_array::Vector{Word} = [123456789, 987654321, 11112222, 33334444]
# st = state.new_from_words(my_array)
# print(st)
# print("\n")
# print(state.set_data_out(st))
# print("\n")
# # print(state.inv_sub_bytes(state.sub_bytes(st)))
# # print("\n")
# print(state.sub_bytes(st))
# print("\n")
# print(st)
# print("\n")
# print(state.inv_shift_rows(st))
# print("\n")

# round_key = [0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c]
# print(state.add_round_key(st, round_key))
# print("\n")

# print(st)
# print("\n")

# print(state.galois_double(Int8(-72)))
# print("\n")

# column::Vector{UInt8} = [0x2b, 0x28, 0xab, 0x09]
# state.mix_column(column)
# print(column)
# print("\n")