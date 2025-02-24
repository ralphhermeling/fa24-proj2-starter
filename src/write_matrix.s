.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)

    mv s0 a2 # number of rows in the matrix
    mv s1 a3 # number of columns in the matrix
    mv s3 a1 # pointer to start of the matrix in memory

    li a1 1  # set write permissions

    jal fopen

    bltz a0 error_fopen

    mv s2 a0 # set file descriptor

    # write rows and columns
    addi sp, sp, -8

    sw s0 0(sp) # set number of rows in buffer
    sw s1 4(sp) # set number of rows in buffer

    mv a0 s2
    mv a1 sp
    li a2 2
    li a3 4

    addi sp, sp, -4
    sw ra 0(sp)

    jal fwrite # write rows and cols

    lw ra 0(sp)
    addi sp, sp, 4

    bltz a0, error_fwrite

    addi sp, sp, 8

write_matrix_values:
    mv a0 s2
    mv a1 s3
    mul t0 s0 s1
    mv a2 t0
    li a3 4

    addi sp, sp, -4
    sw ra 0(sp)

    jal fwrite # write matrix values

    lw ra 0(sp)
    addi sp, sp, 4

    bltz a0, error_fwrite

write_matrix_finish: 
    mv a0 s2    # File descriptor

    addi sp, sp, -4
    sw ra 0(sp)

    jal fclose

    lw ra 0(sp)
    addi sp, sp, 4

    bltz a0, error_fclose
    
finish:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20

    jr ra

error_fopen: 
    li a0 27
    j exit

error_fclose: 
    li a0 28
    j exit

error_fwrite: 
    li a0 30 
    j exit
