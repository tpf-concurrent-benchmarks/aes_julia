include("constants.jl")
using .constants

include("aes_key/aes_key.jl")
using .aes_key

print(S_BOX, "\n")
print(INV_S_BOX, "\n")
print(R_CON, "\n")
word::Word = 0x12345678
for pos::UInt in 0:3
    println("Byte at position ", pos, ": ", aes_key.get_byte_from_word(word, pos))
end
print("hello world!\n")