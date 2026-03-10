#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"/..
set -x
./tests/test.sh -d 10 -Pn -v "$@"
