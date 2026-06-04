#!/usr/bin/env bash
# scripts/freebsd/start.sh
set -euo pipefail
DIR="$(dirname "$(readlink -f "$0")")"
cd "$DIR"

echo "Starting FreeBSD VM..."
VAGRANT_DEFAULT_PROVIDER=libvirt vagrant up
