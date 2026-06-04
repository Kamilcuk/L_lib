#!/usr/bin/env bash
. scripts/L_uv.sh

_L_test_L_uv_basic() {
	L_uv_init myloop
	local val=0
	L_uv_add_once myloop L_eval 'val=1'
	L_uv_run myloop
	L_unittest_eq "$val" 1
}

_L_test_L_uv_timer() {
	L_uv_init
	local count=0
	_timer_cb() {
		if (( ++count == 3 )); then
			L_uv_break
		fi
	}
	# Use small delays for fast tests
	L_uv_add_timer -d 0.001 -r 0.001 "" _timer_cb
	L_uv_run -s 0.004
	L_unittest_eq "$count" 3
}

_L_test_L_uv_wait() {
	L_uv_init
	local exited=0
	_wait_cb() {
		exited=1
		L_uv_break
	}
	(sleep 0.01) &
	L_uv_add_wait "" "$!" _wait_cb
	L_uv_run -s 0.001
	L_unittest_eq "$exited" 1
}

_L_test_L_uv_readline() {
	L_uv_init
	local result=""
	_read_cb() {
		if (($# == 2)); then
			result+="$2"
		else
			L_uv_break
		fi
	}
	L_pipe p
	echo -n "abc" >&"${p[1]}"
	exec {p[1]}>&-
	L_uv_add_readline "" "${p[0]}" _read_cb
	L_uv_run -s 0.001
	L_unittest_eq "$result" "abc"
}

_L_test_L_uv_once_condition() {
	L_uv_init
	local count=0
	local ran=0
	L_uv_add_timer -d 0.001 -r 0.001 "" L_eval '(( ++count ))'
	L_uv_add_once -c '((count >= 3))' "" L_eval 'ran=1; L_uv_break'
	L_uv_run -s 0.001
	L_unittest_eq "$ran" 1
	L_unittest_checkexit 0 L_eval "(( count >= 3 ))"
}

_L_test_L_uv_timeout() {
	L_uv_init
	L_uv_add_timer -d 1000 "" :
	L_unittest_checkexit "$L_EX_TIMEOUT" L_uv_run -t 0.01
}

_L_test_L_uv_remove() {
	L_uv_init
	local idx
	L_uv_add -v idx "" :
	L_unittest_eq "${#L_UV[*]}" 1
	L_uv_remove "" "$idx"
	L_unittest_eq "${#L_UV[*]}" 0
}
