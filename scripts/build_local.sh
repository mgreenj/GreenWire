#!/usr/bin/env bash
set -euo pipefail

# Ensure submodules are available
git submodule update --init --recursive

# Install dependencies
scripts/setup_install_deps.sh

# Source Spack and activate env
. deps/spack/share/spack/setup-env.sh
spack env activate .
spack install

# DPDK Build Environment
scripts/setup_conf_dpdk_env.sh

# Running DPDK Tests to Verify Install
scripts/setup_run_tests.sh

# Installing DPDK
scripts/setup_install_dpdk.sh

# Run tests to verify
scripts/setup_run_tests.sh

# Build project
mkdir -p ../build && cd ../build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$SPACK_ENV/view"
make -j$(nproc)
