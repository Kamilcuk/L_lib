


_L_test_finally() {
	L_finally -r L_log -s 1 'Test finally done #2'
	L_finally L_log -s 1 'Test finally done #1'
	{
		func() {
			L_finally -r echo "$L_UUID"
		}
		L_unittest_cmd -o "$L_UUID" func
	}
	{
		func() {
			L_finally -r printf 2
			L_finally -r printf 1
			# L_finally_list >&2
		}
		L_unittest_cmd -o 12 func
	}
	{
		func() {
			L_finally printf 2
			L_finally -r printf 1
			# L_finally_list >&2
		}
		L_unittest_cmd -o 12 func
	}
	{
		func() {
			L_finally printf 3
			L_finally -r printf 1
			L_finally printf 2
			# L_finally_list >&2
		}
		L_unittest_cmd -o 123 func
	}
	{
		func_inner() {
			printf i
			L_finally -r printf 2
		}
		func_outer() {
			printf 1
			L_finally printf 4
			L_finally -r printf 3
			func_inner
			func_inner
			func_inner
		}
		L_unittest_cmd -o 1i2i2i234 func_outer
	}
	{
		L_info "Test inner RETURN finaly works"
		func_very_inner() {
			L_finally printf V
			printf v
			L_finally -r printf 1
		}
		func_inner() {
			L_finally printf I
			printf i
			L_finally -r printf 2
			func_very_inner
			func_very_inner
			func_very_inner
		}
		func_outer() {
			L_finally printf O
			L_finally -r printf 3
			func_inner
			func_inner
			func_inner
		}
		L_unittest_cmd -o iv1v1v12''iv1v1v12''iv1v1v12''3''VVVIVVVIVVVIO func_outer
	}
	{
		L_info "Test L_finally_pop works"
		func() {
			L_finally echo -n 2
			echo -n 1
			L_finally_pop
			echo -n 3
			! L_finally_pop
			echo -n 4
			! L_finally_pop
			return 0
		}
		L_unittest_cmd -o "1234" func
		#
		func() {
			L_finally printf 2
			L_finally printf 1
			L_finally_pop
			L_finally_pop
		}
		L_unittest_cmd -o 12 func
		#
		func() {
			local a b c
			L_finally -r printf 5
			L_finally -v b printf 2
			L_finally -r -v a printf 1
			L_finally -v c printf 3
			L_finally printf 4
			L_finally_pop -i "$a"
			L_finally_pop -i "$b"
			L_finally_pop -i "$c"
			L_finally_pop
		}
		L_unittest_cmd -o 12345 func
		#
		#
		func_inner() {
			L_finally -r printf "$1"
		}
		func() {
			local a b c
			func_inner 1
			func_inner 2
			L_finally -r printf 8
			L_finally -v b printf 5
			func_inner 3
			L_finally -r -v a printf 4
			L_finally -v c printf 6
			L_finally printf 7
			L_finally_pop -i "$a"
			L_finally_pop -i "$b"
			L_finally_pop -i "$c"
			L_finally_pop
		}
		L_unittest_cmd -o 12345678 func
		#
		func() {
			L_finally printf 9
			L_finally -r printf 8
			L_finally printf 6
			L_finally -r printf 4
			L_finally printf 2
			printf 1
			L_finally_pop
			printf 3
			L_finally_pop
			printf 5
			L_finally_pop
			printf 7
		}
		L_unittest_cmd -o 123456789 func
	}
	{
		L_info "Test that L_finally_pop not afects subshells"
		func() {
			L_finally -r printf 3
			printf 1
			( L_finally_pop )
			printf 2
			L_finally_pop
		}
		L_unittest_cmd -o 123 func
		#
		func_inner() {
			L_finally_pop
			( L_finally_pop )
		}
		func_outer() {
			L_finally -r printf 2
			printf 1
			func_inner
			printf 3
			L_finally_pop
			return 0
		}
		L_unittest_cmd -o 123 func_outer
		#
		func_inner() {
			L_finally_pop
			( L_finally_pop )
			L_finally -r printf 3
		}
		func_outer() {
			L_finally printf 5
			L_finally -r printf 2
			printf 1
			func_inner
			( L_finally_pop )
			printf 4
		}
		L_unittest_cmd -o 12345 func_outer
	}
	{
		L_info "Test exit is ok"
		func() (
			L_finally printf 2
			printf 1
			exit
		)
		L_unittest_cmd -o "12" func
		#
		func() (
			L_finally printf 2
			printf 1
		 	exit 234
		)
		L_unittest_cmd -e 234 -o "12" func
		#
		func() (
			L_finally -r exit 234
			exit 123
		)
		L_unittest_cmd -e 234 func
		#
		func() {
			L_finally -r printf 2
			printf 1
			return 234
		}
		L_unittest_cmd -e 234 -o 12 func
		#
		func() {
			L_finally -r eval 'printf 2'
			printf 1
			return 234
		}
		L_unittest_cmd -e 234 -o 12 func
	}
	{
		L_info "Test exit is ok"
		func() {
			(
				L_finally printf 2
				printf 1
				exit 234
			)
		}
		L_unittest_cmd -o "12" -e 234 func
	}
	{
		L_info "Test signal is ok"
		func() {
			(
				L_finally printf 2
				printf 1
				# L_unsetx L_finally_list >&2
				# pstree -p >&2
				# trap - SIGTERM
				L_raise -"$1"
			)
			# echo $?
			# return $?
		}
		export -f func
		L_unittest_cmd -o "12" -e $(( 128 + $(L_trap_to_number INT) )) \
			"${newbash[@]}" func INT
		L_unittest_cmd -o "12" -e $(( 128 + $(L_trap_to_number TERM) )) \
			"${newbash[@]}" func TERM
		L_unittest_cmd -o "12" -e $(( 128 + $(L_trap_to_number HUP) )) \
			"${newbash[@]}" func HUP
		L_unittest_cmd -o "12" -e $(( 128 + $(L_trap_to_number INT) )) func INT
		L_unittest_cmd -o "12" -e $(( 128 + $(L_trap_to_number TERM) )) func TERM
		L_unittest_cmd -o "12" -e $(( 128 + $(L_trap_to_number HUP) )) func HUP
	}
	{
		L_info "test custom handler"
		func() {
			(
				L_finally
				L_trap USR1 printf 'USR1 '
				L_trap USR2 printf 'USR2 '
				L_finally echo 'EXIT'
				L_trap HUP printf 'HUP '
				L_trap INT printf 'INT '
				# set -x
				L_raise -USR2
				L_raise -INT
				L_raise -HUP
				L_raise -USR1
				L_raise -HUP
				L_raise -USR1
				L_raise -USR2
				L_raise -INT
				L_raise
			)
		}
		export -f func
		L_unittest_cmd -o 'USR2 INT HUP USR1 HUP USR1 USR2 INT EXIT' -e "$((128 + $(L_trap_to_number TERM) ))" func
		L_unittest_cmd -o 'USR2 INT HUP USR1 HUP USR1 USR2 INT EXIT' -e "$((128 + $(L_trap_to_number TERM) ))" "${newbash[@]}" func
	}
	{
		L_info "test command substition"
		func() {
			L_finally -r printf 4
			L_finally printf 5
			a=$(
				L_finally printf 3
				L_finally printf 2
			)
			L_unittest_vareq a 23 >&2 || exit 2
			L_finally -r printf "%s" "$a"
			L_finally -r printf 1
		}
		L_unittest_cmd -o 12345 func
		export -f func
		L_unittest_cmd -o 12345 "${newbash[@]}" func
	}
	{
		L_info "nested return ok"
		a?*() {
			L_finally -r printf "$1"
		}
		a*() {
			L_finally -r printf "$1"
			'a?*' "$2"
		}
		a.*() {
			L_finally -r printf "$1"
			'a*' "$2" "$3"
		}
		a() {
			L_finally -r printf 4
			'a.*' 3 2 1
		}
		export -f "a" "a.*" "a*" "a?*"
		L_unittest_cmd -o 1234 a
		L_unittest_cmd -o 1234 "${newbash[@]}" a
		#
		a?*() {
			L_finally -r printf "$1"
			echo -n a
		}
		a*() {
			L_finally -r printf "$1"
			'a?*' "$2"
			echo -n b
		}
		a.*() {
			L_finally -r printf "$1"
			'a*' "$2" "$3"
			echo -n c
		}
		a() {
			L_finally -r printf 8
			'a.*' 3 2 1
			L_finally -r printf 7
			'a.*' 6 5 4
			echo -n d
		}
		export -f "a" "a.*" "a*" "a?*"
		L_unittest_cmd -o a1b2c3a4b5c6d78 a
		L_unittest_cmd -o a1b2c3a4b5c6d78 L_subshell a
		L_unittest_cmd -o a1b2c3a4b5c6d78 "${newbash[@]}" a
		L_unittest_cmd -o a1b2c3a4b5c6d78 bash -eEo functrace -c ". $L_LIB_SCRIPT && a"
	}
	#
	L_finally_list
	local a
	a=$(L_finally_list)
	L_unittest_cmd -I grep -q L_log <<<"$a"
	L_finally_pop
}

