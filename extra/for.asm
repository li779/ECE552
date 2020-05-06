// branch taken
lbi r0, 0
slbi r0, 6

lbi r1, 0
.FOR:
addi r1, r1, 1
seq r2, r0, r1
beqz r2, .FOR
nop
nop
lbi r1, 0
.FOR2:
addi r1, r1, 1
seq r2, r0, r1
bnez r2, .END
j .FOR2
.END:
nop
halt