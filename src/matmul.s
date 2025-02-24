.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Error checks
    li t0, 1
    blt a1, t0, height_or_width_less_than_one
    blt a2, t0, height_or_width_less_than_one
    blt a4, t0, height_or_width_less_than_one
    blt a5, t0, height_or_width_less_than_one

    bne a2, a4, dimensions_dont_match

    # Prologue
    addi sp, sp, -16

    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)

    mv s0, a2      #s0 corresponds to the number of columns of m0
    mul s1, a1, a2 #s1 corresponds to the number of elements in m0 := a1 * a2
    mv s2, a3      #s2 corresponds to the pointer to the start of d
    mv s3, a5      #s3 corresponds to the number of columns of m1

    mv t0, zero    #t0 corresponds to the index of the outer loop
    mv t1, zero    #t1 corresponds ot the index of the inner loop
    mv t2, a0      #t2 corresponds to a pointer to an element of array m0
    mv t3, a3      #t3 corresponds to a pointer to an element of array m1
    mv t4, a6      #t4 corresponds to a pointer to an element of d 

outer_loop_start:
    bge t0, s1, outer_loop_end

inner_loop_start:
    bge t1, s3, inner_loop_end

    # Prologue
    addi sp, sp, -24
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw t4, 16(sp)
    sw ra, 20(sp)

    # call dot function with a0 = t2, a1 = t3, a2 = s0, a3 = 1, a4 = s0 
    mv a0 t2
    mv a1 t3
    mv a2 s0
    li a3 1
    mv a4 s3

    jal ra, dot

    # Epilogue
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    lw t4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24

    sw a0 0(t4)

    addi t1, t1, 1 # increment the index of the inner loop by 1
    addi t3, t3, 4 # increment the pointer to array m1 by 4 such that it points to the next element

    addi t4, t4, 4 # increment the pointer to array d by 4 such that it points to the next element

    j inner_loop_start

inner_loop_end:
    mv t3, s2      # set address of pointer to m1 to the start of m1

    mv t1, zero    # reset the index of the inner loop to 0

    add t0, t0, s0 # increment the index of the outer loop by the number of columns in m0
    slli t5, s0, 2 # the number of bytes to increment the address with := 4 * number of columns of m0
    add t2, t2, t5 # increment the pointer to array d by 4 * number of columns of m0 such that it points to the next correct element 

    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)

    addi sp, sp, 16

    jr ra

height_or_width_less_than_one:
    li a0, 38
    j exit

dimensions_dont_match:
    li a0, 38
    j exit
