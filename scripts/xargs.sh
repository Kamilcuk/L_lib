#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/../bin/L_lib.sh

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

_L_xargs_wait() {
	local _L_tmp _L_i _L_ret
	L_exit_to _L_ret wait -n -p _L_tmp "${_L_pids[@]}"
	_L_xargs_handle_return "$_L_ret"
	for _L_i in "${!_L_pids[@]}"; do
		if [[ "${_L_pids[_L_i]}" == "$_L_tmp" ]]; then
			unset "_L_pids[$_L_i]"
			break
		fi
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
	# Execute
	if ((_L_verbose)); then
		L_quote_bin_printf "${_L_cmdready[@]}" >&2
	fi
	if ((_L_max_procs == 1)); then
		L_exit_to _L_i "${_L_cmdready[@]}"
		_L_xargs_handle_return "$_L_i"
	else
		"${_L_cmdready[@]}" &
		_L_pids+=("$!")
		if ((_L_max_procs != 0 && ${#_L_pids[@]} >= _L_max_procs)); then
			_L_xargs_wait
		fi
	fi
	_L_runcnt=$((_L_runcnt+1))
}

_L_xargs_trap() {
	eval "${1:-}"
	if ((${_L_pids[@]:+${#_L_pids[@]}}+0 != 0)); then
		if L_is_integer "$BASH_TRAPSIG" && ((BASH_TRAPSIG != 0)); then
			if ((BASH_TRAPSIG == 2)); then
				# https://stackoverflow.com/a/75385863/9072753
				# SIGINT is disabled in subshells so do not send it
				kill "${_L_pids[@]}"
			else
				kill -"$BASH_TRAPSIG" "${_L_pids[@]}"
			fi
		fi
		wait "${_L_pids[@]}"
	fi
}

# @description Everyone wants to have one.
#
# Why not xargs? Because I do not want to export Bash functions and variables.
#
# @option -0 Zero separated input
# @option -u <fd> Get input from this file descriptor.
# @option -d <delimeter> Input items are terminated by th especified character.
# @option -I <replace-str> Replace occurences of replace-str in command.
# @option -i Equal to -I{}. Takes no argument.
# @option -n <max-argS> Use at most max-args arguments per command line.
# @option -P <max-procs> Run up to max-procs processes at a time; the default is 1.
# If max-procs is 0, run as many processes as possible at the same time.
# If max-procs is 1, the command is run in the current execution context.
# SIGINT is not forwarded, because Bash ignores it. Instead SIGKILL is executed.
# Background processes are killed an waited on signal with L_finally.
# @option -r Do not run command if no arguments are given.
# @option -t Print each command to standard error before execution.
L_xargs() {
	local OPTIND OPTARG OPTERR _L_replace="" _L_zero=0 _L_max_args=0 _L_i _L_max_procs=1 _L_delim=""  _L_verbose=0 _L_no_run_if_empty=0
	while getopts 0u:d:I:in:P:rt _L_i; do
		case "$_L_i" in
			0) _L_zero=1 ;;
			u) _L_inputfd=$OPTARG ;;
			d) _L_delim=$OPTARG ;;
			I) _L_replace=$OPTARG ;;
			i) _L_replace="{}" ;;
			n) _L_max_args=$OPTARG ;;
			P) _L_max_procs=$OPTARG ;;
			r) _L_no_run_if_empty=1 ;;
			t) _L_verbose=1 ;;
			*) L_error "L_xargs: invalid option: -$_L_i" ;;
		esac
	done
	shift "$((OPTIND-1))"
	L_assert 'No command to execute' test "$#" -gt 0
	local _L_cmd=("$@") _L_runcnt=0 _L_pids=() _L_args=() _L_line="" _L_return=0 _L_done=0
	L_finally -r _L_xargs_trap
	# Read input line.
	while
		((!_L_done)) &&
			{ IFS= read -r ${_L_delim:+-d"$_L_delim"} ${_L_inputfd:+-u"$_L_inputfd"} _L_line || [[ -n "$_L_line" ]]; }
	do
		# Parse input line.
		if [[ -z "$_L_delim" && -z "$_L_replace" ]]; then
			local _L_tmp=()
			L_assert "Could not parse line: $_L_line" L_str_split -v _L_tmp -- "$_L_line"
			_L_args+=("${_L_tmp[@]}")
		else
			_L_args+=("$_L_line")
		fi
		# Execute commands.
		if ((_L_max_args != 0)); then
			while ((${#_L_args[@]} >= _L_max_args)); do
				_L_xargs_run "${_L_args[@]:0:_L_max_args}"
				_L_args=("${_L_args[@]:_L_max_args}")
			done
		else
			_L_xargs_run "${_L_args[@]}"
			_L_args=()
		fi
	done
	if ((${#_L_args[@]})); then
		_L_xargs_run "${_L_args[@]}"
	elif ((!_L_no_run_if_empty && _L_runcnt == 0)); then
		_L_xargs_run
	fi
	#
	while ((${#_L_pids[@]})); do
		_L_xargs_wait
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




