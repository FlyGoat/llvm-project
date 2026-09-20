//===-- MipsLoadStoreOptimizer.cpp - Load/store combining
//------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Form microMIPS load/store pairs and register lists after register allocation
// and frame index elimination. Match adjacent accesses in either instruction
// order, without moving memory operations across other instructions.
//
//===----------------------------------------------------------------------===//

#include "Mips.h"
#include "MipsInstrInfo.h"
#include "MipsSubtarget.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
#include <iterator>

using namespace llvm;

#define DEBUG_TYPE "mips-load-store-opt"

STATISTIC(NumPairs, "Number of load/store pairs formed");
STATISTIC(NumLists, "Number of load/store register lists formed");

namespace {

class MipsLoadStoreOptimizer : public MachineFunctionPass {
  const MipsSubtarget *ST = nullptr;
  const MipsInstrInfo *TII = nullptr;
  const MipsRegisterInfo *TRI = nullptr;

  bool isCandidate(const MachineInstr &MI) const;
  bool findOpcode(ArrayRef<MachineInstr *> Sorted, unsigned &Opcode,
                  MCRegister &Tuple) const;
  void merge(ArrayRef<MachineInstr *> Instrs, unsigned Opcode, MCRegister Tuple,
             int64_t Offset) const;
  bool optimizeBlock(MachineBasicBlock &MBB) const;

public:
  static char ID;

  MipsLoadStoreOptimizer() : MachineFunctionPass(ID) {}

  StringRef getPassName() const override { return "Mips load/store optimizer"; }

