.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    li t0, 1
    blt a1, t0, throw_exception

    # Prologue
    addi sp, sp, -12 # We are calling the abs function so save a0 and a1 on the stack
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    li s0, 0  #s0 corresponds to the index
    mv s1 a1  #s1 corresponds to the number of elements in the array
    mv s2 a0  #s2 corresponds to the pointer to the array 
loop_start:
    bge s0, s1, loop_end
    lw t0, 0(s2)
    bge t0, zero, skip_update
    sw zero, 0(s2)

skip_update: 
    addi s0, s0, 1
    addi s2, s2, 4
    j loop_start

loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp) # Restore pointer to array and # elements of array to a0 and a1, respectively
    lw s2, 8(sp)
    addi sp, sp, 12 

    jr ra

throw_exception: 
    # Terminate program with error code 36.
    li a7, 93         # system call number for exit on Linux (RISC-V)
    li a0, 36         # error code 36
    ecall   
