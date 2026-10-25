#!/usr/bin/env bash

# =============================================================================
# Tests for L_handle_v_* functions (L_handle_v_scalar, L_handle_v_array,
# L_handle_v_silent, L_handle_v_asa).
#
# Design rules:
#   1. On non-zero return from the *_vL_RET function, output IS printed
#      (except for L_handle_v_silent which never prints by design).
#   2. Exit code is preserved.
#   3. Scalar output: value + newline.
#      Array output: each element on a separate line.
#      Asa output: key=value pairs, no escaping, one per line.
#   4. L_unittest_cmd strips trailing newlines from captured output via L_rstrip.
#   5. L_unittest_cmd uses `!` prefix to assert non-zero exit code.
#
# Note: L_unittest_cmd -c runs in current shell but declares `local L_RET`,
# which shadows any L_RET set by the tested function's _vL_RET handler.
# For L_ARET (asa), there is NO shadowing, so L_ARET values can be checked.
#
# Skip rule:
#   - Only L_handle_v_asa tests are skipped when Bash lacks associative arrays
#     (!L_HAS_ASSOCIATIVE_ARRAY). All other tests run on all Bash versions.
# =============================================================================

# -----------------------------------------------------------------------------
# Original extracted test: exit-code preservation with and without -v, --
# -----------------------------------------------------------------------------
_L_test_a_handle_v() {
	{
		local i
		for i in L_handle_v_scalar L_handle_v_array; do
			return_123() { "$i" "$@"; }
			return_123_vL_RET() { return 123; }
			L_unittest_cmd -ce 123 return_123
			L_unittest_cmd -ce 123 return_123 --
			L_unittest_cmd -ce 123 return_123 a
			L_unittest_cmd -ce 123 return_123 -- a
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -va
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -v a
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -va --
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -v a --
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -va a
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -va -- a
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -v a a
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -v a -- a
			unset a
		done
	}
	{
		wrapper() { set_scalar "$@"; echo "END"; }
		set_scalar() { L_handle_v_scalar "$@"; }
		set_scalar_vL_RET() { L_RET=123; }
		L_unittest_cmd -co $'123\nEND' wrapper
		L_unittest_cmd -co $'123\nEND' wrapper --
		L_unittest_cmd -co $'123\nEND' wrapper a
		L_unittest_cmd -co $'123\nEND' wrapper -- a
		local a=""
		L_unittest_cmd -c set_scalar -va
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_scalar a
		local a=""
		L_unittest_cmd -c set_scalar -v a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_scalar a
		local a=""
		L_unittest_cmd -c set_scalar -va a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_scalar a
		local a=""
		L_unittest_cmd -c set_scalar -v a a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_scalar a
		local a=""
		L_unittest_cmd -c set_scalar -va -- a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_scalar a
		local a=""
		L_unittest_cmd -c set_scalar -v a -- a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_scalar a
	}
	{
		wrapper_set_one() { set_one "$@"; echo "END"; }
		set_one() { L_handle_v_array "$@"; }
		set_one_vL_RET() { L_RET=(123); }
		L_unittest_cmd -co $'123\nEND' wrapper_set_one
		L_unittest_cmd -co $'123\nEND' wrapper_set_one --
		L_unittest_cmd -co $'123\nEND' wrapper_set_one a
		L_unittest_cmd -co $'123\nEND' wrapper_set_one -- a
		local a=""
		L_unittest_cmd -c set_one -va
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
		local a=""
		L_unittest_cmd -c set_one -v a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
		local a=""
		L_unittest_cmd -c set_one -va a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
		local a=""
		L_unittest_cmd -c set_one -v a a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
		local a=""
		L_unittest_cmd -c set_one -va -- a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
		local a=""
		L_unittest_cmd -c set_one -v a -- a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
	}
	{
		wrapper() { set_arr "$@"; echo "END"; }
		set_arr() { L_handle_v_array "$@"; }
		set_arr_vL_RET() { L_RET=(456 789); }
		L_unittest_cmd -co $'456\n789\nEND' wrapper
		L_unittest_cmd -co $'456\n789\nEND' wrapper --
		L_unittest_cmd -co $'456\n789\nEND' wrapper a
		L_unittest_cmd -co $'456\n789\nEND' wrapper -- a
		local a=""
		L_unittest_cmd -c set_arr -va a
		L_unittest_arreq a 456 789
		local a=""
		L_unittest_cmd -c set_arr -v a a
		L_unittest_arreq a 456 789
		local a=""
		L_unittest_cmd -c set_arr -va -- a
		L_unittest_arreq a 456 789
		local a=""
		L_unittest_cmd -c set_arr -v a -- a
		L_unittest_arreq a 456 789
	}
	unset -f set_arr set_one set_arr_vL_RET set_one_vL_RET return_123 return_123_vL_RET set_scalar set_scalar_vL_RET wrapper wrapper_set_one
}

