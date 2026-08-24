# RUN: llvm-mc -triple=mips64el -mcpu=mips64r6 \
# RUN:   -mattr=+fix-loongson3-llsc -filetype=obj %s -o - \
# RUN:   | llvm-objdump -d --mattr=+mips64r6 - \
# RUN:   | FileCheck %s --check-prefix=FIX
# RUN: llvm-mc -triple=mips64el -mcpu=mips64r6 \
# RUN:   -mattr=-fix-loongson3-llsc -filetype=obj %s -o - \
# RUN:   | llvm-objdump -d --mattr=+mips64r6 - \
# RUN:   | FileCheck %s --check-prefix=NOFIX

  ll $2, 0($3)
  sync
  ll $2, 0($3)
  addiu $2, $2, 1
  lld $2, 0($3)
  sc $2, 0($3)
  sync

  .globl labeled_ll
labeled_ll:
  ll $2, 0($3)

  .section .text.sync,"ax",@progbits
  sync
  .section .text.ll,"ax",@progbits
  ll $2, 0($3)

# FIX:      sync
# FIX-NEXT: {{.*}}ll $2, 0x0($3)
# FIX-NEXT: {{.*}}sync
# FIX-NEXT: {{.*}}ll $2, 0x0($3)
# FIX-NEXT: {{.*}}addiu $2, $2, 0x1
# FIX-NEXT: {{.*}}sync
# FIX-NEXT: {{.*}}lld $2, 0x0($3)
# FIX-NEXT: {{.*}}sc $2, 0x0($3)
# FIX-NEXT: {{.*}}sync
# FIX:      <labeled_ll>:
# FIX-NEXT: {{.*}}sync
# FIX-NEXT: {{.*}}ll $2, 0x0($3)
# FIX:      Disassembly of section .text.sync:
# FIX:      sync
# FIX:      Disassembly of section .text.ll:
# FIX:      sync
# FIX-NEXT: {{.*}}ll $2, 0x0($3)

# NOFIX:      ll $2, 0x0($3)
# NOFIX-NEXT: {{.*}}sync
# NOFIX-NEXT: {{.*}}ll $2, 0x0($3)
# NOFIX-NEXT: {{.*}}addiu $2, $2, 0x1
# NOFIX-NEXT: {{.*}}lld $2, 0x0($3)
# NOFIX-NEXT: {{.*}}sc $2, 0x0($3)
# NOFIX-NEXT: {{.*}}sync
# NOFIX:      <labeled_ll>:
# NOFIX-NEXT: {{.*}}ll $2, 0x0($3)
# NOFIX:      Disassembly of section .text.sync:
# NOFIX:      sync
# NOFIX:      Disassembly of section .text.ll:
# NOFIX-NOT:  sync
# NOFIX:      ll $2, 0x0($3)
