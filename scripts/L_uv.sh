#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")"/../bin/L_lib.sh

###############################################################################

# Pause for a specified duration using the best available sleep method.
# @arg $1 Duration in floating point seconds.
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

###############################################################################
# L_uv
#
# L_UV array variable layout:
# | Offset / Formula         | Data Property / Description                   | Group     |
# | :----------------------- | :-------------------------------------------- | :-------- |
# | 1                        | Boolean flag (1 if optimized)                 | Global    |
# | 10000000                 | Next available Timer ID                       | Timer     |
# | 11000000                 | Timer Heap (metadata at base, elements at +1) | Timer     |
# | 12000000 + (TID * 3) + 0 | Timer: User callback                          | Timer     |
# | 12000000 + (TID * 3) + 1 | Timer: Repeat interval (usec)                 | Timer     |
# | 12000000 + (TID * 3) + 2 | Timer: Heap inverse map pointer               | Timer     |
# | 20000000                 | Next available Waiter ID                      | Waiter    |
# | 20000001                 | Active Waiter IDs cache (rel_id)              | Waiter    |
# | 20000002                 | List of space separated pids                  | Waiter    |
# | 21000000 + (WID * 2) + 0 | Waiter: User callback                         | Waiter    |
# | 21000000 + (WID * 2) + 1 | Waiter: PID to monitor                        | Waiter    |
# | 29000000                 | Buckets of pids to waiter id mapping          | Waiter    |
# | 30000000                 | Next available Reader ID                      | Reader    |
# | 30000001                 | Active Reader IDs cache (rel_id)              | Reader    |
# | 31000000 + (RID * 4) + 0 | Reader: User callback                         | Reader    |
# | 31000000 + (RID * 4) + 1 | Reader: Separator (delimiter)                 | Reader    |
# | 31000000 + (RID * 4) + 2 | Reader: File descriptor (FD)                  | Reader    |
# | 31000000 + (RID * 4) + 3 | Reader: Accumulation buffer                   | Reader    |
# | 90000000 + taskid        | L_finally index for resource cleanup          | Cleanup   |
# | 93999999                 | last L_finally index for resource cleanup     | Cleanup   |
# | 98000000                 | Next available Task ID (relative offset)      | Task      |
# | 99000000 + TID           | User task callbacks                           | Execution |
#
# | Type   | ID Range          | Data Base| Multiplier |
# | :----- | :---------------- | :------- | :--------- |
# | Timer  |       0 -  999999 | 12000000 | 3          |
# | Waiter | 1000000 - 1999999 | 21000000 | 2          |
# | Reader | 2000000 - 2999999 | 31000000 | 4          |
# | Task   | 3000000 - 3999999 | 99000000 | 1          |
#
# @description The global uv loop variable.
# L_UV=()

###############################################################################
# timerheap

