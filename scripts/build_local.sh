#!/usr/bin/env bash
set -euo pipefail

# Ensure submodules are available
git submodule update --init --recursive

# Source Spack and activate env
. deps/spack/share/spack/setup-env.sh
spack env activate .
spack install

# Install dependencies
./setup_install_deps.sh

# DPDK Build Environment
./setup_conf_dpdk_env.sh

# Running DPDK Tests to Verify Install
./setup_run_tests.sh

# Installing DPDK
./setup_install_dpdk.sh

# Run tests to verify
./setup_run_tests.sh

# Build project
mkdir -p ../build && cd ../build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$SPACK_ENV/view"
make -j$(nproc)
