# Optimizations to achieve Low-latency

## Architectural Optimizations
* Batching (Using rte_eth_rx_burst) - reduces per-packet overhead; amortizes cost
* NUMA locality - Pin threads to the same NUMA node as NIC to prevent cross-socket memory access latency.
* Memory Layout - Using cache-aligned structs (64B) to minimize false sahring and TLB misses.
* Hugepages - reduces TLB misses
* Memory Pools - Pre-allocate memory for objects to avoid calls to malloc (which is non-deterministic) and free during hot path routines.
* Asynchronous threading
* Zero-Copy / Kernel bypass

## Threading and CPU Optimizations
* Scheduling affinity for threads
* Avoid preemption using PMD and minimizing syscalls

## Code Optimizations
* Typical (loop unrolling, etc.)
* Use compiler decorator likely/unlikely to optimize linking and improve cache coherency
* Use compiler (GCC) attributes to control static scheduling, linking, etc., to optimize code (e.g., __attribute__((hot)) for hot path)
* restrict to help with pointer aliasing

## I/O Optimizations
* Use DMA (either DPDK API or custom DMA Driver) to offload memory copying to NIC / PICe
* Prefetching - wrappers defined in `common.h` that use `__builtin_prefetch`.
* Minimize Context Switching by using unbounded buffers. Define guards to prevent overutilization of memory by threads.

## Networking Optimizations
* Enable RSS (Receive Side Scaling) and Flow Directory on NIC
* Use AF_XDP or eBPF/XDP for ultra-fast userpace networking (alternative to dpdk)
* zero-copy sockets 

## Extra
* Run with nohz_full, isolcpus, rcu_nocbs on Linux to eliminate kernel jitter
* Disable frequency scaling (cpufreq, intel_pstate)
* Disable C-states (intel_idle.max_cstate=0, processor.max_cstate=1)
* Use hugepages for DPDK (2M or 1G if available)