_L_uv_timerheap_swap_with_L_tmp() {
  # Swaps two heap elements and updates their inverse mapping for O(1) removal.
  _L_tmp=${L_UV[11000000 + $1]} \
    L_UV[11000000 + $1]=${L_UV[11000000 + $2]} \
    L_UV[11000000 + $2]=$_L_tmp \
    L_UV[12000000 + (${_L_tmp#*:} * 3) + 2]=$2 \
    L_UV[12000000 + (${L_UV[11000000 + $1]#*:} * 3) + 2]=$1
}

# @description Maintain the min-heap property by sifting an element up.
# @arg $1 Current index in the heap
_L_uv_timerheap_sift_up() {
  local _L_curr=$1 _L_parent _L_tmp
  # Bubbles up an element that expires earlier than its parent.
  while
    (( _L_curr > 1 && ( _L_parent = _L_curr / 2 ) )) &&
    [[ "${L_UV[11000000 + _L_curr]}" < "${L_UV[11000000 + _L_parent]}" ]]
  do
    _L_uv_timerheap_swap_with_L_tmp _L_curr _L_parent
    _L_curr=$_L_parent
  done
}

# @description Maintain the min-heap property by sifting an element down.
# @arg $1 Current index in the heap
_L_uv_timerheap_sift_down() {
  local _L_curr=$1 _L_size=${L_UV[11000000]:-0} _L_child _L_tmp
  # Sinks down an element that expires later than its smallest child.
  while
    (( ( _L_child = _L_curr * 2 ) <= _L_size )) && {
      # Selects the smaller of the two children.
      if (( _L_child + 1 <= _L_size )) && [[ "${L_UV[11000000 + _L_child + 1]}" < "${L_UV[11000000 + _L_child]}" ]]; then
        (( ++_L_child ))
      fi
      # Compare current with child.
      [[ "${L_UV[11000000 + _L_child]}" < "${L_UV[11000000 + _L_curr]}" ]]
    }
  do
    _L_uv_timerheap_swap_with_L_tmp _L_curr _L_child
    _L_curr=$_L_child
  done
}

# @description Push a timer into the min-heap.
# @arg $1 String in format "TIMESTAMP:TASK_ID"
_L_uv_timerheap_push() {
  local _L_size=$(( L_UV[11000000] = ${L_UV[11000000]:-0} + 1 ))
  # Appends the new timer at the end and sifts it up to the correct position.
  L_UV[11000000 + _L_size]=$1
  L_UV[12000000 + (${1#*:} * 3) + 2]=$_L_size
  _L_uv_timerheap_sift_up $_L_size
}

# @description Pop the earliest timer from the min-heap.
# @return 0 on success, results in L_RET
_L_uv_timerheap_pop_vL_RET() {
  local _L_size=${L_UV[11000000]:-0}
  if (( _L_size == 0 )); then
    return 1
  fi
  L_RET=${L_UV[11000001]}
  # Clears the mapping for the popped timer and maintains heap integrity.
  unset -v "L_UV[12000000 + (${L_RET#*:} * 3) + 2]"
  if (( --_L_size == 0 )); then
    unset -v "L_UV[11000001]"
    L_UV[11000000]=0
    return 0
  fi
  # Replaces root with last element and sifts it down.
  L_UV[11000001]=${L_UV[11000000 + _L_size + 1]}
  L_UV[12000000 + (${L_UV[11000001]#*:} * 3) + 2]=1
  unset -v "L_UV[11000000 + _L_size + 1]"
  L_UV[11000000]=$_L_size
  _L_uv_timerheap_sift_down 1
}

# @description Replace the root of the heap and reheapify down.
# @arg $1 New string in format "TIMESTAMP:TASK_ID"
_L_uv_timerheap_update_top() {
  local _L_old=${L_UV[11000001]}
  # Efficiently replaces the top timer (e.g., for repeating timers) and sifts it down.
  L_UV[11000001]=$1
  unset -v "L_UV[12000000 + (${_L_old#*:} * 3) + 2]"
  L_UV[12000000 + (${1#*:} * 3) + 2]=1
  _L_uv_timerheap_sift_down 1
}

# @description Delete a specific timer from the heap by its taskid.
# @arg $1 TaskID to delete
_L_uv_timerheap_delete_taskid() {
  local _L_id=$1 _L_curr="${L_UV[12000000 + ($1 * 3) + 2]:-}" _L_size=${L_UV[11000000]:-0}
  if [[ -z "$_L_curr" ]]; then
    return 0
  fi
  # If the timer is the last element, simple unset; otherwise swap with last and re-sift.
  if (( _L_curr == _L_size )); then
    unset -v "L_UV[11000000 + _L_size]" "L_UV[12000000 + ($1 * 3) + 2]"
    L_UV[11000000]=$(( --_L_size ))
    return 0
  fi
  # Fills the hole with the last element and balances the heap in both directions.
  L_UV[11000000 + _L_curr]=${L_UV[11000000 + _L_size]}
  L_UV[12000000 + (${L_UV[11000000 + _L_curr]#*:} * 3) + 2]=$_L_curr
  unset -v "L_UV[11000000 + _L_size]" "L_UV[12000000 + ($1 * 3) + 2]"
  L_UV[11000000]=$(( --_L_size ))
  if (( _L_curr <= _L_size )); then
    _L_uv_timerheap_sift_up $_L_curr
    _L_uv_timerheap_sift_down $_L_curr
  fi
}

###############################################################################

# @description Initialize a loop array.
L_uv_init() { L_UV=(); }

# Internal function to allocate a new handle ID, store the callback and set _L_v variable.
# @arg $1 Local variable name to store the full ID in
# @arg $2 Counter index
# @arg $3 Data base index
# @arg $4 Multiplier
# @arg $5 Property offset
# @arg $6 ID base
# @arg $@ Callback function and its arguments
_L_uv_add_allocate_id_and_set_v() {
  local _L_v_name=$1 _L_cnt=$2 _L_base=$3 _L_mult=$4 _L_off=$5 _L_id_base=$6 _L_idx _L_id L_RET
  shift 6
  # Check if callback is not empty.
  if (( $# == 0 )); then return "$L_EX_USAGE"; fi
  # Find the next available idx.
  _L_idx=${L_UV[_L_cnt]:-0}
  while [[ -n "${L_UV[_L_base + (_L_idx * _L_mult) + _L_off]:-}" ]]; do
    (( _L_idx = (_L_idx + 1) % 1000000 ))
  done
  L_UV[_L_cnt]=$_L_idx
  _L_id=$(( _L_id_base + _L_idx ))
  printf -v "$_L_v_name" "%s" "$_L_id"
  # _L_v has to be set by caller.
  if [[ -n "$_L_v" ]]; then printf -v "$_L_v" "%s" "$_L_id"; fi
  # Store the formatted callback string
  L_quote_vL_RET "$@"
  L_UV[_L_base + (_L_idx * _L_mult) + 0]="L_UV_CURRENT=$_L_id;$L_RET"
}

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
  _L_uv_add_allocate_id_and_set_v _L_timerid 10000000 12000000 3 0 0 "$@" || return
  # Invalidate optimization on the first timer added.
  if [[ -z "${L_UV[11000001]:-}" ]]; then L_UV[1]=0; fi
  # Store CB at +0, Interval at +1
  L_UV[12000000 + ((_L_timerid % 1000000) * 3) + 1]="$_L_r"
  _L_uv_timerheap_push "$_L_next_us:$_L_timerid"
}

# @description Add a process wait handle to the loop.
# @option -v <var> Variable to assign the wait index to
# @arg $1 PID to wait for
# @arg $@ Callback function and its arguments.
L_uv_add_waiter() {
  local OPTIND OPTARG OPTERR _L_opt _L_v="" _L_wid
  while getopts v:h _L_opt; do
    case "$_L_opt" in
      v) _L_v=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  local _L_pid=$1
  _L_uv_add_allocate_id_and_set_v _L_wid 20000000 21000000 2 0 1000000 "${@:2}" || return
  local _L_rel=$(( _L_wid % 1000000 ))
  # Invalidate optimization state on first waiter added.
  if [[ -z "${L_UV[20000001]:-}" ]]; then L_UV[1]=0; fi
  # Update active waiter cache.
  L_UV[20000001]+=" $_L_rel "
  # Update the list of pids.
  L_UV[20000002]+=" $_L_pid "
  # Store PID at +1
  L_UV[21000000 + (_L_rel * 2) + 1]="$_L_pid"
  # Store rel into map of pids to rel.
  L_UV[29000000 + _L_pid % 1000000]+=" $_L_rel "
}

# @description Add a line-buffered read handle to the loop.
# @option -d Delimiter character (defaults to newline)
# @opiont -c Auto-close the file descriptor either after EOF or error or after return from L_uv_run.
# @option -v <var> Variable to assign the readline index to
# @arg $1 Target file descriptor
# @arg $@ Callback function and its arguments
L_uv_add_reader() {
  local OPTIND OPTARG OPTERR _L_opt _L_d=$'\n' _L_v="" _L_rid _L_c=0
  while getopts d:v:ch _L_opt; do
    case "$_L_opt" in
      d) _L_d=$OPTARG ;;
      v) _L_v=$OPTARG ;;
      c) _L_c=1 ;;
      h) L_func_usage; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  local _L_fd=$1
  _L_uv_add_allocate_id_and_set_v _L_rid 30000000 31000000 4 0 2000000 "${@:2}" || return
  local _L_rel=$(( _L_rid % 1000000 ))
  # Invalidate optimization state on first reader added.
  if [[ -z "${L_UV[30000001]:-}" ]]; then L_UV[1]=0; fi
  # Update active reader cache
  L_UV[30000001]+=" ${L_UV[30000000]} "
  # Store Sep at +1, FD at +2, Buf at +3
  L_UV[31000000 + (_L_rel * 4) + 1]="$_L_d"
  L_UV[31000000 + (_L_rel * 4) + 2]="$_L_fd"
  L_UV[31000000 + (_L_rel * 4) + 3]=""
  if (( _L_c )); then
    # Register closer.
    L_uv_on_remove "$_L_rid" eval "exec $_L_fd>&-"
  fi
}

# @description Add a task callback to the loop.
# @option -v <var> Variable to assign the index to
# @arg $@ Callback function and its arguments
L_uv_add_task() {
  local OPTIND OPTARG OPTERR _L_opt _L_v="" IFS=' ' _L_id
  while getopts v:h _L_opt; do
    case "$_L_opt" in
      v) _L_v=$OPTARG ;;
      h) L_func_usage; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift $((OPTIND - 1))
  _L_uv_add_allocate_id_and_set_v _L_id 98000000 99000000 1 0 3000000 "$@" || return
  L_UV[1]=0
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
    L_uv_add_task -v "$_L_v" _L_uv_once_callback "$_L_c" "${@:2}"
  fi
}

# @description Set a callback at a specific index in the loop.
# @arg $1 Index to set
# @arg $@ Callback function and its arguments
L_uv_set() {
  local L_RET
  L_quote_vL_RET "${@:2}"
  case "$(( $1 / 1000000 ))" in
    0) # Timer Data: CB at +0, Interval at +1, Map at +2
      L_UV[12000000 + ($1 * 3) + 0]="L_UV_CURRENT=$1;$L_RET"
      ;;
    1) # Waiter Data: CB at +0, PID at +1
      L_UV[21000000 + (($1 % 1000000) * 2) + 0]="L_UV_CURRENT=$1;$L_RET"
      ;;
    2) # Reader Data: CB at +0, Sep at +1, FD at +2, Buf at +3
      L_UV[31000000 + (($1 % 1000000) * 4) + 0]="L_UV_CURRENT=$1;$L_RET"
      ;;
    3) # User Task Data: relative indexing at 99,000,000+
      L_UV[99000000 + ($1 % 1000000)]="L_UV_CURRENT=$1;$L_RET"
      # Invalidate optimizer to trigger cache rebuild if we had one
      L_UV[1]=0
      ;;
  esac
}

# @description Remove a callback from the loop by index.
# @arg $1 Index to remove
L_uv_remove() {
  local _L_id=$1 _L_idx="${L_UV[90000000 + $1]:-}" _L_rel=$(( $1 % 1000000 ))
  # Cleanup resource tracking if exists
  if [[ -n "$_L_idx" ]]; then
    L_finally_pop -i "$_L_idx"
    unset -v "L_UV[90000000 + _L_id]"
  fi
  case "$(( _L_id / 1000000 ))" in
    0) # Timer
      _L_uv_timerheap_delete_taskid "$_L_id"
      unset -v "L_UV[12000000 + (_L_id * 3) + 0]" "L_UV[12000000 + (_L_id * 3) + 1]" "L_UV[12000000 + (_L_id * 3) + 2]"
      if (( ${L_UV[11000000]} == 0 )); then L_UV[1]=0; fi
      ;;
    1) # Waiter
      local _L_pid=${L_UV[21000000 + (_L_rel * 2) + 1]}
      unset -v "L_UV[21000000 + (_L_rel * 2) + 0]" "L_UV[21000000 + (_L_rel * 2) + 1]"
      L_UV[20000001]="${L_UV[20000001]/ $_L_rel }"
      L_UV[20000002]="${L_UV[20000002]/ $_L_pid }"
      if [[ -z "${L_UV[20000001]:-}" ]]; then L_UV[1]=0; fi
      L_UV[29000000 + _L_pid % 1000000]="${L_UV[29000000 + _L_pid % 1000000]/ $_L_rel / }"
      ;;
    2) # Reader
      L_UV[30000001]="${L_UV[30000001]/ $_L_rel }"
      unset -v "L_UV[31000000 + (_L_rel * 4) + 0]" "L_UV[31000000 + (_L_rel * 4) + 1]" "L_UV[31000000 + (_L_rel * 4) + 2]" "L_UV[31000000 + (_L_rel * 4) + 3]"
      if [[ -z "${L_UV[30000001]:-}" ]]; then L_UV[1]=0; fi
      ;;
    3) # User Task
      unset -v "L_UV[99000000 + _L_rel]"
      # Invalidate optimizer to trigger cache rebuild if we had one
      L_UV[1]=0
      ;;
  esac
}

# @description Update the current executing callback.
# @arg $@ New callback function and its arguments
# @env L_UV_CURRENT
L_uv_current_set() { L_uv_set "$L_UV_CURRENT" "$@"; }

# @description Remove the current executing callback.
# @env L_UV_CURRENT
L_uv_current_remove() { L_uv_remove "$L_UV_CURRENT"; }

# Returns the next timeout when L_uv should be waked up.
_L_uv_timeout_left_vL_RET() { [[ -n "${L_UV[11000001]:-}" ]] && L_timeout_left_vL_RET "${L_UV[11000001]%%:*}"; }

# @arg $1 Maximum timeout.
_L_uv_timeout_left_capped_vL_RET() {
  if [[ -n "${L_UV[11000001]:-}" ]]; then
    local _L_timer_left
    L_timeout_left_usec_vL_RET "${L_UV[11000001]%%:*}" || return
    _L_timer_left=$L_RET
    L_sec_to_usec_vL_RET "$1"
    (( L_RET > _L_timer_left )) && L_RET=$_L_timer_left
    L_usec_to_sec_vL_RET "$L_RET"
  else
    L_RET=$1
  fi
}

# Internal function to process and execute due timers from the min-heap.
_L_uv_manager_timer() {
  # If there are any timers in the heap
  while (( ${L_UV[11000000]:-0} > 0 )); do
    local _L_top="${L_UV[11000001]:-}"
    local _L_at="${_L_top%%:*}"
    L_epochrealtime_usec_vL_RET; local _L_now_us=$L_RET
    # Check if the earliest timer is due for execution
    if (( _L_at > _L_now_us )); then break; fi
    local _L_id="${_L_top#*:}"
    local _L_code="${L_UV[12000000 + (_L_id * 3) + 0]:-}"
    # Remove timer if it has been deleted (tombstone)
    if [[ -z "$_L_code" ]]; then
      _L_uv_timerheap_pop_vL_RET
    else
      local _L_repeat="${L_UV[12000000 + (_L_id * 3) + 1]:-0}"
      if (( _L_repeat > 0 )); then
        # Calculate next execution time for repeating timers
        local _L_next=$(( _L_at + _L_repeat ))
        while (( _L_now_us >= _L_next )); do (( _L_next += _L_repeat )); done
        _L_uv_timerheap_update_top "$_L_next:$_L_id"
      else
        # Single-shot timer: remove from heap and clean up data
        _L_uv_timerheap_pop_vL_RET
        L_uv_remove "$_L_id"
      fi
      # Set context and execute the user callback
      eval "$_L_code"
      _L_uv_poked=1
    fi
  done
}
# Internal function to sleep until the next timer expires.
_L_uv_delayer_timer_indefinite() {
  local L_RET
  _L_uv_timeout_left${2:-}_vL_RET || L_RET=$1
  if builtin sleep 0 0 2>/dev/null || (( $? == 2 )); then
    builtin sleep "$L_RET"
  elif enable -f sleep sleep 2>/dev/null; then
    builtin sleep "$L_RET"
    enable -d sleep
  else
    command sleep "$1"
  fi
}
_L_uv_delayer_timer_capped() { _L_uv_delayer_timer_indefinite "$1" "_capped"; }

# Internal function to monitor and reap child processes registered as waiters.
_L_uv_manager_waiter_wait_n_p() {
  local _L_rel _L_pid _L_cb _L_status=0 _L_w_done _L_pids="${L_UV[20000002]:-}"
  [[ -z "$_L_pids" ]] && return 0
  wait -n -p _L_w_done $_L_pids 2>/dev/null || _L_status=$?
  if (( _L_status > 128 )); then return 0; fi
  if (( _L_status == 127 )) && ! L_var_is_set _L_w_done; then
    # Prune stale PIDs from the loop to prevent deadlocks.
    for _L_pid in $_L_pids; do
      if ! kill -0 "$_L_pid" 2>/dev/null; then
        # Found a stale PID. Locate its handle via the bucket map and remove it.
        for _L_rel in ${L_UV[29000000 + _L_pid % 1000000]}; do
          if [[ "${L_UV[21000000 + (_L_rel * 2) + 1]}" == "$_L_pid" ]]; then
            L_uv_remove $(( 1000000 + _L_rel ))
          fi
        done
      fi
    done
    return 0
  fi
  # Use the 29M bucket map for O(1) reverse lookup of the PID to handle
  if L_var_is_set _L_w_done; then
    for _L_rel in ${L_UV[29000000 + _L_w_done % 1000000]}; do
      _L_pid="${L_UV[21000000 + (_L_rel * 2) + 1]}"
      if [[ "$_L_pid" == "$_L_w_done" ]]; then
        _L_cb="${L_UV[21000000 + (_L_rel * 2) + 0]}"
        L_uv_remove $(( 1000000 + _L_rel ))
        eval "$_L_cb $_L_pid $_L_status"
        _L_uv_poked=1
      fi
    done
  fi
}
_L_uv_manager_waiter() {
  while [[ -n "${L_UV[20000002]}" ]] && ! kill -0 ${L_UV[20000002]} 2>/dev/null; do
    if (( L_HAS_BASH5_1 )); then
      _L_uv_manager_waiter_wait_n_p
    else
      # Iterate over active Waiter IDs from the string cache
      local _L_rel _L_pid _L_cb _L_status=0
      for _L_rel in ${L_UV[20000001]}; do
        _L_pid="${L_UV[21000000 + (_L_rel * 2) + 1]}"
        if ! kill -0 "$_L_pid" 2>/dev/null; then
          wait "$_L_pid" || _L_status=$?
          _L_cb="${L_UV[21000000 + (_L_rel * 2) + 0]}"
          L_uv_remove $(( 1000000 + _L_rel ))
          eval "$_L_cb $_L_pid $_L_status"
          _L_uv_poked=1
        fi
      done
    fi
  done
}
_L_uv_delayer_waiter_indefinite() {
  local _L_pids="${L_UV[20000002]:-}"
  if [[ -n "$_L_pids" ]]; then
    if (( L_HAS_BASH5_1 )); then
      _L_uv_manager_waiter_wait_n_p
    elif (( L_HAS_BASH4_3 )); then
      wait -n $_L_pids 2>/dev/null || :
    elif L_hash waitpid; then
      waitpid -e -c 1 $_L_pids 2>/dev/null || :
    elif L_hash tail && _L_wait_tail_has_pid && [[ ! "$_L_pids" == *"  "* ]]; then
      # If there is tail and there is only one pid.
      tail --pid="$_L_pids" -f /dev/null 2>/dev/null || :
    else
      _L_uv_delayer_timer_capped "$1"
    fi
  fi
}
# @arg $1 Default sleep timeout. Ignored in timer, used in capped mode.
# @arg $2 if _capped, will cap on the first argument
_L_uv_delayer_waiter_timer() {
  local L_RET _L_pids="${L_UV[20000002]}"
  if L_hash waitpid; then
    _L_uv_timeout_left${2:-}_vL_RET "$1" &&
      waitpid -e -c 1 -t "$L_RET" $_L_pids 2>/dev/null || :
  elif L_hash timeout tail && _L_wait_tail_has_pid && [[ ! "$_L_pids" == *"  "* ]]; then
    # If there is timeout and tail and there is only one pid.
    _L_uv_timeout_left${2:-}_vL_RET "$1" &&
      timeout "$L_RET" tail --pid="$_L_pids" -f /dev/null 2>/dev/null || :
  else
    _L_uv_delayer_timer_capped "$1"
  fi
}
_L_uv_delayer_waiter_capped() { _L_uv_delayer_waiter_timer "$1" "_capped"; }

# Internal function to perform non-blocking reads on registered file descriptors.
# @arg $1 Optional timeout.
# @arg $2 Set to an empty string '' to disable timeout completely.
_L_uv_manager_reader() {
  local _L_rel _L_sep _L_fd _L_cb _L_line _L_buf _L_base _L_ids="${L_UV[30000001]:-}" _L_default_timeout=0.001 L_RET
  if (( !L_HAS_BASH4_4 )); then
    # Bash 3.2 timeouts can only be integers
    _L_default_timeout=1
    if (( $# == 1 )); then
      L_sec_to_usec_vL_RET "$1"
      # Round up.
      set -- "$(( (L_RET + 1000000 - 1) / 1000000 ))"
    fi
  fi
  # Iterate over active Reader IDs from the string cache
  for _L_rel in $_L_ids; do
    _L_base=$(( 31000000 + (_L_rel * 4) ))
    _L_cb="${L_UV[_L_base + 0]}"
    _L_sep="${L_UV[_L_base + 1]}"
    _L_fd="${L_UV[_L_base + 2]}"
    # Perform non-blocking read checks
    while (( $# )) || IFS= read -t 0 -u "$_L_fd" _; do
      if IFS= read ${2--t} ${2-"${1:-$_L_default_timeout}"} -d "$_L_sep" -u "$_L_fd" -r _L_line; then
        # Read successful: prepend stored buffer, clear buffer, and execute callback
        eval "$_L_cb $_L_fd \"\${L_UV[_L_base + 3]:-}\$_L_line\""
        L_UV[_L_base + 3]=""
        L_uv_poke
      elif (( $? > 128 )); then
        # Read timed out (partial data or slow pipe): append to stored buffer
        L_UV[_L_base + 3]+="$_L_line"
        (( $# )) && return
        break
      else
        # EOF reached: remove handle, execute callback with remaining buffer then EOF signal
        _L_buf="${L_UV[_L_base + 3]}"
        L_uv_remove $(( 2000000 + _L_rel ))
        if [[ -n "$_L_buf$_L_line" ]]; then
          eval "$_L_cb $_L_fd \"\$_L_buf\$_L_line\""
        fi
        eval "$_L_cb $_L_fd"
        _L_uv_poked=1
        (( $# )) && return
        break
      fi
    done
  done
}
_L_uv_delayer_reader_indefinite() { _L_uv_manager_reader "" ""; }
_L_uv_delayer_reader_timer() {
  if [[ "${L_UV[30000001]:-}" == *"  "* ]]; then
    # When there are multiple file descriptors, delay read on the first of them.
    _L_uv_delayer_reader_capped "$1"
  else
    # When there is one file descriptor, we can wait on it with the full timer.
    _L_uv_timeout_left_vL_RET && L_setposix _L_uv_manager_reader "$L_RET"
  fi
}
_L_uv_delayer_reader_capped() { _L_uv_timeout_left_capped_vL_RET "$1" && _L_uv_manager_reader "$L_RET"; }

# Internal function to optimize the event loop by building a consolidated evaluation string
# and selecting an appropriate sleeping method based on active handles.
_L_uv_run_optimizer() {
  # Mark optimized flag.
  L_UV[1]=1
  local _L_has_timers=0 _L_has_waiters=0 _L_has_readers=0 _L_has_tasks=0 IFS=';'
  # Check what groups do we have.
  if (( ${L_UV[11000000]:-0} > 0 )); then _L_has_timers=1; fi
  if [[ -n "${L_UV[20000001]:-}" ]]; then _L_has_waiters=1; fi
  if [[ -n "${L_UV[30000001]:-}" ]]; then _L_has_readers=1; fi
  _L_uv_eval="${L_UV[*]:99000000}"
  if [[ -n "$_L_uv_eval" ]]; then _L_has_tasks=1; _L_uv_eval+=";"; fi
  # Create the eval sting.
  if (( _L_has_timers )); then _L_uv_eval+="_L_uv_manager_timer;"; fi
  if (( _L_has_waiters )); then _L_uv_eval+="_L_uv_manager_waiter;"; fi
  if (( _L_has_readers )); then _L_uv_eval+="_L_uv_manager_reader;"; fi
  # If there is nothing to eval, we can finish.
  if [[ -z "$_L_uv_eval" ]]; then
    return 1
  fi
  # Optimize the delayer using a bitmask: Timer(1000), Waiter(100), Reader(10), Task(1).
  case "$(( _L_has_timers * 1000 + _L_has_waiters * 100 + _L_has_readers * 10 + _L_has_tasks ))" in
    0100) _L_uv_delayer_cb=_L_uv_delayer_waiter_indefinite ;; # Single Waiter (Indefinite wait)
    0010) _L_uv_delayer_cb=_L_uv_delayer_reader_indefinite ;; # Single Reader (Indefinite wait)
    1000) _L_uv_delayer_cb=_L_uv_delayer_timer_indefinite ;; # Single Timer (Next Timer wait)
    1010) _L_uv_delayer_cb=_L_uv_delayer_reader_timer ;; # Reader + Timer (Timed wait)
    1100) _L_uv_delayer_cb=_L_uv_delayer_waiter_timer ;; # Waiter + Timer (Timed wait)
    *1?)  _L_uv_delayer_cb=_L_uv_delayer_reader_capped ;; # Capped Reader (Multi-FD / Tasks / Mixed)
    *1)   _L_uv_delayer_cb=_L_uv_delayer_waiter_capped ;; # Tasks + Waiters (Capped 50ms yield)
    *)    _L_uv_delayer_cb=_L_uv_delayer_timer_capped ;; # Fallback to timer-based delayer
  esac
}

# @description Run the event loop until it's empty or timed out.
# @option -s <float> Polling interval in seconds (defaults to 0.1)
# @option -1 Run only one iteration of the loop.
# @option -t <float> Timeout in seconds (defaults to none)
# @option -c Set sigchild trap.
# @arg $1 Loop name (defaults to L_UV)
# @return 0 on success, 124 on timeout, or task exit code.
# @example L_uv_add_timer loop 1 echo "hello"; L_uv_run loop
L_uv_run() {
  local OPTIND OPTARG OPTERR _L_i _L_uv_sleep_time=0.05 _L_uv_break=0 _L_uv_return=0 \
    L_UV_CURRENT _L_uv_stack_depth=${#FUNCNAME[@]} _L_uv_poked=0 L_RET \
    _L_uv_delayer_cb="L_sleep" _L_uv_eval
  while getopts s:1ct:h _L_i; do
    case "$_L_i" in
      s) L_duration_to_usec_vL_RET "$1" && L_usec_to_sec_vL_RET "$L_RET" && _L_uv_sleep_time=$L_RET || return ;;
      1) _L_uv_break=1 ;;
      t) L_uv_add_timer -d "$OPTARG" L_eval '_L_uv_break=1 _L_uv_return=$L_EX_TIMEOUT' || return ;;
      h) L_func_help; return 0 ;;
      c) trap '_L_uv_poked=1' SIGCHLD ;;
      *) L_func_usage_error; return "${L_EX_USAGE:-64}" ;;
    esac
  done
  shift $((OPTIND - 1))
  # For any registered cleanup tasks, register them as L_finally tasks.
  for _L_i in "${!L_UV[@]}"; do
    if (( 90000000 <= _L_i && _L_i < 94000000 )); then
      L_uv_on_remove "$(( _L_i - 90000000 ))" "${L_UV[_L_i]}"
    fi
  done
  # Run optimizer at startup, and then right after tasks. This is to catch changes by tasks.
  if _L_uv_run_optimizer; then
    eval "$_L_uv_eval"
    while (( !_L_uv_break )) && if (( ${L_UV[1]:-0} == 0 )); then _L_uv_run_optimizer; fi; do
      if (( _L_uv_poked )); then
        _L_uv_poked=0
      else
        "$_L_uv_delayer_cb" "$_L_uv_sleep_time"
      fi
      eval "$_L_uv_eval"
    done
  fi
  # on_remove are run automatically by L_finally in RETURN trap.
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
  if L_var_is_set _L_uv_stack_depth; then
    local _L_r_idx
    L_finally -v _L_r_idx -r -s "${#FUNCNAME[@]} - $_L_uv_stack_depth" "${@:2}"
    L_UV[90000000 + $1]="$_L_r_idx"
  else
    local L_RET
    L_quote_vL_RET "${@:2}"
    L_UV[90000000 + $1]="$L_RET"
  fi
}

