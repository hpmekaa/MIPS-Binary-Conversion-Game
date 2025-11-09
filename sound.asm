# sound.asm

.globl snd_success
.globl snd_fail

.text
snd_success:
    li   $a0, 76    # pitch
    li   $a1, 180       # ms
    li   $a2, 0     # piano
    li   $a3, 100
    li   $v0, 31
    syscall
    jr   $ra

snd_fail:
    li   $a0, 52
    li   $a1, 220
    li   $a2, 24    # guitar
    li   $a3, 110
    li   $v0, 31
    syscall
    jr   $ra
