# RUN: rm -rf %t && mkdir -p %t
# RUN: llvm-mc -triple=mipsel-unknown-linux-gnu -mcpu=mips1 -filetype=obj %s -o %t/mips1el.o
# RUN: llvm-mc -triple=mips-unknown-linux-gnu -mcpu=mips1 -filetype=obj %s -o %t/mips1be.o
# RUN: llvm-mc -triple=mips64el-unknown-linux-gnuabi64 -mcpu=mips64 -filetype=obj %s -o %t/mips64el.o
# RUN: llvm-mc -triple=mips64-unknown-linux-gnuabi64 -mcpu=mips64 -filetype=obj %s -o %t/mips64be.o
# RUN: llvm-jitlink -noexec -slab-address=0x10000000 -slab-allocate=128Kb -slab-page-size=4096 %t/mips1el.o
# RUN: llvm-jitlink -noexec -slab-address=0x10000000 -slab-allocate=128Kb -slab-page-size=4096 %t/mips1be.o
# RUN: llvm-jitlink -noexec -slab-address=0x10000000 -slab-allocate=128Kb -slab-page-size=4096 %t/mips64el.o
# RUN: llvm-jitlink -noexec -slab-address=0x10000000 -slab-allocate=128Kb -slab-page-size=4096 %t/mips64be.o
# RUN: /bin/sh -c 'for cpu in mips1 mips2 mips32 mips32r2 mips32r3 mips32r5; do llvm-mc -triple=mipsel-unknown-linux-gnu -mcpu=$cpu -filetype=obj %s -o %t/$cpu-o32el.o && llvm-jitlink -noexec -slab-address=0x10000000 -slab-allocate=128Kb -slab-page-size=4096 %t/$cpu-o32el.o || exit 1; done'
# RUN: /bin/sh -c 'for cpu in mips1 mips2 mips32 mips32r2 mips32r3 mips32r5; do llvm-mc -triple=mips-unknown-linux-gnu -mcpu=$cpu -filetype=obj %s -o %t/$cpu-o32be.o && llvm-jitlink -noexec -slab-address=0x10000000 -slab-allocate=128Kb -slab-page-size=4096 %t/$cpu-o32be.o || exit 1; done'
# RUN: /bin/sh -c 'for cpu in mips3 mips4 mips5 mips64 mips64r2 mips64r3 mips64r5; do llvm-mc -triple=mips64el-unknown-linux-gnuabi64 -mcpu=$cpu -filetype=obj %s -o %t/$cpu-n64el.o && llvm-jitlink -noexec -slab-address=0x10000000 -slab-allocate=128Kb -slab-page-size=4096 %t/$cpu-n64el.o || exit 1; done'
# RUN: /bin/sh -c 'for cpu in mips3 mips4 mips5 mips64 mips64r2 mips64r3 mips64r5; do llvm-mc -triple=mips64-unknown-linux-gnuabi64 -mcpu=$cpu -filetype=obj %s -o %t/$cpu-n64be.o && llvm-jitlink -noexec -slab-address=0x10000000 -slab-allocate=128Kb -slab-page-size=4096 %t/$cpu-n64be.o || exit 1; done'

# Standard MIPS ISA revisions share the relocation and stub model implemented
# by this backend. Only compact-mode MIPS16 and microMIPS objects are rejected.

        .set noreorder
        .text
        .globl main
        .type main,@function
main:
        lui $2, %hi(data)
        addiu $2, $2, %lo(data)
        jr $ra
        nop
        .size main, .-main

        .data
data:
        .word 42