# @description Register a cleanup command for the current task.
# @arg $@ Cleanup command and its arguments
L_uv_current_on_remove() { L_uv_on_remove "$L_UV_CURRENT" "$@"; }

###############################################################################

# @arg $1 L_XARGS_INDEX
_L_xargs_dobuf_flush() {
  if (( _L_x_prefix )); then
    _L_x_dobuf_output[$1]=${_L_x_dobuf_output[$1]%$'\n'}
    printf "%s\n" "${_L_x_dobuf_prefix[$1]:-}: ${_L_x_dobuf_output[$1]//$'\n'/$'\n'${_L_x_dobuf_prefix[$1]:-}: }"
    unset -v "_L_x_dobuf_prefix[$1]"
  else
    printf "%s" "${_L_x_dobuf_output[$1]:-}"
  fi
  unset -v "_L_x_dobuf_output[$1]"
}

# @arg $1 L_XARGS_INDEX
# @arg $2 file descriptor
# @arg [$3] line
_L_xargs_dobuf_stdout_cb() {
  # L_notice "DEBUG: stdout_cb pid=$1 fd=$2 line=${3:-EOF}"
  case "$#" in
    3)
      _L_x_dobuf_output[$1]+="$3"
      if (( _L_x_dobuf_mode == 1 )); then
        _L_x_dobuf_output[$1]+=$'\n'
      fi
      ;;
    2)
      if (( _L_x_dobuf_mode == 1 )); then
        # In single -O mode, we print ouptut in whatever order.
        _L_xargs_dobuf_flush "$1"
      elif (( _L_x_dobuf_mode > 1 )); then
        # In double -O -O mode, we need to print in order.
        _L_x_dobuf_finished[$1]=1
        while (( ${_L_x_dobuf_finished[_L_x_dobuf_next]:-0} )); do
          _L_xargs_dobuf_flush "$_L_x_dobuf_next"
          unset -v "_L_x_dobuf_finished[_L_x_dobuf_next]"
          (( ++_L_x_dobuf_next ))
        done
      fi
      ;;
  esac
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

