// branch not taken
lbi r0, 6
slbi r0, 6
.FOR:
addi r0, r0, -1
beqz r0, .END
j .FOR
.END:
nop
nop
halt