  MachineFunctionProperties getRequiredProperties() const override {
    return MachineFunctionProperties().setNoVRegs();
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
};

} // end anonymous namespace

char MipsLoadStoreOptimizer::ID = 0;

INITIALIZE_PASS(MipsLoadStoreOptimizer, DEBUG_TYPE, "Mips load/store optimizer",
                false, false)

bool MipsLoadStoreOptimizer::isCandidate(const MachineInstr &MI) const {
  switch (MI.getOpcode()) {
  default:
    return false;
  case Mips::LW:
  case Mips::LW_MM:
  case Mips::LW_MMR6:
  case Mips::LW16_MM:
  case Mips::LWSP_MM:
  case Mips::SW:
  case Mips::SW_MM:
  case Mips::SW16_MM:
  case Mips::SWSP_MM:
  case Mips::SW16_MMR6:
  case Mips::SWSP_MMR6:
    break;
  }

  // Do not lose implicit operands or disturb bundles. Frame indices and
  // symbolic addresses must have been lowered before matching a common base.
  if (MI.isBundled() || MI.getNumOperands() != 3 || !MI.getOperand(0).isReg() ||
      !MI.getOperand(1).isReg() || !MI.getOperand(2).isImm() ||
      MI.getOperand(0).getSubReg() || MI.getOperand(1).getSubReg() ||
      MI.getOperand(1).isUndef())
    return false;
  Register Reg = MI.getOperand(0).getReg();
  Register Base = MI.getOperand(1).getReg();
  if (!Mips::GPR32RegClass.contains(Reg) || !Mips::GPR32RegClass.contains(Base))
    return false;
  if (MI.mayLoad() && TRI->regsOverlap(Reg, Base))
    return false;

  // Require known, aligned word accesses. Combining volatile or atomic
  // accesses changes their semantics.
  if (!MI.hasOneMemOperand())
    return false;
  const MachineMemOperand &MMO = **MI.memoperands_begin();
  return !MMO.isVolatile() && !MMO.isAtomic() && MMO.getSize() == 4 &&
         MMO.getAlign() >= Align(4);
}

bool MipsLoadStoreOptimizer::findOpcode(ArrayRef<MachineInstr *> Sorted,
                                        unsigned &Opcode,
                                        MCRegister &Tuple) const {
  int64_t Offset = Sorted.front()->getOperand(2).getImm();
  if (!isInt<12>(Offset))
    return false;
  for (unsigned I = 1; I < Sorted.size(); ++I)
    if (Sorted[I]->getOperand(2).getImm() != Offset + 4 * I)
      return false;

  bool IsLoad = Sorted.front()->mayLoad();
  bool HasRA = Sorted.back()->getOperand(0).getReg() == Mips::RA;
  unsigned Count = Sorted.size() - HasRA;
  bool IsList = Count <= 9;
  for (unsigned I = 0; IsList && I < Count; ++I)
    IsList = TRI->getEncodingValue(Sorted[I]->getOperand(0).getReg()) ==
             (I < 8 ? 16 + I : 30);

  if (IsList) {
    Tuple = MIPS_MC::getRegisterList(Count | (HasRA ? 16 : 0), *TRI);
    if (Mips::GPRMMRegList16RegClass.contains(Tuple) &&
        Sorted.front()->getOperand(1).getReg() == Mips::SP &&
        isShiftedUInt<4, 2>(Offset)) {
      Opcode = ST->hasMips32r6()
                   ? (IsLoad ? Mips::LWM16_MMR6 : Mips::SWM16_MMR6)
                   : (IsLoad ? Mips::LWM16_MM : Mips::SWM16_MM);
      return true;
    }
  }

  // Retain LWP/SWP for two consecutive registers when a compact list cannot
  // be used. These instructions are not available on microMIPS32R6.
  if (Sorted.size() == 2 && !ST->hasMips32r6()) {
    MCRegister First = Sorted[0]->getOperand(0).getReg();
    MCRegister Second = Sorted[1]->getOperand(0).getReg();
    if (First != Mips::ZERO && Second != Mips::RA) {
      MCRegister Pair = MIPS_MC::getRegisterPair(First, Second, *TRI,
                                                 Mips::GPR32PairRegClassID);
      if (Pair) {
        Tuple = Pair;
        Opcode = IsLoad ? Mips::LWP_MM : Mips::SWP_MM;
        return true;
      }
    }
  }
  if (!IsList)
    return false;
  Opcode = IsLoad ? Mips::LWM32_MM : Mips::SWM32_MM;
  return true;
}

void MipsLoadStoreOptimizer::merge(ArrayRef<MachineInstr *> Instrs,
                                   unsigned Opcode, MCRegister Tuple,
                                   int64_t Offset) const {
  MachineInstr &Last = *Instrs.back();
  bool IsLoad = Last.mayLoad();
  bool AllDead = llvm::all_of(Instrs, [](const MachineInstr *MI) {
    return MI->getOperand(0).isDead();
  });
  bool AllKill = llvm::all_of(Instrs, [](const MachineInstr *MI) {
    return MI->getOperand(0).isKill();
  });
  bool AnyUndef = llvm::any_of(Instrs, [](const MachineInstr *MI) {
    return MI->getOperand(0).isUndef();
  });
  RegState Flags = IsLoad
                       ? RegState::Define | getDeadRegState(AllDead)
                       : getKillRegState(AllKill) | getUndefRegState(AnyUndef);
  auto MIB = BuildMI(*Last.getParent(), Last, Instrs.front()->getDebugLoc(),
                     TII->get(Opcode))
                 .addReg(Tuple, Flags)
                 .add(Last.getOperand(1))
                 .addImm(Offset)
                 .setMIFlags(Last.getFlags());

  // An undef tuple use must still keep each defined member live.
  if (!IsLoad && AnyUndef) {
    for (const MachineInstr *MI : Instrs) {
      MachineOperand Reg = MI->getOperand(0);
      if (!Reg.isUndef()) {
        Reg.setImplicit();
        MIB.add(Reg);
      }
    }
  }
  SmallVector<const MachineInstr *, 10> MemInstrs(Instrs.begin(), Instrs.end());
  MIB.cloneMergedMemRefs(MemInstrs);
  LLVM_DEBUG(dbgs() << "Formed " << *MIB);
  if (Opcode == Mips::LWP_MM || Opcode == Mips::SWP_MM)
    ++NumPairs;
  else
    ++NumLists;
  for (MachineInstr *MI : Instrs)
    MI->eraseFromParent();
}

bool MipsLoadStoreOptimizer::optimizeBlock(MachineBasicBlock &MBB) const {
  bool Changed = false;
  for (auto I = MBB.begin(); I != MBB.end();) {
    MachineInstr &First = *I;
    if (!isCandidate(First)) {
      ++I;
      continue;
    }

    // A list has at most ten registers. Keep program order here for liveness
    // and insertion, and sort a copy by offset when testing each candidate.
    SmallVector<MachineInstr *, 10> Instrs;
    for (auto J = I; J != MBB.end() && Instrs.size() < 10; ++J) {
      if (!isCandidate(*J) || J->mayLoad() != First.mayLoad() ||
          J->getOperand(1).getReg() != First.getOperand(1).getReg() ||
          J->getFlags() != First.getFlags())
        break;
      Instrs.push_back(&*J);
    }

    // Prefer the longest encodable run, so a pair does not hide a larger list.
    bool Merged = false;
    while (Instrs.size() >= 2) {
      SmallVector<MachineInstr *, 10> Sorted(Instrs);
      llvm::sort(Sorted, [](const MachineInstr *L, const MachineInstr *R) {
        return L->getOperand(2).getImm() < R->getOperand(2).getImm();
      });
      unsigned Opcode;
      MCRegister Tuple;
      if (findOpcode(Sorted, Opcode, Tuple)) {
        I = std::next(Instrs.back()->getIterator());
        merge(Instrs, Opcode, Tuple, Sorted.front()->getOperand(2).getImm());
        Merged = Changed = true;
        break;
      }
      Instrs.pop_back();
    }
    if (!Merged)
      ++I;
  }
  return Changed;
}

bool MipsLoadStoreOptimizer::runOnMachineFunction(MachineFunction &MF) {
  ST = &MF.getSubtarget<MipsSubtarget>();
  if (skipFunction(MF.getFunction()) || !ST->inMicroMipsMode() ||
      !ST->hasMips32r2() || ST->isGP64bit())
    return false;
  TII = ST->getInstrInfo();
  TRI = &TII->getRegisterInfo();
  bool Changed = false;
  for (MachineBasicBlock &MBB : MF)
    Changed |= optimizeBlock(MBB);
  return Changed;
}

FunctionPass *llvm::createMipsLoadStoreOptimizerPass() {
  return new MipsLoadStoreOptimizer();
}
