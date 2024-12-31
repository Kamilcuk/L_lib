#!/usr/bin/env bash
CMD_a() {
	L_argparse description='a help' -- bar type=int help='bar help' ---- "$@"
}
CMD_b() {
	L_argparse prog=helpme description='b help' epilog='suffix' -- --baz choices='X Y Z' help='baz help' ---- "$@"
}
export -f CMD_a CMD_b
args=(
	-- --foo action=store_true help='foo help' \
	-- class=func prefix=CMD_ \
	---- "$@"
)
echo "+ L_argparse ${args[*]@Q}"
"$(dirname "$0")"/L_argparse "${args[@]}"
