#!/usr/bin/env bash
# scripts/freebsd/restart.sh
set -euo pipefail
DIR="$(dirname "$(readlink -f "$0")")"
cd "$DIR"

./destroy.sh
./start.sh
