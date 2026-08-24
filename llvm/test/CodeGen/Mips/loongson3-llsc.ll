; RUN: llc -mtriple=mips64el -mcpu=mips64r6 \
; RUN:   -mattr=+fix-loongson3-llsc -filetype=obj < %s \
; RUN:   | llvm-objdump -d --mattr=+mips64r6 - \
; RUN:   | FileCheck %s --check-prefix=FIX
; RUN: llc -mtriple=mips64el -mcpu=mips64r6 \
; RUN:   -mattr=-fix-loongson3-llsc -filetype=obj < %s \
; RUN:   | llvm-objdump -d --mattr=+mips64r6 - \
; RUN:   | FileCheck %s --check-prefix=NOFIX
; RUN: llc -mtriple=mipsel -mcpu=mips32r2 \
; RUN:   -mattr=+micromips,+fix-loongson3-llsc -filetype=obj < %s \
; RUN:   | llvm-objdump -d --mattr=+micromips - \
; RUN:   | FileCheck %s --check-prefix=MICROMIPS
; RUN: llc -mtriple=mipsel -mcpu=mips32r6 \
; RUN:   -mattr=+micromips,+fix-loongson3-llsc -filetype=obj < %s \
; RUN:   | llvm-objdump -d --mattr=+micromips,+mips32r6 - \
; RUN:   | FileCheck %s --check-prefix=MICROMIPS

@word = global i32 0, align 4
@dword = global i64 0, align 8

define i32 @atomic32(i32 %value) {
; FIX-LABEL: <atomic32>:
; FIX:       sync
; FIX-NEXT:  {{.*}}ll
; NOFIX-LABEL: <atomic32>:
; NOFIX-NOT: sync
; NOFIX:     ll
; MICROMIPS-LABEL: <atomic32>:
; MICROMIPS:     sync
; MICROMIPS-NEXT: {{.*}}ll
  %old = atomicrmw add ptr @word, i32 %value monotonic
  ret i32 %old
}

define i64 @atomic64(i64 %value) {
; FIX-LABEL: <atomic64>:
; FIX:       sync
; FIX-NEXT:  {{.*}}lld
; NOFIX-LABEL: <atomic64>:
; NOFIX-NOT: sync
; NOFIX:     lld
  %old = atomicrmw add ptr @dword, i64 %value monotonic
  ret i64 %old
}