_L_xargs_prefixer() { while IFS= read -r line || [[ -n "$line" ]]; do printf "%s: %s\n" "$1" "$line"; done; }

_L_xargs_dobuf_or_prefix_notify() {
  case "$1" in
    PREEXEC)
      if (( _L_x_dobuf_mode > 0 )); then
        local _L_prefix=""
        if (( _L_x_prefix )); then
          # Save prefix for later for stdout task handler to consume.
	        printf -v _L_prefix " %q" "${_L_x_atoms[@]:_L_x_atoms_idx:_L_atoms_limit}"
	        _L_x_dobuf_prefix[L_XARGS_INDEX]=${_L_prefix# }
	      fi
        # Create pipe for read from the task.
        L_pipe _L_x_dobuf_pipe
        L_RET=(L_eval "\"\$@\" ${_L_x_dobuf_pipe[0]}>&- >&${_L_x_dobuf_pipe[1]}" "${L_RET[@]}")
      else  # no dobuf_mode
	      if (( _L_x_prefix )); then
	        # Use > >(...) to prefix output from the task.
		      local _L_prefix
	        printf -v _L_prefix " %q" "${_L_x_atoms[@]:_L_x_atoms_idx:_L_atoms_limit}"
	        L_RET=(L_eval "\"\$@\" > >(_L_xargs_prefixer$_L_prefix)" "${L_RET[@]}")
        fi
      fi
      ;;
    POSTEXEC)
      if (( _L_x_dobuf_mode > 0 )); then
        # Close writing side of pipe.
        eval "exec ${_L_x_dobuf_pipe[1]}>&-"
        # Add a task to read stuff.
        local delim=$'\n'
        if (( _L_x_dobuf_mode > 1 )); then
          local delim=''
        fi
        L_uv_add_reader -c -d "$delim" "${_L_x_dobuf_pipe[0]}" _L_xargs_dobuf_stdout_cb "$L_XARGS_INDEX"
      fi
      ;;
  esac
}


