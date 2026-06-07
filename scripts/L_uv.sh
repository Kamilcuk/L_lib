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
    "${@:2}"
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
  L_UV[1073741820-1]=$(( ( L_UV[1073741820-1] == 0 || L_UV[1073741820-1] > $1 ) ? $1 : L_UV[1073741820-1] ))
}

# @description Internal callback for timers.
# @arg $1 Expiration time in microseconds
# @arg $2 Repeat interval in milliseconds
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
  local OPTIND OPTARG OPTERR _L_opt _L_r=0 _L_d=0 _L_RET=_L_tmp _L_now_us _L_tmp
  while getopts r:d:v:h _L_opt; do
    case "$_L_opt" in
      r) L_duration_to_usec -v _L_r "$OPTARG" || return ;;
      d) L_duration_to_usec -v _L_d "$OPTARG" || return ;;
      v) _L_RET=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  L_epochrealtime_usec -v _L_now_us
  local _L_next_us="$(( _L_now_us + _L_d ))"
  L_uv_add -v "$_L_RET" "$1" _L_uv_timer_callback_init "$_L_next_us" "$_L_r" "${@:2}"
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
  local OPTIND OPTARG OPTERR _L_opt _L_RET="" _L_pids="" _L_loop
  while getopts v:h _L_opt; do
    case "$_L_opt" in
      v) _L_RET=$OPTARG ;;
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
  L_uv_add -v "$_L_RET" "$_L_loop" _L_uv_wait_callback "$_L_pids" "${@:2}" && _L_uv_pids_add "$_L_loop" "$_L_pids"
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
  local OPTIND OPTARG OPTERR _L_opt _L_c="" _L_RET=""
  while getopts c:v:h _L_opt; do
    case "$_L_opt" in
      c) _L_c=$OPTARG ;;
      v) _L_RET=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  if (( $# > 1 )); then
    # Otherwise, we handle the condition with a callback.
    L_uv_add -v "$_L_RET" "$1" _L_uv_once_callback "$_L_c" "${@:2}"
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
  local OPTIND OPTARG OPTERR _L_opt _L_d=$'\n' _L_RET=""
  while getopts d:v:h _L_opt; do
    case "$_L_opt" in
      d) _L_d=$OPTARG ;;
      v) _L_RET=$OPTARG ;;
      h) L_func_usage; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  L_uv_add -v "$_L_RET" "$1" _L_uv_readline_callback_init "$_L_d" "$2" "${@:3}"
}

###############################################################################

