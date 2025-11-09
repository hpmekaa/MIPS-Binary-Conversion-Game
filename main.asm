# main.asm: Binary Game
# Manages mode selection and 10-level progression
# Includes a 10-second bonus timer

.globl main
.globl g_mode
.globl g_level
.globl g_linesLeft
.globl g_correct
.globl g_currentBits           # 8 bytes
.globl g_currentDec           # word 0 to 255
.globl g_userBitsStr      
.globl g_userDec           
.globl g_inputBuf           
.globl g_score                  

.data
menuStr:        .asciiz "\n=== Binary Game (MIPS) ===\n1) Binary -> Decimal\n2) Decimal -> Binary\nSelect mode (1/2): "
modeErr:        .asciiz "Invalid selection. Try again.\n"
levelStr:       .asciiz "\n--- Level "
newline:        .asciiz "\n"
lineHead:       .asciiz "  Line "
promptDec:      .asciiz "Enter decimal: "
promptBin:      .asciiz "Enter 8-bit binary (e.g., 10101100): "
goodStr:        .asciiz "✅ Correct!\n"
badStr:         .asciiz "❌ Wrong.\n"
finalStr:       .asciiz "\nGame complete. Score: "
byeStr:         .asciiz "\nGoodbye.\n"
bonusStr:       .asciiz "FAST! +5 bonus!\n" 

g_mode:         .word 0
g_level:        .word 1
g_linesLeft:    .word 10
g_correct:      .word 0
g_currentBits:  .space 9
g_currentDec:   .word 0
g_userBitsStr:  .space 16
g_userDec:      .word 0
g_inputBuf:     .space 32
g_score:        .word 0

.text
main:
# Mode selection loop
mode_loop:
    la   $a0, menuStr
    li   $v0, 4
    syscall

    li   $v0, 5          
    syscall
    move $t0, $v0          

    li   $t1, 1
    beq  $t0, $t1, mode_ok
    li   $t1, 2
    beq  $t0, $t1, mode_ok

    la   $a0, modeErr
    li   $v0, 4
    syscall
    j    mode_loop

mode_ok:
    sw   $t0, g_mode
    li   $t0, 1
    sw   $t0, g_level
    li   $t0, 0
    sw   $t0, g_score

# Level loop: 1 to 10
level_start:
    lw   $t0, g_level
    li   $t1, 11
    beq  $t0, $t1, game_over   # finished level 10

    # Print level header
    la   $a0, levelStr
    li   $v0, 4
    syscall
    lw   $a0, g_level
    li   $v0, 1
    syscall
    la   $a0, newline
    li   $v0, 4
    syscall

    # linesLeft = level
    lw   $t2, g_level
    sw   $t2, g_linesLeft

line_loop:
    lw   $t3, g_linesLeft
    beq  $t3, $zero, next_level

    # Print "  Line k"
    la   $a0, lineHead
    li   $v0, 4
    syscall
    lw   $a0, g_linesLeft
    li   $v0, 1
    syscall
    la   $a0, newline
    li   $v0, 4
    syscall

    # Generate new problem
    jal  gen_problem

    # Draw board & prompt input depending on mode
    lw   $t0, g_mode
    li   $t1, 1
    beq  $t0, $t1, play_b2d
    j    play_d2b

play_b2d:
    # Shows bits, asks for decimal & sets g_userDec
    jal  draw_binary_to_decimal 
    
    # Validate
    jal  validate_b2d

    # Feedback & score
    lw   $t4, g_correct
    beq  $t4, $zero, fb_wrong
fb_right:
    la   $a0, goodStr
    li   $v0, 4
    syscall
    jal  snd_success
    
    # +10 base score
    lw   $t5, g_score
    addi $t5, $t5, 10
    
    # Check for Bonus
    sub  $t0, $s1, $s0     # $t0 = elapsed time
    li   $t1, 10000         # 10000ms = 10 seconds
    bgt  $t0, $t1, b2d_no_bonus # If elapsed > 10000, skip bonus
    
    # If we're here, time was <= 10000
    la   $a0, bonusStr
    li   $v0, 4
    syscall
    addi $t5, $t5, 5      # Add 5 bonus points
    
