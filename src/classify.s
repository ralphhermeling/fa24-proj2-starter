.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    li t0 5
    bne a0 t0 incorrect_argc_error

    # Prologue
    addi sp, sp, -52
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw s7 28(sp)
    sw s8 32(sp)
    sw s9 36(sp)
    sw s10 40(sp)
    sw s11 44(sp)
    sw ra 48(sp)

    mv s0 a2 # Set silent mode 

    # Set filepaths
    lw a2 4(a1)  #pointer to the filepath string of m0           
    lw a3 8(a1)  #pointer to the filepath string of m1
    lw a4 12(a1) #pointer to the filepath string of input matrix
    lw a5 16(a1) #pointer to the filepath string of output file

    addi sp, sp, -16
    sw a2 0(sp)
    sw a3 4(sp)
    sw a4 8(sp)
    sw a5 12(sp)

    # Read pretrained m0
    lw a0 0(sp)  # Set filepath to filepath string of m0 

    addi sp, sp, -8
    mv a1 sp       # Pointer to heap space for number of rows
    addi a2, sp, 4 # Pointer to heap space for number of columns 

    jal read_matrix # Read pretrained m0

    mv s1 a0     # s1 corresponds to the pointer of matrix m0
    lw s2 0(sp)  # s2 corresponds to the number of rows matrix m0 has
    lw s3 4(sp)  # s3 corresponds to the number of columns matrix m0 has

    addi sp, sp, 8 # Restore heap space used for rows and cols

    # Read pretrained m1
    lw a0 4(sp) # Set filepath to filepath string of m1

    addi sp, sp, -8
    mv a1 sp
    addi a2 sp 4

    jal read_matrix # Read pretrained m1

    mv s4 a0    # s4 corresponds to the pointer of matrix m1
    lw s5 0(sp) # s5 corresponds to the number of rows matrix m1 has
    lw s6 4(sp) # s6 corresponds to the number of columns matrix m1 has

    addi sp, sp, 8

    # Read input matrix
    lw a0 8(sp)

    addi sp, sp, -8
    mv a1 sp
    addi a2 sp 4 

    jal read_matrix # Read input matrix

    mv s7 a0    # s7 corresponds to the pointer of matrix input
    lw s8 0(sp) # s8 corresponds to the number of rows matrix input has
    lw s9 4(sp) # s9 corresponds to the number of columns matrix input has

    addi sp, sp, 8

    # Compute h = matmul(m0, input)
    mul t0 s2 s9 # Compute dimension h := n x k k x m, rows m0 x columns input
    slli t0 t0 2
    mv a0 t0     # Number of bytes to allocate

    jal malloc
    beqz a0, malloc_error
    mv s10 a0    # s10 corresponds to the pointer to the start of h

    mv a0 s1     # set pointer to the start of m0
    mv a1 s2     # set # of rows of m0
    mv a2 s3     # set # of columns of m0

    mv a3 s7     # set pointer to the start of input
    mv a4 s8     # set # of rows of input 
    mv a5 s9     # set # of columns of input 

    mv a6 s10    # set pointer to the start of h

    jal matmul

    # Compute h = relu(h)
    mv a0 s10
    mul a1 s2 s9 # number of elements in h := rows of m0 x cols of input

    jal relu

    # Compute o = matmul(m1, h)
    mul a0 s5 s9
    slli a0 a0 2

    jal malloc
    beqz a0 malloc_error
    mv s11 a0   # s11 points to the start of o

    mv a0 s4
    mv a1 s5
    mv a2 s6

    mv a3 s10
    mv a4 s2
    mv a5 s9
    mv a6 s11

    jal matmul

    # Write output matrix o
    lw a0 12(sp)
    mv a1 s11
    mv a2 s5 
    mv a3 s9 
    
    jal write_matrix

    addi sp, sp, 16 # restore stack 

    # Compute and return argmax(o)
    mv a0 s11
    mul a1 s5 s9
    jal argmax

    mv t0 a0     # move index largest element to t0

    addi sp, sp, -4
    sw t0 0(sp)
    mv a0 t0

    # If enabled, print argmax(o) and newline
    li t2 1
    beq s0 t2 cleanup 

    jal print_int
    li a0 '\n'
    jal print_char

cleanup:
    mv a0 s10 # free h 
    jal free

    mv a0 s11 # free o
    jal free

    mv a0 s1  # free m0
    jal free
    
    mv a0 s4  # free m1
    jal free

    mv a0 s7  # free input
    jal free

finish: 
    lw a0 0(sp)
    addi sp, sp, 4

    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)
    lw s7 28(sp)
    lw s8 32(sp)
    lw s9 36(sp)
    lw s10 40(sp)
    lw s11 44(sp)
    lw ra 48(sp)
    addi sp, sp, 52 

    jr ra

incorrect_argc_error:
    li a0 31
    j exit

malloc_error: 
    li a0 26
    j exit
