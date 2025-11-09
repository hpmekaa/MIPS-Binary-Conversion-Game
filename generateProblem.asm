# generateProblem.asm
# Randomly fills either g_currentBits[8] or returns 0 to 255

.globl gen_bits_random
.globl gen_decimal_random

.text

# gen_bits_random(): fills 8 bytes with 0/1
gen_bits_random:
    addi $sp, $sp, -8
    sw   $a0, 0($sp)
    sw   $ra, 4($sp)

    li   $t0, 0
    la   $t2, g_currentBits

gb_loop:
    beq  $t0, 8, gb_done

    li   $v0, 30
    syscall
    move $a1, $a0     
    li   $v0, 42
    syscall        

    andi $t1, $a0, 1    # 0 or 1
    addi $t1, $t1, 48   # ASCII
    sb   $t1, 0($t2)

    addi $t2, $t2, 1
    addi $t0, $t0, 1
    j    gb_loop

gb_done:
    sb   $zero, 0($t2)
    lw   $a0, 0($sp)
    lw   $ra, 4($sp)
    addi $sp, $sp, 8
    jr   $ra


# gen_decimal_random(): v0 = random 0 to 255
gen_decimal_random:
    li   $v0, 30
    syscall
    move $a1, $a0    
    li   $v0, 42
    syscall
    andi $v0, $a0, 0xFF
    jr   $ra


