#!/usr/bin/env bash
set -euo pipefail

_L_test_L_uv_timer_basic() {
	local ran=0 L_UV
	L_uv_init
	L_uv_add_timer -d 0.01 L_eval 'ran=1; L_uv_break'
	L_uv_run
	L_unittest_eq "$ran" 1
}

_L_test_L_uv_timer_repeat() {
	local count=0 L_UV
	L_uv_init
	cb() { if (( ++count == 3 )); then L_uv_break; fi; }
	L_uv_add_timer -d 0.1 -r 0.1 cb
	L_uv_run
	L_unittest_eq "$count" 3
}

_L_test_L_uv_task_removal() {
	local count=0 L_UV
	L_uv_init
	_cb() { ((count+=1)); L_uv_current_remove; }
	L_uv_add_task _cb
	L_uv_add_timer -d 0.05 L_uv_break
	L_uv_run
	L_unittest_eq "$count" 1
}

_L_test_L_uv_reader_behavior() {
	local out="" L_UV
	L_uv_init
	_cb() { out+="${2:-}"; }
	L_pipe p
	echo -n "abc" >&"${p[1]}"
	echo -n "def" >&"${p[1]}"
	eval "exec ${p[1]}>&-"
	L_uv_add_reader "${p[0]}" _cb
	L_uv_run
	L_unittest_eq "$out" "abcdef"
}

_L_test_L_uv_waiter_status() {
	local pid status=-1 L_UV
	L_uv_init
	_cb() { status=$2; L_uv_break; }
	( exit 42 ) & pid=$!
	L_uv_add_waiter "$pid" _cb
	L_uv_run
	L_unittest_eq "$status" 42
}

_L_test_L_uv_poke_keep_alive() {
	local ran=0 L_UV
	L_uv_init
	L_uv_add_task L_eval 'ran=1; L_uv_break'
	L_uv_poke
	L_uv_run
	L_unittest_eq "$ran" 1
}
