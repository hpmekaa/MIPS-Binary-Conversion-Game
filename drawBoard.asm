# drawBoard.asm — UI
# Creates ASCII boards for both modes

.globl ui_show_bits_board
.globl ui_show_decimal_board

.data
topLine:    .asciiz "+---+---+---+---+---+---+---+---+\n"
midSep:     .asciiz "+---+---+---+---+---+---+---+---+\n"
pipe:       .asciiz "| "
spacebar:   .asciiz " "
pipeEnd:    .asciiz "|\n"
decLbl:     .asciiz "Decimal: [       ]\n"
binLbl:     .asciiz "Binary:  [ _ _ _ _ _ _ _ _ ]\n"
decShow:    .asciiz "Decimal: "
db_nl:      .asciiz "\n" 

.text

# ui_show_bits_board
# Draws the binary row as ASCII boxes, then newline
ui_show_bits_board:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    
    la   $t3, g_currentBits
    li   $t0, 0

    # Print top border first
    la   $a0, topLine
    li   $v0, 4
    syscall

bits_loop:
    beq  $t0, 8, end_bits_row

    # Print left border
    la   $a0, pipe
    li   $v0, 4
    syscall

    # Print bit value
    addu $t1, $t3, $t0
    lb   $t2, 0($t1)
    li   $v0, 11
    move $a0, $t2
    syscall

    # Print trailing space
    la   $a0, spacebar
    li   $v0, 4
    syscall

    addi $t0, $t0, 1
    j    bits_loop

end_bits_row:
    # Close last box
    la   $a0, pipeEnd
    li   $v0, 4
    syscall

    # Print bottom border
    la   $a0, topLine
    li   $v0, 4
    syscall
    
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# ui_show_decimal_board
# Shows the decimal and 8 blank binary slots
ui_show_decimal_board:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    la   $a0, topLine
    li   $v0, 4
    syscall

    la   $a0, binLbl
    li   $v0, 4
    syscall

    la   $a0, midSep
    li   $v0, 4
    syscall

    la   $a0, decShow
    li   $v0, 4
    syscall

    lw   $a0, g_currentDec
    li   $v0, 1
    syscall

    la   $a0, db_nl 
    li   $v0, 4
    syscall

    la   $a0, topLine
    li   $v0, 4
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra