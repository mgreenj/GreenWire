#!/usr/bin/env bash
set -euo pipefail

echo "[+] Initializing submodules..."
git submodule update --init --recursive

echo "[+] Installing system dependencies..."
scripts/setup_install_deps.sh

echo "[+] Setting up Spack environment..."
. deps/spack/share/spack/setup-env.sh
spack env activate .
spack install

# echo "[+] Configuring and installing DPDK manually..."
# scripts/setup_conf_dpdk_env.sh
# scripts/setup_run_tests.sh
# scripts/setup_install_dpdk.sh

echo "[+] Building GreenWire project..."
mkdir -p ../build && cd ../build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$SPACK_ENV/view"
make -j"$(nproc)"

echo "[✓] Build complete."