# -----------------------------------------------------------------------------
# Tests: output IS printed even on non-zero return (INTENDED BEHAVIOR)
# Non-asa functions only.
# -----------------------------------------------------------------------------
_L_test_a_handle_v_output_on_error() {
	# L_handle_v_scalar: output preserved on non-zero return
	{
		scalar_err() { L_handle_v_scalar "$@"; }
		scalar_err_vL_RET() { L_RET="error_result"; return 42; }
		L_unittest_cmd -e 42 -o 'error_result' scalar_err
	}
	# L_handle_v_array: output preserved on non-zero return
	{
		arr_err() { L_handle_v_array "$@"; }
		arr_err_vL_RET() { L_RET=(x y z); return 42; }
		L_unittest_cmd -e 42 -o $'x\ny\nz' arr_err
	}
	# L_handle_v_silent: no output ever (by design), but exit code preserved
	{
		silent_err() { L_handle_v_silent "$@"; }
		silent_err_vL_RET() { L_RET="val"; return 42; }
		L_unittest_cmd -e 42 -o '' silent_err
	}
}

# -----------------------------------------------------------------------------
# Tests: L_handle_v_asa output on non-zero return (INTENDED BEHAVIOR)
# Skipped on Bash without associative arrays.
# -----------------------------------------------------------------------------
_L_test_a_handle_v_output_on_error_asa() {
	if ((!L_HAS_ASSOCIATIVE_ARRAY)); then
		L_unittest_skip "L_handle_v_asa requires associative arrays (Bash 4.0+)"
		return 0
	fi
	# L_handle_v_asa: output preserved on non-zero return.
	# The '*' case uses || _L_hvr=$? so output IS printed on non-zero return.
	{
		asa_err() { L_handle_v_asa "$@"; }
		asa_err_vL_ARET() { L_ARET=([k]="v"); return 42; }
		local out
		out=$(asa_err 2>/dev/null) || true
		L_unittest_contains "$out" "k=v"
		# Verify exit code preserved
		L_unittest_cmd -ce 42 asa_err
	}
}

# -----------------------------------------------------------------------------
# Tests: L_handle_v_scalar edge cases
# -----------------------------------------------------------------------------
_L_test_a_handle_v_scalar_edge() {
	# L_RET not set by _vL_RET → empty output
	{
		scalar_empty() { L_handle_v_scalar "$@"; }
		scalar_empty_vL_RET() { :; }
		L_unittest_cmd -o '' scalar_empty
	}
	# L_RET is array → 0-th element is accessible via a[0]
	{
		scalar_arr() { L_handle_v_scalar "$@"; }
		scalar_arr_vL_RET() { L_RET=(first second third); }
		local a=""
		L_unittest_cmd -c scalar_arr -va
		L_unittest_eq "${a[0]:-$a}" "first"
	}
	# Multi-line value preserved
	{
		scalar_ml() { L_handle_v_scalar "$@"; }
		scalar_ml_vL_RET() { L_RET=$'line1\nline2'; }
		L_unittest_cmd -o $'line1\nline2' scalar_ml
	}
	# -h calls help, returns 0
	{
		scalar_h() { L_handle_v_scalar "$@"; }
		scalar_h_vL_RET() { :; }
		L_unittest_cmd -ce 0 scalar_h -h
	}
	# -vL_RET special path (combined format): calls _vL_RET, sets L_RET
	{
		scalar_lret() { L_handle_v_scalar "$@"; }
		scalar_lret_vL_RET() { L_RET="direct"; }
		L_unittest_cmd -ce 0 scalar_lret -vL_RET
	}
	# -v L_RET special path (separate args): calls _vL_RET
	# Note: L_unittest_cmd -c shadows L_RET with its own local, so we can only
	# verify that _vL_RET is called (exit code) not the value.
	{
		scalar_lret_sep() { L_handle_v_scalar "$@"; }
		scalar_lret_sep_vL_RET() { L_RET="sep_direct"; }
		L_unittest_cmd -ce 0 scalar_lret_sep -v L_RET
	}
	# -v L_RET with extra args via -- separator: _vL_RET receives extra args
	{
		scalar_lret_args() { L_handle_v_scalar "$@"; }
		scalar_lret_args_vL_RET() { L_RET="with_args"; }
		L_unittest_cmd -ce 0 scalar_lret_args -v L_RET -- extra
	}
	# Success path return 0
	{
		scalar_ok() { L_handle_v_scalar "$@"; }
		scalar_ok_vL_RET() { L_RET="ok"; return 0; }
		L_unittest_cmd -ce 0 scalar_ok
		local a=""
		L_unittest_cmd -ce 0 scalar_ok -va
		L_unittest_eq "$a" "ok"
	}
	{
		# Non-zero return preserved through -v var
		scalar_v_err() { L_handle_v_scalar "$@"; }
		scalar_v_err_vL_RET() { L_RET="err_val"; return 42; }
		local a=""
		L_unittest_cmd -ce 42 scalar_v_err -va
		L_unittest_eq "$a" "err_val"
	}
}

