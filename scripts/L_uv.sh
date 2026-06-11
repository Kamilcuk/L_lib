#!/bin/bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")"/../bin/L_lib.sh

###############################################################################
# L_uv
#
# L_UV array variable layout:
# | Index Range           | Description                                       |
# | :-------------------- | :------------------------------------------------ |
# | 1                     | Last index of removed or added task (>= 500000)   |
# | 2                     | Space-separated list of PIDs waiting for          |
# | 3                     | Last index of added timer (< 500000)              |
# | 1123000               | Count of timers                                   |
# | 1123001 : 2123000     | Heap of timers (<usec since epoch>:<timerid>)     |
# | 2123000 + taskid      | Registered L_finally index of taskid              |
# | 3123000 + taskid      | Heap index of timer taskid                        |
# | 4123000 + taskid      | The repeat interval of timer taskid               |
# | 8123000 + taskid      | The callback to call for taskid                   |
# | 8123000 : 8623000     | Timers are taskid < 500000                        |
# | 8623000 : 9123000     | Tasks are taskid >= 500000                        |
#
# @description The global uv loop variable.
# L_UV=()

###############################################################################
# timerheap

_L_uv_timerheap_swap_with_L_tmp() {
  # Swaps two heap elements and updates their inverse mapping for O(1) removal.
  _L_tmp=${L_UV[1123000 + $1]} \
    L_UV[1123000 + $1]=${L_UV[1123000 + $2]} \
    L_UV[1123000 + $2]=$_L_tmp \
    L_UV[3123000 + ${_L_tmp#*:}]=$2 \
    L_UV[3123000 + ${L_UV[1123000 + $1]#*:}]=$1
}

# @description Maintain the min-heap property by sifting an element up.
# @arg $1 Current index in the heap
_L_uv_timerheap_sift_up() {
  local _L_curr=$1 _L_parent _L_tmp
  # Bubbles up an element that expires earlier than its parent.
  while
    (( _L_curr > 1 && ( _L_parent = _L_curr / 2 ) )) &&
    [[ "${L_UV[1123000 + _L_curr]}" < "${L_UV[1123000 + _L_parent]}" ]]
  do
    _L_uv_timerheap_swap_with_L_tmp _L_curr _L_parent
    _L_curr=$_L_parent
  done
}

# @description Maintain the min-heap property by sifting an element down.
# @arg $1 Current index in the heap
_L_uv_timerheap_sift_down() {
  local _L_curr=$1 _L_size=${L_UV[1123000]:-0} _L_child _L_tmp
  # Sinks down an element that expires later than its smallest child.
  while
    (( ( _L_child = _L_curr * 2 ) <= _L_size )) && {
      # Selects the smaller of the two children.
      if (( _L_child + 1 <= _L_size )) && [[ "${L_UV[1123000 + _L_child + 1]}" < "${L_UV[1123000 + _L_child]}" ]]; then
        (( ++_L_child ))
      fi
      # Compare current with child.
      [[ "${L_UV[1123000 + _L_child]}" < "${L_UV[1123000 + _L_curr]}" ]]
    }
  do
    _L_uv_timerheap_swap_with_L_tmp _L_curr _L_child
    _L_curr=$_L_child
  done
}

# @description Push a timer into the min-heap.
# @arg $1 String in format "TIMESTAMP:TASK_ID"
_L_uv_timerheap_push() {
  local _L_size=$(( L_UV[1123000] = ${L_UV[1123000]:-0} + 1 ))
  # Appends the new timer at the end and sifts it up to the correct position.
  L_UV[1123000 + _L_size]=$1
  L_UV[3123000 + ${1#*:}]=$_L_size
  _L_uv_timerheap_sift_up $_L_size
}

# @description Pop the earliest timer from the min-heap.
# @return 0 on success, results in L_RET
_L_uv_timerheap_pop_vL_RET() {
  local _L_size=${L_UV[1123000]:-0}
  if (( _L_size == 0 )); then
    return 1
  fi
  L_RET=${L_UV[1123001]}
  # Clears the mapping for the popped timer and maintains heap integrity.
  unset -v "L_UV[3123000 + ${L_RET#*:}]"
  if (( --_L_size == 0 )); then
    unset -v "L_UV[1123001]"
    L_UV[1123000]=0
    return 0
  fi
  # Replaces root with last element and sifts it down.
  L_UV[1123001]=${L_UV[1123000 + _L_size + 1]}
  L_UV[3123000 + ${L_UV[1123001]#*:}]=1
  unset -v "L_UV[1123000 + _L_size + 1]"
  L_UV[1123000]=$_L_size
  _L_uv_timerheap_sift_down 1
}

# @description Replace the root of the heap and reheapify down.
# @arg $1 New string in format "TIMESTAMP:TASK_ID"
_L_uv_timerheap_update_top() {
  local _L_old=${L_UV[1123001]}
  # Efficiently replaces the top timer (e.g., for repeating timers) and sifts it down.
  L_UV[1123001]=$1
  unset -v "L_UV[3123000 + ${_L_old#*:}]"
  L_UV[3123000 + ${1#*:}]=1
  _L_uv_timerheap_sift_down 1
}

# @description Delete a specific timer from the heap by its taskid.
# @arg $1 TaskID to delete
_L_uv_timerheap_delete_taskid() {
  local _L_id=$1 _L_curr="${L_UV[3123000 + $1]:-}" _L_size=${L_UV[1123000]:-0}
  if [[ -z "$_L_curr" ]]; then
    return 0
  fi
  # If the timer is the last element, simple unset; otherwise swap with last and re-sift.
  if (( _L_curr == _L_size )); then
    unset -v "L_UV[1123000 + _L_size]" "L_UV[3123000 + $1]"
    L_UV[1123000]=$(( --_L_size ))
    return 0
  fi
  # Fills the hole with the last element and balances the heap in both directions.
  L_UV[1123000 + _L_curr]=${L_UV[1123000 + _L_size]}
  L_UV[3123000 + ${L_UV[1123000 + _L_curr]#*:}]=$_L_curr
  unset -v "L_UV[1123000 + _L_size]" "L_UV[3123000 + $1]"
  L_UV[1123000]=$(( --_L_size ))
  if (( _L_curr <= _L_size )); then
    _L_uv_timerheap_sift_up $_L_curr
    _L_uv_timerheap_sift_down $_L_curr
  fi
}

###############################################################################

# @description Initialize a loop array.
L_uv_init() { L_UV=(); }

# @description Add a task callback to the loop.
# @option -v <var> Variable to assign the index to
# @arg $@ Callback function and its arguments
L_uv_add() {
  local OPTIND OPTARG OPTERR _L_opt _L_v="" IFS=' ' _L_cmd
  while getopts v:h _L_opt; do
    case "$_L_opt" in
      v) _L_v=$OPTARG ;;
      h) L_func_usage; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  printf -v _L_cmd "%q " "$@"
  while [[ -n "${L_UV[8123000 + ${L_UV[1]:=500000}]:-}" ]]; do
    if (( ++L_UV[1] > 1000000 )); then
      L_UV[1]=500000
    fi
  done
  L_UV[8123000 + L_UV[1]]="L_UV_CURRENT=${L_UV[1]};${_L_cmd% };"
  if [[ -n "$_L_v" ]]; then printf -v "$_L_v" "%s" "${L_UV[1]}"; fi
  L_UV[4]="${L_UV[*]:8623000}"
}

# @description Set a callback at a specific index in the loop.
# @arg $1 Index to set
# @arg $@ Callback function and its arguments
L_uv_set() {
  local _L_cmd
  printf -v _L_cmd "%q " "${@:2}"
  L_UV[8123000 + $1]="L_UV_CURRENT=$1;${_L_cmd% };"
  if (( $1 >= 500000 )); then
    L_UV[4]="${L_UV[*]:8623000}"
  fi
}

# @description Remove a callback from the loop by index.
# @arg $1 Index to remove
L_uv_remove() {
  local _L_idx="${L_UV[2123000 + $1]:-}"
  if [[ -n "$_L_idx" ]]; then
    L_finally_pop -i "$_L_idx"
  fi
  if (( $1 < 500000 )); then
    _L_uv_timerheap_delete_taskid "$1"
    L_UV[3]=$1
  else
    L_UV[1]=$1
    unset -v "L_UV[8123000 + $1]"
    L_UV[4]="${L_UV[*]:8623000}"
  fi
  unset -v "L_UV[2123000 + $1]" "L_UV[4123000 + $1]" "L_UV[8123000 + $1]"
}

# @description Update the current executing callback.
# @arg $@ New callback function and its arguments
# @env L_UV_CURRENT
L_uv_current_set() { L_uv_set "$L_UV_CURRENT" "$@"; }

# @description Remove the current executing callback.
# @env L_UV_CURRENT
L_uv_current_remove() { L_uv_remove "$L_UV_CURRENT"; }

# Pause for a specified duration using the best available sleep method.
# @arg $1 Duration in floting point seconds.
L_sleep() {
  if builtin sleep 0 0 2>/dev/null || (( $? == 2 )); then
    builtin sleep "$1"
  elif enable -f sleep sleep 2>/dev/null; then
    builtin sleep "$1"
    enable -d sleep
  else
    command sleep "$1"
  fi
}

# Returns the next timeout when L_uv should be waked up.
_L_uv_timeout_left_vL_RET() { [[ -n "${L_UV[1123001]:-}" ]] && L_timeout_left_vL_RET "${L_UV[1123001]%%:*}"; }

# @description Run the event loop until it's empty or timed out.
# @option -s <float> Polling interval in seconds (defaults to 0.1)
# @option -1 Run only one iteration of the loop.
# @option -t <float> Timeout in seconds (defaults to none)
# @arg $1 Loop name (defaults to L_UV)
# @return 0 on success, 124 on timeout, or task exit code.
# @example L_uv_add_timer loop 1 echo "hello"; L_uv_run loop
L_uv_run() {
  local OPTIND OPTARG OPTERR _L_opt _L_uv_sleep_time=0.05 _L_uv_break=0 _L_uv_return=0 \
    L_UV_CURRENT _L_uv_stack_depth=${#FUNCNAME[@]} _L_uv_poked=0 L_RET _L_i
  while getopts s:1cCt:h _L_opt; do
    case "$_L_opt" in
      s) L_duration_to_usec_vL_RET "$1" && L_usec_to_sec_vL_RET "$L_RET" && _L_uv_sleep_time=$L_RET || return ;;
      1) _L_uv_break=1 ;;
      t) L_uv_add_timer -d "$OPTARG" L_eval '_L_uv_break=1 _L_uv_return=$L_EX_TIMEOUT' || return ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "${L_EX_USAGE:-64}" ;;
    esac
  done
  shift $((OPTIND - 1))
  # If SIGCHLD trap is not set, set it.
  L_trap_get_vL_RET SIGCHLD
  if [[ -z "$L_RET" ]]; then
    trap 'L_uv_poke' SIGCHLD
  fi
  while [[ -n "${L_UV[4]:-}" ]] || (( L_UV[1123000] > 0 )); do
    # Process Timers (Top-only)
    while (( L_UV[1123000] > 0 )); do
      local _L_top="${L_UV[1123001]}"
      local _L_at="${_L_top%%:*}"
      L_epochrealtime_usec_vL_RET; local _L_now_us=$L_RET
      # If top timer is not yet due, break
      if (( _L_at > _L_now_us )); then break; fi
      local _L_id="${_L_top#*:}"
      local _L_code="${L_UV[8123000 + _L_id]:-}"
      # Tombstone removal
      if [[ -z "$_L_code" ]]; then
        _L_uv_timerheap_pop_vL_RET
      else
        # Reregister the timer in the heap.
        local _L_repeat="${L_UV[4123000 + _L_id]:-0}"
        if (( _L_repeat > 0 )); then
          local _L_next=$(( _L_at + _L_repeat ))
          # Skip skipped callbacks.
          while (( _L_now_us >= _L_next )); do (( _L_next += _L_repeat )); done
          _L_uv_timerheap_update_top "$_L_next:$_L_id"
        else
          _L_uv_timerheap_pop_vL_RET
          L_uv_remove "$_L_id"
        fi
        # Execute
        L_UV_CURRENT=$_L_id
        eval "$_L_code"
        L_uv_poke
      fi
    done
    # Process Generic Tasks
    eval "${L_UV[4]:-}"
    if (( _L_uv_break )); then break; fi
    # Sleep
    if (( !_L_uv_poked )); then
      local _L_timeout=$_L_uv_sleep_time
      if _L_uv_timeout_left_vL_RET; then
         if (( $(L_eval '[[ "$1" < "$2" ]]' "$L_RET" "$_L_timeout") )); then
            _L_timeout=$L_RET
         fi
      fi
      L_sleep "$_L_timeout"
      _L_uv_poked=0
    fi
  done
  return "$_L_uv_return"
}

# @description Break the current event loop.
L_uv_break() { _L_uv_break=1; }

# @description Do not sleep between loops.
L_uv_poke() { _L_uv_poked=1; }

# @description Register a cleanup command to be executed when a task is removed.
# @arg $1 Task index
# @arg $@ Cleanup command and its arguments
L_uv_on_remove() {
  local _L_r_idx
  L_finally -v _L_r_idx -r -s "${#FUNCNAME[@]} - $_L_uv_stack_depth" "${@:2}"
  L_UV[2123000 + $1]="$_L_r_idx"
}

# @description Register a cleanup command for the current task.
# @arg $@ Cleanup command and its arguments
L_uv_current_on_remove() { L_uv_on_remove "$L_UV_CURRENT" "$@"; }

# @description Add a timer to the loop.
# @option -r <int> Repeat interval in milliseconds (defaults to 0)
# @option -d <int> Initial delay in milliseconds (defaults to 0)
# @option -v <var> Variable to assign the timer index to
# @arg $@ Callback function and its arguments
L_uv_add_timer() {
  local OPTIND OPTARG OPTERR _L_opt _L_r=0 _L_d=0 _L_v="" _L_now_us _L_cmd _L_timerid
  while getopts r:d:v:h _L_opt; do
    case "$_L_opt" in
      r) L_duration_to_usec_vL_RET "$OPTARG" && _L_r=$L_RET || return ;;
      d) L_duration_to_usec_vL_RET "$OPTARG" && _L_d=$L_RET || return ;;
      v) _L_v=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  L_epochrealtime_usec_vL_RET; _L_now_us=$L_RET
  local _L_next_us=$(( _L_now_us + _L_d ))
  printf -v _L_cmd "%q " "$@"
  while [[ -n "${L_UV[8123000 + ${L_UV[3]:=0}]:-}" ]]; do
    if (( ++L_UV[3] >= 500000 )); then
      L_UV[3]=0
    fi
  done
  _L_timerid=${L_UV[3]}
  # Store the repeat interval at offset 4123000
  L_UV[4123000 + _L_timerid]="$_L_r"
  # Store the command to execute at offset 8123000 , taskid < 500000
  L_UV[8123000 + _L_timerid]="L_UV_CURRENT=$_L_timerid;${_L_cmd% };"
  _L_uv_timerheap_push "$_L_next_us:$_L_timerid"
  if [[ -n "$_L_v" ]]; then printf -v "$_L_v" "%s" "$_L_timerid"; fi
}

_L_uv_wait_nonblocking() {
  # If we are not using SIGCHLD and there are only pids and timers.
  if [[ "${L_UV[2]:-}" == " $1 "* ]]; then
    local L_RET
    if [[ "${L_UV[2]}" == " $1 " ]]; then
      # Only one pid we are waiting for.
      if _L_uv_timeout_left_vL_RET; then
        if L_hash waitpid; then
          waitpid -c 1 -e -t "$L_RET" "$1" 2>/dev/null || :
        elif L_hash timeout tail && _L_wait_tail_has_pid; then
          timeout "$L_RET" tail --pid="$1" -f /dev/null 2>/dev/null
        fi
      else
        wait "$1" || :
      fi
    else
      # Many pids waiting for.
      local L_RET
      if _L_uv_timeout_left_vL_RET; then
        if L_hash waitpid; then
          waitpid -c 1 -e -t "$L_RET" ${L_UV[2]} 2>/dev/null || :
        fi
      elif (( L_HAS_BASH4_3 )); then
        # Bash 4.3+ wait -n for any child.
        wait -n ${L_UV[2]} || :
      fi
    fi
  fi
}

# @description Internal callback for process waiting.
# @arg $1 PID to wait for.
# @arg $@ Callback function and its arguments
_L_uv_wait_callback() {
  # Check if our specific PID is done.
  if ! kill -0 "$1" 2>/dev/null; then
    L_uv_current_remove
    L_UV[2]=${L_UV[2]/ $1 }
    # Capture exit status. Bash returns 127 if PID is not a child or already reaped.
    if wait "$1"; then
      "${@:2}" "$1" 0
    else
      "${@:2}" "$1" "$?"
    fi
  fi
}

# @description Add a process wait handle to the loop.
# @option -v <var> Variable to assign the wait index to
# @arg $1 PID to wait for
# @arg $@ Callback function and its arguments.
L_uv_add_wait() {
  local OPTIND OPTARG OPTERR _L_opt _L_v=""
  while getopts v:h _L_opt; do
    case "$_L_opt" in
      v) _L_v=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  local _L_pid=$1 _L_cmd
  printf -v _L_cmd "%q " "${@:2}"
  L_UV[9123000 + _L_pid]="${_L_cmd% }"
  L_UV[2]+=" $_L_pid "
  # Add the global reaper if not present.
  if [[ "${L_UV[4]:-}" != *"_L_uv_reaper"* ]]; then
    L_uv_add _L_uv_reaper
  fi
}

# @description Internal callback for once-run conditions.
# @arg $1 Condition to evaluate
# @arg $@ Callback function and its arguments
_L_uv_once_callback() {
  if eval "$1"; then
    L_uv_current_remove
    "${@:2}"
    L_uv_break
  fi
}

# @description Add a callback that runs once when a condition is met.
# @option -c <condition> Condition command to evaluate (defaults to 'true')
# @option -v <var> Variable to assign the wait index to
# @arg $1 Loop name (defaults to L_UV)
# @arg $@ Callback function and its arguments
L_uv_add_once() {
  local OPTIND OPTARG OPTERR _L_opt _L_c="" _L_v=""
  while getopts c:v:h _L_opt; do
    case "$_L_opt" in
      c) _L_c=$OPTARG ;;
      v) _L_v=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  if (( $# > 1 )); then
    # Otherwise, we handle the condition with a callback.
    L_uv_add -v "$_L_v" "$1" _L_uv_once_callback "$_L_c" "${@:2}"
  fi
}

# @description Internal callback for reading lines.
# @arg $1 Accumulated buffer string
# @arg $2 Delimiter character
# @arg $3 Target file descriptor
# @arg $@ Callback function and its arguments
_L_uv_readline_callback() {
  local _L_tmp=""
  while IFS= read -t 0 -u "$3" _; do
    if IFS= read -t 0.001 -d "$2" -u "$3" -r _L_tmp; then
      L_uv_current_set "$FUNCNAME" "" "${@:2}"
      "${@:4}" "$3" "$1$_L_tmp" || return
      _L_tmp="" # Reset buffer for next iteration in loop
    elif (( $? > 128 )); then
      # read timed out, partial line in _L_tmp
      L_uv_current_set "$FUNCNAME" "$1$_L_tmp" "${@:2}"
      break
    else
      L_uv_current_remove
      if [[ -n "$1$_L_tmp" ]]; then
        "${@:4}" "$3" "$1$_L_tmp" || return
      fi
      "${@:4}" "$3" || return
      break
    fi
  done
}

# @description Add a line-buffered read handle to the loop.
# @option -d Delimiter character (defaults to newline)
# @option -v <var> Variable to assign the readline index to
# @arg $1 Target file descriptor
# @arg $@ Callback function and its arguments
L_uv_add_readline() {
  local OPTIND OPTARG OPTERR _L_opt _L_d=$'\n' _L_v=""
  while getopts d:v:h _L_opt; do
    case "$_L_opt" in
      d) _L_d=$OPTARG ;;
      v) _L_v=$OPTARG ;;
      h) L_func_usage; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  L_uv_add -v "$_L_v" _L_uv_readline_callback "" "$_L_d" "$@"
}

###############################################################################

# @arg $1 pid
_L_xargs_dobuf_end() {
  # If the pipe of this pid has been closed.
  if [[ -z "${_L_x_dobuf_pipe[$1]:-}" ]]; then
    if (( _L_x_dobuf_mode == 1 )); then
      # In single -O mode, we print ouptut in whatever order.
      printf "%s" "${_L_x_dobuf_output[$1]}"
      unset -v "_L_x_dobuf_output[$1]"
    elif (( _L_x_dobuf_mode == 2 )); then
      # In double -O -O mode, we need to print in order. Check if we are first.
      if (( _L_x_dobuf_order[0] == "$1" )); then
        printf "%s" "${_L_x_dobuf_output[$1]}"
        unset -v "_L_x_dobuf_output[$1]"
        _L_x_dobuf_order=("${_L_x_dobuf_order[@]:1}")
        # After checking, print the next one, if possible.
        if (( ${#_L_x_dobuf_order[@]} )); then
          _L_xargs_dobuf_end "${_L_x_dobuf_order[0]}"
        fi
      fi
    fi
  fi
}

# @arg $1 pid
# @arg $2 file descriptor
# @arg [$3] line
_L_xargs_dobuf_stdout_cb() {
  # L_notice "DEBUG: stdout_cb pid=$1 fd=$2 line=${3:-EOF}"
  if (( $# == 3 )); then
    _L_x_dobuf_output[$1]+="${_L_x_dobuf_prefix[$1]:-}$3"$'\n'
  elif (( $# == 2 )); then
    eval "exec $2>&-"
    unset -v "_L_x_dobuf_pipe[$1]"
    _L_xargs_dobuf_end "$1"
  fi
}

# @option -9 signal number
# @arg $2 pid to kill
_L_x_task_timeout_cb() {
  kill "$@" 2>/dev/null
  # If we killing the first time, schedule a task to kill -9 after 3 seconds.
  if (( $# == 1 )); then
    L_uv_add_timer -v "_L_x_timers[$1]" -d 3 _L_x_task_timeout_cb -9 "$1"
  fi
}

# @option -9 Signal o use
_L_x_global_timeout_cb() {
  _L_x_done=1
  _L_x_input_stopped=1
  if (( ${#_L_x_running[@]} )); then
    kill "$@" "${!_L_x_running[@]}" 2>/dev/null
    # They have 3 seconds to cleanup, otherwise kill -9 .
    if [[ "$1" != "-9" ]]; then
      L_uv_add_timer -d 3 _L_x_global_timeout_cb -9
    fi
  fi
}

_L_xargs_dobuf_or_prefix_notify() {
  case "$1" in
    PREEXEC)
      if (( _L_x_dobuf_mode == 0 )); then
	      if (( _L_x_prefix )); then
	        # Use > >(...) to prefix output from the task.
		      local _L_prefix
	        printf -v _L_prefix " %q" "${_L_x_atoms[@]::_L_atoms_limit}"
	        L_RET=(L_eval "\"\$@\" > >(_L_xargs_prefixer$_L_prefix)" "${L_RET[@]}")
        fi
      else  # _L_x_dobuf_mode > 0
        local _L_prefix=""
        if (( _L_x_prefix )); then
          # Save prefix for later for stdout task handler to consume.
	        printf -v _L_prefix " %q" "${_L_x_atoms[@]::_L_atoms_limit}"
	        _L_x_dobuf_prefix_idx[L_XARGS_INDEX]=$_L_prefix
	      fi
        # Create pipe for read from the task.
        local _L_pipe
        L_pipe _L_pipe
        _L_x_dobuf_pipe_idx[L_XARGS_INDEX]="${_L_pipe[1]}"
        _L_x_dobuf_read_pipe_idx[L_XARGS_INDEX]="${_L_pipe[0]}"
        L_RET=(L_eval "\"\$@\" ${_L_pipe[0]}>&- >&${_L_pipe[1]}" "${L_RET[@]}")
      fi
      ;;
    POSTEXEC)
      if  (( _L_x_dobuf_mode )); then
        local _L_pid=$2
        _L_x_dobuf_pipe[_L_pid]=${_L_x_dobuf_pipe_idx[L_XARGS_INDEX]}
        local _L_read_fd="${_L_x_dobuf_read_pipe_idx[L_XARGS_INDEX]}"
        unset -v "_L_x_dobuf_pipe_idx[L_XARGS_INDEX]" "_L_x_dobuf_read_pipe_idx[L_XARGS_INDEX]"
        if [[ -n "${_L_x_dobuf_prefix_idx[L_XARGS_INDEX]:-}" ]]; then
          _L_x_dobuf_prefix[_L_pid]="${_L_x_dobuf_prefix_idx[L_XARGS_INDEX]}"
          unset -v "_L_x_dobuf_prefix_idx[L_XARGS_INDEX]"
        fi
        # Close writing side of pipe.
        eval "exec ${_L_x_dobuf_pipe[$_L_pid]}>&-"
        _L_x_dobuf_order+=("$_L_pid")
        # Add a task to read stuff.
        L_uv_add_readline "$_L_read_fd" _L_xargs_dobuf_stdout_cb "$_L_pid"
      fi
      ;;
  esac
}
# Schedule new job from atoms.
_L_xargs_run() {
  local _L_atoms_limit=$(( _L_x_atoms_limit > 0 && _L_x_atoms_limit <= ${#_L_x_atoms[@]} ? _L_x_atoms_limit : ${#_L_x_atoms[@]} )) _L_timer_idx="" L_RET _L_tmp _L_i _L_max
  #
  L_RET=("${_L_x_cmd[@]}")
  #
	if (( _L_x_template )); then
		# Replace {} and {1} {2} ... {N}.
		L_RET=("${L_RET[@]//\{\}/${_L_x_atoms[*]::_L_x_atoms_limit}}")
		for (( _L_i = 1; _L_i <= $_L_x_atoms_limit; ++_L_i )); do
		  L_RET=("${L_RET[@]//\{${_L_i}\}/${_L_x_atoms[*]:$_L_i-1:1}}")
		done
	elif [[ -n "$_L_x_replace" ]]; then
		# Replace {}.
		L_RET=("${L_RET[@]//"$_L_x_replace"/${_L_x_atoms[*]::_L_x_atoms_limit}}")
	else
	  # No templating - add arguments to execute.
    L_RET+=("${_L_x_atoms[@]::_L_atoms_limit}")
	fi
	#
  if (( _L_x_trace )); then
    printf -v _L_tmp " %q" "${L_RET[@]}"
    printf "+$_L_tmp" >&2
  fi
  # Run PREEXEC callbacks.
  set -- PREEXEC ""
  eval "${_L_x_notify_cb:-}"
  # Actually run the job.
  "${L_RET[@]}" &
  local _L_pid=$!
  # Run POSTEXEC callbacks.
  set -- POSTEXEC "$_L_pid"
  eval "${_L_x_notify_cb:-}"
  #
  _L_x_running[_L_pid]=""
  if [[ -n "$_L_x_task_timeout" ]]; then
    L_uv_add_timer -v "_L_x_timers[$_L_pid]" -d "$_L_x_task_timeout" _L_x_task_timeout_cb "$_L_pid"
  fi
  L_uv_add_wait "$_L_pid" _L_xargs_reaper "$L_XARGS_INDEX"
  #
  _L_x_atoms=("${_L_x_atoms[@]:_L_atoms_limit}")
}

# If everything is ok, try to schedule the next job from atoms.
# @env L_RET
_L_xargs_maybe_run() {
  # Consume input from L_RET array.
  if (( ${#L_RET[@]} )); then
	  if (( ${_L_x_split:-1} )); then
		  # Split one record -> Multiple Atoms
		  # shellcheck disable=SC2048
		  L_string_unquote -v L_RET "${L_RET[*]+${L_RET[*]}}" || return 1
	  fi
	  # Bookkeeping of input.
    _L_x_atoms+=(${L_RET[@]+"${L_RET[@]}"})
    (( ++_L_x_cur_records ))
  fi
	# Dual-threshold trigger logic - on number of atoms and number of records.
  while ((
    ( ${#_L_x_running[@]} < _L_x_maxprocs && !_L_x_done ) && (
		  ( _L_x_atoms_limit > 0 && ${_L_x_atoms[*]+${#_L_x_atoms[*]}}+0 >= _L_x_atoms_limit ) ||
		  ( _L_x_records_limit > 0 && _L_x_cur_records >= _L_x_records_limit ) ||
      ( _L_x_input_stopped && ${_L_x_atoms[*]+${#_L_x_atoms[*]}}+0 > 0 )
		)
	)); do
		_L_xargs_run
    _L_x_cur_records=0
    (( ++L_XARGS_INDEX ))
	done
}

# @see https://github.com/jamesyoungman/findutils/blob/master/xargs/xargs.c#L1585
# @see https://github.com/aixoss/findutils/blob/r4.4.2-aix/xargs/xargs.c#L1272
_L_xargs_handle_return() {
	case "$1" in
	0) ;;
	255)
		_L_x_done=1
		if (( _L_x_return < L_EX_TIMEOUT )); then
			_L_x_return=$L_EX_TIMEOUT
		fi
		if (( !_L_x_quiet )); then
			printf "L_xargs: %s: exited with status 255; aborting\n" "${_L_x_cmd[0]}" >&2
		fi
		;;
	126|127)
		_L_x_done=1
		if (( _L_x_return < $1 )); then
			_L_x_return=$1
		fi
		;;
	*)
		if (( 128 < $1 && $1 <= 128 + 64 )); then
			_L_x_done=1
			if (( !_L_x_quiet )); then
				local L_RET
				L_trap_to_name_vL_RET "$(( $1 - 128 ))"
				printf "L_xargs: %s: terminated by signal %s\n" "${_L_x_cmd[0]}" "$L_RET" >&2
			fi
			if (( _L_x_return < 125 )); then
				_L_x_return=125
			fi
		else
			_L_x_return=123
		fi
		;;
	esac
}

# Function executed whena  kid stops running.
# @arg $1 L_XARGS_INDEX of the task
# @arg $2 reaped pid
# @arg $3 exit code
_L_xargs_reaper() {
  # Remove the pid from running list.
  unset -v "_L_x_running[$2]"
  _L_xargs_handle_return "$3"
  if [[ -n "${_L_x_timers[$2]:-}" ]]; then
    L_uv_remove "${_L_x_timers[$2]}"
    unset -v "_L_x_timers[$2]"
  fi
  # Assign the exit status of the command.
  if [[ -n "$_L_x_v" ]]; then
    L_array_set "$_L_x_v" "$1" "$3"
  fi
  # Try to feed more jobs if we have atoms or input is still open.
  _L_xargs_input_trigger
}

# Check if L_RET content is eof string.
_L_xargs_eof_check() {
  if [[ "${L_RET[0]:-}" == "$_L_x_eof_str" ]]; then
    (( _L_x_input_stopped = 1 ))
    L_RET=()
  fi
}

# Try to schedule more jobs.
_L_xargs_input_trigger() {
  if (( _L_x_done )); then return; fi
  if (( !_L_x_input_stopped && ${#_L_x_callback[@]} )); then
    # Read new input from the user provided callback.
    local L_RET=()
    if "${_L_x_callback[@]}"; then
      if "$_L_x_eof_check_cb"; then
        _L_xargs_maybe_run
      fi
    else
      _L_x_input_stopped=1
    fi
  fi
  if (( _L_x_input_stopped || !${#_L_x_callback[@]} )); then
    local L_RET=()
    _L_xargs_maybe_run
  fi
}

# L_uv task that reads data from callback.
_L_xargs_input_task() {
  _L_xargs_input_trigger
  if (( _L_x_input_stopped || _L_done )); then
    L_uv_current_remove
  fi
}

# Callback when a line was read from input file descriptor.
# @arg $1 file descriptor
# @arg [$2] optional line
_L_xargs_feeder_input_cb() {
  if (( _L_x_done || _L_x_input_stopped )); then
    L_uv_current_remove
    return
  fi
  if (( $# == 2 )); then
    local L_RET=("$2")
    if "$_L_x_eof_check_cb"; then
      _L_xargs_maybe_run
    fi
  else
    _L_x_input_stopped=1
  fi
  if (( _L_x_input_stopped )); then
    L_uv_current_remove
    local L_RET=()
    _L_xargs_maybe_run
  fi
}

_L_xargs_callback_array() {
  (( _L_x_array_index < ${#_L_x_array[@]} )) && L_RET=("${_L_x_array[_L_x_array_index++]}")
}

# @description Bash implementation of the `xargs` utility designed for seamless
# integration with local shell environments. Unlike binary `xargs`, `L_xargs` executes within
# the current shell context, enabling the direct use of unexported Bash functions,
# aliases, and variables without requiring `export` or `export -f`.
#
# The tool operates on a dual-unit architecture:
# 1. Records: Discrete segments of input defined by a delimiter (default: `\n`).
# 2. Atoms: The individual arguments passed to the command.
#
# By default, `L_xargs` operates in `-s -0` mode. If `-d` `-0` `-a` options are specified without `-s -S`, `-S` is implied.
#
# Execution follows a first-to-threshold trigger system: the command is dispatched as
# soon as either the Atom limit (-n) or the Record limit (-L) is reached. If no
# limits are specified, the command executes exactly once upon reaching EOF.
#
# @option -0 Use the null character (\0) as the Record separator.
# @option -a <var> Read Records from the specified Bash array variable instead of STDIN.
# @option -c <callback> Execute an eval string to fetch the next Record. Must populate L_RET=() and return 0.
# @option -d <delimiter> Set the Record separator to the specified character.
# @option -s Split Mode: Parse internal Records into multiple Atoms using L_string_unquote.
# @option -S Solid Mode: Treat the entire delimited Record as a single literal Atom (Default).
# @option -u <fd> Read the input stream from the specified file descriptor.
# @option -I <replace-str> Replace occurrences of replace-str in the command. Sets -n 1.
# @option -i Shorthand for -I{}.
# @option -L <max-records> Trigger execution once <max-records> have been accumulated.
# @option -l Shorthand for -L1.
# @option -n <max-atoms> Trigger execution once <max-atoms> have been accumulated.
# @option -r If the input does not contain any atoms, do not run the command. Normally, the command is run once even if there is no input.
# @option -P <max-procs> Concurrent process limit. Supports an integer or 'nproc' for CPU count.
# @option -O Separate output of each command by using pipes. Use twice to keep the output of pipes in order.
# @option -t Verbose: Print each command to STDERR before execution.
# @option -^ Prefix Mode: Prepends the command arguments and a colon to each line of output.
# @option -q Be quiet.
# @option -v <var> Assign array variable the exit statuses of commands. Do not exit with 123-127 exit codes.
# @option -E <eof-str> Set the end of file string to eof-str.  If the end of file string occurs as a line of input, the rest of the input is ignored.
# @option -e <eof-str> Like -E, compatibility wtih GNU xargs, use -E.
# @option -X Exit on error when set -e flag is set. Capture the command exit status with "cmd; rc=$?", preserving set -e flag effect during the duration of cmd.
# @option -T  Use the command as a template: {} is replaced by all arguments,
#             {1} {2} ... {N} are replaced by the corresponding argument.
# @option -h Display this help documentation and exit.
# @arg $@ Command to execute. Default: L_quote_printf.
# @return 0 on success
#         1 on some other error
#         64 ($L_EX_USAGE) on invalid usage
#         123 if any invocation of the command exited with status 1-125 and 192-254
#         124 if the command exited with status 255
#         125 if the command exited with the status 128-192
#         126 if the command cannot be run
#         127 if the command is not found
# @env L_XARGS_INDEX The index of the job being executed.
L_xargs2() {
	local OPTIND OPTARG OPTERR _L_x_replace="" _L_x_atoms_limit=0 _L_x_records_limit="" _L_i _L_x_maxprocs=1 L_RET \
			_L_x_trace=0 _L_registered_xargs_trap=0 _L_x_prefix=0 _L_x_r=0 \
			_L_x_callback=() _L_x_d=$'\n' _L_x_fd=0 _L_x_split="" \
			_L_x_dobuf_mode=0 _L_x_v="" _L_x_rets=() L_XARGS_INDEX=0 _L_x_quiet=0 \
	    _L_x_eof_str _L_x_eof_check_cb=: _L_x_preserve_set_e=0 _L_x_template=0 L_UV=() \
	    _L_x_running=() _L_x_input_stopped=0 _L_x_atoms=() _L_x_task_timeout="" _L_x_timers=() \
	    _L_x_forker=_L_xargs_forker _L_x_notify_cb="" _L_x_return=0 _L_x_done=0 _L_x_cur_records=0 \
      _L_x_dobuf_order=() \
      _L_x_dobuf_pipe=() _L_x_dobuf_prefix=() _L_x_dobuf_output=() _L_x_dobuf_read_pipe=() \
      _L_x_dobuf_pipe_idx=() _L_x_dobuf_prefix_idx=() _L_x_dobuf_read_pipe_idx=()
	while getopts a:0c:d:g:sSu:I:in:L:lrP:tO^qv:E:e:XTh _L_i; do
		case "$_L_i" in
			a)
			  _L_x_callback=(_L_xargs_callback_array)
        if (( L_HAS_NAMEREF )); then
          local -n _L_x_array=$OPTARG
        else
          _L_i="$OPTARG[@]"
          _L_x_array=(${!_L_i+"${!_L_i}"})
        fi
        local _L_x_array_index=0
        _L_x_split=${_L_x_split:-0}
        _L_x_records_limit=${_L_x_records_limit:-1}
        ;;
			0) _L_x_callback=() _L_x_d='' _L_x_split=${_L_x_split:-0} ;;
			c) _L_x_callback=(eval "$OPTARG"); ;;
			d) _L_x_callback=() _L_x_d=$OPTARG _L_x_split=${_L_x_split:-0} ;;
      g) _L_x_task_timeout=$OPTARG; L_duration_to_usec_vL_RET "$_L_x_task_timeout" || return ;;
      G) L_uv_add_timer -v _L_x_global_timex -d "$OPTARG" _L_x_global_timeout_cb || return ;;
			s) _L_x_split=1 ;;
			S) _L_x_split=0 ;;
			u) _L_x_fd=$OPTARG ;;
			I) _L_x_atoms_limit=1 _L_x_replace=$OPTARG ;;
			i) _L_x_atoms_limit=1 _L_x_replace="{}" ;;
			n) _L_x_atoms_limit=$OPTARG ;;
			L) _L_x_records_limit=$OPTARG ;;
			l) _L_x_records_limit=1 ;;
			r) _L_x_r=1 ;;
			P) if [[ "$OPTARG" == n* ]]; then L_nproc_vL_RET; _L_x_maxprocs=$L_RET; else _L_x_maxprocs=$OPTARG; fi ;;
			t) _L_x_trace=1 ;;
			O) _L_x_dobuf_mode=$(( _L_x_dobuf_mode + 1 ))
         [[ "$_L_x_notify_cb" == *"_L_xargs_dobuf_or_prefix_notify"* ]] || _L_x_notify_cb+='_L_xargs_dobuf_or_prefix_notify "$@";'
         ;;
			^) _L_x_prefix=1
         [[ "$_L_x_notify_cb" == *"_L_xargs_dobuf_or_prefix_notify"* ]] || _L_x_notify_cb+='_L_xargs_dobuf_or_prefix_notify "$@";'
         ;;
			q) _L_x_quiet=1 ;;
			v) _L_x_v=$OPTARG ;;
			[eE]) _L_x_eof_check_cb=_L_xargs_eof_check _L_x_eof_str=$OPTARG ;;
			X) _L_x_preserve_set_e=1 ;;
			T) _L_x_template=1 ;;
			h) L_func_help; return 0 ;;
			*) L_func_error "L_xargs: invalid option: -$_L_i"; return "$L_EX_USAGE" ;;
		esac
	done
  shift $((OPTIND - 1))
  if (( _L_x_dobuf_mode || _L_x_prefix )); then
    _L_x_notify+=(_L_xargs_dobuf_or_prefix_notify)
  fi
	local _L_x_cmd=("${@:-L_quote_printf}")
	# Start the loop over records.
  if (( ${#_L_x_callback[@]} )); then
    L_uv_add _L_xargs_input_task
  else
    L_uv_add_readline -d "$_L_x_d" "$_L_x_fd" _L_xargs_feeder_input_cb
  fi
  L_uv_run
  return "$_L_x_return"
}

###############################################################################

if L_is_main; then
  if (($#)); then
    "$@"
  else
    count=0
    mycallback() {
      count=$((count + 1))
      L_notice "mycallback called! count=$count"
      if ((count == 5)); then
        L_notice "ENDING! removing mytimer=$mytimer"
        L_uv_remove "$mytimer"
      fi
    }

    myreader() {
      L_notice "The pipe has written: $*"
    }

    L_finally -f set +e
    L_log_configure -L
    L_uv_init
    L_pipe fd
    L_with_process_into _ L_eval 'for i in 1 2 3; do sleep 0.6; L_log "writing $i"; echo $i; done >&"${fd[1]}"'
    exec {fd[1]}>&-
    L_uv_add_readline "${fd[0]}" myreader
    L_uv_add_timer -d 0.5 -r 0.35 -v mytimer mycallback
    L_notice "process start"
    L_uv_run "$@"
    L_notice "process end"
  fi
fi

# Example usage (commented out):
# count=0
# mycallback() {
#   count=$((counecho WHERE MA I?
#   echo "$(date +%s) mycallback called! count=$count"
#   if ((count == 5)); then
#     echo "ENDING!"
#     L_uv_current_remove
#   fi
# }
# loop1=
# L_uv_init loop1
# L_uv_add_timer -d 100 -r 200 loop1 mycallback
# sleep 0.123 &
# L_uv_add_wait loop1 "$!" L_eval 'echo "$1 died with $2"' $!
