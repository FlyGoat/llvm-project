# RUN: llvm-mc -triple=mips -mcpu=mips32r2 -mattr=+micromips -show-encoding %s | FileCheck %s --check-prefixes=ASM,BE,R2-BE
# RUN: llvm-mc -triple=mips -mcpu=mips32r2 -mattr=+micromips -filetype=obj %s | \
# RUN:   llvm-objdump -d --no-show-raw-insn --no-print-imm-hex - | FileCheck %s --check-prefix=ASM
# RUN: llvm-mc -triple=mipsel -mcpu=mips32r2 -mattr=+micromips -show-encoding %s | FileCheck %s --check-prefixes=ASM,LE,R2-LE
# RUN: llvm-mc -triple=mipsel -mcpu=mips32r2 -mattr=+micromips -filetype=obj %s | \
# RUN:   llvm-objdump -d --no-show-raw-insn --no-print-imm-hex - | FileCheck %s --check-prefix=ASM
# RUN: llvm-mc -triple=mips -mcpu=mips32r6 -mattr=+micromips -show-encoding %s | FileCheck %s --check-prefixes=ASM,BE,R6-BE
# RUN: llvm-mc -triple=mips -mcpu=mips32r6 -mattr=+micromips -filetype=obj %s | \
# RUN:   llvm-objdump -d --no-show-raw-insn --no-print-imm-hex - | FileCheck %s --check-prefix=ASM
# RUN: llvm-mc -triple=mipsel -mcpu=mips32r6 -mattr=+micromips -show-encoding %s | FileCheck %s --check-prefixes=ASM,LE,R6-LE
# RUN: llvm-mc -triple=mipsel -mcpu=mips32r6 -mattr=+micromips -filetype=obj %s | \
# RUN:   llvm-objdump -d --no-show-raw-insn --no-print-imm-hex - | FileCheck %s --check-prefix=ASM

# All 19 nonempty register-list encodings, including singleton and FP lists.

lwm32 $16, 8($4)
# ASM: lwm32 $16, 8($4)
# BE-SAME: encoding: [0x20,0x24,0x50,0x08]
# LE-SAME: encoding: [0x24,0x20,0x08,0x50]

swm32 $16, 8($4)
# ASM: swm32 $16, 8($4)
# BE-SAME: encoding: [0x20,0x24,0xd0,0x08]
# LE-SAME: encoding: [0x24,0x20,0x08,0xd0]

lwm32 $16, $17, 8($4)
# ASM: lwm32 $16, $17, 8($4)
# BE-SAME: encoding: [0x20,0x44,0x50,0x08]
# LE-SAME: encoding: [0x44,0x20,0x08,0x50]

swm32 $16, $17, 8($4)
# ASM: swm32 $16, $17, 8($4)
# BE-SAME: encoding: [0x20,0x44,0xd0,0x08]
# LE-SAME: encoding: [0x44,0x20,0x08,0xd0]

lwm32 $16, $17, $18, 8($4)
# ASM: lwm32 $16, $17, $18, 8($4)
# BE-SAME: encoding: [0x20,0x64,0x50,0x08]
# LE-SAME: encoding: [0x64,0x20,0x08,0x50]

swm32 $16, $17, $18, 8($4)
# ASM: swm32 $16, $17, $18, 8($4)
# BE-SAME: encoding: [0x20,0x64,0xd0,0x08]
# LE-SAME: encoding: [0x64,0x20,0x08,0xd0]

lwm32 $16, $17, $18, $19, 8($4)
# ASM: lwm32 $16, $17, $18, $19, 8($4)
# BE-SAME: encoding: [0x20,0x84,0x50,0x08]
# LE-SAME: encoding: [0x84,0x20,0x08,0x50]

swm32 $16, $17, $18, $19, 8($4)
# ASM: swm32 $16, $17, $18, $19, 8($4)
# BE-SAME: encoding: [0x20,0x84,0xd0,0x08]
# LE-SAME: encoding: [0x84,0x20,0x08,0xd0]

lwm32 $16, $17, $18, $19, $20, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $20, 8($4)
# BE-SAME: encoding: [0x20,0xa4,0x50,0x08]
# LE-SAME: encoding: [0xa4,0x20,0x08,0x50]

swm32 $16, $17, $18, $19, $20, 8($4)
# ASM: swm32 $16, $17, $18, $19, $20, 8($4)
# BE-SAME: encoding: [0x20,0xa4,0xd0,0x08]
# LE-SAME: encoding: [0xa4,0x20,0x08,0xd0]

lwm32 $16, $17, $18, $19, $20, $21, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $20, $21, 8($4)
# BE-SAME: encoding: [0x20,0xc4,0x50,0x08]
# LE-SAME: encoding: [0xc4,0x20,0x08,0x50]

swm32 $16, $17, $18, $19, $20, $21, 8($4)
# ASM: swm32 $16, $17, $18, $19, $20, $21, 8($4)
# BE-SAME: encoding: [0x20,0xc4,0xd0,0x08]
# LE-SAME: encoding: [0xc4,0x20,0x08,0xd0]

lwm32 $16, $17, $18, $19, $20, $21, $22, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $20, $21, $22, 8($4)
# BE-SAME: encoding: [0x20,0xe4,0x50,0x08]
# LE-SAME: encoding: [0xe4,0x20,0x08,0x50]

swm32 $16, $17, $18, $19, $20, $21, $22, 8($4)
# ASM: swm32 $16, $17, $18, $19, $20, $21, $22, 8($4)
# BE-SAME: encoding: [0x20,0xe4,0xd0,0x08]
# LE-SAME: encoding: [0xe4,0x20,0x08,0xd0]

lwm32 $16, $17, $18, $19, $20, $21, $22, $23, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $20, $21, $22, $23, 8($4)
# BE-SAME: encoding: [0x21,0x04,0x50,0x08]
# LE-SAME: encoding: [0x04,0x21,0x08,0x50]

swm32 $16, $17, $18, $19, $20, $21, $22, $23, 8($4)
# ASM: swm32 $16, $17, $18, $19, $20, $21, $22, $23, 8($4)
# BE-SAME: encoding: [0x21,0x04,0xd0,0x08]
# LE-SAME: encoding: [0x04,0x21,0x08,0xd0]

lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, 8($4)
# BE-SAME: encoding: [0x21,0x24,0x50,0x08]
# LE-SAME: encoding: [0x24,0x21,0x08,0x50]

swm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, 8($4)
# ASM: swm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, 8($4)
# BE-SAME: encoding: [0x21,0x24,0xd0,0x08]
# LE-SAME: encoding: [0x24,0x21,0x08,0xd0]

lwm32 $ra, 8($4)
# ASM: lwm32 $ra, 8($4)
# BE-SAME: encoding: [0x22,0x04,0x50,0x08]
# LE-SAME: encoding: [0x04,0x22,0x08,0x50]

swm32 $ra, 8($4)
# ASM: swm32 $ra, 8($4)
# BE-SAME: encoding: [0x22,0x04,0xd0,0x08]
# LE-SAME: encoding: [0x04,0x22,0x08,0xd0]

lwm32 $16, $ra, 8($4)
# ASM: lwm32 $16, $ra, 8($4)
# BE-SAME: encoding: [0x22,0x24,0x50,0x08]
# LE-SAME: encoding: [0x24,0x22,0x08,0x50]

swm32 $16, $ra, 8($4)
# ASM: swm32 $16, $ra, 8($4)
# BE-SAME: encoding: [0x22,0x24,0xd0,0x08]
# LE-SAME: encoding: [0x24,0x22,0x08,0xd0]

lwm32 $16, $17, $ra, 8($4)
# ASM: lwm32 $16, $17, $ra, 8($4)
# BE-SAME: encoding: [0x22,0x44,0x50,0x08]
# LE-SAME: encoding: [0x44,0x22,0x08,0x50]

swm32 $16, $17, $ra, 8($4)
# ASM: swm32 $16, $17, $ra, 8($4)
# BE-SAME: encoding: [0x22,0x44,0xd0,0x08]
# LE-SAME: encoding: [0x44,0x22,0x08,0xd0]

lwm32 $16, $17, $18, $ra, 8($4)
# ASM: lwm32 $16, $17, $18, $ra, 8($4)
# BE-SAME: encoding: [0x22,0x64,0x50,0x08]
# LE-SAME: encoding: [0x64,0x22,0x08,0x50]

swm32 $16, $17, $18, $ra, 8($4)
# ASM: swm32 $16, $17, $18, $ra, 8($4)
# BE-SAME: encoding: [0x22,0x64,0xd0,0x08]
# LE-SAME: encoding: [0x64,0x22,0x08,0xd0]

lwm32 $16, $17, $18, $19, $ra, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $ra, 8($4)
# BE-SAME: encoding: [0x22,0x84,0x50,0x08]
# LE-SAME: encoding: [0x84,0x22,0x08,0x50]

swm32 $16, $17, $18, $19, $ra, 8($4)
# ASM: swm32 $16, $17, $18, $19, $ra, 8($4)
# BE-SAME: encoding: [0x22,0x84,0xd0,0x08]
# LE-SAME: encoding: [0x84,0x22,0x08,0xd0]

lwm32 $16, $17, $18, $19, $20, $ra, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $20, $ra, 8($4)
# BE-SAME: encoding: [0x22,0xa4,0x50,0x08]
# LE-SAME: encoding: [0xa4,0x22,0x08,0x50]

swm32 $16, $17, $18, $19, $20, $ra, 8($4)
# ASM: swm32 $16, $17, $18, $19, $20, $ra, 8($4)
# BE-SAME: encoding: [0x22,0xa4,0xd0,0x08]
# LE-SAME: encoding: [0xa4,0x22,0x08,0xd0]

lwm32 $16, $17, $18, $19, $20, $21, $ra, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $20, $21, $ra, 8($4)
# BE-SAME: encoding: [0x22,0xc4,0x50,0x08]
# LE-SAME: encoding: [0xc4,0x22,0x08,0x50]

swm32 $16, $17, $18, $19, $20, $21, $ra, 8($4)
# ASM: swm32 $16, $17, $18, $19, $20, $21, $ra, 8($4)
# BE-SAME: encoding: [0x22,0xc4,0xd0,0x08]
# LE-SAME: encoding: [0xc4,0x22,0x08,0xd0]

lwm32 $16, $17, $18, $19, $20, $21, $22, $ra, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $20, $21, $22, $ra, 8($4)
# BE-SAME: encoding: [0x22,0xe4,0x50,0x08]
# LE-SAME: encoding: [0xe4,0x22,0x08,0x50]

swm32 $16, $17, $18, $19, $20, $21, $22, $ra, 8($4)
# ASM: swm32 $16, $17, $18, $19, $20, $21, $22, $ra, 8($4)
# BE-SAME: encoding: [0x22,0xe4,0xd0,0x08]
# LE-SAME: encoding: [0xe4,0x22,0x08,0xd0]

lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $ra, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $ra, 8($4)
# BE-SAME: encoding: [0x23,0x04,0x50,0x08]
# LE-SAME: encoding: [0x04,0x23,0x08,0x50]

swm32 $16, $17, $18, $19, $20, $21, $22, $23, $ra, 8($4)
# ASM: swm32 $16, $17, $18, $19, $20, $21, $22, $23, $ra, 8($4)
# BE-SAME: encoding: [0x23,0x04,0xd0,0x08]
# LE-SAME: encoding: [0x04,0x23,0x08,0xd0]

lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4)
# ASM: lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4)
# BE-SAME: encoding: [0x23,0x24,0x50,0x08]
# LE-SAME: encoding: [0x24,0x23,0x08,0x50]

swm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4)
# ASM: swm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4)
# BE-SAME: encoding: [0x23,0x24,0xd0,0x08]
# LE-SAME: encoding: [0x24,0x23,0x08,0xd0]

# All four compact lists, including the largest unsigned offset.

lwm16 $16, $ra, 60($sp)
# ASM: lwm16 $16, $ra, 60($sp)
# R2-BE-SAME: encoding: [0x45,0x0f]
# R2-LE-SAME: encoding: [0x0f,0x45]
# R6-BE-SAME: encoding: [0x44,0xf2]
# R6-LE-SAME: encoding: [0xf2,0x44]

swm16 $16, $ra, 60($sp)
# ASM: swm16 $16, $ra, 60($sp)
# R2-BE-SAME: encoding: [0x45,0x4f]
# R2-LE-SAME: encoding: [0x4f,0x45]
# R6-BE-SAME: encoding: [0x44,0xfa]
# R6-LE-SAME: encoding: [0xfa,0x44]

lwm16 $16, $17, $ra, 60($sp)
# ASM: lwm16 $16, $17, $ra, 60($sp)
# R2-BE-SAME: encoding: [0x45,0x1f]
# R2-LE-SAME: encoding: [0x1f,0x45]
# R6-BE-SAME: encoding: [0x45,0xf2]
# R6-LE-SAME: encoding: [0xf2,0x45]

swm16 $16, $17, $ra, 60($sp)
# ASM: swm16 $16, $17, $ra, 60($sp)
# R2-BE-SAME: encoding: [0x45,0x5f]
# R2-LE-SAME: encoding: [0x5f,0x45]
# R6-BE-SAME: encoding: [0x45,0xfa]
# R6-LE-SAME: encoding: [0xfa,0x45]

lwm16 $16, $17, $18, $ra, 60($sp)
# ASM: lwm16 $16, $17, $18, $ra, 60($sp)
# R2-BE-SAME: encoding: [0x45,0x2f]
# R2-LE-SAME: encoding: [0x2f,0x45]
# R6-BE-SAME: encoding: [0x46,0xf2]
# R6-LE-SAME: encoding: [0xf2,0x46]

swm16 $16, $17, $18, $ra, 60($sp)
# ASM: swm16 $16, $17, $18, $ra, 60($sp)
# R2-BE-SAME: encoding: [0x45,0x6f]
# R2-LE-SAME: encoding: [0x6f,0x45]
# R6-BE-SAME: encoding: [0x46,0xfa]
# R6-LE-SAME: encoding: [0xfa,0x46]

lwm16 $16, $17, $18, $19, $ra, 60($sp)
# ASM: lwm16 $16, $17, $18, $19, $ra, 60($sp)
# R2-BE-SAME: encoding: [0x45,0x3f]
# R2-LE-SAME: encoding: [0x3f,0x45]
# R6-BE-SAME: encoding: [0x47,0xf2]
# R6-LE-SAME: encoding: [0xf2,0x47]

swm16 $16, $17, $18, $19, $ra, 60($sp)
# ASM: swm16 $16, $17, $18, $19, $ra, 60($sp)
# R2-BE-SAME: encoding: [0x45,0x7f]
# R2-LE-SAME: encoding: [0x7f,0x45]
# R6-BE-SAME: encoding: [0x47,0xfa]
# R6-LE-SAME: encoding: [0xfa,0x47]

# Macro selection must check the tuple, base, offset range, and alignment.

lwm $ra, 0($sp)
# ASM: lwm32 $ra, 0($sp)
# BE-SAME: encoding: [0x22,0x1d,0x50,0x00]
# LE-SAME: encoding: [0x1d,0x22,0x00,0x50]

lwm $16, $ra, 0($sp)
# ASM: lwm16 $16, $ra, 0($sp)
# R2-BE-SAME: encoding: [0x45,0x00]
# R2-LE-SAME: encoding: [0x00,0x45]
# R6-BE-SAME: encoding: [0x44,0x02]
# R6-LE-SAME: encoding: [0x02,0x44]

lwm $16-$19, $ra, 60($sp)
# ASM: lwm16 $16, $17, $18, $19, $ra, 60($sp)
# R2-BE-SAME: encoding: [0x45,0x3f]
# R2-LE-SAME: encoding: [0x3f,0x45]
# R6-BE-SAME: encoding: [0x47,0xf2]
# R6-LE-SAME: encoding: [0xf2,0x47]

lwm $16-$20, $ra, 0($sp)
# ASM: lwm32 $16, $17, $18, $19, $20, $ra, 0($sp)
# BE-SAME: encoding: [0x22,0xbd,0x50,0x00]
# LE-SAME: encoding: [0xbd,0x22,0x00,0x50]

lwm $16, $ra, 3($sp)
# ASM: lwm32 $16, $ra, 3($sp)
# BE-SAME: encoding: [0x22,0x3d,0x50,0x03]
# LE-SAME: encoding: [0x3d,0x22,0x03,0x50]

lwm $16, $ra, 64($sp)
# ASM: lwm32 $16, $ra, 64($sp)
# BE-SAME: encoding: [0x22,0x3d,0x50,0x40]
# LE-SAME: encoding: [0x3d,0x22,0x40,0x50]

lwm $16, $ra, -4($sp)
# ASM: lwm32 $16, $ra, -4($sp)
# BE-SAME: encoding: [0x22,0x3d,0x5f,0xfc]
# LE-SAME: encoding: [0x3d,0x22,0xfc,0x5f]

swm $ra, 0($sp)
# ASM: swm32 $ra, 0($sp)
# BE-SAME: encoding: [0x22,0x1d,0xd0,0x00]
# LE-SAME: encoding: [0x1d,0x22,0x00,0xd0]

swm $16, $ra, 0($sp)
# ASM: swm16 $16, $ra, 0($sp)
# R2-BE-SAME: encoding: [0x45,0x40]
# R2-LE-SAME: encoding: [0x40,0x45]
# R6-BE-SAME: encoding: [0x44,0x0a]
# R6-LE-SAME: encoding: [0x0a,0x44]

swm $16-$19, $ra, 60($sp)
# ASM: swm16 $16, $17, $18, $19, $ra, 60($sp)
# R2-BE-SAME: encoding: [0x45,0x7f]
# R2-LE-SAME: encoding: [0x7f,0x45]
# R6-BE-SAME: encoding: [0x47,0xfa]
# R6-LE-SAME: encoding: [0xfa,0x47]

swm $16-$20, $ra, 0($sp)
# ASM: swm32 $16, $17, $18, $19, $20, $ra, 0($sp)
# BE-SAME: encoding: [0x22,0xbd,0xd0,0x00]
# LE-SAME: encoding: [0xbd,0x22,0x00,0xd0]

swm $16, $ra, 3($sp)
# ASM: swm32 $16, $ra, 3($sp)
# BE-SAME: encoding: [0x22,0x3d,0xd0,0x03]
# LE-SAME: encoding: [0x3d,0x22,0x03,0xd0]

swm $16, $ra, 64($sp)
# ASM: swm32 $16, $ra, 64($sp)
# BE-SAME: encoding: [0x22,0x3d,0xd0,0x40]
# LE-SAME: encoding: [0x3d,0x22,0x40,0xd0]

swm $16, $ra, -4($sp)
# ASM: swm32 $16, $ra, -4($sp)
# BE-SAME: encoding: [0x22,0x3d,0xdf,0xfc]
# LE-SAME: encoding: [0x3d,0x22,0xfc,0xdf]