_L_test_finally_loop() {
	{
		L_log "many calls slow down?"
		func() {
			L_finally echo -n "$i "
			L_finally -r echo -n "$i "
			# set -x
		}
		f() {
			local i
			for ((i=0;i<$1;++i)); do
				func
				# set +x
			done
			for ((i=0;i<$1;++i)); do
				L_finally_pop
			done
			echo
			echo "${#_L_finally_arr[@]}"
		}
		L_unittest_cmd L_time f 100
		L_unittest_cmd L_time f 1000
	}
	{
		L_log "nested calls"
		func() {
			L_finally echo -n 6
			L_finally -r echo -n 3
			func() {
				L_finally echo -n 5
				L_finally -r echo -n 2
				func() {
					L_finally echo -n 4
					L_finally -r echo -n 1
				}
				func
				func
			}
			func
			func
		}
		L_unittest_cmd -o 1121344456 func
	}
}

_L_test_finally_subshells() {
	{
		L_info "test all signals in subshell"
		func() {
			(
				# set -x
				L_finally echo EXIT
				L_raise -"$1"
			)
		}
		local i
		for i in $(L_trap_names); do
			case "$i" in
			EXIT|ERR|RETURN|DEBUG|SIGKILL|SIGCONT|SIGSTOP|SIGTSTP|SIGTTIN|SIGTTOU|SIGPIPE|SIGQUIT|SIGSTKFLT|SIGINT) ;;
			SIGINFO|SIGWINCH|SIGURG|SIGCHLD|SIGCLD) L_unittest_cmd -o EXIT func "$i" ;;
			*) L_unittest_cmd -o EXIT -e $(( 128 + $(L_trap_to_number "$i") )) func "$i" ;;
			esac
		done
	}
}

