#!/bin/bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")"/../bin/L_lib.sh

###############################################################################
# L_uv
#
# @description The default uv loop variable.
# L_UV
#

# @description Initialize a loop array.
# @arg $1 Loop name (defaults to L_UV)
L_uv_init() { L_array_clear "${1:-L_UV}"; }

# @description Set a callback at a specific index in the loop.
# @arg $1 Loop name (defaults to L_UV)
# @arg $2 Index to set
# @arg $@ Callback function and its arguments
L_uv_set() {
  local -n _L_UV=${1:-L_UV}
  local _L_cmd
  printf -v _L_cmd "%q " "${@:3}"
  _L_UV[1073741820 + $2]="L_UV_CURRENT=$2;${_L_cmd% };"
}

# @description Add a callback to the loop.
# @option -v <var> Variable to assign the index to
# @arg $1 Loop name (defaults to L_UV)
# @arg $@ Callback function and its arguments
L_uv_add() {
  local OPTIND OPTARG OPTERR _L_opt _L_RET="" IFS=' ' _L_cmd _L_idx=$(( ( RANDOM * RANDOM ) % 1073741820 ))
  while getopts v:h _L_opt; do
    case "$_L_opt" in
      v) _L_RET=$OPTARG ;;
      h) L_func_usage; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  local -n _L_UV=${1:-L_UV}
  printf -v _L_cmd "%q " "${@:2}"
  # Optimistic concurrency: try setting the next index, retry on collision (e.g. from signal)
  while
    local _L_t="L_UV_CURRENT=$_L_idx;${_L_cmd% };"
    [[ "${_L_UV[1073741820 + _L_idx]:=$_L_t}" != "$_L_t" ]]
  do
    (( _L_idx = (_L_idx + 1) % 1073741820 ))
  done
  if [[ -n "$_L_RET" ]]; then printf -v "$_L_RET" "%s" "$_L_idx"; fi
}

# @description Remove a callback from the loop by index.
# @arg $1 Loop name (defaults to L_UV)
# @arg $2 Index to remove
L_uv_remove() {
  local _L_p="${1:-L_UV}[$2]"
  eval "${!_L_p:-}"
  unset -v "$_L_p" "${1:-L_UV}[1073741820 + $2]"
}

# @description Update the current executing callback.
# @arg $@ New callback function and its arguments
# @env L_UV_CURRENT
L_uv_current_set() { L_uv_set "" "$L_UV_CURRENT" "$@"; }

# @description Remove the current executing callback.
# @env L_UV_CURRENT
L_uv_current_remove() { L_uv_remove "" "$L_UV_CURRENT"; }

