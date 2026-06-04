#!/usr/bin/env bash
# scripts/freebsd/logs.sh
set -euo pipefail

SOCKET=$(find ~/.vagrant.d/tmp/vagrant-qemu -name "qemu_socket_serial" | head -n 1)

if [[ -z "$SOCKET" ]]; then
    echo "No QEMU serial socket found. Is the VM starting?"
    exit 1
fi

echo "Connecting to $SOCKET (Press Ctrl+C to exit)..."
# Use socat to connect to the unix socket
# ,raw,echo=0 makes it behave like a serial terminal
socat - UNIX-CONNECT:"$SOCKET"
