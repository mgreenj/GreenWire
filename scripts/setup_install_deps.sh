#!/usr/bin/env bash
set -euo pipefail

echo "[+] Updating APT cache..."
sudo apt update && apt upgrade 

echo "[+] Installing system build dependencies..."
sudo apt install -y \
  build-essential \
  python3-pip \
  # libnuma-dev \
  libbpf-dev

echo "[+] Clearning Apt packages..."
sudo apt autoremov