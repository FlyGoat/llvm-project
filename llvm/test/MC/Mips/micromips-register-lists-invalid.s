# RUN: not llvm-mc -triple=mips -mcpu=mips32r2 -mattr=+micromips %s 2>&1 | FileCheck %s
# RUN: not llvm-mc -triple=mips -mcpu=mips32r6 -mattr=+micromips %s 2>&1 | FileCheck %s

# FP is only encodable after the complete S0-S7 prefix.
lwm32 $16, $fp, 0($4)       # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
swm32 $16, $fp, $ra, 0($4)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction

# RA cannot be repeated or followed by another register.
lwm32 $16, $ra, $ra, 0($4)  # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
swm32 $ra, $fp, 0($4)       # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction

# The 16-bit forms require RA and at least one saved register.
lwm16 $ra, 0($sp)          # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
swm16 $16-$20, $ra, 0($sp) # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction

lwm32 $f16, 0($4)          # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid register operand

# Invalid ranges and separators must not silently shorten the register list.
lwm32 $16-$19-$18, 0($4)   # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid register operand
swm32 $16-$16, 0($4)       # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid register operand
lwm32 $16-, 0($4)          # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid register operand
swm32 $16 0($4)            # CHECK: :[[@LINE]]:{{[0-9]+}}: error: expected comma
lwm32 $16-$23, $fp, $fp, 0($4) # CHECK: :[[@LINE]]:{{[0-9]+}}: error: invalid operand for instruction
