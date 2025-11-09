# validateInput.asm

# validate_b2d(): compares g_userDec vs correct decimal of g_currentBits
# validate_d2b(): checks g_userBitsStr is valid 8-bit string and equals decimal to bin
# sets g_correct = 1/0

.globl validate_b2d
.globl validate_d2b
.globl is_valid_bin8

.data
valErr: .asciiz "Invalid input format.\n"
corrStr:.asciiz "Correct answer was: "
nl:     .asciiz "\n"

.text
validate_b2d:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    # compute correct from bits
    la   $a0, g_currentBits
    jal  bits_to_decimal
    move $t0, $v0           
    lw   $t1, g_userDec
    li   $t2, 0
    bne  $t0, $t1, not_eq
    li   $t2, 1
not_eq:
    sw   $t2, g_correct

    beq  $t2, $zero, show_corr_dec
    j    v_b2d_done     # Jump to exit
show_corr_dec:
    la   $a0, corrStr
    li   $v0, 4
    syscall
    move $a0, $t0
    li   $v0, 1
    syscall
    la   $a0, nl
    li   $v0, 4
    syscall
    # Fall through to exit
v_b2d_done:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

is_valid_bin8:
    move $t0, $a0
    li   $t1, 0
iv_loop:
    beq  $t1, 8, iv_done8
    lb   $t2, 0($t0)
    beq  $t2, $zero, iv_fail
    li   $t3, '0'
    li   $t4, '1'
    beq  $t2, $t3, ok_char
    beq  $t2, $t4, ok_char
    j    iv_fail
ok_char:
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j    iv_loop
iv_done8:
    # 9th may be '\n' or '\0'
    li   $v0, 1
    jr   $ra
iv_fail:
    li   $v0, 0
    jr   $ra

validate_d2b:
    addi $sp, $sp, -20
    sw   $ra, 16($sp) # Save $ra at the top
    
    # format check
    la   $a0, g_userBitsStr
    jal  is_valid_bin8
    beq  $v0, $zero, vd_badfmt

    # compute decimal from user string
    la   $a0, g_userBitsStr
    jal  binstr_to_decimal
    move $t0, $v0           

    # compare to g_currentDec
    lw   $t1, g_currentDec
    li   $t2, 0
    bne  $t0, $t1, d2b_not_eq
    li   $t2, 1
d2b_not_eq:
    sw   $t2, g_correct

    beq  $t2, $zero, show_corr_bin
    j    v_d2b_done     # Jump to exit

vd_badfmt:
    la   $a0, valErr
    li   $v0, 4
    syscall
    li   $t2, 0
    sw   $t2, g_correct
    j    v_d2b_done     # Jump to exit

show_corr_bin:
    move $t9, $sp   
    lw   $a0, g_currentDec
    move $a1, $t9
    jal  decimal_to_binstr

    la   $a0, corrStr
    li   $v0, 4
    syscall
    move $a0, $t9
    li   $v0, 4
    syscall
    la   $a0, nl
    li   $v0, 4
    syscall
    # Fall through to exit

v_d2b_done:
    lw   $ra, 16($sp) # Restore $ra from the top
    addi $sp, $sp, 20
    jr   $ra