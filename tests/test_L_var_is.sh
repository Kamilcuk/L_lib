# @description Tests for L_var_is_* variable attribute inspection functions.
#
# Functions tested:
#   L_var_is_set, L_var_is_notnull, L_var_is_scalar, L_var_is_array,
#   L_var_is_readonly, L_var_is_integer, L_var_is_exported, L_var_is_associative
#
# Note: L_var_is_set and L_var_is_notnull use ${!1+y} / ${!1:+y} indirect
# expansion, which for arrays checks element [0]. Empty arrays and associative
# arrays without key "0" are therefore considered "not set" / "null" by these
# functions. This is tested as actual behavior.

###############################################################################
# Tests - variables declared locally in each function with unique var_* names
###############################################################################

_skip_if_not_bash() {
	if (( !L_HAS_BASH${1//./_} )); then
		L_unittest_skip "requires Bash $1+"
		exit 0
	fi
}

_L_test_L_var_is_basic() {
	{
		unset a
		local a="declare -r a"
		L_unittest_checkexit 1 L_var_is_readonly a
		local -r b="declare b"
		L_unittest_checkexit 0 L_var_is_readonly b
	}
	if ((L_HAS_ASSOCIATIVE_ARRAY)); then
		unset c
		L_unittest_checkexit 1 L_var_is_associative c
		local -A c=(["declare -r c"]="declare -r c")
		L_unittest_checkexit 0 L_var_is_associative c
		if (( L_HAS_BASH4_4 )); then
			unset c
			local -A c
			L_unittest_checkexit 0 L_var_is_associative c
		fi
	fi
	{
		unset d
		L_unittest_checkexit 1 L_var_is_array d
		L_unittest_checkexit 1 L_var_is_scalar d
		local -a d=("declare -r d")
		L_unittest_checkexit 0 L_var_is_array d
		L_unittest_checkexit 1 L_var_is_scalar d
	}
	{
		unset e
		L_unittest_checkexit 1 L_var_is_exported e
		local e="declare -r e"
		L_unittest_checkexit 1 L_var_is_exported e
		export e
		L_unittest_checkexit 0 L_var_is_exported e
		unset e
	}
	{
		L_unittest_checkexit 1 L_var_is_set _L_variable
		local _L_variable
		if ((L_HAS_BASH4_0)); then
			# In bash 3.2 local sets the variable to empty. On newers it doesn't set.
			L_unittest_checkexit 1 L_var_is_set _L_variable
		fi
		_L_variable=
		L_unittest_checkexit 0 L_var_is_set _L_variable
		_L_variable=""
		L_unittest_checkexit 0 L_var_is_set _L_variable
		_L_variable="a"
		L_unittest_checkexit 0 L_var_is_set _L_variable
	}
}

_L_test_var_is_set() {
	local var_set="value" var_empty=""
	local -a var_arr_full=(elem) var_arr_empty=() var_arr_decl
	local -a var_arr_sparse=([1]="sparse")
	unset var_unset var_arr_unset
	L_unittest_checkexit 1 L_var_is_set var_unset
	L_unittest_checkexit 0 L_var_is_set var_empty
	L_unittest_checkexit 0 L_var_is_set var_set
	L_unittest_checkexit 1 L_var_is_set var_arr_decl
	L_unittest_checkexit 1 L_var_is_set var_arr_empty
	L_unittest_checkexit 1 L_var_is_set var_arr_sparse
	L_unittest_checkexit 0 L_var_is_set var_arr_full
}

_L_test_var_is_set_decl() {
	_skip_if_not_bash 4.0
	local var_decl
	L_unittest_checkexit 1 L_var_is_set var_decl
}

_L_test_var_is_set_associative() {
	_skip_if_not_bash 4.0
	local -A var_assoc_set_full=([0]="v") var_assoc_set_empty=() var_assoc_set_decl
	unset var_assoc_set_unset
	L_unittest_checkexit 1 L_var_is_set var_assoc_set_unset
	L_unittest_checkexit 1 L_var_is_set var_assoc_set_decl
	L_unittest_checkexit 1 L_var_is_set var_assoc_set_empty
	L_unittest_checkexit 0 L_var_is_set var_assoc_set_full
}

_L_test_var_is_notnull() {
	local var_set="value" var_empty="" 
	local -a var_arr_full=(elem) var_arr_empty=() var_arr_decl
	local -a var_arr_sparse=([1]="sparse")
	unset var_unset var_arr_unset
	L_unittest_checkexit 1 L_var_is_notnull var_unset
	L_unittest_checkexit 1 L_var_is_notnull var_empty
	L_unittest_checkexit 0 L_var_is_notnull var_set
	L_unittest_checkexit 1 L_var_is_notnull var_arr_decl
	L_unittest_checkexit 1 L_var_is_notnull var_arr_empty
	L_unittest_checkexit 1 L_var_is_notnull var_arr_sparse
	L_unittest_checkexit 0 L_var_is_notnull var_arr_full
}

_L_test_var_is_notnull_decl() {
	_skip_if_not_bash 4.0
	local var_decl
	# Bash 4.0+: local declares but doesn't set
	L_unittest_checkexit 1 L_var_is_notnull var_decl
}

_L_test_var_is_notnull_associative() {
	_skip_if_not_bash 4.0
	local -A var_assoc_set_full=([0]="v") var_assoc_set_empty=() var_assoc_set_decl
	unset var_assoc_set_unset
	L_unittest_checkexit 1 L_var_is_notnull var_assoc_set_unset
	L_unittest_checkexit 1 L_var_is_notnull var_assoc_set_decl
	L_unittest_checkexit 1 L_var_is_notnull var_assoc_set_empty
	L_unittest_checkexit 0 L_var_is_notnull var_assoc_set_full
}

_L_test_var_is_notarray() {
	local var_set="value" var_empty="" 
	local -a var_arr_full=(elem) var_arr_empty=() var_arr_decl
	unset var_unset var_arr_unset
	L_unittest_checkexit 1 L_var_is_scalar var_unset
	L_unittest_checkexit 0 L_var_is_scalar var_empty
	L_unittest_checkexit 0 L_var_is_scalar var_set
	if ((L_HAS_QEPAa_EXPANSIONS)); then
		L_unittest_checkexit 1 L_var_is_scalar var_arr_decl
	fi
	L_unittest_checkexit 1 L_var_is_scalar var_arr_empty
	L_unittest_checkexit 1 L_var_is_scalar var_arr_full
}

_L_test_var_is_notarray_associative() {
	_skip_if_not_bash 4.0
	local -A var_assoc_full=([k]="v") var_assoc_empty=() var_assoc_decl
	unset var_assoc_unset
	L_unittest_checkexit 1 L_var_is_scalar var_assoc_unset
	L_unittest_checkexit 1 L_var_is_scalar var_assoc_decl
	L_unittest_checkexit 1 L_var_is_scalar var_assoc_empty
	L_unittest_checkexit 1 L_var_is_scalar var_assoc_full
}

_L_test_var_is_array() {
	local var_set="value" var_empty="" 
	local -a var_arr_full=(elem) var_arr_empty=()
	unset var_unset var_arr_unset
	L_unittest_checkexit 1 L_var_is_array var_unset
	L_unittest_checkexit 1 L_var_is_array var_empty
	L_unittest_checkexit 1 L_var_is_array var_set
	L_unittest_checkexit 0 L_var_is_array var_arr_empty
	L_unittest_checkexit 0 L_var_is_array var_arr_full
}

_L_test_var_is_array_decl() {
	_skip_if_not_bash 4.0
	local var_decl
	L_unittest_checkexit 1 L_var_is_array var_decl
}

_L_test_var_is_array_associative() {
	_skip_if_not_bash 4.0
	local -A var_assoc_full=([k]="v") var_assoc_empty=() var_assoc_decl
	unset var_assoc_unset
	L_unittest_checkexit 1 L_var_is_array var_assoc_unset
	L_unittest_checkexit 1 L_var_is_array var_assoc_decl
	L_unittest_checkexit 1 L_var_is_array var_assoc_empty
	L_unittest_checkexit 1 L_var_is_array var_assoc_full
}

_L_test_var_is_associative() {
	local var_set="value" var_empty=""
	local -a var_arr_full=(elem) var_arr_empty=() var_arr_decl
	unset var_unset var_arr_unset
	L_unittest_checkexit 1 L_var_is_associative var_unset
	L_unittest_checkexit 1 L_var_is_associative var_empty
	L_unittest_checkexit 1 L_var_is_associative var_set
	L_unittest_checkexit 1 L_var_is_associative var_arr_decl
	L_unittest_checkexit 1 L_var_is_associative var_arr_empty
	L_unittest_checkexit 1 L_var_is_associative var_arr_full
}

_L_test_var_is_associative_decl() {
	_skip_if_not_bash 4.0
	local var_decl
	L_unittest_checkexit 1 L_var_is_associative var_decl
}

_L_test_var_is_associative_associative() {
	_skip_if_not_bash 4.0
	local -A var_assoc_full=([k]="v") var_assoc_empty=() 
	unset var_assoc_unset
	L_unittest_checkexit 1 L_var_is_associative var_assoc_unset
	L_unittest_checkexit 0 L_var_is_associative var_assoc_empty
	L_unittest_checkexit 0 L_var_is_associative var_assoc_full
}

_L_test_var_is_associative_assoc_decl() {
	_skip_if_not_bash 4.4
	local -A var_assoc_decl
	L_unittest_checkexit 0 L_var_is_associative var_assoc_decl
}

_L_test_var_is_readonly() {
	local var_set="value" var_empty="" 
	local -a var_arr_empty=() var_arr_decl
	local -r var_ro_scalar="value"
	local -ar var_ro_arr=()
	unset var_unset var_arr_unset
	L_unittest_checkexit 1 L_var_is_readonly var_unset
	L_unittest_checkexit 1 L_var_is_readonly var_empty
	L_unittest_checkexit 1 L_var_is_readonly var_set
	L_unittest_checkexit 0 L_var_is_readonly var_ro_scalar
	L_unittest_checkexit 1 L_var_is_readonly var_arr_decl
	L_unittest_checkexit 1 L_var_is_readonly var_arr_empty
	L_unittest_checkexit 0 L_var_is_readonly var_ro_arr
}

_L_test_var_is_readonly_decl() {
	_skip_if_not_bash 4.0
	local var_decl
	L_unittest_checkexit 1 L_var_is_readonly var_decl
}

_L_test_var_is_readonly_arr_decl() {
	_skip_if_not_bash 4.0
	local -a var_arr_decl
	L_unittest_checkexit 1 L_var_is_readonly var_arr_decl
}

_L_test_var_is_readonly_associative() {
	_skip_if_not_bash 4.0
	local -A var_assoc_empty=()
	local -Ar var_ro_assoc=()
	unset var_assoc_unset
	L_unittest_checkexit 1 L_var_is_readonly var_assoc_unset
	L_unittest_checkexit 1 L_var_is_readonly var_assoc_empty
	L_unittest_checkexit 0 L_var_is_readonly var_ro_assoc
}

_L_test_var_is_readonly_assoc_decl() {
	_skip_if_not_bash 4.0
	local -A var_assoc_decl
	L_unittest_checkexit 1 L_var_is_readonly var_assoc_decl
}

_L_test_var_is_integer() {
	local var_set="notinteger" var_empty="" 
	local -i var_int_scalar=42
	local -a var_arr_empty=() var_arr_decl
	local -ia var_int_arr=()
	unset var_unset var_arr_unset
	L_unittest_checkexit 1 L_var_is_integer var_unset
	L_unittest_checkexit 1 L_var_is_integer var_empty
	L_unittest_checkexit 1 L_var_is_integer var_set
	L_unittest_checkexit 0 L_var_is_integer var_int_scalar
	L_unittest_checkexit 1 L_var_is_integer var_arr_decl
	L_unittest_checkexit 1 L_var_is_integer var_arr_empty
	L_unittest_checkexit 0 L_var_is_integer var_int_arr
}

# Scalar declared-unassigned (var_decl) - scalar without -i is never integer
_L_test_var_is_integer_decl() {
	local var_decl
	L_unittest_checkexit 1 L_var_is_integer var_decl
}

_L_test_var_is_integer_arr_decl() {
	_skip_if_not_bash 4.0
	local -a var_arr_decl
	L_unittest_checkexit 1 L_var_is_integer var_arr_decl
}

_L_test_var_is_integer_associative() {
	_skip_if_not_bash 4.0
	local -A var_assoc_empty=() var_assoc_decl
	local -iA var_int_assoc=()
	unset var_assoc_unset
	L_unittest_checkexit 1 L_var_is_integer var_assoc_unset
	L_unittest_checkexit 1 L_var_is_integer var_assoc_decl
	L_unittest_checkexit 1 L_var_is_integer var_assoc_empty
	L_unittest_checkexit 0 L_var_is_integer var_int_assoc
}

# --- L_var_is_exported ---
_L_test_var_is_exported() {
	local var_set="value" var_empty="" var_decl
	local var_exp_scalar="value"
	export var_exp_scalar
	local -a var_arr_empty=() var_arr_decl
	local -ax var_exp_arr=()
	unset var_unset var_arr_unset
	L_unittest_checkexit 1 L_var_is_exported var_unset
	L_unittest_checkexit 1 L_var_is_exported var_decl
	L_unittest_checkexit 1 L_var_is_exported var_empty
	L_unittest_checkexit 1 L_var_is_exported var_set
	L_unittest_checkexit 0 L_var_is_exported var_exp_scalar
	L_unittest_checkexit 1 L_var_is_exported var_arr_decl
	L_unittest_checkexit 1 L_var_is_exported var_arr_empty
	L_unittest_checkexit 0 L_var_is_exported var_exp_arr
}

_L_test_var_is_exported_associative() {
	_skip_if_not_bash 4.0
	local -A var_assoc_exp_empty=() var_assoc_exp_decl
	local -Ax var_exp_assoc=()
	unset var_assoc_exp_unset
	L_unittest_checkexit 1 L_var_is_exported var_assoc_exp_unset
	L_unittest_checkexit 1 L_var_is_exported var_assoc_exp_decl
	L_unittest_checkexit 1 L_var_is_exported var_assoc_exp_empty
	L_unittest_checkexit 0 L_var_is_exported var_exp_assoc
}