# @description Internal cleanup for L_uv_run.
_L_uv_run_finally() {
  trap - SIGCHLD
  if [[ -n "${_L_uv_pipe[0]:-}" ]]; then
    eval "exec ${_L_uv_pipe[0]}>&- ${_L_uv_pipe[1]}>&-"
  fi
  if (( ${#_L_uv_childs[*]} )); then
    kill "${!_L_uv_childs[@]}" 2>/dev/null || :
    wait "${!_L_uv_childs[@]}" 2>/dev/null || :
  fi
}

# @description Internal waiter for L_uv_run.
_L_uv_run_fifo_reader() {
  # While:
  # - if there is a timeout, timeout is valid
  # - we have read a line (optionally with the timeout)
  # - and the line is not empty
  # execute the line.
  if (( _L_uv_events )); then
    (( _L_uv_events-- ))
  else
    while
      [[ -n "${_L_uv_pipe[0]:-}" ]] &&
      L_is_fd_open "${_L_uv_pipe[0]}" &&
      if [[ -n "${L_UV[1073741820-1]:-}" ]]; then
        L_timeout_left -v _L_opt "${L_UV[1073741820-1]}" || return "$L_EX_TIMEOUT"
        IFS= read -r -t "$_L_opt" -u "${_L_uv_pipe[0]}" _L_uv_line
      else
        IFS= read -r -u "${_L_uv_pipe[0]}" _L_uv_line
      fi &&
      [[ -n "$_L_uv_line" ]]
    do
      eval "$_L_uv_line" || return
    done
  fi
  L_UV[1073741820-1]=""
}

# @description Internal waiter for L_uv_run.
_L_uv_run_sleeper() {
  if L_timeout_is_expired "$L_UV_TIMEOUT"; then
    return "$L_EX_TIMEOUT"
  fi
  sleep "$1"
}

# @description Run the event loop until it's empty or timed out.
# @option -s <float> Polling interval in seconds (defaults to 0.1)
# @option -1 Run only one iteration of the loop.
# @option -c Enable SIGCHLD support for monitoring background processes.
# @option -C Disable SIGCHLD support (default).
# @option -t <float> Timeout in seconds (defaults to none)
# @arg $1 Loop name (defaults to L_UV)
# @return 0 on success, 124 on timeout, or task exit code.
# @example L_uv_add_timer loop 1 echo "hello"; L_uv_run loop
L_uv_run() {
  local OPTIND OPTARG OPTERR _L_opt _L_uv_sleep_time="" L_UV_TIMEOUT="" _L_uv_break=0 _L_uv_pipe \
  L_UV_USES_SIGCHLD=0 _L_uv_childs _L_uv_line="" L_UV_CURRENT _L_uv_waiter_cb=_L_uv_run_sleeper \
  _L_uv_events=0 _L_uv_pid=$BASHPID
  while getopts s:1cCt:h _L_opt; do
    case "$_L_opt" in
      s) _L_uv_sleep_time=$OPTARG ;;
      1) _L_uv_break=1 ;;
      c) L_UV_USES_SIGCHLD=1 ;;
      C) L_UV_USES_SIGCHLD=0 ;;
      t) L_timeout_init_into L_UV_TIMEOUT "$OPTARG" || return ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "${L_EX_USAGE:-64}" ;;
    esac
  done
  shift $((OPTIND - 1))
  if [[ "${1:-}" != "" && "$1" != "L_UV" ]]; then local -n L_UV=$1; fi
  if (( L_UV_USES_SIGCHLD )); then
    L_finally -r _L_uv_run_finally
    trap "(( ++_L_uv_events ))" SIGCHLD
    _L_uv_waiter_cb=_L_uv_run_fifo_reader
  fi
  eval "${L_UV[@]:1073741820}"
  while
    (( !_L_uv_break )) && {
      (( ${_L_uv_childs[@]:+${#_L_uv_childs[*]}}+0 || _L_uv_events )) || [[ -n "${L_UV[*]:1073741820:1}" ]] ||
      { (( L_UV_USES_SIGCHLD )) && read -t 0 -u "${_L_uv_pipe[0]}" _; }
    }
  do
    "$_L_uv_waiter_cb" "${_L_uv_sleep_time:-0.1}" || return
    eval "${L_UV[@]:1073741820}"
  done
}

# @description Register a cleanup command to be executed when a task is removed.
# @arg $1 Loop name (defaults to L_UV)
# @arg $2 Task index
# @arg $@ Cleanup command and its arguments
L_uv_on_remove() { printf -v "${1:-L_UV}[$2]" "%s;" "${@:3}"; }

# @description Register a cleanup command for the current task.
# @arg $@ Cleanup command and its arguments
L_uv_current_on_remove() { L_uv_on_remove "" "$L_UV_CURRENT" "$@"; }

# @description Send a message to the loop's waker pipe.
# @arg $1 Format string
# @arg $@ Arguments for the format string
L_uv_notify() {
  if (( BASHPID != _L_uv_bashpid )); then
    printf "${1:-}\n" "${@:2}" >&"${_L_uv_pipe[1]:-}"
  else
    (( ++_L_uv_events ))
    if (( $# )); then
      local _L_tmp
      printf -v _L_tmp "$1\n" "${@:2}"
      eval "$_L_tmp"
    fi
  fi
}

# @description Spawn a command in the background and track it as part of the current task.
# This registers a cleanup to kill the process on task removal and updates the task to wait for its exit.
# @arg $@ Command and its arguments
L_uv_current_to_background() {
  if (( L_UV_USES_SIGCHLD )); then
    if [[ -z "${_L_uv_pipe[0]:-}" ]]; then
      # Pipe is lazy opened when the first background process spawns.
      L_pipe _L_uv_pipe
    fi
    "$@" &
    _L_uv_childs["$!"]=""
    L_uv_current_on_remove "kill $! 2>/dev/null && wait $! 2>/dev/null || :"
    L_uv_current_set _L_uv_wait_callback "$!" L_eval "unset -v '_L_uv_childs[$!]'"
  else
    L_fatal "Only call $FUNCNAME with L_uv_run enabled SIGCHLD support"
  fi
}

# @description Break the current event loop.
L_uv_break() { _L_uv_break=1; }

# @description Update the loop wakeup time if the provided time is sooner.
# @arg $1 Time in microseconds since epoch
L_uv_set_next_wakeup_us() {
  (( ( L_UV[1073741820-1] == 0 || L_UV[1073741820-1] > $1 ) && L_UV[1073741820-1]=$1 , 1 ))
}

# @description Internal callback for timers.
# @arg $1 Expiration time in microseconds
# @arg $2 Repeat interval in microseconds
# @arg $@ Callback function and its arguments
_L_uv_timer_callback() {
  local _L_now_us
  L_epochrealtime_usec -v _L_now_us
  if (( $1 <= _L_now_us )); then
    if (( $2 > 0 )); then
      local _L_next_us="$(( $1 + $2 ))"
      L_uv_set_next_wakeup_us "$_L_next_us"
      L_uv_current_set "$FUNCNAME" "$_L_next_us" "${@:2}"
    else
      L_uv_current_remove
    fi
    "${@:3}"
  else
    L_uv_set_next_wakeup_us "$1"
  fi
}

_L_uv_timer_callback_init() {
  if (( L_UV_USES_SIGCHLD )); then
    # Each timer callback sorts the timers to determine the earliest one.
    # After removal, we need to trigger the pipeline once so it re-computes the time.
    L_uv_current_on_remove L_uv_notify
  fi
  L_uv_current_set _L_uv_timer_callback "$@"
  _L_uv_timer_callback "$@"
}

# @description Add a timer to the loop.
# @option -r <int> Repeat interval in milliseconds (defaults to 0)
# @option -d <int> Initial delay in milliseconds (defaults to 0)
# @option -v <var> Variable to assign the timer index to
# @arg $1 Loop name (defaults to L_UV)
# @arg $@ Callback function and its arguments
L_uv_add_timer() {
  local OPTIND OPTARG OPTERR _L_opt _L_r=0 _L_d=0 _L_v=_L_tmp _L_now_us _L_tmp
  while getopts r:d:v:h _L_opt; do
    case "$_L_opt" in
      r) L_duration_to_usec -v _L_r "$OPTARG" || return ;;
      d) L_duration_to_usec -v _L_d "$OPTARG" || return ;;
      v) _L_v=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  L_epochrealtime_usec -v _L_now_us
  local _L_next_us="$(( _L_now_us + _L_d ))"
  L_uv_add -v "$_L_v" "$1" _L_uv_timer_callback_init "$_L_next_us" "$_L_r" "${@:2}"
}

# @return 0 if current task is the only task.
_L_uv_current_is_alone() {
  local -n _L_UV=${1:-L_UV}
  local _L_tasks=("${_L_UV[@]:1073741820:2}")
  (( ${#_L_tasks[@]} == 1 ))
}

_L_uv_all_callbacks_match() {
  local IFS=$'\n'
  [[ "${_L_UV[*]:1073741820}"$'\n' == ^$'\n'(L_UV_CURRENT=[0-9]+;$1" "[^'\n']*;$'\n')+ ]]
}

_L_uv_pids_add() {
  local _L_i="${1:-L_UV}[1073741820-2]"
  L_printf_v "$_L_i" "%s%s" "${!_L_i:-}$2"
}
_L_uv_pids_remove() {
  local _L_i="${1:-L_UV}[1073741820-2]"
  L_printf_v "$_L_i" "%s" "${!_L_i// $2 }"
}
_L_uv_pids_vL_RET() {
  local _L_i="${1:-L_UV}[1073741820-2]"
  L_RET=${!_L_i}
}

_L_uv_wait_call_it() {
  _L_uv_pids_remove "" " $1 "
  if wait "$1"; then
    "${@:2}" "$1" 0
  else
    "${@:2}" "$1" "$?"
  fi
}

# @description Internal callback for process waiting.
# @arg $1 Space separated list of PIDs to wait for.
# @arg $@ Callback function and its arguments
_L_uv_wait_callback() {
  local L_RET
  if (( !L_UV_USES_SIGCHLD )); then
    _L_uv_pids_vL_RET ""
    if [[ "$L_RET" == "$1"* ]] && _L_uv_all_callbacks_match "(_L_uv_wait_callback|_L_uv_timer_callback)"; then
      local _L_pids=($L_RET)
      if [[ -n "$L_UV_TIMEOUT" ]] && L_timeout_left_vL_RET "$L_UV_TIMEOUT"; then
        if L_hash waitpid; then
          waitpid -c 1 -e -t "$L_RET" $1
        elif (( ${#_L_pids[@]} == 1 )) && L_hash timeout tail && _L_wait_tail_has_pid; then
          timeout "$L_RET" tail --pid="$1" -f /dev/null
        fi
      else
        if (( ${#_L_pids[@]} == 1 )); then
          L_uv_current_remove
          _L_uv_wait_call_it "${1// }" "${@:2}"
          return
        else
          wait -n "${_L_pids[@]}"
        fi
      fi
    fi
  fi
  for L_RET in $1; do
    if ! kill -0 "$L_RET" 2>/dev/null; then
      if [[ "$1" == " $L_RET " ]]; then
        L_uv_current_remove
      else
        L_uv_current_set "$FUNCNAME" "${1// $L_RET }" "${@:2}"
      fi
      _L_uv_wait_call_it "$L_RET" "${@:2}"
      return
    fi
  done
}

# @description Add a process wait handle to the loop.
# @option -v <var> Variable to assign the wait index to
# @arg $1 Loop name (defaults to L_UV)
# @arg $@ PIDs to wait for
# @arg $@ Callback function and its arguments.
L_uv_add_wait() {
  local OPTIND OPTARG OPTERR _L_opt _L_v="" _L_pids="" _L_loop
  while getopts v:h _L_opt; do
    case "$_L_opt" in
      v) _L_v=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  _L_loop=$1
  shift
  while [[ "$1" == [0-9]* ]]; do
    _L_pids+=" $1 "
    shift
  done
  if (( ${#_L_pids[@]} == 0 )); then
    L_func_usage_error "Pids to wait for missing"
    return "$L_EX_USAGE"
  fi
  if [[ "$1" == "--" ]]; then
    shift
  fi
  if (( $# == 0 )); then
    L_func_usage_error "Callback to call missing"
    return "$L_EX_USAGE"
  fi
  L_uv_add -v "$_L_v" "$_L_loop" _L_uv_wait_callback "$_L_pids" "${@:2}" && _L_uv_pids_add "$_L_loop" "$_L_pids"
}

# @description Internal callback for once-run conditions.
# @arg $1 Condition to evaluate
# @arg $@ Callback function and its arguments
_L_uv_once_callback() {
  if eval "$1"; then
    L_uv_current_remove
    "${@:2}"
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
_L_uv_readline_callback_polling() {
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

# @description Internal background process for reading lines from a file descriptor.
# @arg $1 Delimiter
# @arg $2 File descriptor
# @arg $3 Callback command
_L_uv_readline_background_reader() {
  local line
  while IFS= read -r -d "$1" -u "$2" line; do
    # L_log "$2 $line"
    L_uv_notify "%s %d %q" "$3" "$2" "$line"
  done
  # L_log "END $2"
  L_uv_notify "%s %d" "$3" "$2"
}

# @description Initialize a line-buffered read task, choosing between proxy and polling backends.
# @arg $1 Delimiter
# @arg $2 File descriptor
# @arg $@ Callback function and its arguments
_L_uv_readline_callback_init() {
  if (( L_UV_USES_SIGCHLD )); then
    local _L_cmd
    printf -v _L_cmd "%q " "${@:3}"
    L_uv_current_to_background _L_uv_readline_background_reader "$1" "$2" "$_L_cmd"
  else
    L_uv_current_set _L_uv_readline_callback_polling "" "$@"
    _L_uv_readline_callback_polling "" "$@"
  fi
}

# @description Add a line-buffered read handle to the loop.
# @option -d Delimiter character (defaults to newline)
# @option -v <var> Variable to assign the readline index to
# @arg $1 Loop name (defaults to L_UV)
# @arg $2 Target file descriptor
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
  L_uv_add -v "$_L_v" "$1" _L_uv_readline_callback_init "$_L_d" "$2" "${@:3}"
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
  if (( $# == 3 )); then
    _L_x_dobuf_output[$1]+="${_L_x_dobuf_prefix[$1]:-}$2"$'\n'
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
    L_uv_add_timer -d 3 _L_x_loop _L_x_task_timeout_cb -9 "$1"
  fi
}

# @option -9 Signal o use
_L_x_global_timeout_cb() {
  _L_x_done=1
  _L_x_input_stopped=1
  if (( ${#_L_x_running[@]} )); then
    kill "$@" "${!_L_x_running[@]}" 2>/dev/null
    # They have 3 seconds to cleanup, otherwise kill -9 .
    L_uv_add_timer -d 3 _L_x_loop _L_x_global_timeout_cb -9
  fi
}

# Used by -^ mode to prefix each line from the task.
_L_xargs_prefixer() { while IFS= read -r line; do printf "%s\n" "$1: $line"; done; }

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
      else  # _L_x_dobus_mode > 0
        if (( _L_x_prefix )); then
          # Save prefix for later for stdout task handler to consume.
		      local _L_prefix
	        printf -v _L_prefix " %q" "${_L_x_atoms[@]::_L_atoms_limit}"
	        _L_x_dobuf_prefix["$!"]=$_L_prefix
	      fi
        # Create pipe for read from the task.
        local _L_pipe
        L_pipe _L_pipe
        _L_x_dobuf_pipe["$!"]="${_L_pipe[1]}"
        L_RET=(L_eval "\"\$@\" ${_L_pipe[0]}>&- >&${_L_pipe[1]}" "${L_RET[@]}")
      fi
      ;;
    POSTEXEC)
      if  (( _L_x_dobuf_mode )); then
        # Close writing side of pipe.
        eval "exec ${_L_x_dobuf_pipe[$1]}>&-"
        _L_x_dobuf_order+=("$!")
        # Add a task to read stuff.
        L_uv_add_readline _L_x_loop "${_L_pipe[0]}" _L_xargs_dobuf_stdout_cb "$!"
      fi
      ;;
  esac
}
# Schedule new job from atoms.
_L_xargs_run() {
  local _L_atoms_limit=$(( _L_x_atoms_limit > 0 && _L_x_atoms_limit <= ${#_L_x_atoms[@]} ? _L_x_atoms_limit : ${#_L_x_atoms[@]} )) _L_t_idx="" L_RET _L_tmp _L_i _L_max
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
  for _L_i in "${_L_x_notify[@]}"; do
    L_eval "$_L_i \"\$@\"" PREEXEC
  done
  # Actually run the job.
  "${L_RET[@]}" &
  local _L_pid=$!
  #
  for _L_i in "${_L_x_notify[@]}"; do
    L_eval "$_L_i \"\$@\"" POSTEXEC "$_L_pid" "${L_RET[@]}"
  done
  #
  _L_x_running[_L_pid]=""
  local _L_t_idx=""
  if [[ -n "$_L_x_task_timeout" ]]; then
    L_uv_add_timer -v _L_t_idx -d "$_L_x_task_timeout" _L_x_loop _L_x_task_timeout_cb "$_L_pid"
  fi
  L_uv_add_wait _L_x_loop "$_L_pid" _L_xargs_reaper "$_L_pid" "$L_XARGS_INDEX" "$_L_t_idx"
  #
  _L_x_atoms=("${_L_x_atoms[@]:_L_atoms_limit}")
}

# If everything is ok, try to schedule the next job from atoms.
# @env L_RET
_L_xargs_maybe_run() {
  # Consume input from L_RET array.
	if (( ${_L_x_split:-1} )); then
		# Split one record -> Multiple Atoms
		# shellcheck disable=SC2048
		L_string_unquote -v L_RET "${L_RET[*]+${L_RET[*]}}" || return 1
	fi
	# Bookkeeping of input.
  _L_x_atoms+=(${L_RET[@]+"${L_RET[@]}"})
  (( ++_L_x_cur_records ))
	# Dual-threshold trigger logic - on number of atoms and number of records.
  if ((
    ( ${#_L_x_running[@]} < _L_x_maxprocs && !_L_x_done ) && (
		  ( _L_x_atoms_limit > 0 && ${_L_x_atoms[*]+${#_L_x_atoms[*]}}+0 >= _L_x_atoms_limit ) ||
		  ( _L_x_records_limit > 0 && _L_cur_records >= _L_x_records_limit )
		)
	)); then
		_L_xargs_run
    _L_x_cur_records=0
    (( ++L_XARGS_INDEX ))
	fi
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
# @arg $1 pid
# @arg $2 L_XARGS_INDEX of the task
# @arg $3 task timer idx
# @arg $4 exit code
_L_xargs_reaper() {
  # Remove the pid from running list.
  unset -v "_L_x_running[$1]"
  _L_xargs_handle_return "$4"
  if [[ -n "${3:-}" ]]; then
    L_uv_remove _L_x_loop "$3"
  fi
  # Assign the exit status of the command.
  if [[ -n "$_L_x_v" ]]; then
    L_array_set "$_L_x_v" "$2" "$4"
  fi
  # Try to feed more jobs if we have atoms or input is still open.
  _L_xargs_input_task
}


# L_uv task that reads data from callback.
_L_xargs_input_task() {
  if (( !_L_x_done && !_L_x_input_stopped && ${#_L_x_callback[@]} )); then
    # Read new input from the user provided callback.
    local L_RET=()
    if "${_L_x_callback[@]}"; then
      if [[ -n "$_L_x_eof_str" && "${L_RET[0]:-}" == "$_L_x_eof_str" ]]; then
        _L_x_input_stopped=1
      else
        _L_xargs_maybe_run
        # If there is space for more tasks, yield yourself for later.
        if (( ${#_L_x_running[@]} < _L_x_maxprocs )); then
          L_uv_notify
        fi
      fi
    else
      _L_x_input_stopped=1;
    fi
  fi
}

# Callback when a line was read from input file descriptor.
# @arg $1 file descriptor
# @arg [$2] optional line
_L_xargs_feeder_input_cb() {
  if (( !_L_x_done && !_L_x_input_stopped )); then
    if (( $# == 2 )); then
      if [[ -n "$_L_x_eof_str" && "$2" == "$_L_x_eof_str" ]]; then
        _L_x_input_stopped=1
      else
        local L_RET
        L_RET=("$2")
        _L_xargs_maybe_run
      fi
    else
      _L_x_input_stopped=1
    fi
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
			_L_x_dobuf_mode="" _L_x_dobuf_output=() _L_x_v="" _L_x_rets=() L_XARGS_INDEX=0 _L_x_quiet=0 _L_x_dobuf_prefix=() \
	    _L_x_eof_str="" _L_x_preserve_set_e=0 _L_x_template=0 _L_x_loop=() \
	    _L_x_running=() _L_x_input_stopped=0 _L_x_atoms=() _L_x_task_timeout="" \
	    _L_x_forker=_L_xargs_forker _L_x_notify=() _L_x_return=0 _L_x_done=0 _L_x_cur_records=0
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
      G) L_uv_add_timer -d "$OPTARG" _L_x_loop _L_x_global_timeout_cb || return ;;
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
			O) _L_x_dobuf_mode=$(( _L_x_dobuf_mode + 1 )) ;;
			^) _L_x_prefix=1 ;;
			q) _L_x_quiet=1 ;;
			v) _L_x_v=$OPTARG ;;
			E) _L_x_eof_str=$OPTARG ;;
			e) _L_x_eof_str=$OPTARG ;;
			X) _L_x_preserve_set_e=1 ;;
			T) _L_x_template=1 ;;
			h) L_func_help; return 0 ;;
			*) L_func_error "L_xargs: invalid option: -$_L_i"; return "$L_EX_USAGE" ;;
		esac
	done
  if (( _L_x_dobuf_mode || _L_x_prefix )); then
    _L_x_notify+=(_L_xargs_dobuf_or_prefix_notify)
  fi
	local _L_x_cmd=("${@:-L_quote_printf}")
	# Start the loop over records.
  if (( ${#_L_x_callback[@]} )); then
    L_uv_add _L_x_loop _L_xargs_input_task
  else
    L_uv_add_readline -d "$_L_x_d" _L_x_loop "$_L_x_fd" _L_xargs_feeder_input_cb
  fi
  L_uv_run _L_x_loop
  return "$_L_x_return"
}

###############################################################################

if L_is_main; then

  count=0
  mycallback() {
    count=$((count + 1))
    L_notice "mycallback called! count=$count"
    if ((count == 5)); then
      L_notice "ENDIGN! removing mytimer=$mytimer"
      L_uv_remove "" "$mytimer"
    fi
  }

  myreader() {
    L_notice "The pipe has written: $*"
  }

  L_finally -f set +e
  L_log_configure -L
  L_uv_init
  L_pipe fd
  L_with_process_into _ L_eval 'for i in 1 2 3; do sleep 0.6; echo $i; done >&"${fd[1]}"'
  exec {fd[1]}>&-
  L_uv_add_readline "" "${fd[0]}" myreader
  L_uv_add_timer -d 1 -r 2 -v mytimer "" mycallback
  L_error "process start"
  L_uv_run "$@"
  L_error "process end"
fi

# Example usage (commented out):
# count=0
# mycallback() {
#   count=$((counecho WHERE MA I?
#   echo "$(date +%s) mycallback called! count=$count"
#   if ((count == 5)); then
#     echo "ENDIGN!"
#     L_uv_current_remove
#   fi
# }
# loop1=
# L_uv_init loop1
# L_uv_add_timer -d 100 -r 200 loop1 mycallback
# sleep 0.123 &
# L_uv_add_wait loop1 "$!" L_eval 'echo "$1 died with $2"' $!
# L_uv_add_once loop1 echo "This should run once immediately"
# L_uv_add_once -c '(( count >= 3 ))' loop1 echo "This should run once count is >= 3"
# L_uv_run loop1


