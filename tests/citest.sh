#!/usr/bin/env bash
set -xeuo pipefail
"$(dirname "$(readlink -f "$0")")"/test.sh -Pn -v "$@"
