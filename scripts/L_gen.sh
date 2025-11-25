#!/bin/bash
set -euo pipefail

. "${BASH_SOURCE[0]%/*}"/../bin/L_lib.sh

###############################################################################
# @section generator
# @description
# generator implementation
#
# Generator context:
#
# - [0] - The current execution depth.
# - [1] - The count of generators in the chain.
# - [2] - Constant 6 . The number of elements before generators to eval start below.
# - [3] - Is generator finished?
# - [4] - Has yielded a value?
# - [5] - Is paused?
# - [L_gen[2] ... L_gen[2]+L_gen[1]-1] - generators to eval in the chain
# - [L_gen[2]+L_gen[1] ... L_gen[2]+L_gen[1]*2-1] - restore context of generators in the chain
# - [L_gen[2]+L_gen[1]*2 ... ?] - current iterator value of generators
#
# Constraints:
#
# - depth >= -1
# - depth < L_gen[1]
# - count of generators > 0
#
# Values:
#
# - L_gen[2]+L_gen[0] = current generator to execute
# - L_gen[2]+L_gen[1]+L_gen[0] = restore context of current generator
# - #L_gen[@] - L_gen[2]+L_gen[1]*2 = length of current iterator vlaue

# @description Run an generator chain.
#
# Takes multiple functions to execute separted by a +.
# The initial has to start with a +.
#
# @option -v <var> If given, do not run the generator chain, instead store it in this variable.
# @option -s <gen> Add to a copy of this generator.
# @option -R <var> Run an iterator using the global state of the variable.
#                  The variable stores an iterator state.
#                  Before first run, the variable shoudl be unset or empty.
#                  Each run it is updated with the state of the iterator.
#                  This allows to iterate over the result using a while loop.
# @option -h Print this help and return 0.
# @arg <+ gens...> Sequence of ['+' func args...] generators function calls prefixed with + to execute in the chain.
L_gen() {
  local OPTIND OPTERR OPTARG _L_v="" _L_v=0 _L_f=0 _L_gen_run=0
  while getopts v:s:R:h _L_i; do
    case "$_L_i" in
      R)
        _L_gen_run=1
        if [[ "$OPTARG" != - ]]; then
          _L_v=1
          local -n L_gen=$OPTARG || return 2
          # Otherwise L_gen should be already defined globally.
        fi
        ;;
      v)
        if [[ "$OPTARG" != - ]]; then
          _L_v=1
          local -n L_gen=$OPTARG || return 2
          # Otherwise L_gen should be already defined globally.
        fi
        ;;
      s)
        _L_s=1
        if [[ "$OPTARG" != - ]]; then
          local -n _L_gen_start=$OPTARG || return 2
        else
          # Otherwise we have to copy from L_gen, which should be already defined.
          local _L_gen_start
          L_array_copy L_gen _L_gen_start
        fi
        ;;
      h) L_func_help; return ;;
      *) L_func_usage_error; return 2 ;;
    esac
  done
  shift "$((OPTIND-1))"
  L_assert "First positional argument must be a +" test "${1:-}" = "+"
  L_assert "There must be more than 1 positinal arguments" test "$#" -gt 1
  # Read arguments.
  local _L_gen_funcs=()
  for _L_i; do
    if [[ "$_L_i" == "+" ]]; then
      _L_gen_funcs=("" "${_L_gen_funcs[@]}")
    else
      L_printf_append _L_gen_funcs[0] "%q " "$_L_i"
    fi
  done
  #
  if (( !_L_v )); then
    # If -v is not given, make L_gen is local.
    local L_gen
  fi
  if (( _L_f )); then
    if (( $# )); then
      # Merge context if -f option is given.
      L_assert "not possible to merge already started generator context" \
        test "${_L_gen_start[0]}" -eq -1 -a "${_L_gen_start[1]}" -gt 0
      L_assert "merging context not possible, invalid context" \
        test "${_L_gen_start[2]}" -eq 4
      L_assert "not possible to merge already finished generator" \
        test "${_L_gen_start[3]}" -eq 0
      # L_var_get_nameref_v _L_gen_start
      # L_var_to_string "$L_v"
      # printf "%q\n" "${_L_gen_start[@]:2:_L_gen_start[2]-2}"
      L_gen=(
        "${_L_gen_start[0]}"
        "$(( _L_gen_start[1] + ${#_L_gen_funcs[*]} ))"
        "${_L_gen_start[@]:2:_L_gen_start[2]-2}"
        "${_L_gen_funcs[@]%% }"  # generators
        "${_L_gen_start[@]:( _L_gen_start[2]           ):( _L_gen_start[1] )}"
        "${_L_gen_funcs[@]//*}"  # generators state
        "${_L_gen_start[@]:( _L_gen_start[2]+_L_gen_start[1] ):( _L_gen_start[1] )}"
      )
    fi
    # When $# == 0, then just use nameference for L_gen.
  elif (( _L_gen_run == 0 || ${L_gen[@]:+${#L_gen[*]}}+0 == 0 )); then
    # Create context.
    L_gen=(
      -1  # [0] - depth
      "${#_L_gen_funcs[*]}"  # [1] - number of generators in chain
      6  # [2] - offset
      0  # [3] - finished?
      ""  # [4] - yielded?
      0  # [5] - paused?
      "${_L_gen_funcs[@]%% }"  # generators
      "${_L_gen_funcs[@]//*}"  # generators state
    )
  fi
  # If v is not given, execute the chain.
  if ((!_L_v || _L_gen_run)); then
    L_gen[0]=0
    local _L_gen_cmd=${L_gen[L_gen[2]+L_gen[0]]}
    eval "${_L_gen_cmd}"
  fi
}

L_gen_with() {
  if [[ "$1" != "-" ]]; then
    local -n L_gen="$1"
  fi
  "${@:2}"
}

L_gen_pause() {
  L_gen[5]=1
}

# @description Parses -f option for other L_gen functions.
_L_gen_getopts_in() {
  local OPTIND OPTERR OPTARG _L_gen_i
  while getopts f:h _L_gen_i; do
    case "$_L_gen_i" in
      f) if [[ "$OPTARG" != "-" ]]; then local -n L_gen=$OPTARG || return 2; fi ;;
      h) L_func_help 1; return ;;
      *) L_func_usage_error 1; return 2 ;;
    esac
  done
  shift "$((OPTIND-1))"
  L_assert "generator is finished" test "${L_gen[3]}" -eq 0
  L_assert 'error: L_gen context variable does not exists' L_var_is_set L_gen
  _"${FUNCNAME[1]}"_in "$@"
}

L_gen_print_context() {
  local i
  echo "L_gen<-> depth=${L_gen[0]} funcs=${L_gen[1]} offset=${L_gen[2]} finished=${L_gen[3]} yielded=${L_gen[4]} alllen=${#L_gen[*]}"
  if L_var_get_nameref -v i L_gen; then
    echo "  L_gen is a namereference to $i"
  fi
  for (( i = 0; i < L_gen[1]; ++i )); do
    echo "  funcs[$i]=${L_gen[L_gen[2]+i]}"
    echo "    context[$i]=${L_gen[L_gen[2]+L_gen[1]+i]}"
  done
  echo -n "  ret=("
  for (( i = L_gen[2] + L_gen[1] * 2; i < ${#L_gen[*]}; ++i )); do
    printf "%q%.*s" "${L_gen[i]}" "$(( i + 1 == ${#L_gen[@]} ? 0 : 1 ))" " " # "
  done
  echo ")"
}

L_gen_next() {
  local _L_gen_yield=${L_gen[4]}
  # Call generate at next depth to get the value.
  L_assert "internal error: depth is lower then -1" test "${L_gen[0]}" -ge -1
  # Increase depth.
  L_gen[0]=$(( L_gen[0]+1 ))
  L_assert "internal error: depth is greater then the number of generators" test "${L_gen[0]}" -lt "${L_gen[1]}"
  local _L_gen_cmd=${L_gen[L_gen[2]+L_gen[0]]}
  L_assert "internal error: generator ${L_gen[0]} is empty?" test -n "$_L_gen_cmd"
  _L_gen[4]=""
  L_debug "Calling function [$_L_gen_cmd] at depth=${L_gen[0]}"
  eval "$_L_gen_cmd" || {
    local _L_gen_i=$?
    L_debug "Function [$_L_gen_cmd] exiting with $_L_gen_i"
    L_gen[3]=$_L_gen_i
    # Reduce depth
    L_gen[0]=$(( L_gen[0]-1 ))
    return "$_L_gen_i"
  }
  local _L_gen_res=("${L_gen[@]:(L_gen[2]+L_gen[1]*2)}")
  L_debug "Returned [$_L_gen_cmd] at depth=${L_gen[0]} yielded#${#_L_gen_res[*]}={${_L_gen_res[*]}}"
  if false && (( L_gen[0] )) && [[ -z "${L_gen[4]}" ]]; then
    L_panic "The generator did not yield a value. Check the [$_L_gen_cmd] call and make sure it call L_gen_yield before retuning, or it returns 1.$L_NL$(L_gen_print_context)"
  fi
  L_assert "internal error: depth is lower then 0 after call [$_L_gen_cmd]" test "${L_gen[0]}" -ge 0
  L_gen[4]=$_L_gen_yield
  # Reduce depth
  L_gen[0]=$(( L_gen[0]-1 ))
  # Extract the value from the return value.
  if (($# == 1)); then
    L_array_assign "$1" "${_L_gen_res[@]}"
  else
    L_assert "number of arguments $# is not equal to the number of tuple elements in the generator element ${#_L_gen_res[*]}" \
      test "${#_L_gen_res[*]}" -eq "$#"
    L_array_extract _L_gen_res "$@"
  fi
  #
  # L_gen_print_context
  # declare -p L_gen
  # "")
}

_L_gen_store() {
  # Run only on RETURN signal from L_finally.
  if [[ -v L_SIGNAL && "$L_SIGNAL" != "RETURN" ]]; then
    return
  fi
  # Create a string that will be evaled later.
  local L_v _L_gen_i
  L_gen[L_gen[2]+L_gen[1]+L_gen[0]]=""
  for _L_gen_i; do
    L_var_to_string_v "$_L_gen_i"
    L_gen[L_gen[2]+L_gen[1]+L_gen[0]]+="$_L_gen_i=$L_v;"
  done
  L_gen[L_gen[2]+L_gen[1]+L_gen[0]]+="#${FUNCNAME[2]}"
  L_debug "Save state depth=${L_gen[0]} idx=$((L_gen[2]+L_gen[1]+L_gen[0])) caller=${FUNCNAME[2]} variables=$*"
}

L_gen_restore() {
  # L_log "$@ ${!1} ${FUNCNAME[1]}"
  local _L_gen
  if (($#)); then
    for _L_gen; do
      L_assert "Variable $_L_gen from ${FUNCNAME[1]} is not set" \
        L_eval 'L_var_is_set "$1" || L_var_is_array "$1" || L_var_is_associative "$1"' "$_L_gen"
    done
    L_finally -r -s 1 _L_gen_store "$@"
    L_debug "Load state depth=${L_gen[0]} idx=$((L_gen[2]+L_gen[1]+L_gen[0])) caller=${FUNCNAME[1]} variables=$* eval={${L_gen[ (L_gen[2]+L_gen[1]+L_gen[0]) ]}}"
    eval "${L_gen[ (L_gen[2]+L_gen[1]+L_gen[0]) ]}"
  fi
}

L_gen_yield() {
  if [[ -n "${L_gen[4]}" ]]; then
    L_panic "Generator yielded a value twice, previous from ${L_gen[4]}. Check the generator source code and make sure it only calls L_gen_yield once before returning.$L_NL$(L_gen_print_context)"
  fi
  L_gen=("${L_gen[@]:: (L_gen[2]+L_gen[1]*2) }" "$@")
  L_gen[4]=${FUNCNAME[*]}
}

###############################################################################
# generator library

L_sourcegen_array() {
  L_assert '' test "$#" -eq 1
  local _L_i=0 _L_len=""
  L_gen_restore _L_i _L_len
  if [[ -z "$_L_len" ]]; then
    L_array_len -v _L_len "$1"
  fi
  (( _L_i < _L_len )) && {
    local -n arr=$1
    L_gen_yield "${arr[_L_i]}"
    (( ++_L_i ))
    # L_gen_store _L_i
  }
}

L_pipegen_enumerate() {
  L_assert '' test "$#" -eq 0
  local _L_i=0 _L_r
  L_gen_restore _L_i
  L_gen_next _L_r || return "$?"
  L_gen_yield "$_L_i" "${_L_r[@]}"
  (( ++_L_i ))
  # L_gen_store _L_i
}

L_sinkgen_for_each() {
  L_assert '' test "$#" -ge 1
  local _L_i
  while L_gen_next _L_i; do
    "$@" "${_L_i[@]}"
  done
}

# @description Printf generator consumer.
# @arg [$1] Format to print. If not given, will join values by spaces and print on lines.
L_sinkgen_printf() {
  local L_v
  while L_gen_next L_v; do
    if (($# == 0)); then
      L_array_join_v L_v " "
      printf "%s\n" "$L_v"
    else
      printf "$1" "${L_v[@]}"
    fi
  done
}

# @description Printf generator pipe.
# @arg [$1] Format to print. If not given, will join values by spaces and print on lines.
L_pipegen_printf() {
  local L_v _L_r
  L_gen_next _L_r || return $?
  if (($# == 0)); then
    L_array_join_v _L_r " "
    printf "%s\n" "$L_v"
  else
    printf "$1" "${_L_r[@]}"
  fi
  L_gen_yield "${_L_r[@]}"
}


L_sinkgen_consume() {
  while L_gen_next _; do
    :
  done
}

# @description Store the generated values into an array variable.
# @arg $1 destination variable
L_sinkgen_assign() {
  L_assert '' test "$#" -eq 1
  local L_v
  while L_gen_next L_v; do
    L_var_to_string_v L_v
    L_array_append "$1" "$L_v"
  done
}

L_pipegen_filter() {
  L_assert '' test "$#" -ge 1
  local _L_e
  L_gen_next _L_e || return "$?"
  while
    ! "$@" "$_L_e"
  do
    L_gen_next _L_e || return "$?"
  done
}

L_pipegen_head() {
  L_assert '' test "$#" -eq 1
  local _L_i=0 _L_e
  L_gen_restore _L_i
  (( _L_i++ < $1 )) && {
    L_gen_next _L_e || return "$?"
    L_gen_yield "${_L_e[@]}"
  }
}

L_pipegen_tail() {
  L_assert '' test "$#" -eq 1
  local _L_i=0 _L_e _L_buf=() L_v _L_send=-1
  L_gen_restore _L_buf _L_send
  if ((_L_send == -1)); then
    while L_gen_next _L_e; do
      L_var_to_string_v _L_e
      _L_buf=("${_L_buf[@]::$1-1}" "$L_v")
    done
    _L_send=0
  fi
  (( _L_send < ${#_L_buf[*]} )) && {
    local -a _L_i="${_L_buf[_L_send]}"
    L_gen_yield "${_L_i[@]}"
    (( ++_L_send ))
  }
}

L_sinkgen_nth() {
  L_assert '' test "$#" -eq 1
  local _L_i=0 _L_e
  L_gen_restore _L_i
  while (( _L_i < $1 )); do
    L_gen_next _L_e || return "$?"
  done
  L_gen_yield "${_L_e[@]}"
}

L_pipegen_padnone() {
  local _L_e
  if L_gen_next _L_e; then
    L_gen_yield "${_L_e[@]}"
  else
    L_gen_yield
  fi
}

L_pipegen_pairwise() {
  local _L_a _L_b=()
  L_gen_next _L_a || return $?
  L_gen_next _L_b || :
  L_gen_yield "${_L_a[@]}" "${_L_b[@]}"
}

L_sourcegen_iota() {
  local i=0
  L_gen_restore i
  case "$#" in
    0)
      L_gen_yield "$i"
      i=$((i+1))
      ;;
    1)
      if ((i >= $1)); then return 1; fi
      L_gen_yield "$i"
      i=$((i+1))
      ;;
    2)
      if ((i >= $2 - $1)); then return 1; fi
      L_gen_yield "$((i+$1))"
      i=$((i+1))
      ;;
    3)
      if ((i >= $3 - $1)); then return 1; fi
      L_gen_yield "$((i+$1))"
      i=$((i+$2))
      ;;
    *) L_func_usage_error; return 2 ;;
  esac
}

L_sinkgen_dotproduct() { L_handle_v_scalar "$@"; }
L_sinkgen_dotproduct_v() {
  L_assert "Wrong number of arguments. Expected 2 but received $#" test "$#" -eq 2
  local a b
  L_v=0
  while
    if L_gen_with "$1" L_gen_next a; then
      if L_gen_with "$2" L_gen_next b; then
        :
      else
        L_panic "generators $1 $2 have different length"
      fi
    else
      if L_gen_with "$2" L_gen_next b; then
        L_panic "generators $1 $2 have different length"
      else
        return 0
      fi
    fi
  do
    L_v=$(( L_v + a * b ))
  done
}

L_sinkgen_fold_left() { L_handle_v_scalar "$@"; }
L_sinkgen_fold_left_v() {
  local _L_a
  L_v="$2"
  while L_gen_with "$1" L_gen_next _L_a; do
    # L_gen_print_context -f "$1"
    "${@:3}" "$L_v" "$_L_a"
  done
}

L_gen_copy() { L_gen_tee "$@"; }

L_gen_tee() {
  local _L_source=$1
  shift
  while (($#)); do
    L_array_copy "$_L_source" "$1"
    shift
  done
}

L_pipgen_cycle() {
  local i=-1 seen=() v
  L_gen_restore i seen
  if ((i == -1)); then
    if L_gen_next v; then
      seen+=("$v")
      L_gen_yield "$v"
      return
    else
      i=0
    fi
  fi
  L_gen_yield "${seen[i]}"
  i=$(( i + 1 % ${#seen[*]} ))
}

L_sourcegen_repeat() {
  case "$#" in
    1) L_gen_yield "$1" ;;
    2)
      local i=0
      L_gen_restore i
      (( i++ < $2 )) && L_gen_yield "$1"
      ;;
    *) L_func_usage_error "invalid number of positional rguments"; return 2 ;;
  esac
}

L_sinkgen_accumulate() {
  local _L_r
  L_v=0
  case "$#" in
    1)
      while L_gen_next _L_r; do
        L_v=$(( L_v + _L_r ))
      done
      ;;
    2)
      while L_gen_next _L_r; do
         L_v="$(_L_r $L_v)"
       done
      ;;
    *)
      L_func_usage_error "wrong number of positional arguments"
      return 2
      ;;
  esac
  echo $L_v
}

L_pipegen_stride() {
  L_assert '' test "$1" -gt 0
  local _L_cnt="$1" _L_r _L_exit=0
  L_gen_restore _L_exit
  if (( _L_exit )); then
    return "$_L_exit"
  fi
  while (( --_L_cnt )); do
    if L_gen_next _L_r; then
      :
    else
      _L_exit="$?"
      break
    fi
  done
  if (( _L_cnt + 1 != $1 )); then
    L_gen_yield "${_L_r[@]}"
  fi
}

L_sinkgen_to_array() {
  local -n _L_to="$1" _L_r
  _L_to=()
  while L_gen_next _L_r; do
    _L_to+=("$_L_r")
  done
}

L_pipegen_sort() { L_getopts_in -p _L_opt_ Ank: _L_pipegen_sort "$@"; }
_L_pipegen_sort() {
  local _L_vals=() _L_idxs=() _L_poss=() _L_lens=() _L_i=0 _L_r _L_pos=0 _L_alllen1=1 _L_run=0
  L_gen_restore _L_vals _L_idxs _L_poss _L_lens _L_i _L_alllen1 _L_run
  if (( !_L_run )); then
    # accumulate
    while L_gen_next _L_r; do
      _L_idxs+=($_L_i)
      _L_poss+=($_L_pos)
      _L_lens+=(${#_L_r[*]})
      _L_vals+=("${_L_r[@]}")
      (( ++_L_i ))
      _L_pos=$(( _L_pos + ${#_L_r[*]} ))
      _L_alllen1=$(( _L_alllen1 && ${#_L_r[*]} == 1 ))
    done
    if (( _L_alllen1 )); then
      L_sort _L_vals
    else
      declare -p _L_idxs
      L_sort_bash -c _L_pipegen_sort_all _L_idxs
      declare -p _L_idxs
    fi
    #
    _L_run=1
    _L_i=0
  fi
  (( _L_i < ${#_L_idxs[*]} )) && {
    if (( _L_alllen1 )); then
      L_gen_yield "${_L_vals[_L_i]}"
    else
      L_gen_yield "${_L_vals[@]:(_L_poss[_L_i]):(_L_lens[_L_i])}"
    fi
    (( ++_L_i ))
  }
}

_L_pipegen_sort_cmp() {
  if (( _L_opt_n )) && L_is_integer "$1" && L_is_integer "$2"; then
    if (( $1 != $2 )); then
      (( $1 > $2 )) || return 2
      return 1
    fi
  else
    if [[ "$1" != "$2" ]]; then
      [[ "$1" > "$2" ]] || return 2
      return 1
    fi
  fi
}

_L_pipegen_sort_all() {
  local -;set -x
  # Sort with specific field.
  if [[ -v _L_opt_k ]]; then
    if (( _L_opt_A )); then
      local a="${_L_vals[_L_poss[$1]+1]}" b="${_L_vals[_L_poss[$2]+1]}"
      local -A ma="$a" mb="$b"
      local a=${ma["$_L_opt_k"]} b=${mb["$_L_opt_k"]}
      _L_pipegen_sort_cmp "$a" "$b" || return "$(($?-1))"
    else
      if (( _L_opt_k < _L_lens[$1] && _L_opt_k < _L_lens[$2] )); then
        local a="${_L_vals[_L_poss[$1]+_L_opt_k]}" b="${_L_vals[_L_poss[$2]+_L_opt_k]}"
        _L_pipegen_sort_cmp "$a" "$b" || return "$(($?-1))"
      fi
    fi
  fi
  # Default sort.
  local i=0 j=0
  for ((; i != _L_lens[$1] && j != _L_lens[$2]; ++i, ++j )); do
    local a="${_L_vals[_L_poss[$1]+i]}" b="${_L_vals[_L_poss[$2]+j]}"
    _L_pipegen_sort_cmp "$a" "$b" || return "$(($?-1))"
  done
  # Stable sort.
  (( i > j && $1 > $2 ))
}

L_sinkgen_first_true() { L_handle_v_array "$@"; }
L_sinkgen_first_true_v() {
  while L_gen_next L_v; do
    if L_is_true "$L_v"; then
      L_v=("${_L_i[@]}")
    fi
  done
  if (($#)); then
    L_v=("$@")
  else
    return 1
  fi
}

# Iterate over each characters in a string.
L_sourcegen_string_chars() {
  local _L_idx=-1
  L_gen_restore _L_idx
  (( ++_L_idx <= ${#1} )) && {
    L_gen_yield "${1:_L_idx:1}"
  }
}

# Yield unique elements, preserving order. Remember only the element just seen.
# @example
#   L_gen \
#   + L_sourcegen_string_chars 'AAAABBBCCDAABBB' \
#   + L_pipegen_unique_justseen \
#   + L_sinkgen_printf  # prints: A B C D A B
# @example
#   L_gen \
#   + L_sourcegen_string_chars 'ABBcCAD' \
#   + L_pipegen_unique_justseen L_eval '[[ "${1,,}" == "${2,,}" ]]' \
#   + L_sinkgen_printf  # prints: A B c A D
L_pipegen_unique_justseen() {
  local _L_last
  L_gen_restore _L_last
  L_gen_next _L_new || return "$?"
  if [[ -z "${_L_last}" ]]; then
    L_gen_yield "$_L_new"
  elif
    if (($#)); then
      "$@" "$_L_last" "$_L_new"
    else
      [[ "$_L_last" == "$_L_new" ]]
    fi
  then
    L_gen_yield "$_L_new"
  fi
  _L_last="$_L_new"
}

L_gen_next_dict() {
  L_assert '' L_var_is_associative "$1"
  local m v
  L_gen_next m v || return "$?"
  L_assert '' test "$m" == "DICT"
  L_assert '' test "${v::1}" == "("
  L_assert '' test "${v:${#v}-1}" == ")"
  eval "$1=$v"
}

L_gen_yield_dict() {
  L_assert '' L_var_is_associative "$1"
  local L_v
  L_var_to_string_v "$1" || L_panic
  L_assert '' test "${L_v::1}" == "("
  L_assert '' test "${L_v:${#L_v}-1}" == ")"
  L_gen_yield DICT "$L_v"
}

L_sourcegen_read_csv() {
  local IFS=, headers=() i arr L_v step=0
  L_gen_restore step headers
  if ((step == 0)); then
    read -ra headers || return $?
    step=1
  fi
  read -ra arr || return $?
  local -A vals
  for i in "${!headers[@]}"; do
    vals["${headers[i]}"]=${arr[i]:-}
  done
  L_gen_yield_dict vals
}

L_pipegen_dropna() {
  local subset
  L_argskeywords / subset -- "$@" || return $?
  L_assert '' test -n "$subset"
  local -A asa=()
  while L_gen_next_dict asa; do
    if [[ -n "${asa[$subset]}" ]]; then
      L_gen_yield_dict asa
      return 0
    fi
  done
  return 1
}

L_set_init() { L_array_assign "$1"; }
L_set_add() {
  local _L_set=$1
  shift
  while (($#)); do
    if ! L_set_has "$_L_set" "$1"; then
      L_array_append "$_L_set" "$1"
    fi
    shift
  done
}
L_set_has() { L_array_contains "$1" "$2"; }

L_pipegen_none() {
  local _L_r
  L_gen_next _L_r || return "$?"
  L_gen_yield "${_L_r[@]}"
}

L_sinkgen_iterate() {
  local _L_r
  L_gen_next _L_r || return "$?"
  # Extract the value from the return value.
  if (($# == 1)); then
    L_array_assign "$1" "${_L_r[@]}"
  else
    L_assert "number of arguments $# is not equal to the number of tuple elements in the generator element ${#_L_r[*]}" \
      test "${#_L_r[*]}" -eq "$#"
    L_array_extract _L_r "$@"
  fi
  L_gen_pause
}

L_pipegen_zip_arrays() {
  local _L_r _L_i=0
  local -n _L_a=$1
  L_gen_restore _L_i || return "$?"
  (( _L_i++ < ${#_L_a[*]} )) && {
    L_gen_next _L_r || return "$?"
    L_gen_yield "${_L_r[@]}" "${_L_a[_L_i-1]}"
  }
}

_L_gen_test() {
  local sales array numbers a
  sales="\
customer,amount
Alice,120
Bob,200
Charlie,50
Alice,180
Bob,
Charlie,150
Dave,300
Eve,250
"
  array=(a b c d e f)
  numbers=(2 0 4 4)
  L_finally
  {
    local out=() it=()
    while L_gen -R it + L_sourcegen_array array + L_sinkgen_iterate a; do
      out+=("$a")
    done
    L_unittest_arreq out "${array[@]}"
  }
  {
    local out=() it=()
    while L_gen -R it + L_sourcegen_array array + L_sinkgen_iterate a; do
      out+=("$a")
    done
    L_unittest_arreq out "${array[@]}"
  }
  {
    local out1=() it=() out2=()
    while L_gen -R it \
        + L_sourcegen_array array \
        + L_pipegen_pairwise \
        + L_sinkgen_iterate a b
    do
      out1+=("$a")
      out2+=("$b")
    done
    L_unittest_arreq out1 a c e
    L_unittest_arreq out2 b d f
  }
  {
    local out1=() it=() out2=() idx=() i a b
    while L_gen -R it \
        + L_sourcegen_array array \
        + L_pipegen_pairwise \
        + L_pipegen_enumerate \
        + L_sinkgen_iterate i a b
    do
      idx+=("$i")
      out1+=("$a")
      out2+=("$b")
    done
    L_unittest_arreq idx 0 1 2
    L_unittest_arreq out1 a c e
    L_unittest_arreq out2 b d f
  }
  {
    L_unittest_cmd -o $'a\nb\nc\nd\ne\nf' \
      L_gen \
      + L_sourcegen_array array \
      + L_sinkgen_for_each printf "%s\n"
  }
  {
    L_unittest_cmd -o '0 1 2 3 4 ' \
      L_gen \
      + L_sourcegen_iota \
      + L_pipegen_head 5 \
      + L_sinkgen_for_each printf "%s "
    L_unittest_cmd -o '0 1 2 3 4 ' \
      L_gen \
      + L_sourcegen_iota 5 \
      + L_sinkgen_for_each printf "%s "
    L_unittest_cmd -o '3 4 5 6 7 8 ' \
      L_gen \
      + L_sourcegen_iota 3 9 \
      + L_sinkgen_for_each printf "%s "
    L_unittest_cmd -o '3 5 7 ' \
      L_gen \
      + L_sourcegen_iota 3 9 2 \
      + L_sinkgen_for_each printf "%s "
  }
}

###############################################################################

_L_gen_main() {
  local x v mode
  L_argparse remainder=1 \
    -- -x flag=1 \
    -- -v flag=1 eval='L_log_level_inc' \
    -- mode nargs="*" default='1' \
    ---- "$@"
  # ulimit -u 10  # no subchilds ever
  if ((x)); then
    set -x
  fi
  _L_gen_test
  case "$mode" in
  while3)
    ;;
  1|'')
    ;;
  2)
    ;;
  3)
    L_gen -v gen \
      + L_sourcegen_iota 5 \
      + L_pipegen_head 5
    L_sinkgen_fold_left -v res -- gen 0 L_eval 'L_v=$(($1+$2))'
    printf "%s\n" "$res"
    ;;
  4)
    L_gen -v gen1 \
      + L_sourcegen_iota \
      + L_pipegen_head 4
    L_gen \
      + L_sourcegen_array numbers \
      + L_pipegen_head 4 \
      + L_sinkgen_dotproduct -v res -- gen1 -
    printf "%s %s\n" "$res" "$(( 0 * 2 + 1 * 0 + 2 * 4 + 3 * 4 ))"
    ;;
  5)
    L_gen -v gen1 \
      + L_sourcegen_iota \
      + L_pipegen_head 4
    L_gen_copy gen1 gen2
    L_gen_with gen1 L_sinkgen_printf
    L_gen_with gen2 L_sinkgen_printf
    ( L_gen_with gen2 L_sinkgen_printf )
    ;;
  6)
    L_gen -v gen1 + L_sourcegen_iota
    L_gen -v gen2 -s gen1 + L_pipegen_head 5
    # L_gen_print_context -f gen1
    # L_gen_print_context -f gen2
    L_gen_with gen2 L_sinkgen_printf
    ;;
  readfile)
    L_gen \
      + L_sourcegen_read file \
      + L_pipegen_transform L_strip -v L_v \
      + L_pipegen_filter L_eval '(( ${#1} != 0 ))' \
      + L_sinkgen_to_array lines <<EOF
    a
  bb
      ccc
EOF
    L_sort_bash -E '(( ${#1} > ${#2} ))' -c compage_length lines
    declare -p lines
    ;;
  longest5)
    L_gen \
      + L_sourcegen_read file \
      + L_pipegen_transform L_eval 'L_regex_replace_v "$1" '$'\x1b''"\\[[0-9;]*m" ""' \
      + L_pipegen_filter L_eval '(( ${#1} != 0 ))' \
      + L_pipegen_transform L_eval 'L_v=("${#1}" "$1")' \
      + L_pipegen_sort -n -k 1 \
      + L_pipegen_transform L_eval 'L_v="$1"' \
      + L_sinkgen_to_array array
    declare -p array
    ;;
  L_*)
    "${mode[@]}"
    ;;
  esac
}

if L_is_main; then
  _L_gen_main "$@"
fi
