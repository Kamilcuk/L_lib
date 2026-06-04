#!/usr/bin/env bash
# scripts/freebsd/stop.sh
set -euo pipefail
DIR="$(dirname "$(readlink -f "$0")")"
cd "$DIR"

echo "Destroying Vagrant VM..."
VAGRANT_DEFAULT_PROVIDER=libvirt vagrant destroy -f || true

echo "Killing any lingering QEMU processes..."
killall -9 qemu-system-x86_64 2>/dev/null || true

echo "Cleaning up temporary sockets..."
rm -rf ~/.vagrant.d/tmp/vagrant-qemu/* 2>/dev/null || true
