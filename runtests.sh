#!/bin/bash
exec "$(dirname "$(readlink -f "$0")")"/tests/test.sh "$@"
