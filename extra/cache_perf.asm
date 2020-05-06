// branch taken
lbi r0, 0x03
slbi r0, 0x50
lbi r1, 0x13
slbi r1, 0x50
lbi r2, 0x23
slbi r2, 0x50

st r0, r0, 0
st r0, r1, 0
st r0, r0, 0
st r0, r2, 0
st r0, r0, 0
st r0, r0, 0
st r0, r1, 0
st r0, r0, 0

nop
halt
