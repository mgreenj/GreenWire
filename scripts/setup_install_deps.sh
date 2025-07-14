#!/usr/bin/env bash
set -euo pipefail

echo "[+] Updating APT cache..."
sudo apt update && upgrade 

echo "[+] Installing system build dependencies..."
sudo apt install -y \
  build-essential \
  pkg-config \
  python3-pip \
  meson \
  ninja-build \
  python3-pyelftools \
  libnuma-dev \
  libarchive-dev  \
  libelf-dev  \
  libbpf-dev
