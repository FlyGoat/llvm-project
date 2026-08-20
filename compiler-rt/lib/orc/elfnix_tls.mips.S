//===-- orc_rt_elfnix_tls.mips.S --------------------------------*- ASM -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file is a part of the ORC runtime support library.
//
//===----------------------------------------------------------------------===//

#if defined(__mips__)

#if _MIPS_SIM == _ABI64
#define PTR_ADDU daddu
#define PTR_ADDIU daddiu
#define PTR_L ld
#else
#define PTR_ADDU addu
#define PTR_ADDIU addiu
#define PTR_L lw
#endif

        .text
        .set noreorder

        // Returns the TLS address in $2, passing the thread pointer in $5.
        .globl ___orc_rt_elfnix_tls_get_addr
___orc_rt_elfnix_tls_get_addr:
#if _MIPS_SIM == _ABIO32
        lui $2, %hi(_gp_disp)
        PTR_ADDIU $2, $2, %lo(_gp_disp)
        PTR_ADDIU $sp, $sp, -24
        sw $ra, 20($sp)
        addu $gp, $2, $25
#else
        PTR_ADDIU $sp, $sp, -16
        sd $gp, 0($sp)
        sd $ra, 8($sp)
        lui $gp, %hi(%neg(%gp_rel(___orc_rt_elfnix_tls_get_addr)))
        PTR_ADDU $gp, $gp, $25
        PTR_ADDIU $gp, $gp, %lo(%neg(%gp_rel(___orc_rt_elfnix_tls_get_addr)))
#endif

        .set push
#if !defined(__mips_isa_rev) || __mips_isa_rev < 2
        // Linux trap-and-emulates rdhwr on pre-r2 CPUs, so it is always valid.
        .set mips32r2
#endif
        rdhwr $5, $29
        .set pop

        PTR_L $25, %call16(__orc_rt_elfnix_tls_get_addr_impl)($gp)
        jalr $25
        nop

#if _MIPS_SIM == _ABIO32
        PTR_L $ra, 20($sp)
        PTR_ADDIU $sp, $sp, 24
#else
        ld $gp, 0($sp)
        ld $ra, 8($sp)
        PTR_ADDIU $sp, $sp, 16
#endif
        jr $ra
        nop

#endif // defined(__mips__)
