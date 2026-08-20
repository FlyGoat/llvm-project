// RUN: %clang -O1 -fPIC -fno-stack-protector -pthread -c -o %t %s
// RUN: %llvm_jitlink %t
// RUN: %clang -O1 -fPIC -fno-stack-protector -pthread -S -emit-llvm -o %t.ll %s
// RUN: %lli_orc_jitlink -emulated-tls=false -relocation-model=pic %t.ll

// Exercise general-dynamic and local-dynamic TLS descriptors in both .tdata
// and .tbss. Each worker must receive an independent copy of the template,
// while the initial thread must remain unchanged.

#include <pthread.h>
#include <stdint.h>

__thread __attribute__((tls_model("global-dynamic"))) int gd_data = 7;
__thread __attribute__((tls_model("global-dynamic"))) int gd_bss;
static __thread __attribute__((tls_model("local-dynamic"))) int ld_data = 11;
static __thread __attribute__((tls_model("local-dynamic"))) int ld_bss;

static int failures;

static void *worker(void *opaque) {
  intptr_t id = (intptr_t)opaque;
  int expected = (int)(100 + id);

  if (gd_data != 7 || gd_bss != 0 || ld_data != 11 || ld_bss != 0)
    __atomic_fetch_add(&failures, 1, __ATOMIC_RELAXED);

  gd_data = expected;
  gd_bss = expected + 1;
  ld_data = expected + 2;
  ld_bss = expected + 3;

  if (gd_data != expected || gd_bss != expected + 1 ||
      ld_data != expected + 2 || ld_bss != expected + 3)
    __atomic_fetch_add(&failures, 1, __ATOMIC_RELAXED);
  return 0;
}

int main(void) {
  pthread_t threads[4];

  if (gd_data != 7 || gd_bss != 0 || ld_data != 11 || ld_bss != 0)
    return 1;

  for (intptr_t i = 0; i != 4; ++i)
    if (pthread_create(&threads[i], 0, worker, (void *)i))
      return 2;
  for (int i = 0; i != 4; ++i)
    if (pthread_join(threads[i], 0))
      return 3;

  if (gd_data != 7 || gd_bss != 0 || ld_data != 11 || ld_bss != 0)
    return 4;
  return failures ? 5 : 0;
}
