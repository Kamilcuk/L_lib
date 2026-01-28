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
# - [6] - '_L_FLOW' constant string
# - [7] - The variable name storing the flow state.
# - [_L_FLOW[2] ... _L_FLOW[2]+_L_FLOW[1]-1] - generators to eval in the chain
# - [_L_FLOW[2]+_L_FLOW[1] ... _L_FLOW[2]+_L_FLOW[1]*2-1] - restore context of generators in the chain
# - [_L_FLOW[2]+_L_FLOW[1]*2 ... ?] - current iterator value of generators
#
# Constraints:
#
# - depth >= -1
# - depth < _L_FLOW[1]
# - count of generators > 0
#
# Values:
#
# - _L_FLOW[2]+_L_FLOW[0] = current generator to execute
# - _L_FLOW[2]+_L_FLOW[1]+_L_FLOW[0] = restore context of current generator
# - #_L_FLOW[@] - _L_FLOW[2]+_L_FLOW[1]*2 = length of current iterator vlaue

L_flow_is_finished() {
  if [[ $# && "$1" != "-" && "$1" != "_L_FLOW" ]]; then local -n _L_FLOW="$1" || return 2; fi
  (( _L_FLOW[3] ))
}

# @description Initialize a new generator pipeline with a chain of source/pipe/sink functions.
#
# Creates and initializes the internal generator context array that manages the execution state
# of a generator pipeline. Each generator in the chain is stored with its execution context,
# allowing for lazy evaluation and state preservation between yields.
#
# The generator pipeline uses a push-down automaton pattern where each level in the pipeline
# can yield values upward and request values downward. This enables composition of arbitrary
# generator chains.
#
# @arg $1 <var> Variable name to store generator context (typically `_L_FLOW`). If omitted, uses `_L_FLOW`.
# @arg $@ Generator function scripts to chain together. Functions are evaluated in order from
#          left to right during pipeline execution.
# @return 0 on success, 2 if variable binding fails
# @example
#   local gen
#   L_flow_new gen 'L_flow_source_range 5' 'L_flow_pipe_head 3' L_flow_sink_printf
L_flow_new() {
  if [[ "$1" != "_L_FLOW" ]]; then local -n _L_FLOW="$1" || return 2; fi
  shift
  # Create context.
  _L_FLOW=(
    -1         # [0] - depth
    "$#"       # [1] - number    of generators in chain
    8          # [2] - offset
    0          # [3] - finished?
    ""         # [4] - yielded?
    0          # [5] - paused?
    "_L_FLOW"  # [6] - mark
    "$1"       # [7] - name
    "${@%% }"  # generators
    "${@//*}"  # generators state
  )
}

L_flow_append() {
  if [[ "$1" != "_L_FLOW" ]]; then local -n _L_FLOW="$1" || return 2; fi
  shift
  # Merge context if -f option is given.
  if ! (( _L_FLOW[0] == -1 && _L_flow_start[1] > 0 )); then
    L_panic "not possible to merge already started generator context"
  fi
  if (( _L_FLOW[2] != 4 )); then
    L_panic "merging context not possible, invalid context"
  fi
  if (( _L_FLOW[3] != 0 )); then
    L_panic "not possible to merge already finished generator"
  fi
  # L_var_get_nameref_v _L_FLOW
  # L_var_to_string "$L_v"
  # printf "%q\n" "${_L_FLOW[@]:2:_L_flow_start[2]-2}"
  _L_FLOW=(
    "${_L_FLOW[0]}"
    "$(( _L_FLOW[1] + $# ))"
    "${_L_FLOW[@]:2:_L_FLOW[2]-2}"
    "${@%% }"  # generators
    "${_L_FLOW[@]:( _L_FLOW[2]           ):( _L_FLOW[1] )}"
    "${@//*}"  # generators state
    "${_L_FLOW[@]:( _L_FLOW[2]+_L_FLOW[1] ):( _L_FLOW[1] )}"
  )
}

# @description Build a generator pipeline using the pipeline DSL syntax.
#
# Parses pipeline syntax where source, pipe, and sink functions are separated by `+` tokens.
# The `+` token acts as a stage separator and appears before the first generator and between stages.
# This syntactic sugar simplifies the visual composition of generator chains.
#
# @arg $1 <var> Variable name to store generator context (typically `_L_FLOW`).
# @arg $2 Single `+` token required as separator before first function.
# @arg $@ Alternating function names and `+` separators (e.g., func1 + func2 + func3).
# @return 0 on success, 2 on argument error
# @example
#   local gen
#   L_flow_make gen + L_flow_source_range 5 + L_flow_pipe_head 3 + L_flow_sink_printf
L_flow_make() {
  if (( $# < 3 )); then
    L_panic "There must be more than 3 positional arguments: $#"
  fi
  if [[ "$2" != "+" ]]; then
    L_panic "Second positional argument must be a +"
  fi
  # Read arguments.
  local _L_flow_funcs=() _L_i
  for _L_i in "${@:2}"; do
    if [[ "$_L_i" == "+" ]]; then
      _L_flow_funcs=("" "${_L_flow_funcs[@]}")
    else
      if [[ -z "${_L_flow_funcs[0]:-}" ]]; then
        if [[ "$(type -t "$_L_i")" != "function" ]]; then
          L_panic "Not a function: $_L_i"
        fi
      fi
      L_printf_append _L_flow_funcs[0] "%q " "$_L_i"
    fi
  done
  #
  L_flow_new "$1" "${_L_flow_funcs[@]}"
}

# @description Start execution of a generator pipeline.
#
# Begins pipeline execution by setting the execution depth to 0 and invoking the first
# stage generator. This must be called once before making any calls to L_flow_next.
# A pipeline can only be run once; attempting to run an already-running or exhausted
# generator will result in an error.
#
# @arg $1 <var> Generator context variable (or `-` to use `_L_FLOW`). If omitted, uses `_L_FLOW`.
# @return 0 on success, non-zero if generator is not in initial state
# @example
#   local gen
#   L_flow_make gen + L_flow_source_range 5 + L_flow_sink_printf
#   L_flow_run gen
L_flow_run() {
  if [[ "$1" != "_L_FLOW" && "$1" != "-" ]]; then local -n _L_FLOW="$1" || return 2; fi
  if (( _L_FLOW[0] != -1 )); then
    L_panic 'depth at run stage should be -1. Are you trying to run a running generator?'
  fi
  _L_FLOW[0]=0
  local _L_flow_cmd=${_L_FLOW[_L_FLOW[2]+_L_FLOW[0]]}
  if [[ -z "$_L_flow_cmd" ]]; then
    L_panic "internal error: generator ${_L_FLOW[0]} is empty?"
  fi
  L_debug "Calling function [$_L_flow_cmd] at depth=${_L_FLOW[0]}"
  eval "$_L_flow_cmd" || L_panic "Function [$_L_flow_cmd] exited with $?"
}

L_flow_make_run() {
  local _L_FLOW=()
  L_flow_make _L_FLOW "$@"
  L_flow_run _L_FLOW
}

# @description Execute a command with a generator variable bound to `_L_FLOW`.
#
# This is useful when you need to pass a generator state variable to a function
# that expects the generator state to be in a variable named `_L_FLOW`.
#
# @arg $1 <var> The generator state variable name. Use `-` to use the current `_L_FLOW`.
# @arg $@ Command to execute.
# @example
#   L_flow_use my_gen L_flow_sink_printf
L_flow_use() {
  if [[ "$1" != "_L_FLOW" && "$1" != "-" ]]; then local -n _L_FLOW="$1" || return 2; fi
  "${@:2}"
}

# @description Pauses the current generator execution.
#
# This sets the internal pause flag, which can be checked by the generator chain
# to stop execution and allow the caller to inspect the state or resume later.
#
# @noargs
L_flow_pause() {
  _L_FLOW[5]=1
}

# @description Prints the internal state of the current generator chain.
#
# This is primarily a debugging tool to inspect the execution depth, function
# chain, saved contexts, and the current yielded value.
#
# @noargs
L_flow_print_context() {
  local i
  echo "_L_FLOW<-> depth=${_L_FLOW[0]} funcs=${_L_FLOW[1]} offset=${_L_FLOW[2]} finished=${_L_FLOW[3]} yielded=${_L_FLOW[4]} alllen=${#_L_FLOW[*]}"
  if L_var_get_nameref -v i _L_FLOW; then
    echo "  _L_FLOW is a namereference to $i"
  fi
  for (( i = 0; i < _L_FLOW[1]; ++i )); do
    echo "  funcs[$i]=${_L_FLOW[_L_FLOW[2]+i]}"
    echo "    context[$i]=${_L_FLOW[_L_FLOW[2]+_L_FLOW[1]+i]}"
  done
  echo -n "  ret=("
  for (( i = _L_FLOW[2] + _L_FLOW[1] * 2; i < ${#_L_FLOW[*]}; ++i )); do
    printf "%q%.*s" "${_L_FLOW[i]}" "$(( i + 1 == ${#_L_FLOW[@]} ? 0 : 1 ))" " " # "
  done
  echo ")"
}

# @description Internal function to request the next element while storing success status.
#
# This is the low-level implementation of generator advancement. It handles the
# push-down automaton depth tracking, generator invocation, and value extraction.
# Unlike L_flow_next, this function stores the success/failure status in a variable
# instead of using return code, allowing for complex control flow patterns.
#
# On success (when a value is yielded), stores 1 in the status variable.
# On failure (when generator is exhausted), stores 0 and returns success (0).
#
# @arg $1 <var> Variable to store success status (1 = yielded, 0 = exhausted).
# @arg $2 <var> Generator context variable (or `-` to use `_L_FLOW`).
# @arg $@ <var>... Variables to assign the yielded tuple elements to.
# @return 0 always on normal operation
# @see L_flow_next
# @example
#   local ok value
#   L_flow_next_ok ok - value || return $?
#   if (( ok )); then
#     echo "Got: $value"
#   fi
L_flow_next_ok() { L_flow_use "$2" _L_flow_next_ok "$1" "${@:3}"; }

_L_flow_next_ok() {
  # Call generate at next depth to get the value.
  if [[ "${_L_FLOW[6]}" != "_L_FLOW" ]]; then
    L_panic "invalid input variable is not a generator"
  fi
  if (( _L_FLOW[0] < -1 )); then
    L_panic "internal error: depth is lower then -1"
  fi
  # Increase depth.
  (( _L_FLOW[0]++ ))
  if (( _L_FLOW[0] >= _L_FLOW[1] )); then
    L_panic "internal error: depth is greater then the number of generators"
  fi
  local _L_flow_cmd=${_L_FLOW[_L_FLOW[2]+_L_FLOW[0]]}
  if [[ -z "$_L_flow_cmd" ]]; then
    L_panic "internal error: generator ${_L_FLOW[0]} is empty?"
  fi
  L_debug "Calling function [$_L_flow_cmd] at depth=${_L_FLOW[0]}"
  eval "$_L_flow_cmd" || L_panic "Function [$_L_flow_cmd] exited with $?"
  # Store the result in ok variable if the function yielded a value or finished?
  if [[ -z "${_L_FLOW[4]}" ]]; then
    printf -v "$1" "0"
  else
    printf -v "$1" "1"
  fi
  # Reduce depth
  if (( _L_FLOW[0] < 0 )); then
    L_panic "internal error: depth is lower then 0 after call [$_L_flow_cmd]"
  fi
  (( _L_FLOW[0]-- ))
  if ((${!1})); then
    # If the function did yield a value.
    local _L_flow_res=("${_L_FLOW[@]:(_L_FLOW[2]+_L_FLOW[1]*2)}")
    L_debug "Returned [$_L_flow_cmd] at depth=${_L_FLOW[0]} yielded#${#_L_flow_res[*]}={${_L_flow_res[*]}}"
    # Extract the value from the return value.
    if (( $# == 2 )); then
      L_array_assign "$2" "${_L_flow_res[@]}"
    else
      if (( ${#_L_flow_res[*]} != $# - 1 )); then
        L_panic "number of arguments $# is not equal to the number of tuple elements in the generator element ${#_L_flow_res[*]}"
      fi
      L_array_extract _L_flow_res "${@:2}"
    fi
  else
    # If the function is finished.
    L_debug "Function [$_L_flow_cmd] did not yield so finished"
    # If depth is 0
    if (( _L_FLOW[0] == 0 )); then
      # Mark that the generator is finished.
      _L_FLOW[3]=1
    fi
  fi
  # Clear yield flag.
  _L_FLOW[4]=""
}

# @description Requests the next element from the upstream generator.
#
# This is the primary user-facing function for consuming elements in a generator chain.
# It advances the generator pipeline, requesting values from the upstream stages and
# ultimately consuming them at the sink stage. Returns 0 if a value was successfully
# yielded, non-zero if the generator is exhausted.
#
# This function is designed to be used directly in while loops for convenient iteration.
# The generator context must be explicitly provided (use `-` to refer to the current `_L_FLOW`).
#
# @arg $1 <var> Generator context variable (or `-` to use current `_L_FLOW`).
# @arg $@ <var>... Variables to assign the yielded tuple elements to.
# @return 0 on successful yield, 1 when generator is exhausted
# @see L_flow_next_ok For explicit status checking in complex control flow
# @example
#   # Simple iteration pattern
#   local element
#   while L_flow_next - element; do
#     echo "Got: $element"
#   done
#
#   # Tuple unpacking
#   local key value
#   while L_flow_next - key value; do
#     echo "$key => $value"
#   done
L_flow_next() {
  local _L_ok
  L_flow_next_ok _L_ok "$@" || L_panic "L_flow_next_ok exited with $?"
  return "$(( !_L_ok ))"
}

# @description Internal helper to save local variables to the generator context.
#
# This function is registered as a `L_finally -r` trap to execute on function
# return. It serializes the specified local variables into a string that is
# stored in the generator's context array, allowing the generator to resume
# from the correct state on the next call.
#
# @arg $@ Names of local variables to save.
_L_flow_store() {
  # Run only on RETURN signal from L_finally.
  if [[ -v L_SIGNAL && "$L_SIGNAL" != "RETURN" ]]; then
    return
  fi
  # Create a string that will be evaled later.
  local L_v _L_flow_i
  _L_FLOW[_L_FLOW[2]+_L_FLOW[1]+_L_FLOW[0]]=""
  for _L_flow_i; do
    L_var_to_string_v "$_L_flow_i"
    _L_FLOW[_L_FLOW[2]+_L_FLOW[1]+_L_FLOW[0]]+="$_L_flow_i=$L_v;"
  done
  _L_FLOW[_L_FLOW[2]+_L_FLOW[1]+_L_FLOW[0]]+="#${FUNCNAME[2]}"
  L_debug "${_L_FLOW[7]}: Save state depth=${_L_FLOW[0]} idx=$((_L_FLOW[2]+_L_FLOW[1]+_L_FLOW[0])) caller=${FUNCNAME[2]} variables=$* eval=${_L_FLOW[_L_FLOW[2]+_L_FLOW[1]+_L_FLOW[0]]}"
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
#     L_flow_restore i
#     # ... generator logic using 'i' ...
#   }
L_flow_restore() {
  # L_log "$@ ${!1} ${FUNCNAME[1]}"
  if (( $# )); then
    local _L_flow_restore_iterator
    for _L_flow_restore_iterator; do
      if
        ! L_var_is_set "$_L_flow_restore_iterator" &&
        ! L_var_is_array "$_L_flow_restore_iterator" &&
        ! L_var_is_associative "$_L_flow_restore_iterator"
      then
        L_panic "Variable $_L_flow_restore_iterator from ${FUNCNAME[1]} is not set, not an array and not an associative array"
      fi
    done
    L_finally -r -s 1 _L_flow_store "$@"
    L_debug "${_L_FLOW[7]}: Load state depth=${_L_FLOW[0]} idx=$((_L_FLOW[2]+_L_FLOW[1]+_L_FLOW[0])) caller=${FUNCNAME[1]} variables=$* eval=${_L_FLOW[ (_L_FLOW[2]+_L_FLOW[1]+_L_FLOW[0]) ]}"
    eval "${_L_FLOW[ (_L_FLOW[2]+_L_FLOW[1]+_L_FLOW[0]) ]}"
  fi
}

# @description Yields a value from the current generator.
#
# This function stores the yielded value(s) in the generator state array and
# sets a flag to indicate a successful yield. The generator function must
# return 0 immediately after calling `L_flow_yield`.
#
# @arg $@ The value(s) to yield. Can be a single scalar or multiple elements for a tuple.
# @example
#   L_flow_yield "element"
#   L_flow_yield "key" "value"
L_flow_yield() {
  if [[ -n "${_L_FLOW[4]}" ]]; then
    L_panic "Generator yielded a value twice, previous from ${_L_FLOW[4]}. Check the generator source code and make sure it only calls L_flow_yield once before returning.$L_NL$(L_flow_print_context)"
  fi
  _L_FLOW=("${_L_FLOW[@]:: (_L_FLOW[2]+_L_FLOW[1]*2) }" "$@")
  _L_FLOW[4]=${FUNCNAME[*]}
}

L_IT_STOP=1

# ]]]
# [[[ source generators
# @section source generators

# @description Generate elements from arguments in order
L_flow_source_args() {
  local _L_i=0
  L_flow_restore _L_i
  if (( _L_i < $# ? ++_L_i : 0 )); then
    L_flow_yield "${*:_L_i:1}"
  fi
}

# @description Source generator that yields elements from a bash array.
# Iterates over the elements of a given array, yielding one element per call.
# @arg $1 <array> The name of the array variable to iterate over.
# @return 0 on successful yield, 1 when the array is exhausted.
# @example
#   local arr=(a b c)
#   _L_FLOW + L_flow_source_array arr + L_flow_sink_printf
L_flow_source_array() {
  if (( $# != 1 )); then
    L_panic ''
  fi
  local _L_i=0 _L_len=""
  L_flow_restore _L_i _L_len
  if [[ -z "$_L_len" ]]; then
    L_array_len -v _L_len "$1"
  fi
  if (( _L_i < _L_len )); then
    local -n arr=$1
    L_flow_yield "${arr[_L_i++]}"
  fi
}

# @description Source generator producing integer sequences.
# Generates a sequence of integers, similar to Python's `range()`.
# Maintains internal state through `L_flow_restore` and `L_flow_yield`.
# @arg [$1] [END] If one argument, emits 0, 1, ..., END-1.
# @arg [$1] [START] [$2] [END] If two arguments, emits START, START+1, ..., END-1.
# @arg [$1] [START] [$2] [STEP] [$3] [END] If three arguments, emits START, START+STEP, ... while < END.
# @return 0 on successful yield, 1 when sequence is exhausted, 2 on invalid invocation.
# @example
#   L_flow_make_run + L_flow_source_range 5 + L_flow_sink_printf  # 0 1 2 3 4
#   L_flow_make_run + L_flow_source_range 3 9 + L_flow_sink_printf # 3 4 5 6 7 8
#   L_flow_make_run + L_flow_source_range 3 2 9 + L_flow_sink_printf # 3 5 7
L_flow_source_range() {
  local i=0
  L_flow_restore i
  case "$#" in
    0)
      L_flow_yield "$i"
      i=$(( i + 1 ))
      ;;
    1)
      if (( i < $1 )); then
        L_flow_yield "$i"
        i=$(( i + 1 ))
      fi
      ;;
    2)
      if (( i < $2 - $1 )); then
        L_flow_yield "$(( i + $1 ))"
        i=$(( i + 1 ))
      fi
      ;;
    3)
      if (( i < $3 - $1 )); then
        L_flow_yield "$(( i + $1 ))"
        i=$(( i + $2 ))
      fi
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
L_flow_source_count() {
  local _L_start=${1:-0} _L_step=${2:-1} _L_i=0
  L_flow_restore _L_i
  L_flow_yield "$(( _L_i++ * _L_step + _L_start ))"
}

# @description Pipe generator that cycles through yielded elements.
# Yields elements from the upstream generator until it is exhausted, then starts
# yielding the collected elements from the beginning indefinitely.
# @noargs
# @return 0 on successful yield.
# @example
#   _L_FLOW + L_flow_source_array arr + L_flow_pipe_cycle + L_flow_pipe_head 10 + L_flow_sink_printf
L_flow_pipe_cycle() {
  local i=-1 seen=() v ok
  L_flow_restore i seen
  if ((i == -1)); then
    L_flow_next_to ok - v || return "$?"
    if ((ok)); then
      seen+=("$v")
      L_flow_yield "$v"
      return
    else
      i=0
    fi
  fi
  L_flow_yield "${seen[i]}"
  i=$(( i + 1 % ${#seen[*]} ))
}

# @description Source generator that repeats a value.
#
# @arg $1 <value> The value to repeat.
# @arg [$2] <int> The number of times to repeat the value. If omitted, repeats indefinitely.
# @return 0 on successful yield, 1 when the repeat count is reached.
# @example
#   _L_FLOW + L_flow_source_repeat "hello" 3 + L_flow_sink_printf
L_flow_source_repeat() {
  case "$#" in
    1) L_flow_yield "$1" ;;
    2)
      local i=0
      L_flow_restore i
      if (( i++ < $2 )); then
        L_flow_yield "$1"
      fi
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
L_flow_pipe_accumulate() { L_getopts_in -p _L_ i:: _L_flow_pipe_accumulate_in "$@"; }
_L_flow_pipe_accumulate_add() { L_v=$(( $1 + $2 )); }
_L_flow_pipe_accumulate_in() {
  local _L_init=0 _L_total=() L_v ok
  L_flow_restore _L_total _L_init
  if (( _L_init == 0 ? _L_init = 1 : 0 )); then
    if ! L_var_is_set _L_i; then
      L_flow_next_ok ok - L_v
      if ((!ok)); then
        return 0
      fi
      _L_total=("${L_v[@]}")
    else
      _L_total=("${_L_i[@]}")
    fi
    L_flow_yield "${_L_total[@]}"
  else
    L_flow_next_ok ok - L_v
    if ((ok)); then
      "${@:-_L_flow_pipe_accumulate_add}" "${_L_total[@]}" "${L_v[@]}"
      _L_total=("${L_v[@]}")
      L_flow_yield "${L_v[@]}"
    fi
  fi
}

# @description Batch data from the iterable into tuples of length n. The last batch may be shorter than n.
# @option -s If set, be strict.
# @arg $1 count
L_flow_pipe_batch() { L_getopts_in -p _L_ -n '?' -- 's' _L_flow_pipe_batch_in "$@"; }
_L_flow_pipe_batch_in() {
  local _L_count=$1 _L_batch=() L_v _L_ok
  while (( _L_count-- > 0 )); do
    L_flow_next_ok _L_ok - L_v
    if (( _L_ok )); then
      _L_batch+=("${L_v[@]}")
    else
      if (( _L_s )); then
        L_func_error "incomplete batch"
        return 2
      fi
      break
    fi
  done
  if ((${#_L_batch[@]})); then
    L_flow_yield "${_L_batch[@]}"
  fi
}

# @description Chain current iterator with other iterators.
# @arg $@ other iterators
L_flow_pipe_chain() {
  local _L_i=1 _L_r _L_flow _L_ok
  L_flow_restore _L_i
  set -- - "$@"
  while (( _L_i <= $# )); do
    echo "${*:_L_i:1}" >&2
    L_flow_next_ok _L_ok "${*:_L_i:1}" _L_r
    if (( _L_ok )); then
      L_flow_yield "${_L_r[@]}"
      return 0
    else
      _L_i=$(( _L_i + 1 ))
    fi
  done
}

# @description Chain current iterator with other single command sourcegen iterator.
# @arg $@ One sourcegen command.
L_flow_pipe_chain_gen() {
  local _L_flow=() _L_done=0 _L_r
  L_flow_restore _L_flow _L_done
  local _L_ok
  if (( _L_done == 0 )) && L_flow_next_ok _L_ok - _L_r && (( _L_ok )); then
    L_flow_yield "${_L_r[@]}"
  else
    _L_done=1
    if (( ${#_L_flow[*]} == 0 )); then
      L_flow_make _L_flow + "$@" || return "$?"
    fi
    L_flow_next_ok _L_ok _L_flow _L_r
    if (( _L_ok )); then
      L_flow_yield "${_L_r[@]}"
    fi
  fi
}

# @description Pipe generator that yields a tuple of (index, element).
# Prepends a zero-based index to each element received from the upstream generator.
# @noargs
# @return 0 on successful yield, non-zero on upstream generator exhaustion or error.
# @example
#   _L_FLOW + L_flow_source_array arr + L_flow_pipe_enumerate + L_flow_sink_printf "%s: %s\n"
L_flow_pipe_enumerate() {
  if (( $# != 0 )); then
    L_panic ''
  fi
  local _L_i=0 _L_r _L_ok
  L_flow_restore _L_i
  L_flow_next_ok _L_ok - _L_r || return $?
  if (( _L_ok )); then
    L_flow_yield "$_L_i" "${_L_r[@]}"
    _L_i=$(( _L_i + 1 ))
  fi
}

# @description Sink generator that executes a command for each element.
# Consumes all elements from the upstream generator and executes the provided
# command for each one, passing the element's components as positional arguments.
# @arg $@ Command to execute for each element.
# @example
#   _L_FLOW + L_flow_source_array arr + L_flow_sink_map echo "Element:"
L_flow_sink_map() {
  if (( $# < 1 )); then
    L_panic ''
  fi
  local L_v _L_ok
  while
    L_flow_next_ok _L_ok - L_v || return $?
    (( _L_ok ))
  do
    "$@" "${L_v[@]}" || return $?
  done
}


# @description Pipe generator that executes a command for each element and forwards the element along.
# The variable L_v can be used to modify the value.
# @arg $@ Command to execute for each element.
#   _L_FLOW + L_flow_source_array arr + L_pipgen_map L_eval 'L_v=$((L_v+1))' + L_flow_sink_map echo "Element:"
L_flow_pipe_map() {
  if (( $# < 1 )); then
    L_panic ''
  fi
  local L_v _L_ok
  L_flow_next_ok _L_ok - L_v || return $?
  if (( _L_ok )); then
    "$@" "${L_v[@]}" || return $?
    L_flow_yield "${L_v[@]}"
  fi
}

# @description Sink generator that prints elements using `printf`.
#
# Consumes all elements and prints them to standard output.
#
# @arg [$1] Format string for `printf`. If omitted, elements are joined by a space
#           and printed on a new line.
# @example
#   _L_FLOW + L_flow_source_array arr + L_flow_sink_printf "Item: %s\n"
L_flow_sink_printf() {
  local L_v _L_ok
  while
    L_flow_next_ok _L_ok - L_v || return $?
    (( _L_ok ))
  do
    if (( $# == 0 )); then
      printf "%s\n" "${L_v[*]}"
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
#   _L_FLOW + L_flow_source_range 5 + L_flow_pipe_printf "DEBUG: %s\n" + L_flow_sink_consume
L_flow_pipe_printf() {
  local L_v _L_r _L_ok
  L_flow_next_ok _L_ok - _L_r || return $?
  if (( _L_ok )); then
    if (( $# == 0 )); then
      printf "%s\n" "${L_v[*]}"
    else
      printf "$1" "${_L_r[@]}"
    fi
    L_flow_yield "${_L_r[@]}"
  fi
}


# @description Advance the iterator n-steps ahead. If n is None, consume entirely
# @arg [$1]
L_flow_sink_consume() {
  if (( $# )); then
    local _L_i=$1
    while (( _L_i-- > 0 )); do
      L_flow_next - _ || return 0
    done
  else
    while L_flow_next - _; do
      :
    done
  fi
}

# @description Given a predicate that returns True or False, count the True results.
# @example
#   arr=(1 0 1 0)
#   _L_FLOW + L_flow_source_array arr + L_flow_sink_quantify -v val L_eval '(( $1 == 0 ))'
L_flow_sink_quantify() { L_handle_v_scalar "$@"; }
L_flow_sink_quantify_v() {
  local _L_r=0
  while L_flow_next - L_v; do
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
#   _L_FLOW + L_flow_source_range 5 + L_flow_sink_assign results
#   # results now contains (0 1 2 3 4)
L_flow_sink_assign() {
  if (( $# != 1 )); then
    L_panic ''
  fi
  local L_v
  while L_flow_next - L_v; do
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
#   _L_FLOW \
#     + L_flow_source_array array \
#     + L_flow_pipe_filter L_is_true \
#     + L_flow_sink_printf
L_flow_pipe_filter() {
  if (( $# < 1 )); then
    L_panic ''
  fi
  local L_v _L_ok
  while
    L_flow_next_ok _L_ok - L_v || return $?
    (( _L_ok ))
  do
    if "$@" "${L_v[@]}"; then
      L_flow_yield "${L_v[@]}"
      break
    fi
  done
}

# @description Pipe generator that yields the first N elements.
#
# Stops the generator chain after yielding the specified number of elements.
#
# @arg $1 <int> The maximum number of elements to yield.
# @return 0 on successful yield, non-zero on upstream generator exhaustion or error.
# @example
#   _L_FLOW + L_flow_source_range + L_flow_pipe_head 3 + L_flow_sink_printf
L_flow_pipe_head() {
  if (( $# != 1 )); then
    L_panic ''
  fi
  local _L_i=0 _L_e _L_ok
  L_flow_restore _L_i
  if (( _L_i++ < $1 )); then
    L_flow_next_ok _L_ok - _L_e || return $?
    if (( _L_ok )); then
      L_flow_yield "${_L_e[@]}"
    fi
  fi
}

# @description Pipe generator that yields the last N elements.
#
# Buffers all elements from the upstream generator and then yields only the last N.
#
# @arg $1 <int> The number of trailing elements to yield.
# @return 0 on successful yield, 1 when all buffered elements are yielded.
# @example
#   _L_FLOW + L_flow_source_range 5 + L_flow_pipe_tail 2 + L_flow_sink_printf
L_flow_pipe_tail() {
  if (( $# != 1 )); then
    L_panic ''
  fi
  local _L_i=0 _L_e _L_buf=() L_v _L_send=-1
  L_flow_restore _L_buf _L_send
  if (( _L_send == -1 )); then
    while L_flow_next - _L_e; do
      L_var_to_string_v _L_e
      _L_buf=("${_L_buf[@]::$1-1}" "$L_v")
    done
    _L_send=0
  fi
  (( _L_send < ${#_L_buf[*]} )) && {
    local -a _L_i="${_L_buf[_L_send]}"
    L_flow_yield "${_L_i[@]}"
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
#   _L_FLOW + L_flow_source_array arr + L_flow_sink_nth 2 + L_flow_sink_printf
L_flow_sink_nth() {
  if (( $# != 1 )); then
    L_panic ''
  fi
  local _L_i=0 _L_e _L_ok
  L_flow_restore _L_i
  while (( _L_i < $1 )); do
    L_flow_next_ok _L_ok - _L_e
    if (( !_L_ok )); then
      return 1
    fi
    (( ++_L_i ))
  done
  L_flow_yield "${_L_e[@]}"
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
#   _L_FLOW + L_flow_source_range 0 + L_flow_pipe_padnone + L_flow_sink_printf
L_flow_pipe_padnone() {
  local _L_e _L_ok
  L_flow_next_ok _L_ok - _L_e
  if (( _L_ok )); then
    L_flow_yield "${_L_e[@]}"
  else
    L_flow_yield
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
#   _L_FLOW + L_flow_source_array arr + L_flow_pipe_pairwise + L_flow_sink_printf "%s %s\n"
L_flow_pipe_pairwise() {
  local _L_a _L_b=() _L_ok
  L_flow_next_ok _L_ok - _L_a || return $?
  if (( _L_ok )); then
    L_flow_next_ok _L_ok - _L_b || return $?
    if (( _L_ok )); then
      L_flow_yield "${_L_a[@]}" "${_L_b[@]}"
    else
      L_flow_yield "${_L_a[@]}"
    fi
  fi
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
#   _L_FLOW -v gen1 + L_flow_source_range 4 + L_flow_pipe_head 4
#   _L_FLOW -v gen2 + L_flow_source_array numbers + L_flow_pipe_head 4
#   L_flow_sink_dotproduct -v res gen1 gen2
L_flow_sink_dotproduct() { L_handle_v_scalar "$@"; }
L_flow_sink_dotproduct_v() {
  if (( $# != 2 && $# != 1 )); then
    L_panic "Wrong number of positional arguments. Expected 1 or 2 2 but received $#"
  fi
  local a b _L_ok1 _L_ok2
  L_v=0
  while
    L_flow_next_ok _L_ok1 "$1" a
    if (( _L_ok1 )); then
      L_flow_next_ok _L_ok2 "${2:--}" b
      if (( _L_ok2 )); then
        :
      else
        L_panic "Generator $1 is longer than generator ${2:--}. Generators have different length!"
      fi
    else
      L_flow_next_ok _L_ok2 "${2:--}" b
      if (( _L_ok2 )); then
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
#   _L_FLOW + L_flow_source_range 5 + L_flow_sink_fold_left -i 0 -v res -- L_eval 'L_v=$(($1+$2))'
L_flow_sink_fold_left() { L_getopts_in -p _L_ v:i:: _L_flow_sink_fold_left_in "$@"; }
_L_flow_sink_fold_left_in() {
  local _L_a L_v=("${_L_i[@]}")
  while L_flow_next - _L_a; do
    # L_flow_print_context -f "$1"
    "$@" "${L_v[@]}" "${_L_a[@]}"
  done
  L_array_assign "$_L_v" "${L_v[@]}"
}

# @description Alias for L_flow_tee.
#
# @arg $1 <gen> Source generator state variable.
# @arg $@ <gen>... Destination generator state variables.
L_flow_copy() { L_flow_tee "$@"; }

# @description Copies a generator state to one or more new variables.
#
# This allows multiple independent generator chains to start from the same point.
#
# @arg $1 <gen> Source generator state variable.
# @arg $@ <gen>... Destination generator state variables.
# @example
#   _L_FLOW -v gen1 + L_flow_source_range 5
#   L_flow_tee gen1 gen2 gen3
L_flow_tee() {
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
#   _L_FLOW + L_flow_source_range 10 + L_flow_pipe_stride 3 + L_flow_sink_printf # 0 3 6 9
L_flow_pipe_stride() {
  if (( $1 <= 0 )); then
    L_panic ''
  fi
  local _L_cnt="$1" _L_r _L_exit=0 _L_ok
  L_flow_restore _L_exit
  if (( _L_exit )); then
    return "$_L_exit"
  fi
  while (( --_L_cnt )); do
    L_flow_next_ok _L_ok - _L_r
    if (( !_L_ok )); then
      _L_exit=1
      break
    fi
  done
  if (( _L_cnt + 1 != $1 )); then
    L_flow_yield "${_L_r[@]}"
  fi
}

# @description Sink generator that collects all yielded elements into a nameref array.
#
# This is an alternative to `L_flow_sink_assign` that uses a nameref for efficiency.
#
# @arg $1 <array> The name of the array variable to store the elements in.
# @example
#   local results=()
#   _L_FLOW + L_flow_source_range 5 + L_flow_sink_to_array results
L_flow_sink_to_array() {
  local _L_r _L_ok
  local -n _L_to="$1"
  _L_to=()
  while
    L_flow_next_ok _L_ok - _L_r || return $?
    (( _L_ok ))
  do
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
#   _L_FLOW + L_flow_source_array numbers + L_flow_pipe_sort -n + L_flow_sink_printf
L_flow_pipe_sort() { L_getopts_in -p _L_opt_ Ank: _L_flow_pipe_sort "$@"; }
_L_flow_pipe_sort() {
  local _L_vals=() _L_idxs=() _L_poss=() _L_lens=() _L_i=-1 _L_r _L_pos=0 _L_alllen1=1
  L_flow_restore _L_vals _L_idxs _L_poss _L_lens _L_i _L_alllen1
  if (( _L_i == -1 )); then
    _L_i=0
    # On first run, accumulate and sort.
    while
      L_flow_next_ok _L_ok - _L_r || return $?
      (( _L_ok ))
    do
      _L_idxs+=("$_L_i")
      _L_poss+=("$_L_pos")
      _L_lens+=("${#_L_r[*]}")
      _L_vals+=("${_L_r[@]}")
      _L_i=$(( _L_i + 1 ))
      _L_pos=$(( _L_pos + ${#_L_r[*]} ))
      _L_alllen1=$(( _L_alllen1 && ${#_L_r[*]} == 1 ))
    done
    if (( _L_alllen1 )); then
      # If all elements are length 1.
      L_sort _L_vals
    else
      # If all elements are not lenght 1, we have to sort indirectly on indexes.
      L_sort_bash -c _L_flow_pipe_sort_all _L_idxs
    fi
    # _L_i was used above.
    _L_i=0
  fi
  # echo "$_L_i"
  if (( _L_i++ < ${#_L_idxs[*]} )); then
    L_flow_yield "${_L_vals[@]:(_L_poss[_L_idxs[_L_i-1]]):(_L_lens[_L_idxs[_L_i-1]])}"
  fi
}

# @description Internal comparison function for L_flow_pipe_sort.
# Compares two values based on the sort options (`-n` for numeric).
# @arg $1 <value> First value.
# @arg $2 <value> Second value.
# @return 1 when $1 > $2 and 2 otherwise.
_L_flow_pipe_sort_cmp() {
  if (( _L_opt_n )) && L_is_integer "$1" && L_is_integer "$2"; then
    if (( $1 != $2 )); then
      if (( $1 > $2 )); then
        return 1
      else
        return 2
      fi
    fi
  else
    if [[ "$1" != "$2" ]]; then
      if [[ "$1" > "$2" ]]; then
        return 1
      else
        return 2
      fi
    fi
  fi
}

# @description Internal comparison function for multi-element sorting in L_flow_pipe_sort.
#
# This function is passed to `L_sort_bash` and handles sorting based on keys (`-k`)
# and associative array keys (`-A`).
#
# @arg $1 <index1> Index of the first element in the internal index array.
# @arg $2 <index2> Index of the second element in the internal index array.
# @return 0 if element1 <= element2, 1 if element1 > element2, 2 on internal error.
_L_flow_pipe_sort_all() {
  # local -;set -x
  # Sort with specific field.
  if [[ -v _L_opt_k ]]; then
    if (( _L_opt_A )); then
      local a="${_L_vals[_L_poss[$1]+1]}" b="${_L_vals[_L_poss[$2]+1]}"
      local -A ma="$a" mb="$b"
      local a=${ma["$_L_opt_k"]} b=${mb["$_L_opt_k"]}
      _L_flow_pipe_sort_cmp "$a" "$b" || return "$(($?-1))"
    else
      # L_unsetx L_error "$_L_opt_k ${_L_lens[$1]} ${_L_lens[$1]} (${_L_vals[*]:_L_poss[$1]:_L_lens[$1]}) (${_L_vals[*]:_L_poss[$2]:_L_lens[$2]})"
      if (( _L_opt_k < _L_lens[$1] && _L_opt_k < _L_lens[$2] )); then
        local a="${_L_vals[_L_poss[$1]+_L_opt_k]}" b="${_L_vals[_L_poss[$2]+_L_opt_k]}"
        _L_flow_pipe_sort_cmp "$a" "$b" || return "$(($?-1))"
      fi
    fi
  fi
  # Default sort.
  local i=0 j=0
  for ((; i != _L_lens[$1] && j != _L_lens[$2]; ++i, ++j )); do
    local a="${_L_vals[_L_poss[$1]+i]}" b="${_L_vals[_L_poss[$2]+j]}"
    _L_flow_pipe_sort_cmp "$a" "$b" || return "$(($?-1))"
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
#   _L_FLOW + L_flow_source_array arr + L_flow_sink_first_true -v result -d default_value L_is_true
L_flow_sink_first_true() { L_getopts_in -p _L_ v:d:: _L_flow_sink_first_true_in "$@"; }
_L_flow_sink_first_true_in() {
  local L_v _L_found=0
  while L_flow_next - L_v; do
    if "$@" "${L_v[@]}"; then
      _L_found=1
      break
    fi
  done
  if (( !_L_found )); then
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
L_flow_sink_all_equal() {
  local _L_a _L_b
  L_flow_next - _L_a || return 1
  while L_flow_next - _L_b; do
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
#   _L_FLOW + L_flow_source_string_chars "abc" + L_flow_sink_printf
L_flow_source_string_chars() {
  local _L_idx=0
  L_flow_restore _L_idx
  if (( _L_idx < ${#1} ? ++_L_idx : 0 )); then
    L_flow_yield "${1:_L_idx-1:1}"
  fi
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
#   _L_FLOW + L_flow_source_string_chars 'AAAABBB' + L_flow_pipe_unique_justseen + L_flow_sink_printf # A B
L_flow_pipe_unique_justseen() {
  local _L_last _L_new _L_ok
  L_flow_restore _L_last
  L_flow_next_ok _L_ok - _L_new
  if (( !_L_ok )); then
    return 1
  fi
  if [[ -z "${_L_last}" ]]; then
    L_flow_yield "$_L_new"
  elif
    if (( $# )); then
      "$@" "$_L_last" "$_L_new"
    else
      [[ "$_L_last" == "$_L_new" ]]
    fi
  then
    L_flow_yield "$_L_new"
  fi
  _L_last="$_L_new"
}

# @description Yield unique elements, preserving order. Remember all elements ever seen.
# @arg $@ Convertion commmand, that should set L_v variable. Default: printf -v L_v "%q "
# @example
#   _L_FLOW + L_flow_source_string_chars 'AAAABBBCCDAABBB' + L_flow_pipe_unique_everseen + L_flow_sink_printf -> A B C D
#   _L_FLOW + L_flow_source_string_chars 'ABBcCAD' + L_flow_pipe_unique_everseen L_eval 'L_v=${@,,}' + L_flow_sink_printf -> A B c D
L_flow_pipe_unique_everseen() {
  local _L_seen=() _L_new L_v _L_ok
  L_flow_restore _L_seen
  while
    L_flow_next_ok _L_ok - _L_new || return $?
    (( _L_ok ))
  do
    "${@:-L_quote_printf_v}" "${_L_new[@]}" || return "$?"
    if ! L_set_has _L_seen "$L_v"; then
      L_flow_yield "${_L_new[@]}"
      L_set_add _L_seen "$L_v"
      break
    fi
  done
}

# @arg $@ compare function
L_flow_pipe_unique() {
  # todo
  :
}


# @description
# [state, ]stop[, step]
# @arg $1
# @arg $2
# @arg $3
L_flow_pipe_islice() {
  # Parse arguments
  case "$#" in
    1) local _L_start=0 _L_stop=$1 _L_step=1 ;;
    2|3) local _L_start=$1 _L_stop=$2 _L_step=${3:-1} ;;
    *) L_func_usage_error "wrong number of positional arguments: $#"; return 2 ;;
  esac
  if (( _L_start < 0 )); then
    L_panic "invalid value: start=$_L_start"
  fi
  if (( _L_stop != -1 && _L_stop < 0 )); then
    L_panic "invalid value: stop=$_L_stop"
  fi
  if (( _L_step <= 0 )); then
    L_panic "invalid values: step=$_L_step"
  fi
  #
  local _L_idx=0 _L_ok _L_r
  L_flow_restore _L_idx
  if (( _L_idx == 0 )); then
    while (( _L_start-- > -1 )); do
      L_flow_next_ok _L_ok - _L_r || return $?
      if (( !_L_ok )); then
        return 1
      fi
    done
    L_flow_yield "${_L_r[@]}"
    _L_idx=1
  else
    # L_error "idx=$_L_idx start=$_L_start stop=$_L_stop step=$_L_step" >&2
    if (( _L_stop == -1 || _L_idx++ < _L_stop - _L_start )); then
      while (( --_L_step > -1 )); do
        L_flow_next_ok _L_ok - _L_r || return $?
        if (( !_L_ok )); then
          return 0
        fi
      done
      L_flow_yield "${_L_r[@]}"
    fi
  fi
}

# @description Make an iterator that returns object over and over again. Runs indefinitely unless the times argument is specified.
# @option -t <int> Number of times to yield the object (default is 0, which means forever).
# @arg $@ Object to return.
L_flow_source_repeat() { L_getopts_in -p _L_ t: _L_flow_source_repeat_in "$@"; }
_L_flow_source_repeat_in() {
  if L_var_is_set _L_t; then
    L_flow_restore _L_t
    (( _L_t > 0 ? _L_t-- : 0 )) && L_flow_yield "$@"
  else
    L_flow_yield "$@"
  fi
}

# Collect data into overlapping fixed-length chunks or blocks."
# sliding_window('ABCDEFG', 3) → ABC BCD CDE DEF EFG
# @arg $1 size
L_flow_pipe_sliding_window() {
  local _L_window=() _L_lens=() _L_r _L_ok
  L_flow_restore _L_window _L_lens
  while (( ${#_L_lens[*]} < $1 )); do
    L_flow_next_ok _L_ok - _L_r || return $?
    if (( !_L_ok )); then
      # if (( ${#_L_lens[*]} )); then
      #   L_flow_yield "${_L_window[@]}"
      #   _L_lens=()
      #   _L_window=()
      # fi
      return 0
    fi
    _L_window+=("${_L_r[@]}")
    _L_lens+=("${#_L_r[*]}")
  done
  # Yield the window and move on.
  L_flow_yield "${_L_window[@]}"
  # Remove the first element and keep the rest of the window.
  _L_window=("${_L_window[@]:(_L_lens[0])}")
  _L_lens=("${_L_lens[@]:1}")
}

# @description Requests the next element and assigns it to an associative array.
#
# This is a convenience wrapper around `L_flow_next -` for generators that yield
# dictionary-like elements (tuples starting with "DICT" and a serialized array).
#
# @arg $1 <array> The name of the associative array variable to assign the element to.
# @return 0 on successful assignment, non-zero on generator exhaustion or error.
L_flow_next_dict() {
  if ! L_var_is_associative "$1"; then
    L_panic ''
  fi
  local m v _L_ok
  L_flow_next_ok _L_ok - m v
  if (( !_L_ok )); then
    return 1
  fi
  if [[ "$m" != "DICT" ]]; then
    L_panic ''
  fi
  if [[ "${v::1}" != "(" ]]; then
    L_panic ''
  fi
  if [[ "${v:${#v}-1}" != ")" ]]; then
    L_panic ''
  fi
  eval "$1=$v"
}

# @description Yields an associative array element.
#
# This is a convenience wrapper around `L_flow_yield` for yielding dictionary-like
# elements. It serializes the associative array into a string and yields it as a
# tuple starting with the "DICT" marker.
#
# @arg $1 <array> The name of the associative array variable to yield.
L_flow_yield_dict() {
  if ! L_var_is_associative "$1"; then
    L_panic ''
  fi
  local L_v
  L_var_to_string_v "$1" || L_panic
  if [[ "${L_v::1}" != "(" ]]; then
    L_panic ''
  fi
  if [[ "${L_v:${#L_v}-1}" != ")" ]]; then
    L_panic ''
  fi
  L_flow_yield DICT "$L_v"
}

# @description Source generator that reads CSV data from stdin.
#
# Reads lines from standard input, treating the first line as headers. Each
# subsequent line is yielded as an associative array where keys are the headers.
#
# @note The field separator is hardcoded to `,`.
# @return 0 on successful yield, non-zero on EOF or error.
# @example
#   echo "col1,col2" | _L_FLOW + L_flow_source_read_csv + L_flow_sink_printf
L_flow_source_read_csv() {
  local IFS=, headers=() i arr L_v step=0
  L_flow_restore step headers
  if ((step == 0)); then
    read -ra headers || return $?
    step=1
  fi
  read -ra arr || return $?
  local -A vals
  for i in "${!headers[@]}"; do
    vals["${headers[i]}"]=${arr[i]:-}
  done
  L_flow_yield_dict vals
}

# @description Pipe generator that filters out elements with empty values in a specified key.
#
# Consumes dictionary-like elements and only yields those where the value for the
# specified key (`subset`) is non-empty.
#
# @arg $1 <key> The key whose value must be non-empty.
# @return 0 on successful yield, 1 on upstream generator exhaustion.
# @example
#   _L_FLOW + L_flow_source_read_csv < data.csv + L_flow_pipe_dropna amount + L_flow_sink_printf
L_flow_pipe_dropna() {
  local subset
  L_argskeywords / subset -- "$@" || return $?
  if [[ -z "$subset" ]]; then
    L_panic ''
  fi
  local -A asa=()
  while L_flow_next_dict asa; do
    if [[ -n "${asa[$subset]}" ]]; then
      L_flow_yield_dict asa
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
L_flow_pipe_none() {
  local _L_r _L_ok
  L_flow_next_ok _L_ok - _L_r
  if (( !_L_ok )); then
    return 1
  fi
  L_flow_yield "${_L_r[@]}"
}

# @description Sink generator that extracts the next element and pauses the chain.
#
# This is primarily used in `while _L_FLOW -R it ...` loops to extract the yielded
# value(s) into local variables and pause the generator chain until the next loop iteration.
#
# @arg $1 <var> Variable to assign the yielded element to (as a scalar or array).
# @arg $@ <var>... Multiple variables to assign the yielded tuple elements to.
# @return 0 on successful extraction, non-zero on generator exhaustion or error.
# @example
#   while _L_FLOW -R it + L_flow_source_range 5 + L_flow_sink_iterate i; do
#     echo "Current: $i"
#   done
L_flow_sink_iterate() {
  local _L_r _L_ok
  L_flow_next_ok _L_ok - _L_r
  if (( _L_ok )); then
    # Extract the value from the return value.
    if (( $# == 1 )); then
      L_array_assign "$1" "${_L_r[@]}"
    else
      if (( ${#_L_r[*]} != $# )); then
        L_panic "number of arguments $# is not equal to the number of tuple elements in the generator element ${#_L_r[*]}"
      fi
      L_array_extract _L_r "$@"
    fi
    L_flow_pause
  fi
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
#   _L_FLOW + L_flow_source_range 3 + L_flow_pipe_zip_array arr + L_flow_sink_printf "%s: %s\n"
L_flow_pipe_zip_array() {
  local _L_r _L_i=0 _L_ok
  local -n _L_a=$1
  L_flow_restore _L_i
  if (( _L_i++ < ${#_L_a[*]} )); then
    L_flow_next_ok _L_ok - _L_r
    if (( _L_ok )); then
      L_flow_yield "${_L_r[@]}" "${_L_a[_L_i-1]}"
    fi
  fi
}

# @description Join current generator with another one.
# @arg $1 Flow variable to join with or ++
# @arg $@ Flow build separated with double ++ instead of +.
L_flow_pipe_zip() {
  local _L_zip_flow=() _L_a _L_b _L_ok
  if [[ "$1" == "++" ]]; then
    L_flow_restore _L_zip_flow
    if (( ${#_L_zip_flow[*]} == 0 )); then
      L_flow_make _L_zip_flow "${@//++/+}"
    fi
  else
    local -n _L_zip_flow=$1
  fi
  L_flow_next_ok _L_ok - _L_a || return $?
  if (( _L_ok )); then
    L_flow_next_ok _L_ok _L_zip_flow _L_b || return $?
    if (( _L_ok )); then
      L_flow_yield "${_L_a[@]}" "${_L_b[@]}"
    fi
  fi
}

# ]]]
# [[[ test

# An array variable that stores the context information of calls to L_flow_iterate without -n option.
# The index of the context maps to _L_FLOW_$NUM variable that is used for iterating.
# _L_FLOW_ITERATE=()


L_flow_iterate() { L_getopts_in -p _L_ -n 2+ s:n: _L_flow_iterate "$@"; }
_L_flow_iterate() {
  # Extract the position of the first +
  local _L_first_plus=-1 _L_i
  for (( _L_i = 0; _L_i < $#; ++_L_i )); do
    if [[ "${@:_L_i+1:1}" == "+" ]]; then
      _L_first_plus=$_L_i
      break
    fi
  done
  if [[ "$_L_first_plus" -le 0 ]]; then
    L_panic "no variables"
  fi
  # Calculate the name of temporary variable name if not specified.
  if ! L_var_is_set _L_n; then
    local _L_idx=$((${_L_s:-0}+3))
    local _L_context="${BASH_SOURCE[*]:_L_idx}:${BASH_LINENO[*]:_L_idx}:${FUNCNAME[*]:_L_idx}"
    if ! L_array_index -v _L_idx _L_FLOW_ITERATE "$_L_context"; then
      _L_idx=$(( ${_L_FLOW_ITERATE[*]:+${#_L_FLOW_ITERATE[*]}}+0 ))
      _L_FLOW_ITERATE[_L_idx]=$_L_context
    fi
    _L_n=_L_FLOW_$_L_idx
  fi
  # Constuct the flow if does not exists.
  if [[ ! -v "$_L_n" ]] || L_flow_is_finished "$_L_n"; then
    L_flow_make "$_L_n" "${@:_L_first_plus+1}" || L_panic "Could not construct flow"
  fi
  # Execute.
  L_flow_next "$_L_n" "${@:1:$_L_first_plus}"
}

# @description Internal unit tests for the generator library.
# @description Internal unit tests for the generator library.
_L_flow_test_1() {
  local sales array a
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
  L_finally
  {
    local out=() it=() a
    while L_flow_iterate -n it a + L_flow_source_array array; do
      out+=("$a")
    done
    L_unittest_arreq out "${array[@]}"
  }
  {
    local out=() it=() a
    declare -p BASH_LINENO BASH_SOURCE FUNCNAME
    while L_flow_iterate a + L_flow_source_array array; do
      out+=("$a")
    done
    L_unittest_arreq out "${array[@]}"
  }
  {
    local out=() it=() a
    while L_flow_iterate -n it a + L_flow_source_array array; do
      out+=("$a")
    done
    L_unittest_arreq out "${array[@]}"
  }
  {
    local out1=() it=() out2=()
    while L_flow_iterate -n it a b \
        + L_flow_source_array array \
        + L_flow_pipe_pairwise
    do
      out1+=("$a")
      out2+=("$b")
    done
    L_unittest_arreq out1 a c e
    L_unittest_arreq out2 b d f
  }
  {
    local out1=() it=() out2=() idx=() i a b
    while L_flow_iterate -n it i a b \
        + L_flow_source_array array \
        + L_flow_pipe_pairwise \
        + L_flow_pipe_enumerate
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
      L_flow_make_run \
      + L_flow_source_array array \
      + L_flow_sink_map printf "%s "
  }
}

_L_flow_test_2() {
  {
    L_unittest_cmd -o '0 1 2 3 4 ' \
      L_flow_make_run \
      + L_flow_source_range \
      + L_flow_pipe_head 5 \
      + L_flow_sink_map printf "%s "
    L_unittest_cmd -o '0 1 2 3 4 ' \
      L_flow_make_run \
      + L_flow_source_range 5 \
      + L_flow_sink_map printf "%s "
    L_unittest_cmd -o '3 4 5 6 7 8 ' \
      L_flow_make_run \
      + L_flow_source_range 3 9 \
      + L_flow_sink_map printf "%s "
    L_unittest_cmd -o '3 5 7 ' \
      L_flow_make_run \
      + L_flow_source_range 3 2 9 \
      + L_flow_sink_map printf "%s "
  }
  {
    local L_v gen=() res
    L_flow_make gen \
      + L_flow_source_range 5 \
      + L_flow_pipe_head 5
    L_flow_use gen L_flow_sink_fold_left -i 0 -v res -- L_eval 'L_v=$(($1+$2))'
    L_unittest_arreq res 10
  }
  {
    L_unittest_cmd -o 'A B C D ' \
      L_flow_make_run \
      + L_flow_source_string_chars 'ABCD' \
      + L_flow_sink_printf "%s "
    L_unittest_cmd -o 'A B C D ' \
      L_flow_make_run \
      + L_flow_source_string_chars 'AAAABBBCCDAABBB' \
      + L_flow_pipe_unique_everseen \
      + L_flow_sink_printf "%s "
    L_unittest_cmd -o 'A B c D ' \
      L_flow_make_run \
      + L_flow_source_string_chars 'ABBcCAD' \
      + L_flow_pipe_unique_everseen L_eval 'L_v=${*,,}' \
      + L_flow_sink_printf "%s "
  }
  {
    L_unittest_cmd -o "A B " \
      L_flow_make_run \
      + L_flow_source_string_chars 'ABCDEFG' \
      + L_flow_pipe_islice 2 \
      + L_flow_sink_printf "%s "
    L_unittest_cmd -o "C D " \
      L_flow_make_run \
      + L_flow_source_string_chars 'ABCDEFG' \
      + L_flow_pipe_islice 2 4 \
      + L_flow_sink_printf "%s "
    L_unittest_cmd -o "C D E F G " \
      L_flow_make_run \
      + L_flow_source_string_chars 'ABCDEFG' \
      + L_flow_pipe_islice 2 -1 \
      + L_flow_sink_printf "%s "
    L_unittest_cmd -o "A C E G " \
      L_flow_make_run \
      + L_flow_source_string_chars 'ABCDEFG' \
      + L_flow_pipe_islice 0 -1 2 \
      + L_flow_sink_printf "%s "
  }
  {
    L_unittest_cmd -o 'ABCD BCDE CDEF DEFG ' \
      L_flow_make_run \
      + L_flow_source_string_chars 'ABCDEFG' \
      + L_flow_pipe_sliding_window 4 \
      + L_flow_sink_printf "%s%s%s%s "
  }
  {
    L_log "test zip"
    local a=("John" "Charles" "Mike")
    local b=("Jenny" "Christy" "Monica")
    L_unittest_cmd -o 'John+Jenny Charles+Christy Mike+Monica ' \
      L_flow_make_run \
      + L_flow_source_array a \
      + L_flow_pipe_zip ++ L_flow_source_array b \
      + L_flow_sink_printf "%s+%s "
  }
  {
    L_log "test L_flow_sink_dotproduct"
    local numbers=(2 0 4 4) gen1=() res=() tmp=()
    L_flow_make gen1 \
      + L_flow_source_range \
      + L_flow_pipe_head 4
    L_flow_copy gen1 tmp
    L_flow_use tmp L_flow_sink_printf "%s\n"
    L_flow_make_run \
      + L_flow_source_array numbers \
      + L_flow_pipe_head 4 \
      + L_flow_sink_dotproduct -v res -- gen1
     L_unittest_arreq res "$(( 0 * 2 + 1 * 0 + 2 * 4 + 3 * 4 ))"
  }
}

_L_flow_test_3() {
  {
    L_unittest_cmd -o "1 2 3 " \
      L_flow_make_run \
      + L_flow_source_string_chars 123 \
      + L_flow_sink_printf "%s "
  }
  {
    L_unittest_cmd -o "1 3 6 10 15 " \
      L_flow_make_run \
      + L_flow_source_string_chars 12345 \
      + L_flow_pipe_accumulate \
      + L_flow_sink_printf "%s "
  }
  {
    L_unittest_cmd -o "[roses red] [violets blue] [sugar sweet] " \
      L_flow_make_run \
      + L_flow_source_args roses red violets blue sugar sweet \
      + L_flow_pipe_batch 2 \
      + L_flow_sink_printf "[%s %s] "
  }
  {
    local gen1=()
    L_flow_make gen1 + L_flow_source_string_chars DEF
    L_unittest_cmd -o "A B C D E F " \
      L_flow_make_run \
      + L_flow_source_string_chars ABC \
      + L_flow_pipe_chain gen1 \
      + L_flow_sink_printf "%s "
    L_unittest_cmd -o "A B C D E F " \
      L_flow_make_run \
      + L_flow_source_string_chars ABC \
      + L_flow_pipe_chain_gen L_flow_source_string_chars DEF \
      + L_flow_sink_printf "%s "
  }
}

L_flow_source_read_fd() {
  local _L_r
  if read -u "${1:-0}" -a _L_r; then
    L_flow_yield "${_L_r[@]}"
  fi
}

_L_flow_test_4_read() {
  {
    local lines
    L_log 'test read_fd with filtering and acumlating and sorting'
    L_flow_make_run \
      + L_flow_source_read_fd \
      + L_flow_pipe_map L_strip_v \
      + L_flow_pipe_filter L_eval '(( ${#1} > 1 ))' \
      + L_flow_sink_to_array lines <<EOF
    a
  bb
      ccc
EOF
    L_sort_bash -E '(( ${#1} > ${#2} ))' lines
    L_unittest_arreq lines "bb" "ccc"
  }
  {
    L_log 'test longest'
    local array
    L_flow_make_run \
      + L_flow_source_read_fd \
      + L_flow_pipe_map L_eval 'L_regex_replace -n _ -v L_v "${1:-}" '$'\x1b''"\\[[0-9;]*m" ""' \
      + L_flow_pipe_filter L_eval '(( ${#1} != 0 ))' \
      + L_flow_pipe_map L_eval 'L_v=("${#1}" "$1")' \
      + L_flow_pipe_sort -n -k 0 \
      + L_flow_pipe_map L_eval 'L_v="$2"' \
      + L_flow_sink_to_array array <<EOF

  b
  ccc
  aa
EOF
    L_unittest_arreq array "b" "aa" "ccc"
  }
}

# ]]]

###############################################################################

# @description Main entry point for the _L_FLOW.sh script.
#
# Parses command-line arguments and executes internal tests or specific generator examples.
_L_flow_main() {
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
  case "$mode" in
  while3)
    ;;
  1|'')
    _L_flow_test_1
    _L_flow_test_2
    _L_flow_test_3
    _L_flow_test_4_read
    ;;
  L_*|_L_*)
    "${mode[@]}"
    ;;
  esac
}

if L_is_main; then
  _L_flow_main "$@"
fi