_L_test_finally_proc() {
	{
		L_info "test all signals in process"
		script() {
			# Somehow SIGINT is not set to default here, reset it.
			trap - SIGINT
			bash -c "
				. $L_LIB_SCRIPT
				ulimit -c 0
				L_finally echo EXIT
				# set -x
				L_raise -$1
				echo 'SIGNAL $1 DID NOT TERMINATE' >&2
			"
		}
		local i
		for i in $(L_trap_names); do
			case "$i" in
			EXIT|ERR|RETURN|DEBUG|SIGKILL|SIGCONT|SIGSTOP|SIGTSTP|SIGTTIN|SIGTTOU|SIGPIPE|SIGQUIT|SIGSTKFLT) ;;
			SIGSTKFLT|SIGINT) ;;
			SIGINFO|SIGWINCH|SIGURG|SIGCHLD|SIGCLD) L_unittest_cmd -o EXIT script "$i" ;;
			*) L_unittest_cmd -o EXIT -e $(( 128 + $(L_trap_to_number "$i") )) script "$i" ;;
			esac
		done
	}
}

_L_test_finally_interrupt() {
	{
		L_info "test SIGRET"
		f() { L_finally eval 'echo $L_SIGRET'; exit 123; }
		L_unittest_cmd -o 123 -e 123 f
		f() { L_finally -r eval 'echo $L_SIGRET'; exit 234; }
		L_unittest_cmd -o 234 -e 234 f
	}
	waiter() {
		# local r=0; while wait "$@" && r=$? || r=$?; (($r>128)); do :; done
		# set +x; while kill -0 "$1" 2>/dev/null; do sleep 0.1; done
		# set +x
		enable sleep 2>/dev/null || :
		local to; L_timeout_set_to to "$1"; while ! L_timeout_expired "$to"; do sleep 0.1; done
	}
	{
		local e=$((128+$(L_trap_to_number USR1)))
		L_info "test interrupting error handling"
		f() {
			L_finally waiter 0.5
			L_bashpid_to bashpid
			sleep 0.2 && kill -USR1 "$bashpid" || : &
			case "$1" in
				pop) L_finally_pop ;;
				return) return ;;
				exit) exit ;;
				signal) L_raise -USR1 ;;
			esac
		}
		export -f f waiter
		L_unittest_cmd -e "$e" "${newbash[@]}" f pop
		L_unittest_cmd -e "$e" "${newbash[@]}" f return
		L_unittest_cmd -e "$e" "${newbash[@]}" f exit
		L_unittest_cmd -e "$e" "${newbash[@]}" f signal
		L_unittest_cmd -e "$e" f pop
		L_unittest_cmd -e "$e" f return
		L_unittest_cmd -e "$e" f exit
		L_unittest_cmd -e "$e" f signal
	}
	{
		L_info "test interrupting error handling twice"
		f2() {
			L_finally waiter 10
			L_bashpid_to bashpid
			sleep 0.2 && kill -USR1 "$bashpid" &
			sleep 0.4 && kill -USR1 "$bashpid" &
			case "$1" in
				pop) L_finally_pop ;;
				return) return ;;
				exit) exit ;;
				signal) L_raise -USR1 ;;
			esac
		}
		export -f f2
		L_unittest_cmd -e "$e" f2 pop
		L_unittest_cmd -e "$e" f2 return
		L_unittest_cmd -e "$e" f2 exit
		L_unittest_cmd -e "$e" "${newbash[@]}" f2 pop
		L_unittest_cmd -e "$e" "${newbash[@]}" f2 return
		L_unittest_cmd -e "$e" "${newbash[@]}" f2 exit
		if ((!L_HAS_BASH5_0)); then
			L_unittest_skip "Disabled below bash5.0"
			return
		fi
		L_unittest_cmd -e "$e" f2 signal
	}
	{
		L_info "test good function calls return"
		f1() {
			echo -n 1
			f2
			echo -n 10
		}
		f2() {
			echo -n 2
			f3
			echo -n 9
		}
		f3() {
			L_finally -r echo -n 8
			echo -n 3
			f4
			echo -n 7
		}
		f4() {
			echo -n 4
			f5
			echo -n 6
		}
		f5() {
			L_finally echo -n 11
			echo -n 5
		}
		L_unittest_cmd -o 1234567891011 f1
		L_unittest_cmd -o 1234567891011 bash -c ". $L_LIB_SCRIPT;"'. "$1"' bash <(declare -f f1 f2 f3 f4 f5; echo f1)
	}
}

