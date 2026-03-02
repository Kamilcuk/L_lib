#!/usr/bin/env bash

# @see https://github.com/jamesyoungman/findutils/blob/master/xargs/xargs.c#L1585
# @see https://github.com/aixoss/findutils/blob/r4.4.2-aix/xargs/xargs.c#L1272
_L_xargs_handle_return() {
	case "$1" in
	0) ;;
	255)
		_L_x_done=1
		if ((_L_x_return < 124)); then
			_L_x_return=124
		fi
		printf "L_xargs: %s: exited with status 255; aborting\n" "${_L_cmd[0]}" >&2
		;;
	126|127)
		_L_x_done=1
		if ((_L_x_return < $1)); then
			_L_x_return=$1
		fi
		;;
	*)
		if ((128 < $1 && $1 <= 128 + 64)); then
			_L_x_done=1
			local _L_tmp
			L_trap_to_name -v _L_tmp "$(($1-128))"
			printf "L_xargs: %s: terminated by signal %s\n" "${_L_cmd[0]}" "$_L_tmp" >&2
			if ((_L_x_return < 125)); then
				_L_x_return=125
			fi
		else
			_L_x_return=123
		fi
		;;
	esac
}

_L_xargs_buf_read() {
	# Read from file descriptors if created pipes.
	if (( ${_L_x_buf_fds[*]:+${#_L_x_buf_fds[*]}}+0 )); then
		local _L_i _L_args _L_fd_idx
		# Prepare arguments for L_read_fds call - fd + buffer variable name.
		for _L_i in "${!_L_x_buf_fds[@]}"; do
			_L_args+=( "${_L_x_buf_fds[_L_i]}" "_L_x_buf_output[$_L_i]" )
		done
		# Read from file dscriptors.
		L_read_fds -i _L_fd_idx "${_L_args[@]}" || return 1
			printf "%s" "${_L_x_buf_output[_L_fd_idx]}"
			eval "exec ${_L_x_buf_fds[$_L_fd_idx]}>&-"
			unset -v "_L_x_buf_fds[$_L_fd_idx]" "_L_x_buf_output[$_L_fd_idx]"
	fi
}

_L_xargs_wait() {
	# If there are no pids, there is nothing to wait for.
	if (( ${_L_x_pids[*]:+${#_L_x_pids[*]}}+0 )); then
		# Read from buffered pipes, if used.
		_L_xargs_buf_read || return 1
		# Capture any command exit. Handle exit code.
		local _L_a_pid_idx _L_a_ret
		L_wait -v _L_a_ret -i _L_a_pid_idx "${_L_x_pids[@]}" || return 1
		# declare -p _L_a_ret _L_a_pid _L_x_pids
		_L_xargs_handle_return "$_L_a_ret"
		unset -v "_L_x_pids[$_L_a_pid_idx]"
	fi
}

_L_xargs_prefixer() {
	while IFS= read -r line; do
		printf "%s\n" "$1: $line"
	done
}

_L_xargs_run() {
	if (( _L_x_done )); then
		return
	fi
	if [[ -n "$_L_x_replace" ]]; then
		# Replace {}.
		local _L_cmdready=("${_L_cmd[@]//"$_L_x_replace"/"$*"}")
	else
		local _L_cmdready=("${_L_cmd[@]}" "$@")
	fi
	if (( _L_x_prefix )); then
		local _L_cmd _L_x_prefix
		printf -v _L_cmd "%q " "${_L_cmdready[@]}"
		printf -v _L_x_prefix " %q" "$@"
		_L_cmd+="> >(_L_xargs_prefixer$_L_x_prefix)"
		_L_cmdready=(eval "$_L_cmd")
	fi
	# Execute
	if (( _L_x_verbose )); then
		L_quote_printf "+" "${_L_cmdready[@]}" >&2
	fi
	if (( _L_x_maxprocs == 1 )); then
		L_exit_to _L_i "${_L_cmdready[@]}"
		_L_xargs_handle_return "$_L_i"
	else
		if (( !_L_registered_xargs_trap )); then
			_L_registered_xargs_trap=1
			L_finally -s 1 -r _L_xargs_trap || return 1
		fi
		if (( _L_x_dobuf )); then
			local _L_pipe _L_cmd
			L_pipe _L_pipe || return 1
			printf -v _L_cmd "%q " "${_L_cmdready[@]}"
			_L_x_buf_fds+=("${_L_pipe[0]}")
			eval "$_L_cmd ${_L_pipe[0]}>&- 1>&${_L_pipe[1]} & exec ${_L_pipe[1]}>&-"
		else
			"${_L_cmdready[@]}" &
		fi
		_L_x_pids+=("$!")
		if (( _L_x_maxprocs != 0 && ${#_L_x_pids[@]} >= _L_x_maxprocs )); then
			_L_xargs_wait || return 1
		fi
	fi
}

_L_xargs_trap() {
	# local i
	# for i in ${_L_x_pids[@]:+"${!_L_x_pids[@]}"}; do
	# 	if ! kill -0 "${_L_x_pids[$i]}" 2>/dev/null; then
	# 		unset -v "_L_x_pids[$i]"
	# 	fi
	# done
	if (( ${_L_x_pids[@]:+${#_L_x_pids[@]}}+0 != 0 )); then
		if [[ " SIGINT RETURN EXIT " == *"$L_SIGNAL"* ]]; then
			# https://stackoverflow.com/a/75385863/9072753
			# SIGINT is disabled in subshells so do not send it
			kill "${_L_x_pids[@]}" 2>/dev/null || :
		else
			kill ${L_SIGNAL:+-"$L_SIGNAL"} "${_L_x_pids[@]}" 2>/dev/null || :
		fi
		wait "${_L_x_pids[@]}" || :
	fi
}

# @description1
# @option -v <var>
# @option -h
L_nproc() { L_handle_v_scalar "$@"; }
L_nproc_v() {
	if L_hash nproc; then
		L_v=$(nproc)
	elif [[ -r /proc/cpuinfo ]]; then
		if L_hash grep; then
			L_v=$(grep -c ^processor /proc/cpuinfo)
		else
			L_v=0
			local line
			while IFS= read -r line; do
				if [[ "$line" == processor* ]]; then
					(( ++L_v ))
				fi
			done </proc/cpuinfo
		fi
	elif [[ -r /proc/sys/hw/ncpu ]]; then
		L_v=$(cat /proc/sys/hw/ncpu)
	else
		L_v=1
	fi
}

_L_xargs_callback_array() { (( _L_x_a_index < (${_L_x_a[*]:+${#_L_x_a[*]}}+0) )) && L_v=("${_L_x_a[_L_x_a_index++]}"); }
_L_xargs_callback_read() { IFS= read ${_L_x_fd:+-u "$_L_x_fd"} -d "$_L_x_d" -r L_v || [[ -n "$L_v" ]]; }

# @description A high-performance Bash implementation of the `xargs` utility designed for seamless
# integration with local shell environments. Unlike binary `xargs`, `L_xargs` executes within
# the current shell context, enabling the direct use of unexported Bash functions,
# aliases, and variables without requiring `expor` or `export -f`.
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
# @option -c <callback> Execute an eval string to fetch the next Record. Must populate L_v=() and return 0.
# @option -d <delimiter> Set the Record separator to the specified character.
# @option -s Split Mode: Parse internal Records into multiple Atoms using L_string_unquote.
# @option -S Solid Mode: Treat the entire delimited Record as a single literal Atom (Default).
# @option -u <fd> Read the input stream from the specified file descriptor.
# @option -I <replace-str> Replace occurrences of replace-str in the command. Forces -n 1.
# @option -i Shorthand for -I{}.
# @option -L <max-records> Trigger execution once <max-records> have been accumulated.
# @option -n <max-atoms> Trigger execution once <max-atoms> have been accumulated.
# @option -r If the input does not contain any atoms, do not run the command. Normally, the command is run once even if there is no input.
# @option -P <max-procs> Concurrent process limit. Supports an integer or 'nproc' for CPU count.
# @option -O Separate output of each command by using pipes.
# @option -t Verbose: Print each command to STDERR before execution.
# @option -^ Prefix Mode: Prepends the command arguments and a colon to each line of output.
# @option -h Display this help documentation and exit.
# @arg $@ Command to execute. Default: L_quote_printf.
# @return 0 on success
#         1 on some other error
#         2 on invalid usage
#         123 if any invocation oft he command exited with status 1-125 and 192-254
#         124 if the command exited with status 255
#         125 if the command exited with the status 128-192
#         126 if the command cannot be run
#         127 if the command is not found
L_xargs() {
	local OPTIND OPTARG OPTERR _L_x_replace="" _L_atoms_limit=0 _L_records_limit=0 _L_i _L_x_maxprocs=1 L_v \
			_L_x_verbose=0 _L_registered_xargs_trap=0 _L_x_prefix=0 _L_x_r=0 \
			_L_x_callback=(_L_xargs_callback_read) _L_x_d=$'\n' _L_x_fd _L_x_a _L_x_a_index=0 _L_x_split="" \
			_L_x_dobuf=0 _L_x_buf_fds _L_x_buf_output
	while getopts a:0c:d:sSu:I:in:L:rP:tO^h _L_i; do
		case "$_L_i" in
			a) _L_x_callback=(_L_xargs_callback_array) _L_i="$OPTARG[@]" _L_x_a=("${!_L_i}") _L_x_split=${_L_x_split:-0} ;;
			0) _L_x_callback=(_L_xargs_callback_read) _L_x_d='' _L_x_split=${_L_x_split:-0} ;;
			c) _L_x_callback=(eval "$OPTARG") ;;
			d) _L_x_callback=(_L_xargs_callback_read) _L_x_d=$OPTARG _L_x_split=${_L_x_split:-0} ;;
			s) _L_x_split=1 ;;
			S) _L_x_split=0 ;;
			u) _L_x_fd=$OPTARG ;;
			I) _L_atoms_limit=1 _L_x_replace=$OPTARG ;;
			i) _L_atoms_limit=1 _L_x_replace="{}" ;;
			n) _L_atoms_limit=$OPTARG ;;
			L) _L_records_limit=$OPTARG ;;
			r) _L_x_r=1 ;;
			P) if [[ "$OPTARG" == n* ]]; then L_nproc_v; _L_x_maxprocs=$L_v; else _L_x_maxprocs=$OPTARG; fi ;;
			t) _L_x_verbose=1 ;;
			O) _L_x_dobuf=1 ;;
			^) _L_x_prefix=1 ;;
			h) L_func_help; return 0 ;;
			*) L_func_error "L_xargs: invalid option: -$_L_i"; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	local _L_cmd=("${@:-L_quote_printf}") _L_x_pids _L_atoms _L_x_return=0 _L_x_done=0 L_v _L_cur_records=0
	while (( !_L_x_done )) && L_v=() && "${_L_x_callback[@]}"; do
		(( ++_L_cur_records ))
		if (( ${_L_x_split:-1} )); then
			# Record -> Multiple Atoms
			L_string_unquote -v L_v "${L_v[*]}" || return 1
		fi
		# Accumulate atoms (L_v is 1 atom in Solid mode, 1+ in Split mode)
		_L_atoms+=("${L_v[@]}")
		# Dual-threshold trigger logic
		while (( (_L_atoms_limit > 0 && ${#_L_atoms[*]} >= _L_atoms_limit) || (_L_records_limit > 0 && _L_cur_records >= _L_records_limit) )); do
			if (( _L_atoms_limit > 0 && ${#_L_atoms[*]} >= _L_atoms_limit )); then
				_L_xargs_run "${_L_atoms[@]:0:_L_atoms_limit}" || return 1
				_L_atoms=("${_L_atoms[@]:_L_atoms_limit}")
			else
				_L_xargs_run "${_L_atoms[@]}" || return 1
				_L_atoms=()
			fi
			_L_cur_records=0
		done
	done
	# Final EOF Flush
	if (( ${_L_atoms[*]:+${#_L_atoms[*]}}+0 )); then
		_L_xargs_run "${_L_atoms[@]}" || return 1
	fi
	# Reaper for parallel mode
	while (( ${_L_x_pids[*]:+${#_L_x_pids[*]}}+0 )); do
		_L_xargs_wait || return 1
	done
	return "$_L_x_return"
}

set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")"/../bin/L_lib.sh
if ! L_is_main; then return; fi

L_log_configure -L

L_argparse \
	-- -x flag=1 \
	-- -c flag=1 \
	-- args nargs="*" default= \
	---- "$@"
if ((x)); then
	set -x;
fi
compare() {
	input=$(cat)
	L_info "L_xargs vs xargs # + printf %%s %q | *xargs %s" "$input" "$(L_quote_printf "$@")"
	aexit=0
	a=$( printf "%s" "$input" | L_xargs "$@" 2>&1 ) || aexit=$?
	bexit=0
	b=$( printf "%s" "$input" | xargs "$@" 2>&1 ) || bexit=$?
	sdiff <(printf "%s\n" "$aexit" "$a") <(printf "%s\n" "$bexit" "$b")
}
if ((c)); then
	compare "${args[@]}"
	exit
fi
if ((${#args[@]})); then
	L_xargs "${args[@]}"
	exit
fi

compare -t -n3 bash -c 'echo $#' -- <<<'1 2 3 4'
compare -t -d $'\n' -n3 bash -c 'echo $#' -- <<<'1 2 3 4'
compare -t -d ' ' -n3 bash -c 'echo $#' -- <<<'1 2 3 4'
compare -n3 bash -c 'echo $#' -- <<<'1 2 3 4'
compare -t -i bash -c 'echo $#' -- <<<'1 2 3 4'
compare -t -i bash -c 'echo {} @ {}' -- <<<'1 2 3 4'
compare -n3 bash -c 'printf "%q " "$@" "$#"; echo' -- <<<$'1\n2\n3\n4\n5'
compare -d $'\n' -r -i bash -c 'printf "%q " "$@" "$#"; echo' -- {} <<<$'1 \n 2\n'
L_log "exit 255 stops"
L_unittest_cmd -r 1$'\n'".*255" -e 124 -- eval "L_xargs -n1 bash -c 'echo \$1; exit 255' -- <<<'1 2' 2>&1"

cmd() {
	trap_exit() {
		kill $c 2>/dev/null
		echo "$BASHPID" "$BASH_TRAPSIG$(printf " %q" "$@" "$#")"
	}
	trap trap_exit EXIT SIGINT SIGTERM
	sleep 30s &
	c=$!
	wait
}

L_log "kill stops childs"
L_unittest_cmd -r $'[0-9]+ 15 0\n[0-9]+ 15 0\n[0-9]+ 0 0\n[0-9]+ 0 0' -e "$((128+15))" -- eval 'L_xargs -P2 -n1 cmd <<<"1 2" 2>&1 & sleep 0.1; kill $!; wait $!'




