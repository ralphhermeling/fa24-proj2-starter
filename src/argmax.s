.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
# keep index of the max element
# keep number of elements in the array
# keep current index
# keep pointer to array
argmax:
    li t0, 1
    blt a1, t0, terminate

    # Prologue
    addi sp, sp, -12
    sw s0, 0(sp) 
    sw s1, 4(sp) 
    sw s2, 8(sp) 

    mv s0, a1      # s0 number of elements in the array
    li s1, 0       # index max value                    
    lw s2 0(a0)    # current max value 

    li t0, 1       # current index
    mv t1, a0
    addi t1, t1, 4 # current pointer to the array

loop_start:
    bge t0, s0, loop_end

    lw t2, 0(t1) # get value at current index
    ble t2, s2, loop_continue # if value of current index <= then continue loop

    mv s2, t2 # update max value
    mv s1, t0 # update max value index

loop_continue:
    addi t0, t0, 1
    addi t1, t1, 4
    j loop_start

loop_end:
    mv a0, s1

    # Epilogue
    lw s0, 0(sp) 
    lw s1, 4(sp) 
    lw s2, 8(sp) 
    addi sp, sp, 12

    jr ra

terminate:
    li a0, 36
    j exit
