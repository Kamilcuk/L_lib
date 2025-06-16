#!/bin/bash
SCOPE+=("source_test_2")
eval "$SCRIPT"
. "${BASH_SOURCE[0]%/*}/source_test_3.sh" ${ARGS[@]:+"${ARGS[@]}"}
