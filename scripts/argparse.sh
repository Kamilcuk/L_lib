#!/usr/bin/env bash

MODE_one() {
	args=(
		-- --foo action=store_true help='foo help' \
		-- class=subparser \
		'{' \
			a description='a help' \
			-- bar type=int help='bar help' \
		'}' \
		'{' \
			b description='b help' \
			-- --baz choices='X Y Z' help='baz help' \
		'}' \
		---- "$@"
	)
}

MODE_two() {
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
}

MODE_podman() {
	args=(
		description="Set default trust policy or a new trust policy for a registry"
		epilog="god"
		-- -f --pubkeysfile dest=stringArray action=append help="\
			Path of installed public key(s) to trust for TARGET.
			Absolute path to keys is added to policy.json. May
			used multiple times to define multiple public keys.
			File(s) must exist before using this command" \
		-- -t --type dest=type metavar=string \
		help="Trust type, accept values: signedBy(default), accept, reject" \
		default="signedBy" show_default=1 choices='signedBy accept reject' \
		-- -o --option
		-- REGISTRY dest=registry
		---- "$@"
	)
}

. "$(dirname "$0")"/../bin/L_lib.sh
mode=MODE_$1
if L_function_exists "$mode"; then
	"$mode" "${@:2}"
else
	echo "Usage: $0 $(L_list_functions_with_prefix_removed MODE_ | paste -sd'|')" >&2
	exit 1
fi
echo "L_argparse ${args[*]@Q}"
"$(dirname "$0")"/L_argparse "${args[@]}"
