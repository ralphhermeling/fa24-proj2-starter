.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    li t0, 1
    blt a2, t0, terminate_code_36
    blt a3, t0, terminate_code_37 
    blt a4, t0, terminate_code_37 

    # Prologue
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    mv s0, a3 # s0 corresponds to the stride of arr0
    mv s1, a4 # s1 corresponds to the stride of arr1
    mv s2, a2 # s2 corresponds to the number of elements to use

    mv t0, a0   # t0 corresponds to the pointer arr0
    mv t1, a1   # t1 corresponds to the pointer arr1
    mv t2, zero # t2 corresponds to the current number of elements in the dot product 
    mv t3, zero # t3 corresponds to the dot product

loop_start:
    bge t2, s2, loop_end

    lw t4, 0(t0)
    lw t5, 0(t1)

    ecall

    mul t6, t5, t4  # dot product 

    add t3, t3, t6 # increment dot product

    # stride determines by how much you need to increment the index
    # increment address by stride -> address = address + 4 * stride
    slli t4, s0, 2
    add t0, t0, t4

    slli t5, s1, 2
    add t1, t1, t5

    # increment number of elements in the dot product
    addi t2, t2, 1

    j loop_start

loop_end:
    mv a0, t3

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 12

    jr ra

terminate_code_36:
    li a0, 36
    j exit

terminate_code_37:
    li a0, 37
    j exit
