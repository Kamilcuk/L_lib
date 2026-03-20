#!/usr/bin/env bash

# We will write the functions to a temporary file, and have perfbash source it,
# so the commands passed to -C are very short and clearly named.

cat << 'EOF' > /tmp/l_sete_funcs.sh
L_sete_shopt() { if shopt -po errexit >/dev/null; then "$@"; else set -e; "$@"; eval "set +e;return "\$?""; fi; }
L_sete_match() { if [[ $- == *e* ]]; then "$@"; else set -e; "$@"; eval "set +e;return "\$?""; fi; }
L_sete_opt() { if [[ -o errexit ]]; then "$@"; else set -e; "$@"; eval "set +e;return "\$?""; fi; }
L_sete_case() { case $- in *e*) "$@" ;; *) set -e; "$@"; eval "set +e;return "\$?"" ;; esac; }

loop_shopt() { for ((i=0; i<5000; i++)); do L_sete_shopt :; done; set -e; for ((i=0; i<5000; i++)); do L_sete_shopt :; done; }
loop_match() { for ((i=0; i<5000; i++)); do L_sete_match :; done; set -e; for ((i=0; i<5000; i++)); do L_sete_match :; done; }
loop_opt() { for ((i=0; i<5000; i++)); do L_sete_opt :; done; set -e; for ((i=0; i<5000; i++)); do L_sete_opt :; done; }
loop_case() { for ((i=0; i<5000; i++)); do L_sete_case :; done; set -e; for ((i=0; i<5000; i++)); do L_sete_case :; done; }
EOF

echo "============================================================"
echo " Profiling Scenario 1: Single Execution (Parsing Overhead)  "
echo "============================================================"
sudo env PATH=/usr/bin:$PATH ./scripts/perfbash -r 100 --no-bwrap -C 1 \
    --prefix '. /tmp/l_sete_funcs.sh; ' \
    "L_sete_shopt :" \
    "L_sete_match :" \
    "L_sete_opt :" \
    "L_sete_case :"

echo ""
echo "============================================================"
echo " Profiling Scenario 2: Loop Execution (Runtime Overhead)    "
echo "============================================================"
sudo env PATH=/usr/bin:$PATH ./scripts/perfbash -r 100 --no-bwrap -C 1 \
    --prefix '. /tmp/l_sete_funcs.sh; ' \
    "loop_shopt" \
    "loop_match" \
    "loop_opt" \
    "loop_case"