_L_x_stdout_cb() {
  if (( $# == 2 )); then
    printf "OUT [%d]: %s\n" "$1" "$2"
  fi
}

_L_x_task_timeout_cb() { kill -9 "$1" 2>/dev/null; }

_L_x_global_timeout_cb() {
  _L_x_stopped=1
  if (( ${#_L_x_pids[@]} )); then
    kill -9 "${!_L_x_pids[@]}" 2>/dev/null
  fi
}

_L_x_reaper() {
  # $1: task_timer_idx, $2: pid, $3: exit_code
  (( _L_x_running-- ))
  unset -v "_L_x_pids[$2]"
  if [[ -n "${1:-}" ]]; then
    L_uv_remove _L_x_loop "$1"
  fi
  # Always try to feed more jobs if we have atoms or input is still open
  L_uv_add_once _L_x_loop _L_xargs_feeder
}

_L_xargs_run() {
  local _L_current_args=()
  if (( _L_x_atoms_limit > 0 )); then
    _L_current_args=("${_L_x_atoms[@]:0:_L_x_atoms_limit}")
    _L_x_atoms=("${_L_x_atoms[@]:_L_x_atoms_limit}")
  else
    _L_current_args=("${_L_x_atoms[@]}")
    _L_x_atoms=()
  fi
  _L_x_cur_records=0
  (( ++_L_x_running ))
  local pipe _L_t_idx=""
  if (( _L_x_dobuf )); then
    L_pipe pipe
    "${_L_x_cmd[@]}" "${_L_current_args[@]}" "${pipe[0]}">&- >&"${pipe[1]}" &
    eval "exec ${pipe[1]}>&-"
    L_uv_add_readline _L_x_loop "${pipe[0]}" _L_x_stdout_cb
  else
    "${_L_x_cmd[@]}" "${_L_current_args[@]}" &
  fi
  local _L_pid=$!
  _L_x_pids[$_L_pid]=""
  if [[ -n "$_L_x_task_timeout" ]]; then
    L_uv_add_timer -v _L_t_idx -d "$_L_x_task_timeout" _L_x_loop _L_x_task_timeout_cb "$_L_pid"
  fi
  L_uv_add_wait _L_x_loop "$_L_pid" _L_x_reaper "$_L_t_idx" "$_L_pid"
}

_L_xargs_feeder() {
  # Add input once if called asynchronously.
  if (( $# )); then
    _L_x_atoms+=("$@")
    (( ++_L_x_cur_records ))
  else
    _L_x_input_stopped=1
  fi
  #
  while (( _L_x_running < _L_x_maxprocs )); do
    # If callback is present, read from the callback.
    if (( ${#_L_x_callback[@]} )); then
      local L_RET=()
      if "${_L_x_callback[@]}"; then
        _L_x_atoms+=(${L_RET[@]+"${L_RET[@]}"})
        (( ++_L_x_cur_records ))
      else
        _L_x_input_stopped=1;
      fi
    fi
    #
		if (( _L_atoms_limit > 0 )); then
			while (( ${_L_atoms[*]+${#_L_atoms[*]}}+0 >= _L_atoms_limit && _L_x_running < _L_x_maxprocs )); do
				_L_xargs_run "${_L_atoms[@]:0:_L_atoms_limit}"
				_L_atoms=("${_L_atoms[@]:_L_atoms_limit}")
				_L_cur_records=0
			done
		fi

    #
    if (( _L_x_input_stopped )); then
      # EOF call
      if (( ${#_L_x_atoms[@]} )); then
        
      # If input is stopped, and we did not schedule anbything, means we need to get out.
      break
    fi
  done


    local _L_trigger=0
    if (( _L_x_stopped )); then
      if (( ${#_L_x_atoms[@]} > 0 )); then
        _L_trigger=1
      else
        break
      fi
    elif (( _L_x_atoms_limit > 0 && ${#_L_x_atoms[@]} >= _L_x_atoms_limit )); then
      _L_trigger=1
    elif (( _L_x_records_limit > 0 && _L_x_cur_records >= _L_x_records_limit )); then
      _L_trigger=1
    elif (( _L_x_atoms_limit == 0 && _L_x_records_limit == 0 && ${#_L_x_atoms[@]} > 0 )); then
      _L_trigger=1
    else
      # If not stopped, we might need to read more.
      # If using callback (like -a), try reading more right now.
      if [[ -n "${_L_x_feeder_pull:-}" ]]; then
        local L_RET=()
        if ! "${_L_x_callback[@]}"; then
          _L_x_stopped=1
          continue
        fi
        continue
      fi
      break
    fi
    if (( _L_trigger )); then
      _L_xargs_run
    elif (( _L_x_stopped )); then
      break
    fi
  done
}

_L_xargs_feeder_input_cb() {
  # $1: fd, $2: line (if set)
  if (( $# == 2 )); then
    _L_x_atoms+=("$2")
    (( ++_L_x_cur_records ))
  else
    _L_x_stopped=1
  fi
  _L_xargs_feeder
}

_L_xargs_callback_array() {
  (( _L_x_a_index < ${#_L_x_a[@]} )) && L_RET=("${_L_x_a[_L_x_a_index++]}")
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
#         123 if any invocation oft he command exited with status 1-125 and 192-254
#         124 ($L_EX_TIMEOUT) if the command exited with status 255
#         125 if the command exited with the status 128-192
#         126 if the command cannot be run
#         127 if the command is not found
# @env L_XARGS_INDEX The index of the job being executed.
L_xargs2() {
	local OPTIND OPTARG OPTERR _L_x_replace="" _L_x_atoms_limit=0 _L_x_records_limit="" _L_i _L_x_maxprocs=1 L_RET \
			_L_x_verbose=0 _L_registered_xargs_trap=0 _L_x_prefix=0 _L_x_r=0 \
			_L_x_callback=(_L_xargs_callback_read) _L_x_d=$'\n' _L_x_fd=0 _L_x_a _L_x_a_index=0 _L_x_split="" \
			_L_x_dobuf=0 _L_x_buf_fds_set=() _L_x_buf_output=() _L_x_v="" _L_x_rets=() L_XARGS_INDEX=0 _L_x_quiet=0 \
	    _L_x_eof_str="" _L_x_preserve_set_e=0 _L_x_template=0 _L_x_loop=() \
	    _L_x_running=0 _L_x_stopped=0 _L_x_atoms=() _L_x_task_timeout=""
	while getopts a:0c:d:g:sSu:I:in:L:lrP:tO^qv:E:e:XTh _L_i; do
		case "$_L_i" in
			a) _L_x_callback=(_L_xargs_callback_array) _L_i="$OPTARG[@]" _L_x_a=(${!_L_i+"${!_L_i}"}) _L_x_split=${_L_x_split:-0} _L_x_records_limit=${_L_x_records_limit:-1} ;;
			0) _L_x_callback=(_L_xargs_callback_read) _L_x_d='' _L_x_split=${_L_x_split:-0} ;;
			c) _L_x_callback=(eval "$OPTARG"); ;;
			d) _L_x_callback=(_L_xargs_callback_read) _L_x_d=$OPTARG _L_x_split=${_L_x_split:-0} ;;
      g) _L_x_task_timeout=$OPTARG; L_duration_to_usec "$_L_x_task_timeout" >/dev/null || return ;;
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
			P) if [[ "$OPTARG" == n* ]]; then L_nproc_v; _L_x_maxprocs=$L_RET; else _L_x_maxprocs=$OPTARG; fi ;;
			t) _L_x_verbose=1 ;;
			O) _L_x_dobuf=$(( _L_x_dobuf + 1 )) ;;
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
	# When under -E or -e, exit when a line is exactly something.
	if (( _L_x_eof_str )); then
		_L_x_callback=(_L_xargs_handle_eof_str "${_L_x_callback[@]}")
	fi
	# Start the loop over records.
	local _L_cmd=("${@:-L_quote_printf}") _L_x_pid_to_num=() _L_atoms=() _L_x_return=0 _L_x_done=0 _L_x_cur_records=0
	# _L_x_done is set when any command exits wtih 255.
  if [[ "${_L_x_callback[*]}" == "_L_xargs_callback_read" ]]; then
    L_uv_add_readline _L_x_loop "$_L_x_fd" _L_xargs_feeder_input_cb
  else
    local _L_x_feeder_pull=1
    L_uv_add_once _L_x_loop _L_xargs_feeder
  fi
  L_uv_run _L_x_loop
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


