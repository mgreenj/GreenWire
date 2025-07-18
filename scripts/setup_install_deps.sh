#!/usr/bin/env bash
set -euo pipefail

echo "[+] Updating APT cache..."
sudo apt update && apt upgrade 

echo "[+] Installing system build dependencies..."
sudo apt install -y \
  build-essential \
  python3-pip \
  libbpf-dev
  # libnuma-dev \

echo "[+] Clearning Apt packages..."
sudo apt autoremove