# -----------------------------------------------------------------------------
# Tests: L_handle_v_array edge cases
# -----------------------------------------------------------------------------
_L_test_a_handle_v_array_edge() {
	# Empty array
	{
		arr_empty() { L_handle_v_array "$@"; }
		arr_empty_vL_RET() { L_RET=(); }
		L_unittest_cmd -o '' arr_empty
	}
	# Array with empty elements
	{
		arr_eelem() { L_handle_v_array "$@"; }
		arr_eelem_vL_RET() { L_RET=("" "val" ""); }
		local a=""
		L_unittest_cmd -c arr_eelem -va
		L_unittest_arreq a "" "val" ""
	}
	# Single empty element
	{
		arr_se() { L_handle_v_array "$@"; }
		arr_se_vL_RET() { L_RET=(""); }
		local a=1
		L_unittest_cmd -c arr_se -va
		L_unittest_eq "${#a[@]}" 1
		L_unittest_eq "${a[0]}" ""
	}
	# Invalid variable names return non-zero (not necessarily 64)
	{
		bad_arr() { L_handle_v_array "$@"; }
		bad_arr_vL_RET() { L_RET=hello; }
		L_unittest_cmd ! bad_arr -v 'rm -rf'
		L_unittest_cmd ! bad_arr -v '1bad'
		L_unittest_cmd ! bad_arr -v ''
	}
	# -h help
	{
		arr_h() { L_handle_v_array "$@"; }
		arr_h_vL_RET() { :; }
		L_unittest_cmd -ce 0 arr_h -h
	}
	# -vL_RET special path (combined format)
	{
		arr_lret() { L_handle_v_array "$@"; }
		arr_lret_vL_RET() { L_RET=(1 2 3); }
		L_unittest_cmd -ce 0 arr_lret -vL_RET
	}
	# -v L_RET special path (separate args): _vL_RET is called (exit code checked)
	# Note: L_unittest_cmd -c shadows L_RET; we verify _vL_RET is invoked via exit code.
	{
		arr_lret_sep() { L_handle_v_array "$@"; }
		arr_lret_sep_vL_RET() { L_RET=(sep1 sep2); }
		L_unittest_cmd -ce 0 arr_lret_sep -v L_RET
	}
	# -v L_RET with -- separator: _vL_RET receives extra args
	{
		arr_lret_args() { L_handle_v_array "$@"; }
		arr_lret_args_vL_RET() { L_RET=(arg1 arg2); }
		L_unittest_cmd -ce 0 arr_lret_args -v L_RET -- extra
	}
	# Success path
	{
		arr_ok() { L_handle_v_array "$@"; }
		arr_ok_vL_RET() { L_RET=(ok); }
		L_unittest_cmd -ce 0 arr_ok
		local a=""
		L_unittest_cmd -ce 0 arr_ok -va
		L_unittest_arreq a ok
	}
	{
		# Non-zero return preserved through -v var
		arr_v_err() { L_handle_v_array "$@"; }
		arr_v_err_vL_RET() { L_RET=(e1 e2); return 42; }
		local a=""
		L_unittest_cmd -ce 42 arr_v_err -va
		L_unittest_arreq a e1 e2
	}
}

