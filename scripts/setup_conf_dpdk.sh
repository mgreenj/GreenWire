#!/usr/bin/env bash
set -euo pipefail

echo "[+] Reserving 4 hugepages (1GB)..."
echo 4 | sudo tee /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages

echo "[+] Mounting hugepages if not already mounted..."
sudo mkdir -p /mnt/huge
mountpoint -q /mnt/huge || sudo mount -t hugetlbfs pagesize=1G /mnt/huge

echo "[+] Current hugepage status:"
grep Huge /proc/meminfo

echo "[+] Persisting Huge Page Config"
grep -q "/mnt/huge" /etc/fstab || echo 'nodev /mnt/huge hugetlbfs pagesize=1G 0 0' | sudo tee -a /etc/fstab

echo "[+] Updating GRUB Bootloader"
sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="default_hugepagesz=1G hugepagesz=1G hugepages=4 /' /etc/default/grub
sudo update-grub

echo "[+] Setup complete."
