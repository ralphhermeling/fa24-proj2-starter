.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # Prologue
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw ra, 24(sp)

    mv s0, a1 # s0 := pointer to an integer that corresponds to the number of rows 
    mv s1, a2 # s1 := pointer to an integer that corresponds to the number of columns 
    mv s2, a0 # s2 := file_descriptor 

    # Open file with read permissions
    mv a0 s2
    li a1 0
    jal fopen

    bltz a0 error_fopen # exit if fopen failed

    mv s2 a0            # Store file descriptor in s2

read_matrix_dimensions:
    addi sp, sp, -8

    # read rows and columns from file_descriptor (first 8 bytes)
    mv a0 s2   # set file_descriptor
    mv a1 sp   # Buffer to store rows & cols
    li a2 8    # Read exactly 8 bytes

    jal ra, fread
    beqz a0 error_fread # exit if fread failed

    lw t0 0(sp)  # corresponds to the number of rows
    lw t1 4(sp)  # corresponds to the number of columns
    mul s5 t0 t1 # # of elements in the matrix
    slli s5 s5 2    # # of bytes matrix has

    addi sp, sp, 8

    sw t0, 0(s0) # set integer that corresponds to the number of rows  
    sw t1, 0(s1) # set integer that corresponds to the number of columns  

allocate_matrix:
    mul t0 t0 t1 # corresponds to the number of values in the matrix
    slli t0 t0 2    # corresponds to the number of bytes the matrix requires 

    mv a0 t0
    jal malloc
    beqz a0 error_malloc # exit if malloc failed

    mv s3 a0     # s3 corresponds to pointer to start matrix now

read_matrix_start: 
    mv s4, s3    # s4 = Current write position in matrix

read_matrix_loop:
    sub t0, s4, s3 # t0 = bytes read so far
    sub t0, s5, t0 # t0 = remaining bytes to read
    beqz t0, read_matrix_finished

    li t1, 16      # Max read size
    bge t0, t1, use_full_read
    mv t1, t0

use_full_read:
    mv a0, s2    # File descriptor
    mv a1, s4    # Buffer to write into
    mv a2, t1    # Read size = min(remianing bytes, 16)
    jal fread

    # Make room on stack to store # bytes read by fread
    addi sp, sp -4
    sw a0 0(sp)

    bltz a0, error_fread  #  If fread fails exit
    beqz a0, check_ferror #  If fread returns 0, check for error

    # Restore # bytes read by fread from stack
    lw t0, 0(sp)
    addi sp, sp, 4

    add s4, s4, t0

    j read_matrix_loop

check_ferror: 
    mv a0, s2
    jal ferror
    bnez a0, error_fread

read_matrix_finished:
    mv a0 s2    # File descriptor
    jal fclose
    bltz a0, error_fclose

finish:
    mv a0 s3

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)
    addi sp, sp,28 

    jr ra

error_malloc:
    li a0 26
    j exit

error_fopen: 
    li a0 27
    j exit

error_fclose: 
    li a0 28
    j exit

error_fread: 
    li a0 29
    j exit
