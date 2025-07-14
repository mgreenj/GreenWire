#!/usr/bin/env bash
set -euo pipefail

DPDK_DIR="../deps/dpdk"
BUILD_DIR="${DPDK_DIR}/build"

echo "[+] Creating debug build directory..."
meson setup --buildtype=debug "${BUILD_DIR}" "${DPDK_DIR}"

echo "[+] Configuring DPDK build..."
meson configure "${BUILD_DIR}" \
  -Dcheck_includes=false \
  -Dcpu_instruction_set=auto \
  -Ddeveloper_mode=enabled \
  -Ddisable_apps='' \
  -Ddisable_drivers='' \
  -Ddisable_libs='' \
  -Ddrivers_install_subdir='dpdk/pmds-<VERSION>' \
  -Denable_apps='' \
  -Denable_deprecated_libs='' \
  -Denable_docs=false \
  -Denable_driver_sdk=true \
  -Denable_drivers='' \
  -Denable_iova_as_pa=true \
  -Denable_kmods=false \
  -Denable_libs='' \
  -Denable_stdatomic=false \
  -Denable_trace_fp=false \
  -Dexamples='' \
  -Dibverbs_link=shared \
  -Dinclude_subdir_arch='' \
  -Dkernel_dir='' \
  -Dmachine=auto \
  -Dmax_ethports=32 \
  -Dmax_lcores=default \
  -Dmax_numa_nodes=default \
  -Dmbuf_refcnt_atomic=true \
  -Dplatform=native \
  -Dpkt_mbuf_headroom=128 \
  -Dtests=true \
  -Duse_hpet=false

echo "[+] Building DPDK..."
cd "${BUILD_DIR}"
ninja

echo "[+] Installing DPDK..."
sudo meson install
