#!/usr/bin/env bash
# shellcheck disable=SC2178,SC2034,SC2128,SC2190

_L_test_var_get_nameref() {
	if (( !L_HAS_NAMEREF )); then
		L_unittest_skip "No nameref support (requires Bash >= 4.3)"
		return
	fi

	# A nameref resolves to the name of the variable it references (printed to stdout).
	local target="hello world"
	local -n ref=target
	L_unittest_cmd -o target L_var_get_nameref ref

	# The -v option assigns the referenced name to a variable and prints nothing.
	local out
	L_var_get_nameref -v out ref
	L_unittest_vareq out target
	L_unittest_checkexit 0 L_var_get_nameref -v out ref

	# The -- separator is supported and behaves like the plain form.
	L_unittest_cmd -o target L_var_get_nameref -- ref

	# A nameref to a name containing an underscore.
	local my_target=1
	local -n my_ref=my_target
	L_unittest_cmd -o my_target L_var_get_nameref my_ref

	# A nameref to an array variable returns the array's name.
	local -a arr=("a" "b" "c")
	local -n ref_arr=arr
	L_unittest_cmd -o arr L_var_get_nameref ref_arr

	# A nested nameref returns only the immediate (one level) target name,
	# not the fully dereferenced variable.
	local -n a_ref=b_ref
	local -n b_ref=c_var
	local c_var="final"
	L_unittest_cmd -o b_ref L_var_get_nameref a_ref
}

_L_test_var_get_nameref_not_nameref() {
	if (( !L_HAS_NAMEREF )); then
		L_unittest_skip "No nameref support (requires Bash >= 4.3)"
		return
	fi

	# A plain scalar variable is not a nameref: empty output, exit code 1.
	local scalar="value"
	L_unittest_cmd -e 1 L_var_get_nameref scalar
	L_unittest_eq "$(trap - ERR; L_var_get_nameref scalar)" ""

	# With -v on a non-nameref, the variable is emptied and exit code is 1.
	L_unittest_eq "$(trap - ERR; local out=preset; L_var_get_nameref -v out scalar || :; printf %s "$out")" ""
	L_unittest_cmd -e 1 L_var_get_nameref -v out scalar

	# An array variable is not a nameref.
	local -a arr=("a" "b")
	L_unittest_cmd -e 1 L_var_get_nameref arr

	# An undefined variable is not a nameref.
	unset undefined_var
	L_unittest_cmd -e 1 L_var_get_nameref undefined_var
	L_unittest_eq "$(trap - ERR; L_var_get_nameref undefined_var)" ""
}
