## Test invalid LA32R instructions.

# RUN: not llvm-mc --triple=loongarch32 --mattr +la32r %s 2>&1 | FileCheck %s

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
alsl.w $tp, $t5, $tp, 4

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
pcaddi $a5, 187

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
pcalau12i $a6, 89

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
andn $s5, $s2, $a1

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
rotr.w $ra, $s3, $t6

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
rotri.w $s0, $t8, 23

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
orn $tp, $sp, $s2

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
ext.w.h $s0, $s0

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
ext.w.b $t8, $t6

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
ext.w.h $s0, $s0

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
clo.w $ra, $sp

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
clz.w $a3, $a6

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
cto.w $tp, $a2

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
ctz.w $a1, $fp

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
bytepick.w $s6, $zero, $t4, 0

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
revb.2h $t8, $a7

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
bitrev.4b $r21, $s4

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
bitrev.w $s2, $a1

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
bstrins.w $a4, $a7, 7, 2

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
bstrpick.w $ra, $a5, 10, 4

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
maskeqz $t8, $a7, $t6

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
masknez $t8, $t1, $s3

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
beqz $a5, 96

# CHECK: :[[#@LINE+1]]:1: error: instruction requires the following: LA32 Standard Basic Integer and Privilege Instruction Set
bnez $sp, 212
