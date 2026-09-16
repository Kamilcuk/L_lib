#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "$0")"/../bin/L_lib.sh -s

f() {
	sleep 0.$(( ${SRANDOM:-${RANDOM}} ))
	L_notice "${FUNCNAME[1]}"
}

_L_test_unittest_fast_ok() {
	true
}

_L_test_unittest_fast_false() {
	false
}

_L_test_unittest_skip() {
	f
	L_setx L_unittest_skip "tests skipping"
	false
}

_L_test_unittest_long_skip() {
	f
	L_setx L_unittest_skip "also tests skipping but this one has kind of long skipping message"
	false
}

_L_test_unittest_false() {
	f
	false
}

_L_test_unittest_exit1() {
	f
	exit 1
}

_L_test_unittest_exit127() {
	f
	exit 127
}

_L_test_unittest_exit254() {
	f
	exit 254
}

_L_test_unittest_exit0() {
	f
	exit 0
}

_L_test_unittest_ok() {
	f
	true
}

_L_test_unittest_also_ok() {
	f
	true
}

_L_test_unittest_another_ok() {
	f
	true
}

_L_test_unittest_raise_sigusr1() {
	L_finally
	L_raise -SIGUSR1
	false
}

_L_test_unittest_long_output_20000() {
	printf '%*s' "${FUNCNAME[0]//*_}" '' | tr ' ' A
}

_L_test_unittest_output_safe_allchars() {
	_L_SAFE_ALLCHARS=${L_ALLCHARS//[$'\001\177\r']}
	echo "$_L_SAFE_ALLCHARS"
	# echo $'\x80' ## X
}

_L_test_unittest_output_allchars() {
	echo "${L_ALLCHARS//[$'\001\177\r']}"
}


# _L_test_unittest_clear_finally() {
#   f
#   trap - EXIT INT TERM
# }
#
# _L_test_unittest_clear_finally_exit1() {
#   f
#   trap - EXIT INT TERM
#   exit 1
# }
#
# _L_test_unittest_clear_finally_false() {
#   f
#   trap - EXIT INT TERM
#   false
# }

L_log_configure -1
L_unittest_main -p _L_test_unittest_ "$@"