# -----------------------------------------------------------------------------
# Tests: L_handle_v_silent edge cases
# -----------------------------------------------------------------------------
_L_test_a_handle_v_silent_edge() {
	# -v assigns value
	{
		silent_v() { L_handle_v_silent "$@"; }
		silent_v_vL_RET() { L_RET="value"; }
		local a=""
		L_unittest_cmd -c silent_v -va
		L_unittest_eq "$a" "value"
	}
	# -v with separate var
	{
		silent_comb() { L_handle_v_silent "$@"; }
		silent_comb_vL_RET() { L_RET="cb"; }
		local a=""
		L_unittest_cmd -c silent_comb -v a
		L_unittest_eq "$a" "cb"
	}
	# Invalid variable names return non-zero
	{
		bad_silent() { L_handle_v_silent "$@"; }
		bad_silent_vL_RET() { L_RET=hello; }
		L_unittest_cmd ! bad_silent -v 'rm -rf'
		L_unittest_cmd ! bad_silent -v '1bad'
	}
	# -h help
	{
		silent_h() { L_handle_v_silent "$@"; }
		silent_h_vL_RET() { :; }
		L_unittest_cmd -ce 0 silent_h -h
	}
	# -vL_RET special path (combined format)
	{
		silent_lret() { L_handle_v_silent "$@"; }
		silent_lret_vL_RET() { L_RET=val; }
		L_unittest_cmd -ce 0 silent_lret -vL_RET
	}
	# -v L_RET special path (separate args): _vL_RET is called (exit code checked)
	{
		silent_lret_sep() { L_handle_v_silent "$@"; }
		silent_lret_sep_vL_RET() { L_RET="sep_val"; }
		L_unittest_cmd -ce 0 silent_lret_sep -v L_RET
	}
	# -v L_RET with -- separator
	{
		silent_lret_args() { L_handle_v_silent "$@"; }
		silent_lret_args_vL_RET() { L_RET="dd_val"; }
		L_unittest_cmd -ce 0 silent_lret_args -v L_RET -- extra
	}
	# -- path: no output
	{
		silent_dd() { L_handle_v_silent "$@"; }
		silent_dd_vL_RET() { (( $# == 0 )) || return 123; L_RET="val"; }
		L_unittest_cmd -o '' silent_dd --
	}
}

# -----------------------------------------------------------------------------
# Tests: L_handle_v_asa edge cases
# Skipped entirely on Bash without associative arrays.
#
# Only _vL_ARET is defined in each test (L_handle_v_asa only calls _vL_ARET).
# -----------------------------------------------------------------------------
_L_test_a_handle_v_asa_edge() {
	if ((!L_HAS_ASSOCIATIVE_ARRAY)); then
		L_unittest_skip "L_handle_v_asa requires associative arrays (Bash 4.0+)"
		return 0
	fi

	# --- Tests that work on ALL Bash versions (including nameref) ---

	# Default output: key=value pairs, one per line (non-deterministic order)
	{
		asa_print() { L_handle_v_asa "$@"; }
		asa_print_vL_ARET() { L_ARET=([k1]="v1" [k2]="v2"); }
		local out
		out=$(asa_print 2>/dev/null) || true
		L_unittest_contains "$out" "k1=v1"
		L_unittest_contains "$out" "k2=v2"
	}

	# -- path: output preserved, key=value pairs
	{
		asa_dd() { L_handle_v_asa "$@"; }
		asa_dd_vL_ARET() { L_ARET=([k]="v"); }
		local out
		out=$(asa_dd -- 2>/dev/null) || true
		L_unittest_contains "$out" "k=v"
	}

	# -- path: output preserved on non-zero return
	{
		asa_dd_err() { L_handle_v_asa "$@"; }
		asa_dd_err_vL_ARET() { L_ARET=([k]="v"); return 42; }
		local out
		out=$(asa_dd_err -- 2>/dev/null) || true
		L_unittest_contains "$out" "k=v"
		L_unittest_cmd -ce 42 asa_dd_err --
	}

	# -h help returns 0
	{
		asa_h() { L_handle_v_asa "$@"; }
		asa_h_vL_ARET() { :; }
		L_unittest_cmd -ce 0 asa_h -h
	}

	# Invalid variable names return non-zero
	{
		bad_asa() { L_handle_v_asa "$@"; }
		bad_asa_vL_ARET() { L_ARET=(); }
		L_unittest_cmd ! bad_asa -v 'rm -rf'
		L_unittest_cmd ! bad_asa -v '1bad'
		L_unittest_cmd ! bad_asa -v ''
	}

	# Empty assoc array → no output
	{
		asa_empty() { L_handle_v_asa "$@"; }
		asa_empty_vL_ARET() { L_ARET=(); }
		L_unittest_cmd -o '' asa_empty
	}

	# Exit code preserved from default path
	{
		asa_ec() { L_handle_v_asa "$@"; }
		asa_ec_vL_ARET() { L_ARET=([k]="v"); return 42; }
		L_unittest_cmd -ce 42 asa_ec
	}

	# --- Key with spaces: Bash 4.3+ handles correctly, Bash 4.0-4.2 does not ---
	if ((L_HAS_BASH4_3)); then
		{
			asa_sp() { L_handle_v_asa "$@"; }
			asa_sp_vL_ARET() { L_ARET=(["key with space"]="val with space"); }
			local out
			out=$(asa_sp 2>/dev/null) || true
			L_unittest_contains "$out" "key with space=val with space"
		}
	fi

	# --- -v path tests: differs by Bash version ---
	# -v path tests: differs by Bash version

	# -va (combined)
	{
		asa_v() { L_handle_v_asa "$@"; }
		asa_v_vL_ARET() { L_ARET=([k]="v"); }
		local -A a=([_]=_)
		L_unittest_cmd -c asa_v -va
		L_unittest_eq "${a[k]}" "v"
	}

	# -v var (separate args)
	{
		asa_v_sep() { L_handle_v_asa "$@"; }
		asa_v_sep_vL_ARET() { L_ARET=([k]="v"); }
		local -A a=([_]=_)
		L_unittest_cmd -c asa_v_sep -v a
		L_unittest_eq "${a[k]}" "v"
	}

	# -v var -- args
	{
		asa_v_args() { L_handle_v_asa "$@"; }
		asa_v_args_vL_ARET() { L_ARET=([k]="$1"); }
		local -A a=([_]=_)
		L_unittest_cmd -c asa_v_args -va -- extra
		L_unittest_eq "${a[k]}" "extra"
	}

	# -v L_ARET (special var, separate args)
	{
		asa_laret() { L_handle_v_asa "$@"; }
		asa_laret_vL_ARET() { L_ARET=([k]="v"); }
		local -A L_ARET=([_]=_)
		L_unittest_cmd -c asa_laret -v L_ARET
		L_unittest_eq "${L_ARET[k]}" "v"
	}

	# -vL_ARET (combined special var)
	{
		asa_lr_c() { L_handle_v_asa "$@"; }
		asa_lr_c_vL_ARET() { L_ARET=([k]="v"); }
		local -A L_ARET=([_]=_)
		L_unittest_cmd -c asa_lr_c -vL_ARET
		L_unittest_eq "${L_ARET[k]}" "v"
	}

	# -v var with non-zero return: exit code and value preserved
	{
		asa_v_err() { L_handle_v_asa "$@"; }
		asa_v_err_vL_ARET() { L_ARET=([k]="v"); return 42; }
		local -A a=([_]=_)
		L_unittest_cmd -ce 42 asa_v_err -va
		L_unittest_eq "${a[k]}" "v"
	}

	# --- Invalid -v* names return non-zero ---
	{
		bad_asa_vstar() { L_handle_v_asa "$@"; }
		bad_asa_vstar_vL_ARET() { L_ARET=(); }
		L_unittest_cmd ! bad_asa_vstar -v1bad
		L_unittest_cmd ! bad_asa_vstar -v'rm -rf'
	}

		# --- Exit code from -v path on success ---
	{
		asa_v_ok() { L_handle_v_asa "$@"; }
		asa_v_ok_vL_ARET() { L_ARET=([k]="v"); }
		local -A a=([_]=_)
		L_unittest_cmd -c asa_v_ok -va
		L_unittest_eq "${a[k]}" "v"
	}

	# Cleanup
	unset -f asa_print asa_print_vL_ARET
	unset -f asa_nona_pre asa_nona_pre_vL_ARET
	unset -f asa_nona_unset asa_nona_unset_vL_ARET
	unset -f asa_nona_scalar asa_nona_scalar_vL_ARET
	unset -f asa_nona_idx asa_nona_idx_vL_ARET
	unset -f asa_print asa_print_vL_ARET
	unset -f asa_dd asa_dd_vL_ARET
	unset -f asa_dd_err asa_dd_err_vL_ARET
	unset -f asa_h asa_h_vL_ARET
	unset -f bad_asa bad_asa_vL_ARET
	unset -f asa_empty asa_empty_vL_ARET
	unset -f asa_ec asa_ec_vL_ARET
	unset -f asa_sp asa_sp_vL_ARET
	unset -f asa_v asa_v_vL_ARET
	unset -f asa_v_sep asa_v_sep_vL_ARET
	unset -f asa_v_args asa_v_args_vL_ARET
	unset -f asa_laret asa_laret_vL_ARET
	unset -f asa_lr_c asa_lr_c_vL_ARET
	unset -f asa_v_err asa_v_err_vL_ARET
	unset -f bad_asa_vstar bad_asa_vstar_vL_ARET
	unset -f asa_v_ok asa_v_ok_vL_ARET
}

# -----------------------------------------------------------------------------
# Cross-function tests (non-asa only)
# -----------------------------------------------------------------------------
_L_test_a_handle_v_cross() {
	# Define helper function and callback that sets a known value
	local _f _f_impl _is_array _val
	for spec in 's:L_handle_v_scalar:scalar:s' 'a:L_handle_v_array:array:a\ b' 'si:L_handle_v_silent:silent:s'; do
		_f="${spec%%:*}"; rest="${spec#*:}"
		_f_impl="${rest%%:*}"; rest="${rest#*:}"
		_is_array="${rest%%:*}"; rest="${rest#*:}"
		_val="${rest}"

		# -h returns 0 for all three non-asa functions
		eval "${_f}_h() { ${_f_impl} \"\$@\"; }"
		eval "${_f}_h_vL_RET() { :; }"
		L_unittest_cmd -ce 0 "${_f}_h" -h

		# -vL_RET -- extra and -v L_RET -- extra: success with separator
		eval "${_f}_ret() { ${_f_impl} \"\$@\"; }"
		if [[ $_is_array == array ]]; then
			eval "${_f}_ret_vL_RET() { L_RET=(${_val}); }"
		else
			eval "${_f}_ret_vL_RET() { L_RET=\"${_val}\"; }"
		fi
		L_unittest_cmd -ce 0 "${_f}_ret" -vL_RET -- extra
		L_unittest_cmd -ce 0 "${_f}_ret" -v L_RET -- extra

		# Non-zero return preserved
		if [[ $_is_array == array ]]; then
			eval "${_f}_ret_err_vL_RET() { L_RET=(e1 e2); return 42; }"
		else
			eval "${_f}_ret_err_vL_RET() { L_RET=\"err\"; return 42; }"
		fi
		eval "${_f}_ret_err() { ${_f_impl} \"\$@\"; }"
		L_unittest_cmd -ce 42 "${_f}_ret_err" -vL_RET -- extra
		L_unittest_cmd -ce 42 "${_f}_ret_err" -v L_RET -- extra
	done

	# Output on non-zero return with -- separator
	{
		_x_dd_err() { L_handle_v_scalar "$@"; }
		_x_dd_err_vL_RET() { L_RET="dd_err"; return 42; }
		L_unittest_cmd -e 42 -o 'dd_err' _x_dd_err --
		_y_dd_err() { L_handle_v_array "$@"; }
		_y_dd_err_vL_RET() { L_RET=(d1 d2); return 42; }
		L_unittest_cmd -e 42 -o $'d1\nd2' _y_dd_err --
	}
	unset -f _x_dd_err _x_dd_err_vL_RET _y_dd_err _y_dd_err_vL_RET
}

# -----------------------------------------------------------------------------
# Cross-function tests (asa only)
# Skipped on Bash without associative arrays.
# -----------------------------------------------------------------------------
_L_test_a_handle_v_cross_asa() {
	if ((!L_HAS_ASSOCIATIVE_ARRAY)); then
		L_unittest_skip "L_handle_v_asa requires associative arrays (Bash 4.0+)"
		return 0
	fi
	# Define functions once; test all combinations of arguments
	asa_ok_kv() { L_handle_v_asa "$@"; }
	asa_ok_kv_vL_ARET() { (( $# == 0 )) || return 123; L_ARET=([k]="v"); }
	asa_20_kv() { L_handle_v_asa "$@"; }
	asa_20_kv_vL_ARET() { (( $# == 0 )) || return 123; L_ARET=([k]="v"); return 20; }
	# Helper: check key/value pairs in associative array
	assert_asa_eq() {
		local arr_name="$1"; shift
		local k v _val
		while (($#)); do
			k="$1"; v="$2"; shift 2
			eval "_val=\"\${${arr_name}[$k]:-}\""
			L_unittest_eq "$_val" "$v"
		done
	}

	# -h returns 0
	L_unittest_cmd -ce 0 asa_ok_kv -h
	# -h returns 0 for the other function too
	L_unittest_cmd -ce 0 asa_20_kv -h

	# -vL_ARET requires L_ARET be associative (unset → fail)
	unset L_ARET
	L_unittest_cmd -c ! asa_ok_kv -vL_ARET

	# -v asa requires asa be associative (unset → fail)
	L_unittest_cmd -c ! asa_ok_kv -v asa

	# declare -a (indexed) → should fail
	declare -a L_ARET asa
	L_unittest_cmd -c ! asa_ok_kv -vL_ARET
	L_unittest_cmd -c ! asa_ok_kv -v asa

	if (( L_HAS_BASH4_4 )); then
		local var dashbang
		for var in '-vL_ARET' '-vasa' '-v L_ARET' '-v asa'; do
			for dashbang in '' '--'; do
				unset L_ARET asa
				declare -A L_ARET asa
				L_unittest_cmd -c asa_ok_kv $var $dashbang
				if [[ $var == *asa* ]]; then
					assert_asa_eq asa k v
				else
					assert_asa_eq L_ARET k v
				fi
			done
		done
	fi

	# With pre-existing values → should overwrite
	for var in '-vL_ARET' '-vasa' '-v L_ARET' '-v asa'; do
		for dashbang in '' '--'; do
			unset L_ARET asa
			declare -A L_ARET=([k]=IGNORE) asa=([k]=IGNORE)
			L_unittest_cmd -c asa_ok_kv $var $dashbang
			if [[ $var == *asa* ]]; then
				assert_asa_eq asa k v
			else
				assert_asa_eq L_ARET k v
			fi
		done
	done

	# With pre-existing values + non-zero return → should overwrite and return 20
	for var in '-vL_ARET' '-vasa' '-v L_ARET' '-v asa'; do
		for dashbang in '' '--'; do
			unset L_ARET asa
			declare -A L_ARET=([k]=IGNORE) asa=([k]=IGNORE)
			L_unittest_cmd -ce 20 asa_20_kv $var $dashbang
			if [[ $var == *asa* ]]; then
				assert_asa_eq asa k v
			else
				assert_asa_eq L_ARET k v
			fi
		done
	done

	# -vL_ARET with extra args: OK path for 1 arg, FAIL path for wrong count
	asa_ok_arg() { L_handle_v_asa "$@"; }
	asa_ok_arg_vL_ARET() { L_ARET=([k]="${1-UNSET}"); (( $# == 1 )) || return 123; }
	declare -A L_ARET asa
	# OK path: exactly 1 arg → exit 0
	for var in '' '-vL_ARET' '-vasa' '-v L_ARET' '-v asa'; do
		for dashdash in '' '--'; do
			L_unittest_cmd -c asa_ok_arg $var $dashdash a
		done
	done
	# FAIL path: wrong number of args → exit 123
	for var in '' '-vL_ARET' '-vasa' '-v L_ARET' '-v asa'; do
		for dashdash in '' '--'; do
			L_unittest_cmd -ce123 asa_ok_arg $var $dashdash
			L_unittest_cmd -ce123 asa_ok_arg $var $dashdash a b
		done
	done

	unset -f asa_ok_kv asa_ok_kv_vL_ARET asa_20_kv asa_20_kv_vL_ARET
	unset -f asa_ok_arg asa_ok_arg_vL_ARET
	unset -f assert_asa_eq
}

# -----------------------------------------------------------------------------
# Tests: L_handle_v_asa with associative array variable (has 'A' attribute)
# 6 call patterns + -- separator extra test = 7 tests
# Note: initialized with a dummy element to work around ${var@a} unbound issue with set -u
# -----------------------------------------------------------------------------
_L_test_a_handle_v_asa_cross_asapos_assoc() {
	if ((!L_HAS_ASSOCIATIVE_ARRAY)); then
		L_unittest_skip "L_handle_v_asa requires associative arrays (Bash 4.0+)"
		return 0
	fi

	# Common test function and callback that sets a known key
	_p() { L_handle_v_asa "$@"; }
	_p_vL_ARET() { L_ARET=([k1]="v1" [k2]="v2"); }
	_p_check_keys() {
		local arr_name="$1"
		local v1="" v2=""
		eval "v1=\"\${${arr_name}[k1]:-}\""
		eval "v2=\"\${${arr_name}[k2]:-}\""
		[[ "$v1" == "v1" ]] && [[ "$v2" == "v2" ]]
	}

	# All 6 call patterns
	local var args j
	for spec in 'a:-v a' 'L_ARET:-v L_ARET' 'L_ARET:-vL_ARET' 'a:-va' 'L_RET:-v L_RET' 'L_RET:-vL_RET'; do
		for j in '' '--'; do
			var="${spec%%:*}"
			args="${spec#*:}"
			unset "$var" L_ARET
			eval "local -A ${var}=([_]=_)"
			if [[ $var == L_RET ]]; then
				_p $args $j
			else
				L_unittest_cmd -c _p $args $j
			fi
			_p_check_keys "$var" || L_unittest_fail "$args: k1=v1,k2=v2"
		done
	done

	# 7. -v var -- extra (separator passed to handler)
	_p_vL_ARET() { L_ARET=([k]="$1"); }
	declare -A a=([_]=_)
	L_unittest_cmd -c _p -v a -- extra
	[[ "${a[k]}" == "extra" ]] || L_unittest_fail "7: a[k]=extra"

	unset -f _p _p_vL_ARET
}

# -----------------------------------------------------------------------------
# Tests: L_handle_v_asa with non-associative variables (negative cases)
# 6 call patterns × 3 states (unset, scalar, indexed) = 18 tests
# -----------------------------------------------------------------------------
_L_handle_v_asa_neg() {
	local mode="$1"  # unset|scalar|indexed
	if ((!L_HAS_ASSOCIATIVE_ARRAY)); then
		L_unittest_skip "L_handle_v_asa requires associative arrays (Bash 4.0+)"
		return 0
	fi

	_n() { L_handle_v_asa "$@"; }
	# Should not get called at all.
	_n_vL_ARET() { exit 0; }

	local generic_var="_nona_$mode"
	local var args
	for var in "$generic_var" L_ARET L_RET; do
		case "$mode" in
			unset)  unset "$generic_var" L_ARET L_RET ;;
			scalar) local "$generic_var"="scalar_val"; local L_ARET="scalar_val"; local L_RET="scalar_val" ;;
			indexed) eval "local -a ${generic_var}=(first\ second)"; eval "local -a L_ARET=(first\ second)"; eval "local -a L_RET=(first\ second)" ;;
		esac
		for j in '' -- -- a; do
			L_unittest_cmd ! _n -v "$var" $j
			L_unittest_cmd ! _n -v"$var" $j
		done
	done

unset -f _n _n_vL_ARET
}
_L_test_a_handle_v_asa_neg_unset() { _L_handle_v_asa_neg unset; }
_L_test_a_handle_v_asa_neg_scalar() { _L_handle_v_asa_neg scalar; }
_L_test_a_handle_v_asa_neg_indexed() { _L_handle_v_asa_neg indexed; }


