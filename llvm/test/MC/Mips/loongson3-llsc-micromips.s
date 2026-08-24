# RUN: llvm-mc -triple=mipsel -mcpu=mips32r2 \
# RUN:   -mattr=+micromips,+fix-loongson3-llsc -filetype=obj %s -o - \
# RUN:   | llvm-objdump -d --mattr=+micromips - \
# RUN:   | FileCheck %s
# RUN: llvm-mc -triple=mipsel -mcpu=mips32r6 \
# RUN:   -mattr=+micromips,+fix-loongson3-llsc -filetype=obj %s -o - \
# RUN:   | llvm-objdump -d --mattr=+micromips,+mips32r6 - \
# RUN:   | FileCheck %s

  ll $2, 0($3)
  sync
  ll $2, 0($3)
  sc $2, 0($3)

# CHECK:      sync
# CHECK-NEXT: {{.*}}ll $2, 0x0($3)
# CHECK-NEXT: {{.*}}sync
# CHECK-NEXT: {{.*}}ll $2, 0x0($3)
# CHECK-NEXT: {{.*}}sc $2, 0x0($3)
