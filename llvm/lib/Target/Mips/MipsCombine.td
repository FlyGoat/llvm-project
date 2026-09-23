//=- MipsCombine.td - Define Mips Combine Rules --------------*- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

include "llvm/Target/GlobalISel/Combine.td"

def MipsPostLegalizerCombiner: GICombiner<
  "MipsPostLegalizerCombinerImpl",
  [commute_int_constant_to_rhs,
   constant_fold_binop, constant_fold_unary_int_op,
   right_identity_zero, right_identity_one_int, binop_same_val, same_val_zero,
   binop_left_to_zero, binop_right_to_zero, add_sub_reg,
   select_same_val, select_constant_cmp,
   mul_to_shl, sub_to_add, shift_immed_chain,
   icmp_to_true_false_known_bits, icmp_to_lhs_known_bits,
   load_and_mask,
   overlapping_and, redundant_and, redundant_or, binop_left_undef_to_zero,
   ptr_add_immed_chain]> {
}
