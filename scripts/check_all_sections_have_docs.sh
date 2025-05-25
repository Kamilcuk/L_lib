#!/bin/bash
set -xeuo pipefail
cd "$(dirname "$0")/.."
sections=$(sed -n 's!# @section \(.*\)$!\1!p' bin/L_lib.sh)
if ! sed "s@.*@docs/section/&.md@" <<<"$sections" | xargs ls; then
  echo "ERROR: not all sections have md file"
  exit 1
fi
