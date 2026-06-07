#!/usr/bin/env bash
# scripts/freebsd/ssh.sh
set -euo pipefail
DIR="$(dirname "$(readlink -f "$0")")"
cd "$DIR"

echo "Connecting to FreeBSD VM via SSH..."
VAGRANT_DEFAULT_PROVIDER=libvirt vagrant ssh -- "$@"
