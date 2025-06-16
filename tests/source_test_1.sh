#!/bin/bash

SCOPE+=("source_test_1")
eval "$SCRIPT"
. "${BASH_SOURCE[0]%/*}/source_test_2.sh" ${ARGS[@]:+"${ARGS[@]}"}