_L_test_finally_source() {
	if ((!L_HAS_BASH4_4)); then
		L_warning "ignoring test for bash below 4.4"
		return
	fi
	{
		L_log "source return finally works?"
		L_unittest_cmd -o 21 bash -euo pipefail -c ". $L_LIB_SCRIPT; . <(echo 'L_finally echo -n 1'); echo -n 2"
		L_unittest_cmd -o 12 bash -euo pipefail -c ". $L_LIB_SCRIPT
			. <(echo '
				L_finally -r echo -n 1
				return 2
				'
			) || r=\$?
			echo -n \$r
			"
		L_log "using L_source instead of ."
		L_unittest_cmd -o 1234567 bash -euo pipefail -c ". $L_LIB_SCRIPT -s
			f() {
				local r
				L_finally -r echo -n 6
				echo -n 2
				L_source <(echo '
					L_finally -r echo -n 4
					echo -n 3
					return 5
					'
				) || r=\$?
				echo -n \$r
			}
			echo -n 1
			f
			echo -n 7
			"
		L_log "using source. Special handling"
		L_unittest_cmd -o 1234567 bash -euo pipefail -c ". $L_LIB_SCRIPT -s
			f() {
				local r
				L_finally -r echo -n 6
				echo -n 2
				. <(echo '
					L_finally -r echo -n 4
					echo -n 3
					return 5
					'
				) || r=\$?
				echo -n \$r
			}
			echo -n 1
			f
			echo -n 7
			"
	}
}

###############################################################################

_L_test_finally_signal_var() {
	f() {
		(
			L_finally eval 'echo $L_SIGNAL'
			L_raise -USR1
		)
	}
	L_unittest_cmd -o "SIGUSR1" -e "$(( 128 + $(L_trap_to_number USR1) ))" f
}

_L_test_finally_last() {
	f() {
		L_finally printf "2"
		L_finally -l printf "3"
		L_finally printf "1"
	}
	L_unittest_cmd -o "123" f
}

_L_test_finally_simple_cleanup() {
	local tmpf
	tmpf=$(mktemp)
	f() {
		local f="$1"
		(
			L_finally rm "$f"
			echo "work"
		)
	}
	L_unittest_cmd -o "work" f "$tmpf"
	L_unittest_cmd ! test -e "$tmpf"
}