b2d_no_bonus:
    sw   $t5, g_score      # Save new score
    j    after_fb

fb_wrong:
    la   $a0, badStr
    li   $v0, 4
    syscall
    jal  snd_fail
after_fb:
    j    consume_line

play_d2b:
    # Shows decimal, asks for 8-bit string & sets g_userBitsStr
    jal  draw_decimal_to_binary
    
    # Validate
    jal  validate_d2b

    # Feedback & score
    lw   $t4, g_correct
    beq  $t4, $zero, fb_wrong2
fb_right2:
    la   $a0, goodStr
    li   $v0, 4
    syscall
    jal  snd_success

    # +10 base score
    lw   $t5, g_score
    addi $t5, $t5, 10
    
    # Check for Bonus
    sub  $t0, $s1, $s0     # $t0 = elapsed time
    li   $t1, 10000         # 10000ms = 10 seconds
    bgt  $t0, $t1, d2b_no_bonus # If elapsed > 10000, skip bonus
    
    # If we are here, time was <= 10000
    la   $a0, bonusStr
    li   $v0, 4
    syscall
    addi $t5, $t5, 5      # Add 5 bonus points

d2b_no_bonus:
    sw   $t5, g_score      # Save new score
    j    after_fb2
    
fb_wrong2:
    la   $a0, badStr
    li   $v0, 4
    syscall
    jal  snd_fail
after_fb2:

consume_line:
    # linesLeft
    lw   $t3, g_linesLeft
    addi $t3, $t3, -1
    sw   $t3, g_linesLeft
    j    line_loop

next_level:
    # level++
    lw   $t0, g_level
    addi $t0, $t0, 1
    sw   $t0, g_level
    j    level_start

game_over:
    la   $a0, finalStr
    li   $v0, 4
    syscall
    lw   $a0, g_score
    li   $v0, 1
    syscall
    la   $a0, byeStr
    li   $v0, 4
    syscall

    li   $v0, 10
    syscall

gen_problem:
    # Save $ra
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    
    lw   $t0, g_mode
    li   $t1, 1
    beq  $t0, $t1, gp_b2d
    j    gp_d2b
gp_b2d:
    jal  gen_bits_random       
    la   $a0, g_currentBits
    jal  bits_to_decimal       
    sw   $v0, g_currentDec
    j    gp_done     # Jump to exit
gp_d2b:
    jal  gen_decimal_random   
    sw   $v0, g_currentDec
    # Fall through to exit
    
gp_done:
    # Restore $ra
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# draw_binary_to_decimal: board & read decimal into g_userDec
draw_binary_to_decimal:
    # Save $ra
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    
    # TIMER: Get Start Time 
    jal  timer_now_ms  # $v0 now has the time
    move $s0, $v0      # Save start time to $s0

    # Show board using UI module
    jal  ui_show_bits_board

    # Prompt user
    la   $a0, promptDec
    li   $v0, 4
    syscall

    la   $a0, g_inputBuf
    li   $a1, 16
    li   $v0, 8
    syscall
    
    # TIMER: Get End Time
    jal  timer_now_ms # $v0 now has the time
    move $s1, $v0      # Save end time to $s1

    la   $a0, g_inputBuf
    jal  str_to_int
    sw   $v0, g_userDec
    
    # Restore $ra
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# draw_decimal_to_binary: board & read 8-char string into g_userBitsStr
draw_decimal_to_binary:
    # Save $ra
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    
    # TIMER: Get Start Time
    jal  timer_now_ms  # $v0 now has the time
    move $s0, $v0      # Save start time to $s0
    
    # Show board using UI module
    jal  ui_show_decimal_board

prompt_dbin:
    la   $a0, promptBin
    li   $v0, 4
    syscall

    la   $a0, g_userBitsStr
    li   $a1, 16
    li   $v0, 8
    syscall
    
    # TIMER: Get End Time
    jal  timer_now_ms # $v0 now has the time
    move $s1, $v0      # Save end time to $s1

    # Validate input
    la   $a0, g_userBitsStr
    jal  is_valid_bin8
    beq  $v0, $zero, prompt_dbin   # bad input, retry

    # Restore $ra
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra