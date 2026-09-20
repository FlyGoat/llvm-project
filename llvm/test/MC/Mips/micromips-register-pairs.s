# RUN: llvm-mc -triple=mips -mcpu=mips32r2 -mattr=+micromips -show-encoding %s | FileCheck %s --check-prefixes=ASM,R2-BE,BE
# RUN: llvm-mc -triple=mips -mcpu=mips32r2 -mattr=+micromips -filetype=obj %s | llvm-objdump -d --no-show-raw-insn --no-print-imm-hex - | FileCheck %s --check-prefix=ASM
# RUN: llvm-mc -triple=mipsel -mcpu=mips32r2 -mattr=+micromips -show-encoding %s | FileCheck %s --check-prefixes=ASM,R2-LE,LE
# RUN: llvm-mc -triple=mipsel -mcpu=mips32r2 -mattr=+micromips -filetype=obj %s | llvm-objdump -d --no-show-raw-insn --no-print-imm-hex - | FileCheck %s --check-prefix=ASM
# RUN: llvm-mc -triple=mips -mcpu=mips32r6 -mattr=+micromips -show-encoding %s | FileCheck %s --check-prefixes=ASM,R6-BE,BE
# RUN: llvm-mc -triple=mips -mcpu=mips32r6 -mattr=+micromips -filetype=obj %s | llvm-objdump -d --no-show-raw-insn --no-print-imm-hex - | FileCheck %s --check-prefix=ASM
# RUN: llvm-mc -triple=mipsel -mcpu=mips32r6 -mattr=+micromips -show-encoding %s | FileCheck %s --check-prefixes=ASM,R6-LE,LE
# RUN: llvm-mc -triple=mipsel -mcpu=mips32r6 -mattr=+micromips -filetype=obj %s | llvm-objdump -d --no-show-raw-insn --no-print-imm-hex - | FileCheck %s --check-prefix=ASM

.set noat

# Exercise all eight destination encodings and all eight source registers.

movep $5, $6, $zero, $20
# ASM: movep $5, $6, $zero, $20
# R2-BE-SAME: encoding: [0x84,0x70]
# R2-LE-SAME: encoding: [0x70,0x84]
# R6-BE-SAME: encoding: [0x44,0x74]
# R6-LE-SAME: encoding: [0x74,0x44]

movep $5, $7, $17, $19
# ASM: movep $5, $7, $17, $19
# R2-BE-SAME: encoding: [0x84,0xe2]
# R2-LE-SAME: encoding: [0xe2,0x84]
# R6-BE-SAME: encoding: [0x44,0xe5]
# R6-LE-SAME: encoding: [0xe5,0x44]

movep $6, $7, $2, $18
# ASM: movep $6, $7, $2, $18
# R2-BE-SAME: encoding: [0x85,0x54]
# R2-LE-SAME: encoding: [0x54,0x85]
# R6-BE-SAME: encoding: [0x45,0x56]
# R6-LE-SAME: encoding: [0x56,0x45]

movep $4, $21, $3, $16
# ASM: movep $4, $21, $3, $16
# R2-BE-SAME: encoding: [0x85,0xc6]
# R2-LE-SAME: encoding: [0xc6,0x85]
# R6-BE-SAME: encoding: [0x45,0xc7]
# R6-LE-SAME: encoding: [0xc7,0x45]

movep $4, $22, $16, $3
# ASM: movep $4, $22, $16, $3
# R2-BE-SAME: encoding: [0x86,0x38]
# R2-LE-SAME: encoding: [0x38,0x86]
# R6-BE-SAME: encoding: [0x46,0x3c]
# R6-LE-SAME: encoding: [0x3c,0x46]

movep $4, $5, $18, $2
# ASM: movep $4, $5, $18, $2
# R2-BE-SAME: encoding: [0x86,0xaa]
# R2-LE-SAME: encoding: [0xaa,0x86]
# R6-BE-SAME: encoding: [0x46,0xad]
# R6-LE-SAME: encoding: [0xad,0x46]

movep $4, $6, $19, $17
# ASM: movep $4, $6, $19, $17
# R2-BE-SAME: encoding: [0x87,0x1c]
# R2-LE-SAME: encoding: [0x1c,0x87]
# R6-BE-SAME: encoding: [0x47,0x1e]
# R6-LE-SAME: encoding: [0x1e,0x47]

movep $4, $7, $20, $zero
# ASM: movep $4, $7, $20, $zero
# R2-BE-SAME: encoding: [0x87,0x8e]
# R2-LE-SAME: encoding: [0x8e,0x87]
# R6-BE-SAME: encoding: [0x47,0x8f]
# R6-LE-SAME: encoding: [0x8f,0x47]

# Include pairs crossing gaps in LLVM register IDs and the last legal pair.

lwp $zero, 8($4)
# ASM: lwp $zero, 8($4)
# BE-SAME: encoding: [0x20,0x04,0x10,0x08]
# LE-SAME: encoding: [0x04,0x20,0x08,0x10]

swp $zero, 8($4)
# ASM: swp $zero, 8($4)
# BE-SAME: encoding: [0x20,0x04,0x90,0x08]
# LE-SAME: encoding: [0x04,0x20,0x08,0x90]

lwp $1, 8($4)
# ASM: lwp $1, 8($4)
# BE-SAME: encoding: [0x20,0x24,0x10,0x08]
# LE-SAME: encoding: [0x24,0x20,0x08,0x10]

swp $1, 8($4)
# ASM: swp $1, 8($4)
# BE-SAME: encoding: [0x20,0x24,0x90,0x08]
# LE-SAME: encoding: [0x24,0x20,0x08,0x90]

lwp $3, 8($4)
# ASM: lwp $3, 8($4)
# BE-SAME: encoding: [0x20,0x64,0x10,0x08]
# LE-SAME: encoding: [0x64,0x20,0x08,0x10]

swp $3, 8($4)
# ASM: swp $3, 8($4)
# BE-SAME: encoding: [0x20,0x64,0x90,0x08]
# LE-SAME: encoding: [0x64,0x20,0x08,0x90]

lwp $15, 8($4)
# ASM: lwp $15, 8($4)
# BE-SAME: encoding: [0x21,0xe4,0x10,0x08]
# LE-SAME: encoding: [0xe4,0x21,0x08,0x10]

swp $15, 8($4)
# ASM: swp $15, 8($4)
# BE-SAME: encoding: [0x21,0xe4,0x90,0x08]
# LE-SAME: encoding: [0xe4,0x21,0x08,0x90]

lwp $gp, 8($4)
# ASM: lwp $gp, 8($4)
# BE-SAME: encoding: [0x23,0x84,0x10,0x08]
# LE-SAME: encoding: [0x84,0x23,0x08,0x10]

swp $gp, 8($4)
# ASM: swp $gp, 8($4)
# BE-SAME: encoding: [0x23,0x84,0x90,0x08]
# LE-SAME: encoding: [0x84,0x23,0x08,0x90]

lwp $sp, 8($4)
# ASM: lwp $sp, 8($4)
# BE-SAME: encoding: [0x23,0xa4,0x10,0x08]
# LE-SAME: encoding: [0xa4,0x23,0x08,0x10]

swp $sp, 8($4)
# ASM: swp $sp, 8($4)
# BE-SAME: encoding: [0x23,0xa4,0x90,0x08]
# LE-SAME: encoding: [0xa4,0x23,0x08,0x90]

lwp $fp, 8($4)
# ASM: lwp $fp, 8($4)
# BE-SAME: encoding: [0x23,0xc4,0x10,0x08]
# LE-SAME: encoding: [0xc4,0x23,0x08,0x10]

swp $fp, 8($4)
# ASM: swp $fp, 8($4)
# BE-SAME: encoding: [0x23,0xc4,0x90,0x08]
# LE-SAME: encoding: [0xc4,0x23,0x08,0x90]