# Replace {} and {1} {2} ... {N}.
_L_xargs_run_template_template() {
	L_RET=("${L_RET[@]//\{\}/${_L_x_atoms[*]:_L_x_atoms_idx:_L_atoms_limit}}")
	for (( _L_i = 1; _L_i <= $_L_atoms_limit; ++_L_i )); do
		L_RET=("${L_RET[@]//\{${_L_i}\}/${_L_x_atoms[*]:_L_x_atoms_idx+_L_i-1:1}}")
	done
}

# Replace {}.
_L_xargs_run_template_replace() {
	L_RET=("${L_RET[@]//"$_L_x_replace"/${_L_x_atoms[*]:_L_x_atoms_idx:_L_atoms_limit}}")
}

# No templating - add arguments to execute.
_L_xargs_run_template_no() {
  L_RET+=("${_L_x_atoms[@]:_L_x_atoms_idx:_L_atoms_limit}")
}

# If everything is ok, try to schedule the next job from atoms.
# @env L_RET
_L_xargs_maybe_run() {
  # Consume input from L_RET array.
  if (( ${#L_RET[@]} )); then
	  if (( ${_L_x_split:-1} )); then
		  # Split one record -> Multiple Atoms
		  # shellcheck disable=SC2048
		  L_string_unquote -v L_RET "${L_RET[*]}" || return 1
	  fi
	  # Bookkeeping of input.
    _L_x_atoms+=("${L_RET[@]}")
    (( ++_L_x_cur_records ))
  fi
	# Dual-threshold trigger logic - on number of atoms and number of records.
  local _L_atoms_limit=$(( _L_x_atoms_limit > 0 && _L_x_atoms_limit <= ${#_L_x_atoms[@]} ? _L_x_atoms_limit : ${#_L_x_atoms[@]} )) _L_tmp
  while
    (( ${#_L_x_running[@]} < _L_x_maxprocs && !_L_x_done )) && {
	    {
	      (( _L_x_atoms_limit > 0 )) && (( ${#_L_x_atoms[*]} - _L_x_atoms_idx >= _L_x_atoms_limit ))
	    } ||
	      (( _L_x_records_limit > 0 && _L_x_cur_records >= _L_x_records_limit )) ||
	    {
        (( _L_x_input_stopped )) && (( ${#_L_x_atoms[*]} - _L_x_atoms_idx > 0 ))
      }
		}
	do
    L_RET=("${_L_x_cmd[@]}")
    # Template tehe command.
    "$_L_x_template_cb"
    if (( _L_x_trace )); then
      printf -v _L_tmp " %q" "${L_RET[@]}"
      printf "+$_L_tmp\n" >&2
    fi
    # Run PREEXEC callbacks.
    set -- PREEXEC
    eval "${_L_x_notify_cb:-}"
    # Actually run the job.
    "${L_RET[@]}" &
    # Post stuff.
    _L_x_running[$!]=""
    if [[ -n "$_L_x_task_timeout" ]]; then
      L_uv_add_timer -v "_L_x_timers[$!]" -d "$_L_x_task_timeout" _L_x_task_timeout_cb "$!"
    fi
    L_uv_add_waiter "$!" _L_xargs_reaper "$L_XARGS_INDEX"
    # Run POSTEXEC callbacks.
    set -- POSTEXEC "$!"
    eval "${_L_x_notify_cb:-}"
    # Update state.
    (( _L_x_atoms_idx += _L_atoms_limit ))
    if (( L_XARGS_INDEX++ % 10 == 0 )); then
      _L_x_atoms=("${_L_x_atoms[@]:_L_x_atoms_idx}")
      _L_x_atoms_idx=0
    fi
    _L_x_cur_records=0
    #
    L_uv_poke
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
  if (( _L_x_input_stopped || _L_x_done )); then
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
	local OPTIND OPTARG OPTERR _L_x_replace="" _L_x_atoms_idx=0 _L_x_atoms_limit=0 _L_x_records_limit="" _L_i _L_x_maxprocs=1 L_RET \
			_L_x_trace=0 _L_registered_xargs_trap=0 _L_x_prefix=0 _L_x_r=0 \
			_L_x_callback=() _L_x_d=$'\n' _L_x_fd=0 _L_x_split="" \
			_L_x_v="" _L_x_rets=() L_XARGS_INDEX=0 _L_x_quiet=0 \
	    _L_x_eof_str _L_x_eof_check_cb=: _L_x_preserve_set_e=0 _L_x_template_cb=_L_xargs_run_template_no \
	    _L_x_running=() _L_x_input_stopped=0 _L_x_atoms=() _L_x_task_timeout="" _L_x_timers=() \
	    _L_x_forker=_L_xargs_forker _L_x_notify_cb="" _L_x_return=0 _L_x_done=0 _L_x_cur_records=0 \
	    \
	    _L_x_dobuf_mode=0 _L_x_dobuf_pipe _L_x_dobuf_output _L_x_dobuf_prefix _L_x_dobuf_finished _L_x_dobuf_next=0
  local L_UV; L_uv_init
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
			I) _L_x_atoms_limit=1 _L_x_template_cb=_L_xargs_run_template_replace  _L_x_replace=$OPTARG ;;
			i) _L_x_atoms_limit=1 _L_x_template_cb=_L_xargs_run_template_replace _L_x_replace="{}" ;;
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
			T) _L_x_template_cb=_L_xargs_run_template_template ;;
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
    L_uv_add_task _L_xargs_input_task
  else
    L_uv_add_reader -d "$_L_x_d" "$_L_x_fd" _L_xargs_feeder_input_cb
  fi
  L_uv_run
  return "$_L_x_return"
}

###############################################################################

if L_is_main; then
  set -euo pipefail
  if (( $# )); then
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
    L_uv_add_reader "${fd[0]}" myreader
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
# L_uv_add_waiter loop1 "$!" L_eval 'echo "$1 died with $2"' $!
# L_uv_add_waiter loop1 "$!" L_eval 'echo "$1 died with $2"' $!

