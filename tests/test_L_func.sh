# This is a test file for L_func_* functions

# @description This is a dummy test function.
# @arg $1 Some argument.
_L_dummy_comment_func() {
	:
}

test_followed() {
	awk '
/^[[:space:]]*#/{ next }
/'"$1"'.*; return /{
	print NR, $0
	next
}
/^[[:space:]]*'"$1"' / {
	print NR, $0
	pending = NR
	next
}
pending && /^[[:space:]]*return /{
	print NR, $0
	pending = 0
}
pending { exit -1 }
END {
    if (pending) {
        print NR, $0
        printf "ERROR: '"$1"' without following return at %s:%d\n", FILENAME, pending
        exit -1
    }
}
' bin/L_lib.sh
}

_L_test_func_usage() {
	L_log "Check that every L_func_assert is followed by return"
	! grep 'L_func_assert ' bin/L_lib.sh | grep -v '|| return'
	L_log "Check every L_func_error is followed by return"
	test_followed L_func_error
	L_log "Check every L_func_help is followed by return"
	test_followed L_func_help
}

_L_test_L_func_comment() {
	local help_out=""
	L_unittest_cmd -c L_func_comment -v help_out -f _L_dummy_comment_func
	L_unittest_eq "${help_out//$'\r'/}" '# @description This is a dummy test function.
# @arg $1 Some argument.
'
}

_L_test_L_func_help_all() {
	local funcs func def
	L_compgen -V funcs -A function -- L_
	for func in "${funcs[@]}"; do
		# Skip L_readarray since it redefines itself to mapfile builtin which doesn't support -h
		[[ "$func" == "L_readarray" ]] && continue
		def=$(declare -f "$func")
		if [[ "$def" == *"getopts"* && "$def" == *"L_func_help"* ]]; then
			L_unittest_cmd "$func" -h
		fi
	done
}

# @description Example function for testing L_func_help rendering.
# This is a second description line.
# @option -v <var> Store result in var.
# @option --verbose Enable verbose mode.
# @arg <file> The input file to process.
# @env MYVAR An environment variable used.
# @return 0 on success.
# @return 1 on failure.
# @example
#   testfn -v out input.txt
# @see https://example.com
# @shellcheck disable=SC2086
_L_dummy_help_func() {
	:
}

_L_test_L_func_help() {
	local help_out=""
	L_unittest_cmd -c L_func_help -v help_out -f _L_dummy_help_func
	L_unittest_contains "$help_out" "Description:"
	L_unittest_contains "$help_out" "Example function for testing L_func_help rendering."
	L_unittest_contains "$help_out" "This is a second description line."
	L_unittest_contains "$help_out" "Options:"
	L_unittest_contains "$help_out" "-v <var>"
	L_unittest_contains "$help_out" "--verbose"
	L_unittest_contains "$help_out" "Arguments:"
	L_unittest_contains "$help_out" "<file>"
	L_unittest_contains "$help_out" "Environment:"
	L_unittest_contains "$help_out" "MYVAR"
	L_unittest_contains "$help_out" "Returns:"
	L_unittest_contains "$help_out" "on success."
	L_unittest_contains "$help_out" "on failure."
	L_unittest_contains "$help_out" "Example:"
	L_unittest_contains "$help_out" "testfn -v out input.txt"
	L_unittest_contains "$help_out" "See:"
	L_unittest_contains "$help_out" "https://example.com"
	# @shellcheck directive must be ignored, not rendered
	L_unittest_eq "$([[ "$help_out" == *shellcheck* ]] && echo yes || echo no)" "no"
}
