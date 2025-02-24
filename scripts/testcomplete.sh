#!/bin/bash
set -euo pipefail
tmp=$("$1" --L_argparse_complete_bash)
eval "$tmp"
func="${1##*/}"
func="_L_argparse_complete_${func//[^a-zA-Z0-9]/_}"
compopt() {
	true fakecompopt "$@"
}
COMP_WORDS=("$@")
COMP_CWORD=$#
COMP_LINE="$*"
COMP_POINT=${#COMP_LINE}
COLUMNS=$(tput cols)
COMPREPLY=()
set -x
"$func" "$1" "${*:$#-1}" "${*:$#-2}"
set +x
for i in "${COMPREPLY[@]}"; do
	echo "$i"'$'
done
