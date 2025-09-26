#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")"/../bin/L_lib.sh
L_log_configure -L

# @see https://github.com/jamesyoungman/findutils/blob/master/xargs/xargs.c#L1585
# @see https://github.com/aixoss/findutils/blob/r4.4.2-aix/xargs/xargs.c#L1272
_L_xargs_handle_return() {
	case "$1" in
	0) ;;
	255)
		_L_done=1
		if ((_L_return < 124)); then
			_L_return=124
		fi
		printf "L_xargs: %s: exited with status 255; aborting\n" "${_L_cmd[0]}" >&2
		;;
	126|127)
		_L_done=1
		if ((_L_return < $1)); then
			_L_return=$1
		fi
		;;
	*)
		if ((128 < $1 && $1 <= 128 + 64)); then
			_L_done=1
			local _L_tmp
			L_trap_to_name -v _L_tmp "$(($1-128))"
			printf "L_xargs: %s: terminated by signal %s\n" "${_L_cmd[0]}" "$_L_tmp" >&2
			if ((_L_return < 125)); then
				_L_return=125
			fi
		else
			_L_return=123
		fi
		;;
	esac
}

_L_xargs_read_outputs() {
	local IFS='' _L_i _L_fd_done="" _L_args=()
	# Read from file descriptors if created pipes.
	if (( ${_L_outputfds[@]:+${#_L_outputfds[@]}} )); then
		for _L_i in "${!_L_outputfds[@]}"; do
			_L_args+=( "${_L_outputfds[_L_i]}" "_L_outputs[$_L_i]" )
		done
		L_read_fds "$@" -n _L_fd_done "${_L_args[@]}"
		if [[ -n "$_L_fd_done" ]]; then
			for _L_i in "${!_L_outputfds[@]}"; do
				if [[ "${_L_outputfds[_L_i]}" == "$_L_fd_done" ]]; then
					printf "%s" "${_L_outputs[_L_i]}"
					eval "exec ${_L_outputfds[$_L_i]}>&-"
					unset -v "_L_outputfds[$_L_i]"
					return 0
				fi
			done
		fi
	fi
}

_L_xargs_wait() {
	if (( ${_L_pids[@]:+1} )); then
		return 1
	fi
	if ((_L_separateoutput)); then
		local _L_ret
		_L_xargs_read_outputs -1
		while
			L_exit_to _L_ret L_wait -t 1 "${_L_pids[@]}"
			((_L_ret == 124))
		do
			_L_xargs_read_outputs -1
		done
	fi
	#
	local _L_pid _L_i _L_ret
	# Exit for a command.
	L_wait -v _L_ret -p _L_pid "${_L_pids[@]}"
	_L_xargs_handle_return "$_L_ret"
	for _L_i in "${!_L_pids[@]}"; do
		if [[ "${_L_pids[_L_i]}" == "$_L_pid" ]]; then
			unset -v "_L_pids[$_L_i]"
			return 0
		fi
	done
	return 1
}

_L_xargs_prefixer() {
	while IFS= read -r line; do
		printf "%s\n" "$1) $line"
	done
}

_L_xargs_run() {
	if ((_L_done)); then
		return
	fi
	if [[ -n "$_L_replace" ]]; then
		# Replace {}.
		local _L_cmdready=("${_L_cmd[@]//"$_L_replace"/"${1:-}"}")
	else
		local _L_cmdready=("${_L_cmd[@]}" "$@")
	fi
	if ((_L_prefix)); then
		local _L_cmd _L_prefix
		printf -v _L_cmd "%q " "${_L_cmdready[@]}"
		printf -v _L_prefix " %q" "$@"
		_L_cmd+="> >(_L_xargs_prefixer$_L_prefix)"
		_L_cmdready=(eval "$_L_cmd")
	fi
	# Execute
	if ((_L_verbose)); then
		L_quote_printf "+" "${_L_cmdready[@]}" >&2
	fi
	if ((_L_maxprocs == 1)); then
		L_exit_to _L_i "${_L_cmdready[@]}"
		_L_xargs_handle_return "$_L_i"
	else
		if ((!_L_registered_xargs_trap)); then
			_L_registered_xargs_trap=1
			L_finally -s 1 -r _L_xargs_trap || return 1
		fi
		if ((_L_separateoutput)); then
			local _L_pipe _L_cmd
			L_pipe _L_pipe || return 1
			printf -v _L_cmd "%q " "${_L_cmdready[@]}"
			_L_outputfds+=("${_L_pipe[0]}")
			_L_cmd+=" ${_L_pipe[0]}>&- 1>&${_L_pipe[1]}"
			eval "$_L_cmd &"
			eval "exec ${_L_pipe[1]}>&-"
		else
			"${_L_cmdready[@]}" &
		fi
		_L_pids+=("$!")
		if ((_L_maxprocs != 0 && ${#_L_pids[@]} >= _L_maxprocs)); then
			_L_xargs_wait || return 1
		fi
	fi
	_L_runcnt=$((_L_runcnt+1))
}

_L_xargs_trap() {
	if (( ${_L_pids[@]:+${#_L_pids[@]}}+0 != 0 )); then
		local sig=$L_SIGNAL
		if ((sig == SIGINT)); then
			# https://stackoverflow.com/a/75385863/9072753
			# SIGINT is disabled in subshells so do not send it
			sig=""
		fi
		kill ${sig:+-"$sig"} "${_L_pids[@]}" || :
		wait "${_L_pids[@]}"
	fi
}

L_nproc_v() {
	if L_hash nproc; then
		L_v=$(nproc)
	elif [[ -r /proc/cpuinfo ]]; then
		if L_hash grep; then
			L_v=$(grep -c ^processor /proc/cpuinfo)
		else
			L_readarray a </proc/cpuinfo
			L_array_filter_eval a '[[ "$1" == processor* ]]'
			L_v=${#a[@]}
		fi
	elif [[ -r /proc/sys/hw/ncpu ]]; then
		L_v=$(cat /proc/sys/hw/ncpu)
	else
		L_v=1
	fi
}

# @description Everyone wants to have one.
#
# Why not xargs? Because I do not want to export Bash functions and variables.
#
# @option -0 Zero separated input
# @option -d <delimeter> Input items are terminated by th especified character.
# @option -u <fd> Get input from this file descriptor.
# @option -I <replace-str> Replace occurences of replace-str in command.
# @option -i Equal to -I{}. Takes no argument.
# @option -n <max-args> Use at most max-args arguments per command line.
# @option -P <max-procs> Run up to max-procs processes at a time; the default is 1.
#            If max-procs is 0, run as many processes as possible at the same time.
#            If max-procs is 1, the command is run in the current execution context.
#            If max-procs is n, the max-procs is set to the number of processors.
#            Signals are forwarded to subshells, except SIGINT.
#            SIGINT is not forwarded, because Bash ignores it. Instead SIGKILL is sent.
#            Background processes are killed an waited on signal with L_finally.
# @option -r Do not run command if no arguments are given.
# @option -t Print each command to standard error before execution.
# @option -O Buffer and output each command stdout separately.
# @option -^ Prefix output from each command with space joined arguments followed by ") ".
# @option -h Print this help and exit.
# @return 0 on success
#         1 on some other error
#         2 on invalid usage
#         123 if any invocation oft he command exited wtih status 1-125
#         124 if the command exited with status 255
#         125 if the command exited wiht the status 128-192
#         126 if the command cannot be run
#         127 if the command is not found
L_xargs() {
	local OPTIND OPTARG OPTERR _L_replace="" _L_split=1 _L_maxargs=60000 _L_i _L_maxprocs=1 \
		_L_verbose=0 _L_no_run_if_empty=0 _L_read=() _L_registered_xargs_trap=0 \
		_L_separateoutput=0 _L_outputfds=() _L_outputs=() _L_prefix=0
	while getopts 0d:u:I:in:P:rtO^h _L_i; do
		case "$_L_i" in
			0) _L_split=0 _L_read+=(-d '') ;;
			d) _L_split=0 _L_read+=(-d "$OPTARG") ;;
			u) _L_read+=(-u "$OPTARG") ;;
			I) _L_maxargs=1 _L_replace=$OPTARG ;;
			i) _L_maxargs=1 _L_replace="{}" ;;
			n) _L_maxargs=$OPTARG ;;
			P) if [[ "$OPTARG" == n* ]]; then L_nproc_v; _L_maxprocs=$L_v; else _L_maxprocs=$OPTARG; fi ;;
			r) _L_no_run_if_empty=1 ;;
			t) _L_verbose=1 ;;
			O) _L_separateoutput=1 ;;
			^) _L_prefix=1 ;;
			h) L_func_help; return 0 ;;
			*) L_func_error "L_xargs: invalid option: -$_L_i"; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	if ((!$#)); then
		set -- echo
	fi
	local _L_cmd=("$@") _L_runcnt=0 _L_pids=() _L_args=() _L_line="" _L_return=0 _L_done=0 _L_procs=()
	# Read input line.
	while
		((!_L_done)) &&
			if ((_L_split)); then
				# Collect all input into one variable.
				if IFS= read -r -d '' ${_L_read[@]:+"${_L_read[@]}"} _L_i || [[ -n "$_L_i" ]]; then
					_L_line+="$_L_i"
					while IFS= read -r -d '' ${_L_read[@]:+"${_L_read[@]}"} _L_i || [[ -n "$_L_i" ]]; do
						_L_line+="$_L_i"
					done
				else
					false
				fi &&
				[[ -n "$_L_line" ]]
			else
				# Read one line of input.
				IFS= read -r ${_L_read[@]:+"${_L_read[@]}"} _L_line ||
				[[ -n "$_L_line" ]]
			fi
	do
		# Parse input line.
		if ((_L_split)); then
			local _L_tmp=()
			if ! L_str_split -v _L_tmp -- "$_L_line"; then
				L_func_error "Could not parse line: $_L_line. By default quotes are special for L_xargs, unless you use -0 or -d options."
				return 2
			fi
			_L_args+=("${_L_tmp[@]}")
		else
			_L_args+=("$_L_line")
		fi
		# Execute commands.
		if ((_L_maxargs != 1)); then
			while ((${#_L_args[@]} >= _L_maxargs)); do
				_L_xargs_run "${_L_args[@]:0:_L_maxargs}" || return 1
				_L_args=("${_L_args[@]:_L_maxargs}")
			done
		else
			_L_xargs_run "${_L_args[@]}"
			_L_args=()
		fi
	done
	if ((${#_L_args[@]})); then
		_L_xargs_run "${_L_args[@]}" || return 1
	elif ((!_L_no_run_if_empty && _L_runcnt == 0)); then
		_L_xargs_run || return 1
	fi
	#
	while ((${#_L_pids[@]})); do
		_L_xargs_wait || return 1
	done
	#
	return "$_L_return"
}

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




