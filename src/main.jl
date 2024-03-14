include("constants.jl")
using .constants

include("aes_key/aes_key.jl")
using .aes_key

using Pkg
Pkg.add("StaticArrays")
using StaticArrays

print(S_BOX, "\n")
print(INV_S_BOX, "\n")
print(R_CON, "\n")
word::Word = 0x12345678
for pos::UInt in 0:3
    println("Byte at position ", pos, ": ", aes_key.get_byte_from_word(word, pos))
end
my_tuple::NTuple{16, UInt8} = (0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c)
cipher_key = aes_key.CipherKey(my_tuple)
key = aes_key.new_direct(cipher_key)
print(key, "\n")
print("hello world!\n")