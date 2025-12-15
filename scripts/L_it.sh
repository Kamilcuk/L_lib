#!/bin/bash
# vim: foldmethod=marker foldmarker=[[[,]]] ft=bash
set -euo pipefail

. "${BASH_SOURCE[0]%/*}"/../bin/L_lib.sh

# [[[
# @section generator
# @description
# generator implementation
#
# Generator context:
#
# - [0] - The current execution depth.
# - [1] - The count of generators in the chain.
# - [2] - Constant 7 . The number of elements before generators to eval start below.
# - [3] - Is generator finished?
# - [4] - Has yielded a value?
# - [5] - Is paused?
# - [6] - '_L_IT' constant string
# - [_L_IT[2] ... _L_IT[2]+_L_IT[1]-1] - generators to eval in the chain
# - [_L_IT[2]+_L_IT[1] ... _L_IT[2]+_L_IT[1]*2-1] - restore context of generators in the chain
# - [_L_IT[2]+_L_IT[1]*2 ... ?] - current iterator value of generators
#
# Constraints:
#
# - depth >= -1
# - depth < _L_IT[1]
# - count of generators > 0
#
# Values:
#
# - _L_IT[2]+_L_IT[0] = current generator to execute
# - _L_IT[2]+_L_IT[1]+_L_IT[0] = restore context of current generator
# - #_L_IT[@] - _L_IT[2]+_L_IT[1]*2 = length of current iterator vlaue

L_it_new() {
  if [[ "$1" != "_L_IT" ]]; then local -n _L_IT="$1" || return 2; fi
  shift
  # Create context.
  _L_IT=(
    -1         # [0] - depth
    "$#"       # [1] - number    of generators in chain
    7          # [2] - offset
    0          # [3] - finished?
    ""         # [4] - yielded?
    0          # [5] - paused?
    "_L_IT"    # [6] - mark
    "${@%% }"  # generators
    "${@//*}"  # generators state
  )
}

L_it_append() {
  if [[ "$1" != "_L_IT" ]]; then local -n _L_IT="$1" || return 2; fi
  shift
  # Merge context if -f option is given.
  L_assert "not possible to merge already started generator context" \
    test "${_L_IT[0]}" -eq -1 -a "${_L_it_start[1]}" -gt 0
  L_assert "merging context not possible, invalid context" \
    test "${_L_IT[2]}" -eq 4
  L_assert "not possible to merge already finished generator" \
    test "${_L_IT[3]}" -eq 0
  # L_var_get_nameref_v _L_IT
  # L_var_to_string "$L_v"
  # printf "%q\n" "${_L_IT[@]:2:_L_it_start[2]-2}"
  _L_IT=(
    "${_L_IT[0]}"
    "$(( _L_IT[1] + $# ))"
    "${_L_IT[@]:2:_L_IT[2]-2}"
    "${@%% }"  # generators
    "${_L_IT[@]:( _L_IT[2]           ):( _L_IT[1] )}"
    "${@//*}"  # generators state
    "${_L_IT[@]:( _L_IT[2]+_L_IT[1] ):( _L_IT[1] )}"
  )
}

L_it_make() {
  L_assert "There must be more than 3 positional arguments" test "$#" -gt 3
  L_assert "Second positional argument must be a +" test "${2:-}" = "+"
  # Read arguments.
  local _L_it_funcs=() _L_i
  for _L_i in "${@:2}"; do
    if [[ "$_L_i" == "+" ]]; then
      _L_it_funcs=("" "${_L_it_funcs[@]}")
    else
      L_printf_append _L_it_funcs[0] "%q " "$_L_i"
    fi
  done
  #
  L_it_new "$1" "${_L_it_funcs[@]}"
}

L_it_run() {
  if [[ "$1" != "_L_IT" && "$1" != "-" ]]; then local -n _L_IT="$1" || return 2; fi
  L_assert 'depth at run stage should be -1. Are you trying to run a running generator?' test "${_L_IT[0]}" -eq -1
  _L_IT[0]=0
  eval "${_L_IT[@]:(_L_IT[2]):1}"
}

L_it_make_run() {
  local _L_IT=()
  L_it_make _L_IT "$@"
  L_it_run _L_IT
}

# @description Execute a command with a generator variable bound to `_L_IT`.
#
# This is useful when you need to pass a generator state variable to a function
# that expects the generator state to be in a variable named `_L_IT`.
#
# @arg $1 <var> The generator state variable name. Use `-` to use the current `_L_IT`.
# @arg $@ Command to execute.
# @example
#   L_it_use my_gen L_sinkit_printf
L_it_use() {
  if [[ "$1" != "_L_IT" && "$1" != "-" ]]; then local -n _L_IT="$1" || return 2; fi
  "${@:2}"
}

# @description Pauses the current generator execution.
#
# This sets the internal pause flag, which can be checked by the generator chain
# to stop execution and allow the caller to inspect the state or resume later.
#
# @noargs
L_it_pause() {
  _L_IT[5]=1
}

