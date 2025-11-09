# score.asm

.globl score_add

.text
score_add:
    # a0 = points
    lw   $t0, g_score
    addu $t0, $t0, $a0
    sw   $t0, g_score
    jr   $ra
