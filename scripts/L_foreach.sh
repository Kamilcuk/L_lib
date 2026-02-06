#!/bin/bash
# vim: foldmethod=marker foldmarker=[[[,]]] ft=bash
set -euo pipefail

. "${BASH_SOURCE[0]%/*}"/../bin/L_lib.sh

###############################################################################
# [[[

# @description Iterate over elements of an array by assigning it to variables.
#
# Each loop the arguments to the function are REQUIRED to be exactly the same.
#
# The function takes positional arguments in the form:
# - at least one variable name to assign to,
# - followed by a required ':' colon character,
# - followed by at least one array variable to iterate over.
#
# Without -k option:
#   - For each array variable:
#     - If -s option, sort array keys.
#     - For each element in the array:
#       - Assign the element to the variables in order.
#
# With -k option:
#   - Accumulate all keys of all arrays into a set of keys.
#   - If -s option, sort the set.
#   - For each value in the set of keys:
#     - Assign the values of each array[key] to corresponding variable.
#
# @option -s Output in sorted keys order. Does nothing on non-associative arrays.
# @option -r Output in reverse sorted keys order. Implies -s.
# @option -n <num> Each variable name is repeated as an array variable with indexes from 0 to num-1.
#                  For example: '-n 3 a : arr' is equal to 'a[0] a[1] a[2] : arr'.
# @option -i <var> Store loop index in specified variable. First loop has index 0.
# @option -v <var> Store state in the variable, instead of picking unique name starting with _L_FOREACH_*.
# @option -k <var> Store key of the first element in specified variable.
# @option -f <var> First loop stores 1 into the variable, otherwise 0 is stored in the variable.
# @option -l <var> Last loop stores 1 into the variable, otherwise 0 is stored in the variable.
# @option h Print this help and return 0.
# @arg $@ Variable names to assign, followed by : colon character, followed by arrays variables.
# @env _L_FOREACH
# @env _L_FOREACH_[0-9]+
# @return 0 if iteration should be continued,
#         1 on interanl error,
#         2 on usage error,
#         4 if iteration should stop.
# @example
#    local array1=(a b c d) array2=(d e f g)
#    while L_foreach a : array1; do echo $a; done  # a b c d
#    while L_foreach a b : array1; do echo $a,$b; done  # a,b c,d
#    while L_foreach a b : array1 array2; do echo $a,$b; done  # a,d b,e c,f g,d
#    while L_foreach a b c : array1 array2; do echo $a,$b; done  # a,d,b e,c,f g,d,<unset>
#    while L_foreach -n 3 a : array1; do echo ${#a[@]},${a[*]},; done  # 3,a b c, 1,d,
#
#    local -A dict1=([a]=b [c]=d) dict2=([a]=e [c]=f)
#    while L_foreach -n 3 a : dict1; do echo ${#a[@]},${a[*]},; done  # 2,b d or 2,d b
#                            # the order of elements is unknown in associative arrays
#    while L_foreach -s -k k a b : dict1 dict2; do echo $k,$a,$b; done  # a,b,e  c,d,f
#    while L_foreach -s -k k a b : dict1 dict2; do echo $k,$a,$b; done  # a,b,e  c,d,f
L_foreach() {
  local OPTIND OPTERR OPTARG \
    _L_opt_v="" _L_opt_s=0 _L_opt_r=0 _L_opt_n="" _L_opt_i="" _L_opt_v="" _L_opt_k="" _L_opt_f="" _L_opt_l="" \
    _L_i IFS=' ' \
    _L_s_keys _L_s_loopidx=0 _L_s_colon=1 _L_s_arridx=0 _L_s_idx=0
  while getopts srn:i:v:k:f:l:h _L_i; do
    case "$_L_i" in
      s) _L_opt_s=1 ;;
      r) _L_opt_r=1 ;;
      n) _L_opt_n=$OPTARG ;;
      i) _L_opt_i=$OPTARG ;;
      v) _L_opt_v=$OPTARG ;;
      k) _L_opt_k=$OPTARG ;;
      f) _L_opt_f=$OPTARG ;;
      l) _L_opt_l=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_error; return 2 ;;
    esac
  done
  shift "$((OPTIND-1))"
  # Pick variable name to store state in.
  if [[ -z "$_L_opt_v" ]]; then
    local _L_context="${BASH_SOURCE[*]}:${BASH_LINENO[*]}:${FUNCNAME[*]}"
    # Find the context inside _L_FOREACH array.
    if ! L_array_index -v _L_vidx _L_FOREACH "$_L_context"; then
      # If not found, add it.
      _L_vidx=$(( ${_L_FOREACH[*]:+${#_L_FOREACH[*]}}+0 ))
      _L_FOREACH[_L_vidx]=$_L_context
    fi
    _L_opt_v=_L_FOREACH_$_L_vidx
  fi
  # Restore variables state.
  eval "${!_L_opt_v:-}"
  # First run.
  if (( _L_s_loopidx == 0 )); then
    # Parse arguments. Find position of :.
    while (( _L_s_colon <= $# )) && [[ "${!_L_s_colon}" != ":" ]]; do
      _L_s_colon=$(( _L_s_colon + 1 ))
    done
    if (( _L_s_colon > $# )); then
      L_panic "Colon ':' not found in the arguments: $*"
    fi
    # If -k option, accumulate all keys into one set.
    if [[ -n "$_L_opt_k" ]]; then
      local -n _L_arr
      for _L_arr in "${@:_L_s_colon + 1}"; do
        for _L_i in "${!_L_arr[@]}"; do
          if ! L_array_contains _L_s_keys "$_L_i"; then
            _L_s_keys+=("$_L_i")
          fi
        done
      done
      if (( _L_opt_r )); then
        L_sort_bash -r _L_s_keys
      elif (( _L_opt_s )); then
        L_sort_bash _L_s_keys
      fi
    fi
  fi
  local _L_vars=("${@:1:_L_s_colon - 1}") _L_arrs=("${@:_L_s_colon + 1}")
  if (( _L_opt_n > 1 )); then
    # If -n options is given, repeat each variable with assignment as an array with indexes.
    # _L_vars=(a b) n=3 -> _L_vars=(a[0] a[1] a[2] b[0] b[1] [2])
    eval eval \''_L_vars=('\' \\\"\\\${_L_vars[{0..$(( ${#_L_vars} - 1))}]}[{0..$(( _L_opt_n - 1 ))}]\\\" \'')'\'
  fi
  local _L_varslen=${#_L_vars[*]} _L_arrslen=${#_L_arrs[*]}
  if [[ -n "$_L_opt_k" ]]; then
    if (( _L_s_idx >= ${_L_s_keys[*]:+${#_L_s_keys[*]}}+0 )); then
      return 4
    fi
    local _L_key=${_L_s_keys[_L_s_idx++]}
    printf -v "$_L_opt_k" "%s" "$_L_key"
    # With -k option, stuff is vertical.
    if (( _L_varslen == 1 )); then
      # When there is one variable, it is an array with the results.
      for (( _L_i = 0; _L_i < _L_arrslen; ++_L_i )); do
        local -n _L_arr=${_L_arrs[_L_i]}
        if [[ -v _L_arr[$_L_key] ]]; then
          printf -v "${_L_vars[_L_i]}" "%s" "${_L_arr[$_L_key]}"
        fi
      done
    else
      # Otherwise, extra arrays are just ignored.
      for (( _L_i = 0; _L_i < _L_varslen && _L_i < _L_arrslen; ++_L_i )); do
        local -n _L_arr=${_L_arrs[_L_i]}
        if [[ -v _L_arr[$_L_key] ]]; then
          printf -v "${_L_vars[_L_i]}" "%s" "${_L_arr[$_L_key]}"
        else
          unset -v "${_L_vars[_L_i]}"
        fi
      done
    fi
    if [[ -n "$_L_opt_l" ]]; then
      printf -v "$_L_opt_l" "%s" "$(( _L_s_idx >= ${#_L_s_keys[*]} ))"
    fi
  else
    # Without -k option, stuff is horizontal.
    local _L_varsidx=0
    # For each array.
    while (( _L_s_arridx < _L_arrslen )); do
      local -n _L_arr=${_L_arrs[_L_s_arridx]}
      # L_debug "_L_s_idx=${_L_s_idx} arridx=$_L_s_arridx arrslen=$_L_arrslen arrayvar=${_L_arrs[_L_s_arridx]}"
      # Sorted array keys are cached. Unsorted are not.
      if (( _L_opt_s || _L_opt_r )); then
        if (( _L_s_idx == 0 )); then
          # Compute keys in the sorted order if requested.
          _L_s_keys=("${!_L_arr[@]}")
          if L_var_is_associative _L_arr; then
            if (( _L_opt_r )); then
              L_sort_bash -r _L_s_keys
            elif (( _L_opt_s )); then
              L_sort_bash _L_s_keys
            fi
          else
            if (( _L_opt_r )); then
              L_array_reverse _L_s_keys
            fi
          fi
          local -n _L_keys=_L_s_keys
        fi
      else
        local _L_keys=("${!_L_arr[@]}")
      fi
      # For each element in the array.
      while (( _L_s_idx < ${_L_arr[*]:+${#_L_arr[*]}}+0 )); do
        if (( _L_varsidx >= ${#_L_vars[*]} )); then
          # L_debug "Assigned all variables from the list. ${_L_varsidx} vars=[${#_L_vars[*]}]"
          break 2
        fi
        # L_debug "Set varsidx=$_L_varsidx var=${_L_vars[_L_varsidx]} val=${_L_arr[${_L_keys[_L_s_idx]}]} key=${_L_keys[_L_s_idx]}"
        if [[ -v _L_arr[${_L_keys[_L_s_idx]}] ]]; then
          printf -v "${_L_vars[_L_varsidx++]}" "%s" "${_L_arr[${_L_keys[_L_s_idx]}]}"
        else
          unset -v "${_L_vars[_L_varsidx++]}"
        fi
        _L_s_idx=$(( _L_s_idx + 1 ))
      done
      _L_s_idx=0
      _L_s_arridx=$(( _L_s_arridx + 1 ))
    done
    #
    if (( _L_varsidx == 0 )); then
      # Means no variables were assigned -> end the loop.
      return 4
    fi
    if [[ -n "$_L_opt_l" ]]; then
      if (( _L_s_arridx > _L_arrslen )); then
        # Loop ends when we looped through all the arrays, i.e. condition from the 'while' loop above.
        # L_debug "set -l arridx=$_L_s_arridx arrslen=$_L_arrslen varsidx=$_L_varsidx"
        printf -v "$_L_opt_l" 1
      else
        # Or when on the next loop we would finish. Which means we have to calculate all remaining elements.
        local _L_todo=-$_L_s_idx  # Substract the count processed in the current array.
        for (( _L_i = _L_s_arridx; _L_i < _L_arrslen; ++_L_i )); do
          local -n _L_arr=${_L_arrs[_L_i]}
          if (( ( _L_todo += ${#_L_arr[*]} ) > 0 )); then
            break
          fi
        done
        # L_debug "set -l todo=$_L_todo varslen=$_L_varslen val=$(( _L_todo < _L_varslen )) arridx=$_L_s_arridx arrslen=$_L_arrslen varsidx=$_L_varsidx idx=$_L_s_idx"
        printf -v "$_L_opt_l" "%s" "$(( _L_todo <= 0 ))"
      fi
    fi
    # Unset rest of variables that have not been assigned.
    while (( _L_varsidx < ${#_L_vars[*]} )); do
      unset -v "${_L_vars[_L_varsidx++]}"
    done
  fi
  if [[ -n "$_L_opt_f" ]]; then
    printf -v "$_L_opt_f" "%s" "$(( _L_s_loopidx == 0 ))"
  fi
  if [[ -n "$_L_opt_i" ]]; then
    printf -v "$_L_opt_i" "%s" "$_L_s_loopidx"
  fi
  # Serialize and store state.
  printf -v _L_i "${_L_s_keys[*]:+%q} " "${_L_s_keys[@]}"
  printf -v "$_L_opt_v" "local _L_s_keys=(%s) _L_s_loopidx=%d _L_s_colon=%d _L_s_arridx=%d _L_s_idx=%d" \
    "${_L_i%% }" "$(( _L_s_loopidx + 1 ))" "$_L_s_colon" "$_L_s_arridx" "$_L_s_idx"
  # L_debug "State:${!_L_opt_v}"
  # Yield
}

_L_test_foreach_1_all() {
  local array1=(a b c d) array2=(e f g h)
  L_log "Test simple one or two vars in array"
  L_unittest_cmd -o 'a:b:c:d:' \
    eval 'while L_foreach a : array1; do echo -n $a:; done'
  L_unittest_cmd -o 'a,b:c,d:' \
    eval 'while L_foreach a b : array1; do echo -n $a,$b:; done'
  L_unittest_cmd -o 'a,b:c,d:e,f:g,h:' \
    eval 'while L_foreach a b : array1 array2; do echo -n $a,$b:; done'
  L_unittest_cmd -o 'a,b,c:d,e,f:g,h,unset:' \
    eval 'while L_foreach a b c : array1 array2; do echo -n $a,$b,${c:-unset}:; done'
  L_unittest_cmd -o '3,a b c:1,d:' \
    eval 'while L_foreach -n 3 a : array1; do echo -n ${#a[@]},${a[*]}:; done'

  L_log "Test pairs of arrays"
  L_unittest_cmd -o 'a,e:b,f:c,g:d,h:' \
    eval 'while L_foreach -s -k _ a b : array1 array2; do echo -n $a,$b:; done'
  L_unittest_cmd -o '0,a,e:1,b,f:2,c,g:3,d,h:' \
    eval 'while L_foreach -s -k k a b : array1 array2; do echo -n $k,$a,$b:; done'
  L_unittest_cmd -o '3,d,h:2,c,g:1,b,f:0,a,e:' \
    eval 'while L_foreach -r -k k a b : array1 array2; do echo -n $k,$a,$b:; done'

  L_log "Test associative arrays"
  local -A dict1=([a]=b [c]=d) dict2=([a]=e [c]=f)
  L_unittest_cmd -o '2,d b:' \
    eval 'while L_foreach -n 3 a : dict1; do echo -n ${#a[@]},${a[*]}:; done'
  L_unittest_cmd -o 'a,b,e:c,d,f:' \
    eval 'while L_foreach -s -k k a b : dict1 dict2; do echo -n $k,$a,$b:; done'
  L_unittest_cmd -o 'a,b,e:c,d,f:' \
    eval 'while L_foreach -s -k k a b : dict1 dict2; do echo -n $k,$a,$b:; done'
 }

_L_test_foreach_2_all_index_first_last() {
  local array1=(a b c d) array2=(e f g h)
  L_log "Test simple one or two vars in array"
  L_unittest_cmd -o '010,a:100,b:200,c:301,d:' \
    eval 'while L_foreach -ii -ff -ll a : array1; do echo -n $i$f$l,$a:; done'
  L_unittest_cmd -o '010,a,b:101,c,d:' \
    eval 'while L_foreach -ii -ff -ll a b : array1; do echo -n $i$f$l,$a,$b:; done'
  L_unittest_cmd -o '010,a,b:100,c,d:200,e,f:301,g,h:' \
    eval 'while L_foreach -ii -ff -ll a b : array1 array2; do echo -n $i$f$l,$a,$b:; done'
  L_unittest_cmd -o '010,a,b,c:100,d,e,f:201,g,h,unset:' \
    eval 'while L_foreach -ii -ff -ll a b c : array1 array2; do echo -n $i$f$l,$a,$b,${c:-unset}:; done'
  L_unittest_cmd -o '010,3,a b c:101,1,d:' \
    eval 'while L_foreach -ii -ff -ll -n 3 a : array1; do echo -n $i$f$l,${#a[@]},${a[*]}:; done'

  L_log "Test pairs of arrays"
  L_unittest_cmd -o '010,a,e:100,b,f:200,c,g:301,d,h:' \
    eval 'while L_foreach -ii -ff -ll -s -k _ a b : array1 array2; do echo -n $i$f$l,$a,$b:; done'
  L_unittest_cmd -o '010,0,a,e:100,1,b,f:200,2,c,g:301,3,d,h:' \
    eval 'while L_foreach -ii -ff -ll -s -k k a b : array1 array2; do echo -n $i$f$l,$k,$a,$b:; done'
  L_unittest_cmd -o '010,3,d,h:100,2,c,g:200,1,b,f:301,0,a,e:' \
    eval 'while L_foreach -ii -ff -ll -r -k k a b : array1 array2; do echo -n $i$f$l,$k,$a,$b:; done'

  L_log "Test associative arrays"
  local -A dict1=([a]=b [c]=d) dict2=([a]=e [c]=f)
  L_unittest_cmd -o '011,2,d b:' \
    eval 'while L_foreach -ii -ff -ll -n 3 a : dict1; do echo -n $i$f$l,${#a[@]},${a[*]}:; done'
  L_unittest_cmd -o '010,a,b,e:101,c,d,f:' \
    eval 'while L_foreach -ii -ff -ll -s -k k a b : dict1 dict2; do echo -n $i$f$l,$k,$a,$b:; done'
  L_unittest_cmd -o '010,a,b,e:101,c,d,f:' \
    eval 'while L_foreach -ii -ff -ll -s -k k a b : dict1 dict2; do echo -n $i$f$l,$k,$a,$b:; done'
 }


_L_test_foreach_3_normal() {
  local arr=(a b c d e) i a k acc=() acc1=() acc2=()
  {
    L_log "test simple"
    while L_foreach a : arr; do
      acc+=("$a")
    done
    L_unittest_arreq acc a b c d e
  }
  {
    L_log "test simple two"
    while L_foreach a b : arr; do
      acc1+=("$a")
      acc2+=("${b:-unset}")
    done
    L_unittest_arreq acc1 a c e
    L_unittest_arreq acc2 b d unset
  }
}

_L_test_foreach_4_k_normal() {
  local arr=(a b c d e) i a k acc=() acc1=() acc2=()
  {
    L_log "test simple"
    while L_foreach -k k a : arr; do
      acc+=("$k" "$a")
    done
    L_unittest_arreq acc 0 a 1 b 2 c 3 d 4 e
  }
  {
    L_log "test simple two"
    while L_foreach a b : arr; do
      acc1+=("$a")
      acc2+=("${b:-unset}")
    done
    L_unittest_arreq acc1 a c e
    L_unittest_arreq acc2 b d unset
  }
}

_L_test_foreach_5_first() {
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

_L_test_foreach_6_last() {
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

if [[ "${1:-}" == -v ]]; then
  L_log_configure -l DEBUG
  shift
fi

if L_is_main; then
  if ((!$#)); then
    for i in $(compgen -A function -- _L_test_foreach_); do
      "$i"
    done
  else
    L_logrun "$@"
  fi
fi