# @description Prints the internal state of the current generator chain.
#
# This is primarily a debugging tool to inspect the execution depth, function
# chain, saved contexts, and the current yielded value.
#
# @noargs
L_it_print_context() {
  local i
  echo "_L_IT<-> depth=${_L_IT[0]} funcs=${_L_IT[1]} offset=${_L_IT[2]} finished=${_L_IT[3]} yielded=${_L_IT[4]} alllen=${#_L_IT[*]}"
  if L_var_get_nameref -v i _L_IT; then
    echo "  _L_IT is a namereference to $i"
  fi
  for (( i = 0; i < _L_IT[1]; ++i )); do
    echo "  funcs[$i]=${_L_IT[_L_IT[2]+i]}"
    echo "    context[$i]=${_L_IT[_L_IT[2]+_L_IT[1]+i]}"
  done
  echo -n "  ret=("
  for (( i = _L_IT[2] + _L_IT[1] * 2; i < ${#_L_IT[*]}; ++i )); do
    printf "%q%.*s" "${_L_IT[i]}" "$(( i + 1 == ${#_L_IT[@]} ? 0 : 1 ))" " " # "
  done
  echo ")"
}

# @description Requests the next element from the upstream generator.
#
# This is the core mechanism for consuming elements in a generator chain.
# It increments the execution depth, calls the next generator function,
# and handles the return value or exit status.
#
# @arg $1 <var> Variable to assign the yielded element to (as a scalar or array).
# @arg $@ <var>... Multiple variables to assign the yielded tuple elements to.
# @return 0 on successful yield, non-zero on generator exhaustion or error.
# @example
#   local element
#   while L_it_next element; do
#     echo "Got: $element"
#   done
L_it_next() {
  # Call generate at next depth to get the value.
  L_assert "invalid input variable is not a generator" test "${_L_IT[6]}" = "_L_IT"
  L_assert "internal error: depth is lower then -1" test "${_L_IT[0]}" -ge -1
  # Increase depth.
  _L_IT[0]=$(( _L_IT[0]+1 ))
  L_assert "internal error: depth is greater then the number of generators" test "${_L_IT[0]}" -lt "${_L_IT[1]}"
  local _L_it_cmd=${_L_IT[_L_IT[2]+_L_IT[0]]}
  L_assert "internal error: generator ${_L_IT[0]} is empty?" test -n "$_L_it_cmd"
  local _L_it_yield=${_L_IT[4]}
  _L_IT[4]=""
  L_debug "Calling function [$_L_it_cmd] at depth=${_L_IT[0]}"
  eval "$_L_it_cmd" || {
    local _L_it_i=$?
    L_debug "Function [$_L_it_cmd] exiting with $_L_it_i"
    _L_IT[3]=$_L_it_i
    # Reduce depth
    _L_IT[0]=$(( _L_IT[0]-1 ))
    return "$_L_it_i"
  }
  local _L_it_res=("${_L_IT[@]:(_L_IT[2]+_L_IT[1]*2)}")
  L_debug "Returned [$_L_it_cmd] at depth=${_L_IT[0]} yielded#${#_L_it_res[*]}={${_L_it_res[*]}}"
  if [[ -z "${_L_IT[4]}" ]]; then
    L_panic "The generator [$_L_it_cmd] did not yield a value. Make sure it call L_it_yield before retuning, or it returns non-zero.$L_NL$(L_it_print_context)"
  fi
  L_assert "internal error: depth is lower then 0 after call [$_L_it_cmd]" test "${_L_IT[0]}" -ge 0
  _L_IT[4]=$_L_it_yield
  # Reduce depth
  _L_IT[0]=$(( _L_IT[0]-1 ))
  # Extract the value from the return value.
  if (($# == 1)); then
    L_array_assign "$1" "${_L_it_res[@]}"
  else
    L_assert "number of arguments $# is not equal to the number of tuple elements in the generator element ${#_L_it_res[*]}" \
      test "${#_L_it_res[*]}" -eq "$#"
    L_array_extract _L_it_res "$@"
  fi
  #
  # L_it_print_context
  # declare -p _L_IT
  # "")
}

# @description Internal helper to save local variables to the generator context.
#
# This function is registered as a `L_finally -r` trap to execute on function
# return. It serializes the specified local variables into a string that is
# stored in the generator's context array, allowing the generator to resume
# from the correct state on the next call.
#
# @arg $@ Names of local variables to save.
_L_it_store() {
  # Run only on RETURN signal from L_finally.
  if [[ -v L_SIGNAL && "$L_SIGNAL" != "RETURN" ]]; then
    return
  fi
  # Create a string that will be evaled later.
  local L_v _L_it_i
  _L_IT[_L_IT[2]+_L_IT[1]+_L_IT[0]]=""
  for _L_it_i; do
    L_var_to_string_v "$_L_it_i"
    _L_IT[_L_IT[2]+_L_IT[1]+_L_IT[0]]+="$_L_it_i=$L_v;"
  done
  _L_IT[_L_IT[2]+_L_IT[1]+_L_IT[0]]+="#${FUNCNAME[2]}"
  L_debug "Save state depth=${_L_IT[0]} idx=$((_L_IT[2]+_L_IT[1]+_L_IT[0])) caller=${FUNCNAME[2]} variables=$* eval=${_L_IT[_L_IT[2]+_L_IT[1]+_L_IT[0]]}"
}

# @description Restores the local state of a generator function.
#
# This function must be called at the beginning of a generator function.
# It registers a return trap to save the specified variables on exit and
# immediately loads the saved state from the generator context if available.
#
# @arg $@ Names of local variables to restore and save.
# @example
#   my_generator() {
#     local i=0
#     L_it_restore i
#     # ... generator logic using 'i' ...
#   }
L_it_restore() {
  # L_log "$@ ${!1} ${FUNCNAME[1]}"
  local _L_it
  if (($#)); then
    for _L_it; do
      L_assert "Variable $_L_it from ${FUNCNAME[1]} is not set" \
        L_eval 'L_var_is_set "$1" || L_var_is_array "$1" || L_var_is_associative "$1"' "$_L_it"
    done
    L_finally -r -s 1 _L_it_store "$@"
    L_debug "Load state depth=${_L_IT[0]} idx=$((_L_IT[2]+_L_IT[1]+_L_IT[0])) caller=${FUNCNAME[1]} variables=$* eval=${_L_IT[ (_L_IT[2]+_L_IT[1]+_L_IT[0]) ]}"
    eval "${_L_IT[ (_L_IT[2]+_L_IT[1]+_L_IT[0]) ]}"
  fi
}

# @description Yields a value from the current generator.
#
# This function stores the yielded value(s) in the generator state array and
# sets a flag to indicate a successful yield. The generator function must
# return 0 immediately after calling `L_it_yield`.
#
# @arg $@ The value(s) to yield. Can be a single scalar or multiple elements for a tuple.
# @example
#   L_it_yield "element"
#   L_it_yield "key" "value"
L_it_yield() {
  if [[ -n "${_L_IT[4]}" ]]; then
    L_panic "Generator yielded a value twice, previous from ${_L_IT[4]}. Check the generator source code and make sure it only calls L_it_yield once before returning.$L_NL$(L_it_print_context)"
  fi
  _L_IT=("${_L_IT[@]:: (_L_IT[2]+_L_IT[1]*2) }" "$@")
  _L_IT[4]=${FUNCNAME[*]}
}

L_IT_STOP=1

# ]]]
# [[[ source generators
# @section source generators

# @description Generate elements from arguments in order
L_sourceit_args() {
  local _L_i=0
  L_it_restore _L_i
  (( _L_i < $# ? ++_L_i : 0 )) && L_it_yield "${*:_L_i:1}"
}

# @description Source generator that yields elements from a bash array.
# Iterates over the elements of a given array, yielding one element per call.
# @arg $1 <array> The name of the array variable to iterate over.
# @return 0 on successful yield, 1 when the array is exhausted.
# @example
#   local arr=(a b c)
#   _L_IT + L_sourceit_array arr + L_sinkit_printf
L_sourceit_array() {
  L_assert '' test "$#" -eq 1
  local _L_i=0 _L_len=""
  L_it_restore _L_i _L_len
  if [[ -z "$_L_len" ]]; then
    L_array_len -v _L_len "$1"
  fi
  (( _L_i < _L_len ? ++_L_i : 0 )) && {
    local -n arr=$1
    L_it_yield "${arr[_L_i]}"
  }
}

# @description Source generator producing integer sequences.
# Generates a sequence of integers, similar to Python's `range()`.
# Maintains internal state through `L_it_restore` and `L_it_yield`.
# @arg [$1] [END] If one argument, emits 0, 1, ..., END-1.
# @arg [$1] [START] [$2] [END] If two arguments, emits START, START+1, ..., END-1.
# @arg [$1] [START] [$2] [STEP] [$3] [END] If three arguments, emits START, START+STEP, ... while < END.
# @return 0 on successful yield, 1 when sequence is exhausted, 2 on invalid invocation.
# @example
#   _L_IT + L_sourceit_range 5 + L_sinkit_printf  # 0 1 2 3 4
#   _L_IT + L_sourceit_range 3 9 + L_sinkit_printf # 3 4 5 6 7 8
#   _L_IT + L_sourceit_range 3 2 9 + L_sinkit_printf # 3 5 7
L_sourceit_range() {
  local i=0
  L_it_restore i
  case "$#" in
    0)
      L_it_yield "$i"
      i=$((i+1))
      ;;
    1)
      if ((i >= $1)); then return 1; fi
      L_it_yield "$i"
      i=$((i+1))
      ;;
    2)
      if ((i >= $2 - $1)); then return 1; fi
      L_it_yield "$((i+$1))"
      i=$((i+1))
      ;;
    3)
      if ((i >= $3 - $1)); then return 1; fi
      L_it_yield "$((i+$1))"
      i=$((i+$2))
      ;;
    *) L_func_usage_error; return 2 ;;
  esac
}

# ]]]
# [[[
# @section infite iterators

# @description
# start, start+step, start+2*step, …
# @arg [start]
# @arg [step]
L_sourceit_count() {
  local _L_start=${1:-0} _L_step=${2:-1} _L_i=0
  L_it_restore _L_i
  L_it_yield "$(( _L_i++ * _L_step + _L_start ))"
}

# @description Pipe generator that cycles through yielded elements.
# Yields elements from the upstream generator until it is exhausted, then starts
# yielding the collected elements from the beginning indefinitely.
# @noargs
# @return 0 on successful yield.
# @example
#   _L_IT + L_sourceit_array arr + L_pipeit_cycle + L_pipeit_head 10 + L_sinkit_printf
L_pipeit_cycle() {
  local i=-1 seen=() v
  L_it_restore i seen
  if ((i == -1)); then
    if L_it_next v; then
      seen+=("$v")
      L_it_yield "$v"
      return
    else
      i=0
    fi
  fi
  L_it_yield "${seen[i]}"
  i=$(( i + 1 % ${#seen[*]} ))
}

# @description Source generator that repeats a value.
#
# @arg $1 <value> The value to repeat.
# @arg [$2] <int> The number of times to repeat the value. If omitted, repeats indefinitely.
# @return 0 on successful yield, 1 when the repeat count is reached.
# @example
#   _L_IT + L_sourceit_repeat "hello" 3 + L_sinkit_printf
L_sourceit_repeat() {
  case "$#" in
    1) L_it_yield "$1" ;;
    2)
      local i=0
      L_it_restore i
      (( i++ < $2 )) && L_it_yield "$1"
      ;;
    *) L_func_usage_error "invalid number of positional rguments"; return 2 ;;
  esac
}

# ]]]
# [[[ Iterators terminating on the shortest input sequence:

# @description Make an iterator that returns accumulated sums or accumulated results from other binary functions.
# The function defaults to addition. The function should accept two arguments, an accumulated total and a value from the iterable.
# If an initial value is provided, the accumulation will start with that value and the output will have one more element than the input iterable.
# @option -i <initial>
# @arg $@ Command that takes current total and iterator arguments and should set variable L_v as the next iterator state.
L_pipeit_accumulate() { L_getopts_in -p _L_ i:: _L_pipeit_accumulate_in "$@"; }
_L_pipeit_accumulate_add() { L_v=$(( $1 + $2 )); }
_L_pipeit_accumulate_in() {
  local _L_init=0 _L_total=() L_v
  L_it_restore _L_total _L_init
  if (( _L_init == 0 ? _L_init = 1 : 0 )); then
    if ! L_var_is_set _L_i; then
      L_it_next L_v || return $?
      _L_total=("${L_v[@]}")
    else
      _L_total=("${_L_i[@]}")
    fi
    L_it_yield "${_L_total[@]}"
  else
    L_it_next L_v || return "$?"
    "${@:-_L_pipeit_accumulate_add}" "${_L_total[@]}" "${L_v[@]}"
    _L_total=("${L_v[@]}")
    L_it_yield "${L_v[@]}"
  fi
}

# @description Batch data from the iterable into tuples of length n. The last batch may be shorter than n.
# @option -s If set, be strict.
# @arg $1 count
L_pipeit_batched() { L_getopts_in -p _L_ -n '?' -- 's' _L_pipeit_batched_in "$@"; }
_L_pipeit_batched_in() {
  local _L_count=$1 _L_batch=() L_v
  while (( _L_count-- > 0 )); do
    if ! L_it_next L_v; then
      if (( _L_s )); then
        L_func_error "incomplete batch"
        return 2
      fi
      if (( _L_count + 1 == $1 )); then
        return 1
      fi
      break
    fi
    _L_batch+=("${L_v[@]}")
  done
  L_it_yield "${_L_batch[@]}"
}

# @description Chain current iterator with other iterators.
# @arg $@ other iterators
L_pipeit_chain() {
  local _L_i=-1 _L_r _L_it
  L_it_restore _L_i
  if (( _L_i == -1 )); then
    L_it_next _L_r
  elif (( _L_i < $# )); then
    L_it_use "${*:_L_i + 1:1}" L_it_next _L_r
  else
    return "$L_IT_STOP"
  fi && L_it_yield "${_L_r[@]}"
}

# @description Chain current iterator with other single command sourcegen iterator.
# @arg $@ One sourcegen command.
L_pipeit_chain_gen() {
  local _L_it=() _L_done=0 _L_r
  L_it_restore _L_it _L_done
  if (( _L_done == 0 )) && L_it_next _L_r; then
    L_it_yield "${_L_r[@]}"
  else
    _L_done=1
    if (( ${#_L_it[*]} == 0 )); then
      _L_IT -v _L_it + "$@" || return "$?"
    fi
    L_it_use _L_it L_it_next _L_r || return "$?"
    L_it_yield "${_L_r[@]}"
  fi
}

# @description Pipe generator that yields a tuple of (index, element).
# Prepends a zero-based index to each element received from the upstream generator.
# @noargs
# @return 0 on successful yield, non-zero on upstream generator exhaustion or error.
# @example
#   _L_IT + L_sourceit_array arr + L_pipeit_enumerate + L_sinkit_printf "%s: %s\n"
L_pipeit_enumerate() {
  L_assert '' test "$#" -eq 0
  local _L_i=0 _L_r
  L_it_restore _L_i
  L_it_next _L_r || return "$?"
  L_it_yield "$_L_i" "${_L_r[@]}"
  (( ++_L_i ))
  # L_it_store _L_i
}

# @description Sink generator that executes a command for each element.
# Consumes all elements from the upstream generator and executes the provided
# command for each one, passing the element's components as positional arguments.
# @arg $@ Command to execute for each element.
# @example
#   _L_IT + L_sourceit_array arr + L_sinkit_map echo "Element:"
L_sinkit_map() {
  L_assert '' test "$#" -ge 1
  local L_v
  while L_it_next L_v; do
    "$@" "${L_v[@]}"
  done
}


# @description Pipe generator that executes a command for each element and forwards the element along.
# The variable L_v can be used to modify the value.
# @arg $@ Command to execute for each element.
#   _L_IT + L_sourceit_array arr + L_pipgen_map L_eval 'L_v=$((L_v+1))' + L_sinkit_map echo "Element:"
L_pipeit_map() {
  L_assert '' test "$#" -ge 1
  local L_v
  L_it_next L_v || return "$?"
  "$@" "${L_v[@]}"
  L_it_yield "${L_v[@]}"
}

# @description Sink generator that prints elements using `printf`.
#
# Consumes all elements and prints them to standard output.
#
# @arg [$1] Format string for `printf`. If omitted, elements are joined by a space
#           and printed on a new line.
# @example
#   _L_IT + L_sourceit_array arr + L_sinkit_printf "Item: %s\n"
L_sinkit_printf() {
  local L_v
  while L_it_next L_v; do
    if (($# == 0)); then
      L_array_join_v L_v " "
      printf "%s\n" "$L_v"
    else
      printf "$1" "${L_v[@]}"
    fi
  done
}

# @description Pipe generator that prints the element and passes it downstream.
#
# This is useful for debugging a generator chain by inspecting the elements
# as they pass through a specific point.
#
# @arg [$1] Format string for `printf`. If omitted, elements are joined by a space
#           and printed on a new line.
# @return 0 on successful yield, non-zero on upstream generator exhaustion or error.
# @example
#   _L_IT + L_sourceit_range 5 + L_pipeit_printf "DEBUG: %s\n" + L_sinkit_consume
L_pipeit_printf() {
  local L_v _L_r
  L_it_next _L_r || return $?
  if (($# == 0)); then
    L_array_join_v _L_r " "
    printf "%s\n" "$L_v"
  else
    printf "$1" "${_L_r[@]}"
  fi
  L_it_yield "${_L_r[@]}"
}


# @description Advance the iterator n-steps ahead. If n is None, consume entirely
# @arg [$1]
L_sinkit_consume() {
  if (($#)); then
    local _L_i=$1
    while ((_L_i-- > 0)); do
      L_it_next _ || return 0
    done
  else
    while L_it_next _; do
      :
    done
  fi
}

# @description Given a predicate that returns True or False, count the True results.
# @example
#   arr=(1 0 1 0)
#   _L_IT + L_sourceit_array arr + L_sinkit_quantify -v val L_eval '(( $1 == 0 ))'
L_sinkit_quantify() { L_handle_v_scalar "$@"; }
L_sinkit_quantify_v() {
  local _L_r=0
  while L_it_next L_v; do
    if "$@" "${L_v[@]}"; then
      (( ++_L_r ))
    fi
  done
  L_v=$_L_r
}

# @description Sink generator that collects all yielded elements into an array.
#
# @arg $1 <array> The name of the array variable to store the elements in.
# @example
#   local results=()
#   _L_IT + L_sourceit_range 5 + L_sinkit_assign results
#   # results now contains (0 1 2 3 4)
L_sinkit_assign() {
  L_assert '' test "$#" -eq 1
  local L_v
  while L_it_next L_v; do
    L_var_to_string_v L_v
    L_array_append "$1" "$L_v"
  done
}

# @description Filter elements from the upstream generator.
#
# Consumes elements from the upstream generator until one passes the filter
# command, and then yields that element downstream.
#
# @arg $@ Command to execute as a filter. The command is executed with the
#          current element as its positional arguments. The element passes the
#          filter if the command returns 0 (success).
# @example
#   _L_IT \
#     + L_sourceit_array array \
#     + L_pipeit_filter L_is_true \
#     + L_sinkit_printf
L_pipeit_filter() {
  L_assert '' test "$#" -ge 1
  local _L_e
  L_it_next _L_e || return "$?"
  while
    ! "$@" "${_L_e[@]}"
  do
    L_it_next _L_e || return "$?"
  done
  L_it_yield "${_L_e[@]}"
}

# @description Pipe generator that yields the first N elements.
#
# Stops the generator chain after yielding the specified number of elements.
#
# @arg $1 <int> The maximum number of elements to yield.
# @return 0 on successful yield, non-zero on upstream generator exhaustion or error.
# @example
#   _L_IT + L_sourceit_range + L_pipeit_head 3 + L_sinkit_printf
L_pipeit_head() {
  L_assert '' test "$#" -eq 1
  local _L_i=0 _L_e
  L_it_restore _L_i
  (( _L_i++ < $1 )) && {
    L_it_next _L_e || return "$?"
    L_it_yield "${_L_e[@]}"
  }
}

# @description Pipe generator that yields the last N elements.
#
# Buffers all elements from the upstream generator and then yields only the last N.
#
# @arg $1 <int> The number of trailing elements to yield.
# @return 0 on successful yield, 1 when all buffered elements are yielded.
# @example
#   _L_IT + L_sourceit_range 5 + L_pipeit_tail 2 + L_sinkit_printf
L_pipeit_tail() {
  L_assert '' test "$#" -eq 1
  local _L_i=0 _L_e _L_buf=() L_v _L_send=-1
  L_it_restore _L_buf _L_send
  if ((_L_send == -1)); then
    while L_it_next _L_e; do
      L_var_to_string_v _L_e
      _L_buf=("${_L_buf[@]::$1-1}" "$L_v")
    done
    _L_send=0
  fi
  (( _L_send < ${#_L_buf[*]} )) && {
    local -a _L_i="${_L_buf[_L_send]}"
    L_it_yield "${_L_i[@]}"
    (( ++_L_send ))
  }
}

# @description Sink generator that yields the N-th element.
#
# Consumes elements until the N-th element is reached, yields it, and then stops.
#
# @arg $1 <int> The zero-based index of the element to yield.
# @return 0 on successful yield, non-zero on upstream generator exhaustion or error.
# @example
#   _L_IT + L_sourceit_array arr + L_sinkit_nth 2 + L_sinkit_printf
L_sinkit_nth() {
  L_assert '' test "$#" -eq 1
  local _L_i=0 _L_e
  L_it_restore _L_i
  while (( _L_i < $1 )); do
    L_it_next _L_e || return "$?"
  done
  L_it_yield "${_L_e[@]}"
}

# @description Pipe generator that yields an empty element on upstream exhaustion.
#
# If the upstream generator yields an element, it is passed through. If the
# upstream generator is exhausted, this generator yields an empty element instead
# of stopping the chain.
#
# @noargs
# @return 0 on successful yield.
# @example
#   _L_IT + L_sourceit_range 0 + L_pipeit_padnone + L_sinkit_printf
L_pipeit_padnone() {
  local _L_e
  if L_it_next _L_e; then
    L_it_yield "${_L_e[@]}"
  else
    L_it_yield
  fi
}

# @description Pipe generator that yields elements in pairs.
#
# Consumes two elements from the upstream generator and yields them as a single
# tuple of `(element1, element2)`. If only one element remains, it is yielded
# with an empty second element.
#
# @noargs
# @return 0 on successful yield, non-zero on upstream generator exhaustion or error.
# @example
#   _L_IT + L_sourceit_array arr + L_pipeit_pairwise + L_sinkit_printf "%s %s\n"
L_pipeit_pairwise() {
  local _L_a _L_b=()
  L_it_next _L_a || return $?
  L_it_next _L_b || :
  L_it_yield "${_L_a[@]}" "${_L_b[@]}"
}

# @description Sink generator that calculates the dot product of two generators.
#
# Consumes elements from two separate generators and calculates their dot product.
# Both generators must yield single numeric values.
#
# @option -v <var> Store the result in this variable.
# @arg $1 <gen> The first generator state variable.
# @arg [$2] <gen> The second generator state variable.
# @return 0 on success, 1 on generator exhaustion, 2 on usage error.
# @example
#   local res
#   _L_IT -v gen1 + L_sourceit_range 4 + L_pipeit_head 4
#   _L_IT -v gen2 + L_sourceit_array numbers + L_pipeit_head 4
#   L_sinkit_dotproduct -v res gen1 gen2
L_sinkit_dotproduct() { L_handle_v_scalar "$@"; }
L_sinkit_dotproduct_v() {
  L_assert "Wrong number of positional arguments. Expected 1 or 2 2 but received $#" test "$#" -eq 2 -o "$#" -eq 1
  local a b
  L_v=0
  while
    if L_it_use "$1" L_it_next a; then
      if L_it_use "${2:--}" L_it_next b; then
        :
      else
        L_panic "Generator $1 is longer than generator ${2:--}. Generators have different length!"
      fi
    else
      if L_it_use "${2:--}" L_it_next b; then
        L_panic "Generator $1 is shorter then generator ${2:--}. Generators have different length!"
      else
        return 0
      fi
    fi
  do
    L_v=$(( L_v + a * b ))
  done
}

# @description Sink generator that performs a left fold (reduce) operation.
#
# Applies a function to an accumulator and each generated element. The accumulator
# is updated by the function's output.
#
# @option -v <str> Variable name holding the accumulator (result).
# @option -i <str> Initial accumulator value(s). Multiple uses append to the list.
# @arg $@ Command to execute for the fold operation. It receives the current
#          accumulator value(s) followed by the current element's value(s).
#          The command must update the accumulator variable(s) in place.
# @example
#   _L_IT + L_sourceit_range 5 + L_sinkit_fold_left -i 0 -v res -- L_eval 'L_v=$(($1+$2))'
L_sinkit_fold_left() { L_getopts_in -p _L_ v:i:: _L_sinkit_fold_left_in "$@"; }
_L_sinkit_fold_left_in() {
  local _L_a L_v=("${_L_i[@]}")
  while L_it_next _L_a; do
    # L_it_print_context -f "$1"
    "$@" "${L_v[@]}" "${_L_a[@]}"
  done
  L_array_assign "$_L_v" "${L_v[@]}"
}

# @description Alias for L_it_tee.
#
# @arg $1 <gen> Source generator state variable.
# @arg $@ <gen>... Destination generator state variables.
L_it_copy() { L_it_tee "$@"; }

# @description Copies a generator state to one or more new variables.
#
# This allows multiple independent generator chains to start from the same point.
#
# @arg $1 <gen> Source generator state variable.
# @arg $@ <gen>... Destination generator state variables.
# @example
#   _L_IT -v gen1 + L_sourceit_range 5
#   L_it_tee gen1 gen2 gen3
L_it_tee() {
  local _L_source=$1
  shift
  while (($#)); do
    L_array_copy "$_L_source" "$1"
    shift
  done
}

# @description Pipe generator that skips elements.
#
# Consumes elements from the upstream generator but only yields every N-th element.
#
# @arg $1 <int> The stride count (N). Must be greater than 0.
# @return 0 on successful yield, non-zero on upstream generator exhaustion or error.
# @example
#   _L_IT + L_sourceit_range 10 + L_pipeit_stride 3 + L_sinkit_printf # 0 3 6 9
L_pipeit_stride() {
  L_assert '' test "$1" -gt 0
  local _L_cnt="$1" _L_r _L_exit=0
  L_it_restore _L_exit
  if (( _L_exit )); then
    return "$_L_exit"
  fi
  while (( --_L_cnt )); do
    if L_it_next _L_r; then
      :
    else
      _L_exit="$?"
      break
    fi
  done
  if (( _L_cnt + 1 != $1 )); then
    L_it_yield "${_L_r[@]}"
  fi
}

# @description Sink generator that collects all yielded elements into a nameref array.
#
# This is an alternative to `L_sinkit_assign` that uses a nameref for efficiency.
#
# @arg $1 <array> The name of the array variable to store the elements in.
# @example
#   local results=()
#   _L_IT + L_sourceit_range 5 + L_sinkit_to_array results
L_sinkit_to_array() {
  local -n _L_to="$1" _L_r
  _L_to=()
  while L_it_next _L_r; do
    _L_to+=("$_L_r")
  done
}

# @description Pipe generator that sorts all elements.
#
# Consumes all elements from the upstream generator, buffers them, sorts them,
# and then yields them one by one.
#
# @option -A Sort associative array elements by key.
# @option -n Numeric sort.
# @option -k <int> Sort by the N-th element of the tuple (0-based index).
# @arg $1 <gen> The generator state variable.
# @return 0 on successful yield, 1 when all elements are yielded.
# @example
#   _L_IT + L_sourceit_array numbers + L_pipeit_sort -n + L_sinkit_printf
L_pipeit_sort() { L_getopts_in -p _L_opt_ Ank: _L_pipeit_sort "$@"; }
_L_pipeit_sort() {
  local _L_vals=() _L_idxs=() _L_poss=() _L_lens=() _L_i=0 _L_r _L_pos=0 _L_alllen1=1 _L_run=0
  L_it_restore _L_vals _L_idxs _L_poss _L_lens _L_i _L_alllen1 _L_run
  if (( !_L_run )); then
    # accumulate
    while L_it_next _L_r; do
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
      L_sort_bash -c _L_pipeit_sort_all _L_idxs
      declare -p _L_idxs
    fi
    #
    _L_run=1
    _L_i=0
  fi
  (( _L_i < ${#_L_idxs[*]} )) && {
    if (( _L_alllen1 )); then
      L_it_yield "${_L_vals[_L_i]}"
    else
      L_it_yield "${_L_vals[@]:(_L_poss[_L_i]):(_L_lens[_L_i])}"
    fi
    (( ++_L_i ))
  }
}

# @description Internal comparison function for L_pipeit_sort.
#
# Compares two values based on the sort options (`-n` for numeric).
#
# @arg $1 <value> First value.
# @arg $2 <value> Second value.
# @return 0 if $1 <= $2, 1 if $1 > $2, 2 on internal error.
_L_pipeit_sort_cmp() {
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

# @description Internal comparison function for multi-element sorting in L_pipeit_sort.
#
# This function is passed to `L_sort_bash` and handles sorting based on keys (`-k`)
# and associative array keys (`-A`).
#
# @arg $1 <index1> Index of the first element in the internal index array.
# @arg $2 <index2> Index of the second element in the internal index array.
# @return 0 if element1 <= element2, 1 if element1 > element2, 2 on internal error.
_L_pipeit_sort_all() {
  local -;set -x
  # Sort with specific field.
  if [[ -v _L_opt_k ]]; then
    if (( _L_opt_A )); then
      local a="${_L_vals[_L_poss[$1]+1]}" b="${_L_vals[_L_poss[$2]+1]}"
      local -A ma="$a" mb="$b"
      local a=${ma["$_L_opt_k"]} b=${mb["$_L_opt_k"]}
      _L_pipeit_sort_cmp "$a" "$b" || return "$(($?-1))"
    else
      if (( _L_opt_k < _L_lens[$1] && _L_opt_k < _L_lens[$2] )); then
        local a="${_L_vals[_L_poss[$1]+_L_opt_k]}" b="${_L_vals[_L_poss[$2]+_L_opt_k]}"
        _L_pipeit_sort_cmp "$a" "$b" || return "$(($?-1))"
      fi
    fi
  fi
  # Default sort.
  local i=0 j=0
  for ((; i != _L_lens[$1] && j != _L_lens[$2]; ++i, ++j )); do
    local a="${_L_vals[_L_poss[$1]+i]}" b="${_L_vals[_L_poss[$2]+j]}"
    _L_pipeit_sort_cmp "$a" "$b" || return "$(($?-1))"
  done
  # Stable sort.
  (( i > j && $1 > $2 ))
}

# @description Sink generator that yields the first element that evaluates to true.
# Consumes elements until one passes the `L_is_true` check, yields it, and then stops.
# @option -v <var> Store the yielded element in this variable.
# @option -d <default>
# @arg $@ Command to determine if element is true. or not.
# @return 0 on successful yield, 1 if no true element is found and no default is provided.
# @example
#   _L_IT + L_sourceit_array arr + L_sinkit_first_true -v result -d default_value L_is_true
L_sinkit_first_true() { L_getopts_in -p _L_ v:d:: _L_sinkit_first_true_in "$@"; }
_L_sinkit_first_true_in() {
  local L_v _L_found=0
  while L_it_next L_v; do
    if "$@" "${L_v[@]}"; then
      _L_found=1
      break
    fi
  done
  if ((!_L_found)); then
    if L_var_is_set _L_d; then
      L_v=("${_L_d[@]}")
    else
      return 1
    fi
  fi
  if L_var_is_set _L_v; then
    L_array_assign "$_L_v" "${L_v[@]}"
  else
    printf "%s\n" "${L_v[@]}"
  fi
}

# @description Returns 1 all the elements are equal to each other.
# @arg $@ Command to compare two values.
L_sinkit_all_equal() {
  local _L_a _L_b
  L_it_next _L_a || return 1
  while L_it_next _L_b; do
    if ! "$@" "${_L_a[@]}" "${_L_b[@]}"; then
      return 1
    fi
    _L_a=("${_L_b[@]}")
  done
}


# @description Source generator that yields each character of a string.
# @arg $1 <str> The string to iterate over.
# @return 0 on successful yield, 1 when the string is exhausted.
# @example
#   _L_IT + L_sourceit_string_chars "abc" + L_sinkit_printf
L_sourceit_string_chars() {
  local _L_idx=0
  L_it_restore _L_idx
  (( _L_idx < ${#1} ? ++_L_idx : 0 )) && {
    L_it_yield "${1:_L_idx-1:1}"
  }
}

# @description Pipe generator that yields unique, consecutive elements.
#
# Filters out elements that are the same as the immediately preceding element.
# An optional comparison command can be provided for custom comparison logic.
#
# @arg [$1] <command> Optional command to compare the last and new element.
#                     It receives `(last_element, new_element)` and should return 0 if they are the same.
# @return 0 on successful yield, non-zero on upstream generator exhaustion or error.
# @example
#   _L_IT + L_sourceit_string_chars 'AAAABBB' + L_pipeit_unique_justseen + L_sinkit_printf # A B
L_pipeit_unique_justseen() {
  local _L_last _L_new
  L_it_restore _L_last
  L_it_next _L_new || return "$?"
  if [[ -z "${_L_last}" ]]; then
    L_it_yield "$_L_new"
  elif
    if (($#)); then
      "$@" "$_L_last" "$_L_new"
    else
      [[ "$_L_last" == "$_L_new" ]]
    fi
  then
    L_it_yield "$_L_new"
  fi
  _L_last="$_L_new"
}

# @description Yield unique elements, preserving order. Remember all elements ever seen.
# @arg $@ Convertion commmand, that should set L_v variable. Default: printf -v L_v "%q "
# @example
#   _L_IT + L_sourceit_string_chars 'AAAABBBCCDAABBB' + L_pipeit_unique_everseen + L_sinkit_printf -> A B C D
#   _L_IT + L_sourceit_string_chars 'ABBcCAD' + L_pipeit_unique_everseen L_eval 'L_v=${@,,}' + L_sinkit_printf -> A B c D
L_pipeit_unique_everseen() {
  local _L_seen=() _L_new L_v
  L_it_restore _L_seen
  while
    L_it_next _L_new || return "$?"
    "${@:-L_quote_printf_v}" "${_L_new[@]}" || return "$?"
    L_set_has _L_seen "$L_v"
  do
    :
  done
  L_it_yield "${_L_new[@]}"
  L_set_add _L_seen "$L_v"
}

# @arg $@ compare function
L_pipeit_unique() {
  # todo
  :
}


# @description
# [state, ]stop[, step]
# @arg $1
# @arg $2
# @arg $3
L_pipeit_islice() {
  case "$#" in
    0) L_func_usage_error "missing positional argument"; return 2 ;;
    1) local _L_start=0 _L_stop=$1 _L_step=1 _L_r ;;
    *) local _L_start=$1 _L_stop=$2 _L_step=${3:-1} _L_r ;;
  esac
  if (( _L_start < 0 && (_L_stop != -1 && _L_stop < 0) && _L_step <= 0 )); then
    L_panic "invalid values: start=$_L_start stop=$_L_stop step=$_L_step"
  fi
  L_it_restore _L_start _L_stop
  while (( _L_start > 0 ? (_L_stop > 0 ? _L_stop-- : 0), _L_start-- : 0 )); do
    L_it_next _L_r || return "$?"
  done
  (( _L_stop == -1 || (_L_stop > 0 ? _L_stop-- : 0) )) && {
    L_it_next _L_r || return "$?"
    while (( --_L_step > 0 )); do
      L_it_next _ || break
    done
    L_it_yield "${_L_r[@]}"
  }
}

# @description Make an iterator that returns object over and over again. Runs indefinitely unless the times argument is specified.
# @option -t <int> Number of times to yield the object (default is 0, which means forever).
# @arg $@ Object to return.
L_sourceit_repeat() { L_getopts_in -p _L_ t: _L_sourceit_repeat_in "$@"; }
_L_sourceit_repeat_in() {
  if L_var_is_set _L_t; then
    L_it_restore _L_t
    (( _L_t > 0 ? _L_t-- : 0 )) && L_it_yield "$@"
  else
    L_it_yield "$@"
  fi
}

# @arg $1 size
L_pipeit_sliding_window() {
  local _L_window=() _L_lens=() _L_r
  L_it_restore _L_window _L_lens
  while (( ${#_L_lens[*]} < $1 )); do
    if ! L_it_next _L_r; then
      if (( ${#_L_lens[*]} )); then
        L_it_yield "${_L_window[@]}"
        _L_lens=()
        _L_window=()
      fi
      return 0
    fi
    _L_window+=("${_L_r[@]}")
    _L_lens+=("${#_L_r[*]}")
  done
  # Yield the window and move on.
  L_it_yield "${_L_window[@]}"
  # Remove the first element and keep the rest of the window.
  _L_window=("${_L_window[@]:(_L_lens[0])}")
  _L_lens=("${_L_lens[@]:1}")
}

# @description Requests the next element and assigns it to an associative array.
#
# This is a convenience wrapper around `L_it_next` for generators that yield
# dictionary-like elements (tuples starting with "DICT" and a serialized array).
#
# @arg $1 <array> The name of the associative array variable to assign the element to.
# @return 0 on successful assignment, non-zero on generator exhaustion or error.
L_it_next_dict() {
  L_assert '' L_var_is_associative "$1"
  local m v
  L_it_next m v || return "$?"
  L_assert '' test "$m" == "DICT"
  L_assert '' test "${v::1}" == "("
  L_assert '' test "${v:${#v}-1}" == ")"
  eval "$1=$v"
}

# @description Yields an associative array element.
#
# This is a convenience wrapper around `L_it_yield` for yielding dictionary-like
# elements. It serializes the associative array into a string and yields it as a
# tuple starting with the "DICT" marker.
#
# @arg $1 <array> The name of the associative array variable to yield.
L_it_yield_dict() {
  L_assert '' L_var_is_associative "$1"
  local L_v
  L_var_to_string_v "$1" || L_panic
  L_assert '' test "${L_v::1}" == "("
  L_assert '' test "${L_v:${#L_v}-1}" == ")"
  L_it_yield DICT "$L_v"
}

# @description Source generator that reads CSV data from stdin.
#
# Reads lines from standard input, treating the first line as headers. Each
# subsequent line is yielded as an associative array where keys are the headers.
#
# @note The field separator is hardcoded to `,`.
# @return 0 on successful yield, non-zero on EOF or error.
# @example
#   echo "col1,col2" | _L_IT + L_sourceit_read_csv + L_sinkit_printf
L_sourceit_read_csv() {
  local IFS=, headers=() i arr L_v step=0
  L_it_restore step headers
  if ((step == 0)); then
    read -ra headers || return $?
    step=1
  fi
  read -ra arr || return $?
  local -A vals
  for i in "${!headers[@]}"; do
    vals["${headers[i]}"]=${arr[i]:-}
  done
  L_it_yield_dict vals
}

# @description Pipe generator that filters out elements with empty values in a specified key.
#
# Consumes dictionary-like elements and only yields those where the value for the
# specified key (`subset`) is non-empty.
#
# @arg $1 <key> The key whose value must be non-empty.
# @return 0 on successful yield, 1 on upstream generator exhaustion.
# @example
#   _L_IT + L_sourceit_read_csv < data.csv + L_pipeit_dropna amount + L_sinkit_printf
L_pipeit_dropna() {
  local subset
  L_argskeywords / subset -- "$@" || return $?
  L_assert '' test -n "$subset"
  local -A asa=()
  while L_it_next_dict asa; do
    if [[ -n "${asa[$subset]}" ]]; then
      L_it_yield_dict asa
      return 0
    fi
  done
  return 1
}

# @description Initializes a set (implemented as a simple array).
#
# @arg $1 <array> The name of the array variable to use as a set.
L_set_init() { L_array_assign "$1"; }

# @description Adds elements to a set if they are not already present.
#
# @arg $1 <array> The name of the array variable (set).
# @arg $@ <value>... Elements to add to the set.
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

# @description Checks if a set contains a specific element.
#
# @arg $1 <array> The name of the array variable (set).
# @arg $2 <value> The element to check for.
# @return 0 if the element is in the set, 1 otherwise.
L_set_has() { L_array_contains "$1" "$2"; }

# @description Pipe generator that passes the element through unchanged.
#
# This is a no-operation pipe, useful as a placeholder or for debugging.
#
# @noargs
# @return 0 on successful yield, non-zero on upstream generator exhaustion or error.
L_pipeit_none() {
  local _L_r
  L_it_next _L_r || return "$?"
  L_it_yield "${_L_r[@]}"
}

# @description Sink generator that extracts the next element and pauses the chain.
#
# This is primarily used in `while _L_IT -R it ...` loops to extract the yielded
# value(s) into local variables and pause the generator chain until the next loop iteration.
#
# @arg $1 <var> Variable to assign the yielded element to (as a scalar or array).
# @arg $@ <var>... Multiple variables to assign the yielded tuple elements to.
# @return 0 on successful extraction, non-zero on generator exhaustion or error.
# @example
#   while _L_IT -R it + L_sourceit_range 5 + L_sinkit_iterate i; do
#     echo "Current: $i"
#   done
L_sinkit_iterate() {
  local _L_r
  L_it_next _L_r || return "$?"
  # Extract the value from the return value.
  if (($# == 1)); then
    L_array_assign "$1" "${_L_r[@]}"
  else
    L_assert "number of arguments $# is not equal to the number of tuple elements in the generator element ${#_L_r[*]}" \
      test "${#_L_r[*]}" -eq "$#"
    L_array_extract _L_r "$@"
  fi
  L_it_pause
}

# @description Pipe generator that zips elements with an array.
#
# Consumes elements from the upstream generator and yields a tuple of
# `(element, array_element)` by pairing them with elements from a given array.
#
# @arg $1 <array> The name of the array variable to zip with.
# @return 0 on successful yield, non-zero when either the generator or the array is exhausted.
# @example
#   local arr=(a b c)
#   _L_IT + L_sourceit_range 3 + L_pipeit_zip_arrays arr + L_sinkit_printf "%s: %s\n"
L_pipeit_zip_arrays() {
  local _L_r _L_i=0
  local -n _L_a=$1
  L_it_restore _L_i || return "$?"
  (( _L_i++ < ${#_L_a[*]} )) && {
    L_it_next _L_r || return "$?"
    L_it_yield "${_L_r[@]}" "${_L_a[_L_i-1]}"
  }
}

# @description Join current generator with another one.
# @arg $@ L_sourceit generator to join with.
L_pipeit_zip() {
  local _L_it=() _L_a _L_b
  L_it_restore _L_it
  if (( ${_L_it[*]} == 0 )); then
    _L_IT -v _L_it + "$@"
  fi
  L_it_next _L_a || return "$?"
  L_it_use _L_it L_it_next _L_b || return "$?"
  L_it_yield "${_L_a[@]}" "${_L_b[@]}"
}

# ]]]
# [[[ test

# @description Internal unit tests for the generator library.
# @description Internal unit tests for the generator library.
_L_it_test_1() {
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
    while _L_IT -R it + L_sourceit_array array + L_sinkit_iterate a; do
      out+=("$a")
    done
    L_unittest_arreq out "${array[@]}"
  }
  {
    local out=() it=()
    while _L_IT -R it + L_sourceit_array array + L_sinkit_iterate a; do
      out+=("$a")
    done
    L_unittest_arreq out "${array[@]}"
  }
  {
    local out1=() it=() out2=()
    while _L_IT -R it \
        + L_sourceit_array array \
        + L_pipeit_pairwise \
        + L_sinkit_iterate a b
    do
      out1+=("$a")
      out2+=("$b")
    done
    L_unittest_arreq out1 a c e
    L_unittest_arreq out2 b d f
  }
  {
    local out1=() it=() out2=() idx=() i a b
    while _L_IT -R it \
        + L_sourceit_array array \
        + L_pipeit_pairwise \
        + L_pipeit_enumerate \
        + L_sinkit_iterate i a b
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
    L_unittest_cmd -o 'a b c d e f ' \
      _L_IT \
      + L_sourceit_array array \
      + L_sinkit_map printf "%s "
  }
  {
    L_unittest_cmd -o '0 1 2 3 4 ' \
      _L_IT \
      + L_sourceit_range \
      + L_pipeit_head 5 \
      + L_sinkit_map printf "%s "
    L_unittest_cmd -o '0 1 2 3 4 ' \
      _L_IT \
      + L_sourceit_range 5 \
      + L_sinkit_map printf "%s "
    L_unittest_cmd -o '3 4 5 6 7 8 ' \
      _L_IT \
      + L_sourceit_range 3 9 \
      + L_sinkit_map printf "%s "
    L_unittest_cmd -o '3 5 7 ' \
      _L_IT \
      + L_sourceit_range 3 2 9 \
      + L_sinkit_map printf "%s "
  }
  {
    local L_v gen=() res
    _L_IT -v gen \
      + L_sourceit_range 5 \
      + L_pipeit_head 5
    L_it_use gen L_sinkit_fold_left -i 0 -v res -- L_eval 'L_v=$(($1+$2))'
    L_unittest_arreq res 10
  }
  {
    L_unittest_cmd -o 'A B C D ' \
      _L_IT \
      + L_sourceit_string_chars 'ABCD' \
      + L_sinkit_printf "%s "
    L_unittest_cmd -o 'A B C D ' \
      _L_IT \
      + L_sourceit_string_chars 'AAAABBBCCDAABBB' \
      + L_pipeit_unique_everseen \
      + L_sinkit_printf "%s "
    L_unittest_cmd -o 'A B c D ' \
      _L_IT \
      + L_sourceit_string_chars 'ABBcCAD' \
      + L_pipeit_unique_everseen L_eval 'L_v=${*,,}' \
      + L_sinkit_printf "%s "
  }
  {
    L_unittest_cmd -o "A B " \
      _L_IT \
      + L_sourceit_string_chars 'ABCDEFG' \
      + L_pipeit_islice 2 \
      + L_sinkit_printf "%s "
    L_unittest_cmd -o "C D " \
      _L_IT \
      + L_sourceit_string_chars 'ABCDEFG' \
      + L_pipeit_islice 2 4 \
      + L_sinkit_printf "%s "
    L_unittest_cmd -o "C D E F G " \
      _L_IT \
      + L_sourceit_string_chars 'ABCDEFG' \
      + L_pipeit_islice 2 -1 \
      + L_sinkit_printf "%s "
    L_unittest_cmd -o "A C E G " \
      _L_IT \
      + L_sourceit_string_chars 'ABCDEFG' \
      + L_pipeit_islice 0 -1 2 \
      + L_sinkit_printf "%s "
  }
  {
    L_unittest_cmd -o 'ABCD BDCE CDEF DEFG ' \
      _L_IT \
      + L_sourceit_string_chars 'ABCDEFG' \
      + L_pipeit_sliding_window 4 \
      + L_sinkit_printf "%s%s%s%s "
  }
  # {
  #   L_unittest_cmd -o '0 1 4 9 ' \
  #     _L_IT \
  #     + L_sourceit_range 4 \
  #     + L_pipeit_zip ${ L_it_build_temp + L_sourceit_repeat 2; } \
  #     + L_pipeit_map
  # }
  {
    local gen1=() res=()
    _L_IT -v gen1 \
      + L_sourceit_range \
      + L_pipeit_head 4
    L_it_use gen1 L_sinkit_printf "%s\n"
    echo
    _L_IT \
      + L_sourceit_array numbers \
      + L_pipeit_head 4 \
      + L_sinkit_dotproduct -v res -- gen1
     L_unittest_arreq res "$(( 0 * 2 + 1 * 0 + 2 * 4 + 3 * 4 ))"
  }
}

_L_it_test_2() {
  {
    L_unittest_cmd -o "1 3 6 10 15 " \
      L_it_make_run \
      + L_sourceit_string_chars 12345 \
      + L_pipeit_accumulate \
      + L_sinkit_printf "%s "
  }
  {
    L_unittest_cmd -o "[roses red] [violets blue] [sugar sweet] " \
      L_it_make_run \
      + L_sourceit_args roses red violets blue sugar sweet \
      + L_pipeit_batched 2 \
      + L_sinkit_printf "[%s %s] "
  }
  {
    local gen1=()
    L_it_make gen1 + L_sourceit_string_chars DEF
    L_unittest_cmd -o "A B C D E F " \
      L_it_make_run \
      + L_sourceit_string_chars ABC \
      + L_pipeit_chain gen1 \
      + L_sinkit_printf "%s "
    L_unittest_cmd -o "A B C D E F " \
      L_it_make_run \
      + L_sourceit_string_chars ABC \
      + L_pipeit_chain_gen L_sourceit_string_chars DEF \
      + L_sinkit_printf "%s "
  }
}
# ]]]

###############################################################################

# @description Main entry point for the _L_IT.sh script.
#
# Parses command-line arguments and executes internal tests or specific generator examples.
_L_it_main() {
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
  _L_it_test_2
  case "$mode" in
  while3)
    ;;
  1|'')
    ;;
  2)
    ;;
  3)
    ;;
  4)
    ;;
  5)
    _L_IT -v gen1 \
      + L_sourceit_range \
      + L_pipeit_head 4
    L_it_copy gen1 gen2
    L_it_use gen1 L_sinkit_printf
    L_it_use gen2 L_sinkit_printf
    ( L_it_use gen2 L_sinkit_printf )
    ;;
  6)
    _L_IT -v gen1 + L_sourceit_range
    _L_IT -v gen2 -s gen1 + L_pipeit_head 5
    # L_it_print_context -f gen1
    # L_it_print_context -f gen2
    L_it_use gen2 L_sinkit_printf
    ;;
  readfile)
    _L_IT \
      + L_sourceit_read file \
      + L_pipeit_transform L_strip -v L_v \
      + L_pipeit_filter L_eval '(( ${#1} != 0 ))' \
      + L_sinkit_to_array lines <<EOF
    a
  bb
      ccc
EOF
    L_sort_bash -E '(( ${#1} > ${#2} ))' -c compage_length lines
    declare -p lines
    ;;
  longest5)
    _L_IT \
      + L_sourceit_read file \
      + L_pipeit_transform L_eval 'L_regex_replace_v "$1" '$'\x1b''"\\[[0-9;]*m" ""' \
      + L_pipeit_filter L_eval '(( ${#1} != 0 ))' \
      + L_pipeit_transform L_eval 'L_v=("${#1}" "$1")' \
      + L_pipeit_sort -n -k 1 \
      + L_pipeit_transform L_eval 'L_v="$1"' \
      + L_sinkit_to_array array
    declare -p array
    ;;
  L_*)
    "${mode[@]}"
    ;;
  esac
}

if L_is_main; then
  _L_it_main "$@"
fi
