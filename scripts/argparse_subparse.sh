#!/usr/bin/env bash
args=(
	-- --foo action=store_true help='foo help' \
	-- cmd action=subparser \
	{ \
		a description='a help' \
		-- bar type=int help='bar help' \
	} \
	{ \
		b description='b help' \
		-- --baz choices='X Y Z' help='baz help' \
	} \
	---- "$@"
)
echo "L_argparse ${args[*]@Q}"
"$(dirname "$0")"/L_argparse "${args[@]}"
