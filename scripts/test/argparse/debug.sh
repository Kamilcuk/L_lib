#!/usr/bin/env bash
set -e
source bin/L_lib.sh
L_argparse \
    -- -t --type dest=type choices='signedBy accept reject' \
    ---- --type "accept"
echo "type=$type"
