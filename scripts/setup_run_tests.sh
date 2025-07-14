#!/usr/bin/env bash
set -euo pipefail

EXAMPLE_BIN="../deps/dpdk/build/examples/dpdk-helloworld"

echo "[+] Verifying pkg-config output for libdpdk..."
CFLAGS=$(pkg-config --cflags libdpdk)
LDFLAGS=$(pkg-config --libs libdpdk)

echo "[+] CFLAGS: $CFLAGS"
echo "[+] LDFLAGS: $LDFLAGS"

if [ ! -x "$EXAMPLE_BIN" ]; then
  echo "[-] Error: $EXAMPLE_BIN not found or not executable"
  exit 1
fi

echo "[+] Running DPDK example: helloworld"
sudo "$EXAMPLE_BIN" -l 0-3 -n 4
