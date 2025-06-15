#pragma once 

#include <limits.h>
#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdalign.h>
//#include <sys/epoll.h>

#ifdef __cplusplus
extern "C" {
#endif

#define DAGG_IS_GNU 0
#if defined __clang__ 
#define DAGG_CLANG
#elif defined __GNUC__
#define DAGG_GCC
#undef DAGG_IS_GNU
#define DAGG_IS_GNU 1
#endif
#if DAGG_IS_GNU
#define GCC_VERSION (__GNUC__ * 1000 + __GNUC_MINOR__ + 100 + \
                __GNUC_PATCHLEVEL__)
#endif

/**
 * * * * Mechanisms and Macros for Runtime Efficiency * * * *
 * 
 * 
 * the GCC builtin for prefetching has the following variadic form
 *      __builtin_prefetch(const void *addr, ...)
 * 
 * See: https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html for 
 * a detailed description.  Usage is pretty straightforward; the 
 * optional arguments include rw and locality.
 * 
 * rw is a compile-time constant.  The default value of zero indicates
 * preparation to read, while 1 indicates prepartion to write.
 * 
 * locality is a compile-time constant.  The four optional values are 
 * 0 - 3.  Temporal locality refers to the liklihood that a recently
 * access memory address will be accessed repeatedly in a short period.
 * 
 * 0    = No temporal  locality
 * 1    = low temporal locality
 * 2    = moderate temporal locality
 * 3    = high temporal locality
 * 
 */


 // for struct packed
#define __dagg_packed __attribute__((__packed__))

// mark type if ont type-based alias type
#define __dagg_alias __attribute__((__may_alias__))

// mark weak reference
#define __dagg_weak __attribute__((__weak__))

// mark function pure
#define __dagg_pure __attribute__((pure))

// force symbol generation
#define __dagg_used __attribute__((used))

//  mark function unused
#define __dagg__unused __attribute__((__unused__))


// advisible to use -fprofile-arcs to confirm assumptions

// branch prediction, mark branch unlikely to be taken
#define unlikely(x) __builtin_expect(!!(x), 0);

// branch prediction, mark branch likely to be taken
#define likely(x)   __builint_expect(!!(x), 1);

/** Instruct compiler that return points to memory. */
#if defined(dagg_GCC) || defined(dagg_CLANG)
#define __dagg_alloc_size(...)   \
        __attribute__((alloc_size(__VA_ARGS__)))
#else 
#define __dagg_alloc_size(...)
#endif

#define CACHE_LINE_SIZE     64
#define N_CACHE_LINE_SIZE   128
#define CACHE_LINE_SIZE_MIN 64

#define __dagg_aligned(a) __attribute__((__aligned__(a)))

#define __dagg_cache_aligned __dagg_aligned(CACHE_LINE_SIZE)

#define __dagg_cache_min_aligned __dagg_aligned(CACHE_LINE_SIZE_MIN)

#define __slimdagg_always_inline inline __attribute__((always_inline))

#define __slimdagg_never_inline __attribute__((noinline))

#define __slimdagg_cold __attribute__((cold))

#define __slimdagg_hot __attribute__((hot))

// Ensure pointers are always aligned
// #define always_alloc_align 

static inline void prefetch_writeH(const void *p)
{   // see prefetch comment on usage above on above

    // __builtin_prefetch(const void *addr, rw, locality)
    __builtin_prefetch(p, 1, 3); // high temporal locality
}

static inline void prefetch_writeM(const void *p)
{   // see prefetch comment on usage above on above

    // __builtin_prefetch(const void *addr, rw, locality)
    __builtin_prefetch(p, 1, 2); // moderate temporal locality
}

static inline void prefetch_writeL(const void *p)
{   // see prefetch comment on usage above on above

    // __builtin_prefetch(const void *addr, rw, locality)
    __builtin_prefetch(p, 1, 1); // low temporal locality
}

static inline void prefetch_writeN(const void *p)
{   // see prefetch comment on usage above on above

    // __builtin_prefetch(const void *addr, rw, locality)
    __builtin_prefetch(p, 1, 0); // no temporal locality
}

#ifdef __cplusplus
}
#endif