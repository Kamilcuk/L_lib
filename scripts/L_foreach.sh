#!/bin/bash
# vim: foldmethod=marker foldmarker=[[[,]]] ft=bash
set -euo pipefail

. "${BASH_SOURCE[0]%/*}"/../bin/L_lib.sh

###############################################################################
# [[[

# @description
# @option -s output in sorted keys
# @option -r output in reverse sorted keys
# @option -n <num> Only one positional variable allowed. It is assigned num elements from the input as an array.
# @option -i <var> Store loop index in specified variable. First loop has index 0.
# @option -v <var> Store state in the variable, instead of picking unique name starting with _L_FOREACH_*.
# @option -k <var> Store key of the first element in specified variable.
# @option -f <var> First loop stores 1 into the variable, otherwise 0 is stored in the variable.
# @option -l <var> Last loop stores 1 into the variable, otherwise 0 is stored in the variable.
# @env _L_FOREACH
# @env _L_FOREACH_[0-9]+
# @example
#    local array1=(a b c d) array2=(d e f g)
#    local -A dict1=([a]=b [c]=d) dict2=([a]=e [c]=f)
#    while L_foreach a : array1; do echo $a; done  # a b c d
#    while L_foreach a b : array1; do echo $a,$b; done  # a,b c,d
#    while L_foreach a b : array1 array2; do echo $a,$b; done  # a,d b,e c,f g,d
#    while L_foreach a b c : array1 array2; do echo $a,$b; done  # error
#    while L_foreach -k k -i i a b : array1; do echo $k,$i,$a,$b; done  # 0,0,a,b 2,0,c,d
#    while L_foreach -n 3 a : array1; do echo ${#a[@]},${a[*]},; done  # 3,a b c, 1,d,
#    while L_foreach -n 3 a : dict1; do echo ${#a[@]},${a[*]},; done  # 2,? ?
#                            # ?=one of abcd. the order of elements is unknown in associative array
#    while L_foreach -s -k k a b : dict1 dict2; do echo $k,$a,$b; done  # a,b,e  c,d,f
L_foreach() {
  local OPTIND OPTERR OPTARG _L_opt_v="" _L_opt_s=0 _L_opt_r=0 _L_opt_i="" _L_opt_k=0 _L_opt_n="" _L_i _L_j
  while getopts n:sri:kv:h _L_i; do
    case "$_L_i" in
      n) _L_opt_n=$OPTARG ;;
      s) _L_opt_s=1 ;;
      r) _L_opt_r=1 ;;
      i) _L_opt_i=$OPTARG ;;
      k) _L_opt_k=$OPTARG ;;
      v) _L_opt_v=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_fund_error; return 2 ;;
    esac
  done
  shift "$((OPTIND-1))"
  # Pick variable name to store state in.
  if [[ -n "$_L_opt_v" ]]; then
    local _L_vidx=1
    local _L_context="${BASH_SOURCE[*]:_L_vidx}:${BASH_LINENO[*]:_L_vidx}:${FUNCNAME[*]:_L_vidx}"
    for (( _L_i = BASH_LINENO[1]; ; ++_L_i )); do
      _L_j=_L_FOREACH_$_L_i
      if [[ ${!_L_j:-} == "$_L_context"
    if ! L_array_index -v _L_vidx _L_FOREACH "$_L_context"; then
      _L_vidx=$(( ${_L_FOREACH[*]:+${#_L_FOREACH[*]}}+0 ))
      _L_FOREACH[_L_vidx]=$_L_context
    fi
    _L_opt_v=_L_FOREACH_$_L_vidx
  fi
  # Restore variables state.
  local _L_keys=() _L_vars=() _L_arrs=() _L_arridx=-1 _L_idx=-1
  eval "${!_L_opt_v:-}"
  # First run.
  if (( _L_arridx == -1 )); then
    # Parse arguments. Find position of :.
    for (( _L_arridx = $#; _L_arridx > 0; --_L_arridx )); do
      if [[ "${@:_L_arridx-1:1}" == ":" ]]; then
        break
      fi
    done
    if (( _L_arridx == 0 )); then
      L_panic "Doublepoint ':' not found in the arguments: $*"
    fi
  fi
  while (( _L_arridx <= $# )); do
    local -n _L_arr=${@:_L_arridx:1}
    # Sorted array keys are cached. Unsorted are not.
    if (( _L_s || _L_r )); then
      if (( _L_idx == -1 )); then
        _L_idx=0
        # Compute keys in the sorted order if requested.
        _L_keys=("${!_L_arr[@]}")
        if L_var_is_associative _L_arr; then
          if (( _L_r )); then
            L_sort_bash -r _L_keys
          else
            L_sort_bash _L_keys
          fi
        else
          if (( _L_r )); then
            L_array_reverse _L_keys
          fi
        fi
        # Store keys for later.
        printf -v _L_tmp " %q" "${_L_keys[@]}"
        printf -v "$_L_opt_v" "local _L_keys=(%s) _ _" "${_L_tmp## }"
      fi
    else
      if (( _L_idx == -1 )); then
        _L_idx=0
        printf -v "$_L_opt_v" "local _ _"
      fi
      _L_keys=("${!_L_arr[@]}")
    fi
    # If current _L_idx reached max of an array, increment the arrays index.
    if (( _L_idx >= ${#_L_arr[@]} )); then
      _L_arridx=$(( _L_arridx + 1 ))
      _L_idx=-1
      continue
    fi
    # Output.
    if L_var_is_set _L_i; then
      printf -v "$_L_i" "%d" "$_L_idx"
    fi
    while (( $# )) && [[ "$1" != ":" ]]; do
      if (( _L_k )); then
        printf -v "$1" "%s" "${_L_keys[_L_idx]}"
        shift
      fi
      printf -v "$1" "%s" "${_L_arr[${_L_keys[_L_idx]}]}"
      _L_idx=$(( _L_idx + 1 ))
      shift
    done
    # Store index.
    printf -v "$_L_opt_v" "%s _L_arridx=%d _L_idx=%d" "${!_L_opt_v% * *}" "$_L_arridx" "$_L_idx"
    # Yield
    return 0
  done
  # The end - we iterated over all arrays in the list.
  return 4
}

_L_test_foreach_1() {
  {
    L_log "test sorted array L_foreach"
    local arr=(a b c d e) i a k acc=()
    while L_foreach -i i -k k a : arr; do
      acc+=("$i" "$k" "$a")
    done
    L_unittest_arreq acc 0 0 a 1 1 b 2 2 c 3 3 d 4 4 e
  }
  {
    L_log "test dict L_foreach"
    local -A dict=(a b c d e)
    local i k a acc=() j=0
    while L_foreach -i i -k k a : dict; do
      L_unittest_eq "${dict[$k]}" "$a"
      L_unittest_vareq j "$i"
      j=$(( j + 1 ))
    done
  }
  {
    L_log "test sorted dict L_foreach"
    local -A dict=(a b c d e)
    local i k a acc=()
    while L_foreach -s -i i -k j a : dict; do
      acc+=("$i" "$j" "$a")
    done
    L_unittest_arreq acc 0 a b 1 c d 2 e ''
  }
}

_L_test_foreach_2() {
  {
    local arr=(a b c d e) other=(1 2 3 4) i a k acc=()
    while L_foreach -i i -k k a : arr; do
      acc+=("$i" "$k" "$a")
    done
    L_unittest_arreq acc 0 0 a 1 1 b 2 2 c 3 3 d 4 4 e
  }
  {
    L_log "test dict L_foreach"
    local -A dict=(a b c d e)
    local i k a acc=() j=0
    while L_foreach -i i -k k a : dict; do
      L_unittest_eq "${dict[$k]}" "$a"
      L_unittest_vareq j "$i"
      j=$(( j + 1 ))
    done
  }
  {
    L_log "test sorted dict L_foreach"
    local -A dict=(a b c d e)
    local i k a acc=()
    while L_foreach -s -i i -k j a : dict; do
      acc+=("$i" "$j" "$a")
    done
    L_unittest_arreq acc 0 a b 1 c d 2 e ''
  }
}

# ]]]
###############################################################################


if L_is_main; then
  _L_test_foreach_1
  _L_test_foreach_2
fi
