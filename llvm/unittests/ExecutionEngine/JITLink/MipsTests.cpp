//===-- MipsTests.cpp - Tests for MIPS JITLink utilities ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/ExecutionEngine/JITLink/mips.h"
#include "gtest/gtest.h"

using namespace llvm;
using namespace llvm::jitlink;

TEST(MipsJITLinkTest, N32PointerSize) {
  LinkGraph G("n32", std::make_shared<orc::SymbolStringPool>(),
              Triple("mips64el-unknown-linux-gnuabin32"), SubtargetFeatures(),
              mips::getEdgeKindName, 4);
  EXPECT_EQ(G.getPointerSize(), 4U);
  EXPECT_EQ(G.getEndianness(), endianness::little);
  EXPECT_EQ(mips::getPointerEdgeKind(G), mips::Pointer32);
}

TEST(MipsJITLinkTest, EndianInstructionHelpers) {
  char Little[4] = {};
  char Big[4] = {};
  mips::writeInstruction32<endianness::little>(Little, 0x12345678);
  mips::writeInstruction32<endianness::big>(Big, 0x12345678);
  EXPECT_EQ(mips::readInstruction32<endianness::little>(Little), 0x12345678U);
  EXPECT_EQ(mips::readInstruction32<endianness::big>(Big), 0x12345678U);
  EXPECT_EQ(static_cast<unsigned char>(Little[0]), 0x78U);
  EXPECT_EQ(static_cast<unsigned char>(Big[0]), 0x12U);

  mips::writeImmediate16<endianness::little>(Little, 0xabcd);
  mips::writeImmediate26<endianness::big>(Big, 0x01234567);
  EXPECT_EQ(mips::readInstruction32<endianness::little>(Little), 0x1234abcdU);
  EXPECT_EQ(mips::readInstruction32<endianness::big>(Big), 0x11234567U);
}

TEST(MipsJITLinkTest, ISARevisionDetection) {
  LinkGraph Legacy("mips-r1", std::make_shared<orc::SymbolStringPool>(),
                   Triple("mipsel-unknown-linux"), SubtargetFeatures("+mips32"),
                   mips::getEdgeKindName);
  EXPECT_FALSE(mips::isR6(Legacy));

  LinkGraph R6("mips-r6", std::make_shared<orc::SymbolStringPool>(),
               Triple("mipsel-unknown-linux"), SubtargetFeatures("+mips32r6"),
               mips::getEdgeKindName);
  EXPECT_TRUE(mips::isR6(R6));
}

TEST(MipsJITLinkTest, PointerAndR6StubHelpers) {
  LinkGraph G("mips-r6", std::make_shared<orc::SymbolStringPool>(),
              Triple("mipsel-unknown-linux"), SubtargetFeatures("+mips32r6"),
              mips::getEdgeKindName);
  auto &GOT =
      G.createSection("$__GOT", orc::MemProt::Read | orc::MemProt::Write);
  auto &Stubs =
      G.createSection("$__STUBS", orc::MemProt::Read | orc::MemProt::Exec);
  auto &Target = G.addAbsoluteSymbol("target", orc::ExecutorAddr(0x12345678), 0,
                                     Linkage::Strong, Scope::Local, false);
  auto &Pointer = mips::createAnonymousPointer(G, GOT, &Target, 4);
  ASSERT_EQ(Pointer.getBlock().edges_size(), 1U);
  auto &PointerEdge = *Pointer.getBlock().edges().begin();
  EXPECT_EQ(PointerEdge.getKind(), mips::Pointer32);
  EXPECT_EQ(&PointerEdge.getTarget(), &Target);
  EXPECT_EQ(PointerEdge.getAddend(), 4);

  auto &Stub = mips::createAnonymousPointerJumpStub(G, Stubs, Pointer);
  ASSERT_EQ(Stub.getSize(), 20U);
  auto Content = Stub.getBlock().getContent();
  EXPECT_EQ(support::endian::read32le(Content.data()), 0x3c190000U);
  EXPECT_EQ(support::endian::read32le(Content.data() + 4), 0x27390000U);
  EXPECT_EQ(support::endian::read32le(Content.data() + 8), 0x8f390000U);
  EXPECT_EQ(support::endian::read32le(Content.data() + 12), 0x03200009U);
  ASSERT_EQ(Stub.getBlock().edges_size(), 2U);
  auto StubEdge = Stub.getBlock().edges().begin();
  EXPECT_EQ(StubEdge->getKind(), mips::Hi16);
  EXPECT_EQ(&StubEdge->getTarget(), &Pointer);
  ++StubEdge;
  EXPECT_EQ(StubEdge->getKind(), mips::Lo16);
  EXPECT_EQ(&StubEdge->getTarget(), &Pointer);

  EXPECT_TRUE(static_cast<bool>(
      getAnonymousPointerCreator(Triple("mips64-unknown-linux-gnuabi64"))));
  EXPECT_TRUE(static_cast<bool>(
      getPointerJumpStubCreator(Triple("mipsel-unknown-linux"))));
}

TEST(MipsJITLinkTest, N64BigEndianStubHelper) {
  LinkGraph G("mips64be-r2", std::make_shared<orc::SymbolStringPool>(),
              Triple("mips64-unknown-linux-gnuabi64"),
              SubtargetFeatures("+mips64r2"), mips::getEdgeKindName);
  auto &GOT =
      G.createSection("$__GOT", orc::MemProt::Read | orc::MemProt::Write);
  auto &Stubs =
      G.createSection("$__STUBS", orc::MemProt::Read | orc::MemProt::Exec);
  auto &Target =
      G.addAbsoluteSymbol("target", orc::ExecutorAddr(0x123456789abcdef0ULL), 0,
                          Linkage::Strong, Scope::Local, false);
  auto &Pointer = mips::createAnonymousPointer(G, GOT, &Target);
  EXPECT_EQ(Pointer.getBlock().edges().begin()->getKind(), mips::Pointer64);

  auto &Stub = mips::createAnonymousPointerJumpStub(G, Stubs, Pointer);
  ASSERT_EQ(Stub.getSize(), 36U);
  auto Content = Stub.getBlock().getContent();
  EXPECT_EQ(support::endian::read32be(Content.data()), 0x3c190000U);
  EXPECT_EQ(support::endian::read32be(Content.data() + 4), 0x67390000U);
  EXPECT_EQ(support::endian::read32be(Content.data() + 8), 0x0019cc38U);
  EXPECT_EQ(support::endian::read32be(Content.data() + 24), 0xdf390000U);
  EXPECT_EQ(support::endian::read32be(Content.data() + 28), 0x03200008U);
  ASSERT_EQ(Stub.getBlock().edges_size(), 4U);
  auto I = Stub.getBlock().edges().begin();
  EXPECT_EQ((I++)->getKind(), mips::Highest16);
  EXPECT_EQ((I++)->getKind(), mips::Higher16);
  EXPECT_EQ((I++)->getKind(), mips::Hi16);
  EXPECT_EQ(I->getKind(), mips::Lo16);
}
