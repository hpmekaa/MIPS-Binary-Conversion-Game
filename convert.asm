.globl bits_to_decimal
.globl binstr_to_decimal
.globl decimal_to_binstr

.text

# bits_to_decimal
bits_to_decimal:
    move $t0, $a0     # ptr
    li   $t1, 0       # result = 0
    li   $t2, 0       # i = 0
b2d_loop:
    beq  $t2, 8, b2d_done

    sll  $t1, $t1, 1     

    lb   $t3, 0($t0)     
    li   $t4, '1'
    beq  $t3, $t4, add_one_b2d
    j    skip_add_b2d
add_one_b2d:
    addi $t1, $t1, 1
skip_add_b2d:
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j    b2d_loop
b2d_done:
    move $v0, $t1
    jr   $ra


# binstr_to_decimal
binstr_to_decimal:
    move $t0, $a0     # ptr
    li   $t1, 0       # sum
    li   $t2, 0
bsd_loop:
    beq  $t2, 8, bsd_done
    lb   $t3, 0($t0)
    beq  $t3, $zero, bsd_done
    sll  $t1, $t1, 1
    li   $t4, '1'
    beq  $t3, $t4, add_one_bsd
    # treat non-'1' as 0
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j    bsd_loop
add_one_bsd:
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j    bsd_loop
bsd_done:
    move $v0, $t1
    jr   $ra


# decimal_to_binstr
decimal_to_binstr:
    move $t0, $a0     # value
    move $t1, $a1     # out
    # produce bits MSB..LSB
    li   $t2, 7
dtb_loop:
    bltz $t2, dtb_end
    # compute (value >> t2) & 1
    move $t3, $t0
    move $t4, $t2
shift_loop:
    beq  $t4, $zero, shifted
    srl  $t3, $t3, 1
    addi $t4, $t4, -1
    j    shift_loop
shifted:
    andi $t3, $t3, 1
    beq  $t3, $zero, put_zero
    li   $t5, '1'
    sb   $t5, 0($t1)
    j    adv
put_zero:
    li   $t5, '0'
    sb   $t5, 0($t1)
adv:
    addi $t1, $t1, 1
    addi $t2, $t2, -1
    j    dtb_loop
dtb_end:
    sb   $zero, 0($t1) 
    jr   $ra

# str_to_int: converts an ASCII decimal string to integer
    .globl str_to_int
str_to_int:
    li   $t0, 0      # accumulator
si_loop:
    lb   $t1, 0($a0)
    beq  $t1, $zero, si_done
    blt  $t1, '0', si_done
    bgt  $t1, '9', si_done
    mul  $t0, $t0, 10
    addi $t1, $t1, -48
    add  $t0, $t0, $t1
    addi $a0, $a0, 1
    j    si_loop
si_done:
    move $v0, $t0
    jr   $ra
