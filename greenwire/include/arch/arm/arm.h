/**
 * 
 * Author:      Maurice Green
 * 
 * arm.h       Arm header file for holding ARM helper,
 *             functions and ARM-specific definitions
 * 
 */

#include "stdint.h"

#pragma once 
#include "cpuinfo_shared.h"

#if defined __ARM_ARCH && __ARM_ARCH == 8
    #define ARCH_NAME                   "ARM64"
    #define ARCH_CACHE_LINE_SIZE        64

    // Prototype Function pointers for MIDR_EL1
    uint32_t (*midrptrv8)(uint32_t);
    static inline arch_read_midr() {
        // 
    }
#elif defined __ARM_ARCH && __ARM_ARCH == 7
    #define ARCH_NAME                   "ARMv7"
    #define ARCH_CACHE_LINE_SIZE        32

    // Prototype function pointer for MIDR
    uint32_t (*midrptrv7)(uint32_t)
#endif

// READ MIDR_EL1 (ARM64) or MIDR (ARMv7)