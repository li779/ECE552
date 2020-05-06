// branch taken
lbi r0, 6
slbi r0, 6


.FOR:
addi r0, r0, -1
bnez r0, .FOR
nop
nop
halt
