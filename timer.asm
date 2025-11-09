# timer.asm
# Provides current system time in milliseconds

.globl timer_now_ms

.text
timer_now_ms:
    li   $v0, 30    # system time (ms)
    syscall       
    move $v0, $a0  
    jr   $ra
