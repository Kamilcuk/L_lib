f_xargs_e() {
	if [[ "$1" -ge 5 ]]; then
		return 1
	fi
	printf "%s:" "$1"
}

_L_test_xargs_extra_e() {
	local i
	local -a a=()
	for ((i = 0; i < 10; ++i)); do
		a+=("$i")
	done

	L_unittest_cmd -e 123 -o "0:1:2:3:4:" L_xargs -a a -n 1 f_xargs_e

	local out
	L_unittest_cmd -e 123 -v out L_xargs -a a -P 5 -n 1 f_xargs_e
	local -a arr
	IFS=: read -r -a arr <<<"$out"
	L_sort_bash -n arr
	L_unittest_arreq arr 0 1 2 3 4
}

f_xargs_X() {
	if [[ $1 -ge 5 ]]; then
		exit 1
	fi
	echo "$1"
}

_L_test_xargs_extra_X() {
	local i
	local -a a=()
	for ((i = 0; i < 10; ++i)); do
		a+=("$i")
	done

	local out
	L_readarray out < <( L_xargs -X -a a -n 1 f_xargs_X )
	L_unittest_arreq out 0 1 2 3 4

	L_readarray out < <( L_xargs -X -a a -P 5 -n 1 f_xargs_X )
	L_sort_bash -n out
	L_unittest_arreq out 0 1 2 3 4
}

_L_test_xargs_extra_T() {
	local i
	local -a a=()
	for ((i = 0; i < 10; ++i)); do
		a+=("$i")
	done

	L_unittest_checkexit 0 L_xargs -a a -n 1 -T echo {}
}

_L_test_xargs_T() {
	local -a a=("foo bar" "baz" "qux")
	L_unittest_cmd -e 0 -o "foo bar baz qux" L_xargs -a a -L 3 -T echo "{}"
	L_unittest_cmd -e 0 -o "foo bar-baz-qux-" L_xargs -a a -L 3 -T printf "%s-" "{1}" "{2}" "{3}"
}
