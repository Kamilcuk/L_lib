# Tests for L_finally -f and -l options (first and last queues)

_L_test_finally2_queues_exit() {
	L_info "Test queue ordering on EXIT (no -r): first, normal, last"
	{
		f() {
			L_finally -f echo first
			L_finally -l echo last
			L_finally echo normal
		}
		L_unittest_cmd -o $'first\nnormal\nlast' f
	}
	{
		L_info "Test -f multiple: LIFO ordering on EXIT"
		f() {
			L_finally -f echo 1
			L_finally -f echo 2
			L_finally -f echo 3
		}
		L_unittest_cmd -o $'3\n2\n1' f
	}
	{
		L_info "Test -l multiple: FIFO ordering on EXIT"
		f() {
			L_finally -l echo 1
			L_finally -l echo 2
			L_finally -l echo 3
		}
		L_unittest_cmd -o $'1\n2\n3' f
	}
	{
		L_info "Test normal multiple: LIFO ordering on EXIT"
		f() {
			L_finally echo 1
			L_finally echo 2
			L_finally echo 3
		}
		L_unittest_cmd -o $'3\n2\n1' f
	}
	{
		L_info "Test mixed queues: -f -l -f -l normal normal on EXIT"
		f() {
			L_finally -f echo 1
			L_finally -l echo 5
			L_finally -f echo 2
			L_finally -l echo 6
			L_finally echo 3
			L_finally echo 4
		}
		L_unittest_cmd -o $'2\n1\n4\n3\n5\n6' f
	}
}

_L_test_finally2_queues_return() {
	L_info "Test queue ordering on RETURN (-r): first, normal, last"
	{
		f() {
			L_finally -r -f echo first
			L_finally -r -l echo last
			L_finally -r echo normal
			return 0
		}
		L_unittest_cmd -o $'first\nnormal\nlast' f
	}
	{
		L_info "Test -r -f multiple: LIFO on RETURN"
		f() {
			L_finally -r -f echo 1
			L_finally -r -f echo 2
			L_finally -r -f echo 3
			return 0
		}
		L_unittest_cmd -o $'3\n2\n1' f
	}
	{
		L_info "Test -r -l multiple: FIFO on RETURN"
		f() {
			L_finally -r -l echo 1
			L_finally -r -l echo 2
			L_finally -r -l echo 3
			return 0
		}
		L_unittest_cmd -o $'1\n2\n3' f
	}
	{
		L_info "Test -r normal multiple: LIFO on RETURN"
		f() {
			L_finally -r echo 1
			L_finally -r echo 2
			L_finally -r echo 3
			return 0
		}
		L_unittest_cmd -o $'3\n2\n1' f
	}
	{
		L_info "Test mixed -r queues: -r -f -r -l -r -f -r -l -r -r normal on RETURN"
		f() {
			L_finally -r -f echo 1
			L_finally -r -l echo 5
			L_finally -r -f echo 2
			L_finally -r -l echo 6
			L_finally -r echo 3
			L_finally -r echo 4
			return 0
		}
		L_unittest_cmd -o $'2\n1\n4\n3\n5\n6' f
	}
}

_L_test_finally2_mixed_r_and_non_r() {
	L_info "Test normal return: -r items run on RETURN, non-r on EXIT"
	{
		f() {
			L_finally -r -f echo Rfirst
			L_finally -r -l echo Rlast
			L_finally -r echo Rnormal
			L_finally -f echo EXITfirst
			L_finally echo EXITnormal
			L_finally -l echo EXITlast
			return 0
		}
		L_unittest_cmd -o $'Rfirst\nRnormal\nRlast\nEXITfirst\nEXITnormal\nEXITlast' f
	}
	{
		L_info "Test exit: all items run on EXIT in queue order"
		f() {
			L_finally -r -f echo Rf
			L_finally -r -l echo Rl
			L_finally -f echo Ef
			L_finally -l echo El
			exit
		}
		L_unittest_cmd -o $'Ef\nRf\nRl\nEl' f
	}
}

_L_test_finally2_pop_i() {
	L_info "Test L_finally_pop -i with -f (first queue)"
	{
		f() {
			L_finally -r -f -v a echo first
			L_finally -r -v b echo normal
			L_finally -r -l -v c echo last
			L_finally_pop -i "$a"
			return 0
		}
		L_unittest_cmd -o $'first\nnormal\nlast' f
	}
	{
		L_info "Test L_finally_pop -i with -l (last queue)"
		f() {
			L_finally -r -f -v a echo first
			L_finally -r -v b echo normal
			L_finally -r -l -v c echo last
			L_finally_pop -i "$c"
			return 0
		}
		L_unittest_cmd -o $'last\nfirst\nnormal' f
	}
	{
		L_info "Test L_finally_pop -i with normal queue"
		f() {
			L_finally -r -f -v a echo first
			L_finally -r -v b echo normal
			L_finally -r -l -v c echo last
			L_finally_pop -i "$b"
			return 0
		}
		L_unittest_cmd -o $'normal\nfirst\nlast' f
	}
	{
		L_info "Test L_finally_pop -i with -f non-r on EXIT"
		f() {
			L_finally -f -v a echo first
			L_finally -v b echo normal
			L_finally -l -v c echo last
			L_finally_pop -i "$a"
			exit
		}
		L_unittest_cmd -o $'first\nnormal\nlast' f
	}
	{
		L_info "Test L_finally_pop -i with -l non-r on EXIT"
		f() {
			L_finally -f -v a echo first
			L_finally -v b echo normal
			L_finally -l -v c echo last
			L_finally_pop -i "$c"
			exit
		}
		L_unittest_cmd -o $'last\nfirst\nnormal' f
	}
	{
		L_info "Test L_finally_pop -i removes from both _L_finally_arr and _L_finally_return"
		f() {
			L_finally -r -f -v a echo first
			L_finally -r -v b echo normal
			L_finally_pop -i "$a"
			L_finally -r -l echo last_added_after_pop
			return 0
		}
		L_unittest_cmd -o $'first\nnormal\nlast_added_after_pop' f
	}
}

_L_test_finally2_pop_n() {
	L_info "Test L_finally_pop -n -i with -f (no execute)"
	{
		f() {
			L_finally -r -f -v a echo first
			L_finally -r -v b echo normal
			L_finally -r -l -v c echo last
			L_finally_pop -n -i "$a"
			return 0
		}
		L_unittest_cmd -o $'normal\nlast' f
	}
	{
		L_info "Test L_finally_pop -n -i with -l (no execute)"
		f() {
			L_finally -r -f -v a echo first
			L_finally -r -v b echo normal
			L_finally -r -l -v c echo last
			L_finally_pop -n -i "$c"
			return 0
		}
		L_unittest_cmd -o $'first\nnormal' f
	}
	{
		L_info "Test L_finally_pop -n -i with normal (no execute)"
		f() {
			L_finally -r -f -v a echo first
			L_finally -r -v b echo normal
			L_finally -r -l -v c echo last
			L_finally_pop -n -i "$b"
			return 0
		}
		L_unittest_cmd -o $'first\nlast' f
	}
	{
		L_info "Test L_finally_pop -n -i with -l non-r (no execute on EXIT)"
		f() {
			L_finally -f -v a echo first
			L_finally -v b echo normal
			L_finally -l -v c echo last
			L_finally_pop -n -i "$c"
			exit
		}
		L_unittest_cmd -o $'first\nnormal' f
	}
}

_L_test_finally2_pop_default() {
	L_info "Test L_finally_pop default (no -i): pops lowest index (first queue)"
	{
		f() {
			L_finally -f echo 1
			L_finally -l echo 5
			L_finally -f echo 2
			L_finally echo 3
			L_finally_pop
			exit
		}
		L_unittest_cmd -o $'2\n1\n3\n5' f
	}
	{
		L_info "Test L_finally_pop default on RETURN -r"
		f() {
			L_finally -r -f echo 1
			L_finally -r -l echo 5
			L_finally -r -f echo 2
			L_finally -r echo 3
			L_finally_pop
			return 0
		}
		L_unittest_cmd -o $'2\n1\n3\n5' f
	}
}

_L_test_finally2_nested() {
	L_info "Test nested functions with -r -f/-l"
	{
		inner() {
			L_finally -r -f echo 'inner-first'
			L_finally -r -l echo 'inner-last'
			echo inner-body
			return 0
		}
		outer() {
			L_finally -r -f echo 'outer-first'
			L_finally -r -l echo 'outer-last'
			echo outer-body
			inner
			return 0
		}
		L_unittest_cmd -o $'outer-body\ninner-body\ninner-first\ninner-last\nouter-first\nouter-last' outer
	}
	{
		L_info "Test nested -f and -l without -r on EXIT"
		inner() {
			L_finally -f echo 'inner-first'
			L_finally -l echo 'inner-last'
			echo inner-body
		}
		outer() {
			L_finally -f echo 'outer-first'
			L_finally -l echo 'outer-last'
			echo outer-body
			inner
		}
		L_unittest_cmd -o $'outer-body\ninner-body\ninner-first\nouter-first\nouter-last\ninner-last' outer
	}
}

_L_test_finally2_stack_offset() {
	L_info "Test -r -s stack offset with -f and -l"
	{
		inner() {
			echo inner
		}
		outer() {
			L_finally -r -s 1 -f echo 'outer-first-on-inner-return'
			L_finally -r -s 1 -l echo 'outer-last-on-inner-return'
			inner
			return 0
		}
		L_unittest_cmd -o $'inner\nouter-first-on-inner-return\nouter-last-on-inner-return' outer
	}
}

_L_test_finally2_signal() {
	L_info "Test signal handling with -f -l on EXIT"
	{
		f() {
			L_finally -f echo first
			L_finally -l echo last
			L_finally echo normal
			L_raise -USR1
		}
		L_unittest_cmd -o $'first\nnormal\nlast' -e $((128 + $(L_trap_to_number USR1))) f
	}
	{
		L_info "Test signal handling with -r -f -l on RETURN"
		f() {
			L_finally -r -f echo first
			L_finally -r -l echo last
			L_finally -r echo normal
			L_raise -USR1
		}
		L_unittest_cmd -o $'first\nnormal\nlast' -e $((128 + $(L_trap_to_number USR1))) f
	}
}

_L_test_finally2_list() {
	L_info "Test L_finally_list with -f and -l"
	{
		f() {
			L_finally -f echo first
			L_finally -l echo last
			L_finally echo normal
			L_finally_list
		}
		L_unittest_cmd -o $'Function Action\n         echo first;\n         echo normal;\n         echo last;\nfirst\nnormal\nlast' f
	}
}

_L_test_finally2_errors() {
	L_info "Test -f conflicts with -l error"
	{
		f() {
			L_finally -f -l echo test
		}
		L_unittest_cmd -e "$L_EX_USAGE" f
	}
}

_L_test_finally2_subprocess() {
	L_info "Test -f -l on EXIT in subprocess (bash -c)"
	{
		f() {
			L_finally -f echo first
			L_finally -l echo last
			L_finally echo normal
		}
		L_unittest_cmd -o $'first\nnormal\nlast' bash -c ". $L_LIB_SCRIPT; f() { L_finally -f echo first; L_finally -l echo last; L_finally echo normal; }; f"
	}
	{
		L_info "Test -r -f -l on RETURN in subprocess"
		f() {
			L_finally -r -f echo first
			L_finally -r -l echo last
			L_finally -r echo normal
			return 0
		}
		L_unittest_cmd -o $'first\nnormal\nlast' bash -c ". $L_LIB_SCRIPT; f() { L_finally -r -f echo first; L_finally -r -l echo last; L_finally -r echo normal; return 0; }; f"
	}
	{
		L_info "Test -r mixed with non-r in subprocess"
		f() {
			L_finally -r -f echo Rf
			L_finally -r -l echo Rl
			L_finally echo Ef
			L_finally -l echo El
			return 0
		}
		L_unittest_cmd -o $'Rf\nRl\nEf\nEl' bash -c ". $L_LIB_SCRIPT; f() { L_finally -r -f echo Rf; L_finally -r -l echo Rl; L_finally echo Ef; L_finally -l echo El; return 0; }; f"
	}
	{
		L_info "Test pop -i with -f in subprocess"
		f() {
			L_finally -r -f -v a echo first
			L_finally -r -v b echo normal
			L_finally_pop -i "$a"
			return 0
		}
		L_unittest_cmd -o $'first\nnormal' bash -c ". $L_LIB_SCRIPT; f() { L_finally -r -f -v a echo first; L_finally -r -v b echo normal; L_finally_pop -i \"\$a\"; return 0; }; f"
	}
}

_L_test_finally2_return_vs_exit() {
	L_info "Test return vs exit: -r items only on RETURN, non-r on EXIT"
	{
		f() {
			L_finally -r echo R
			L_finally echo E
			return 0
		}
		L_unittest_cmd -o $'R\nE' f
	}
	{
		L_info "Test exit: both -r and non-r on EXIT (no RETURN)"
		f() {
			L_finally -r echo R
			L_finally echo E
			exit
		}
		L_unittest_cmd -o $'E\nR' f
	}
	{
		L_info "Test -r -f -l return vs exit"
		f() {
			L_finally -r -f echo Rf
			L_finally -r -l echo Rl
			L_finally -f echo Ef
			L_finally -l echo El
			return 0
		}
		L_unittest_cmd -o $'Rf\nRl\nEf\nEl' f
	}
	{
		f() {
			L_finally -r -f echo Rf
			L_finally -r -l echo Rl
			L_finally -f echo Ef
			L_finally -l echo El
			exit
		}
		L_unittest_cmd -o $'Ef\nRf\nRl\nEl' f
	}
}

_L_test_finally2_complex_combinations() {
	L_info "Test complex: multiple pops in different queues"
	{
		f() {
			L_finally -r -f -v a1 echo a1
			L_finally -r -f -v a2 echo a2
			L_finally -r -v b1 echo b1
			L_finally -r -v b2 echo b2
			L_finally -r -l -v c1 echo c1
			L_finally -r -l -v c2 echo c2
			L_finally_pop -i "$a1"
			L_finally_pop -i "$c2"
			return 0
		}
		L_unittest_cmd -o $'a1\nc2\na2\nb2\nb1\nc1' f
	}
	{
		L_info "Test -s offset with nested pops"
		inner() {
			echo inner
		}
		outer() {
			L_finally -r -s 1 -f -v a echo 'outer-first-on-inner'
			L_finally -r -s 1 -l -v b echo 'outer-last-on-inner'
			inner
			L_finally_pop -i "$a"
			return 0
		}
		L_unittest_cmd -o $'inner\nouter-first-on-inner\nouter-last-on-inner' outer
	}
}

_L_test_finally2_bash_version_compat() {
	L_info "Test -f -l with \${newbash[@]} (multi-bash compatibility)"
	{
		L_unittest_cmd -o $'first\nnormal\nlast' bash -c ". $L_LIB_SCRIPT; f() { L_finally -f echo first; L_finally -l echo last; L_finally echo normal; }; f"
	}
	{
		L_unittest_cmd -o $'first\nnormal\nlast' bash -c ". $L_LIB_SCRIPT; f() { L_finally -r -f echo first; L_finally -r -l echo last; L_finally -r echo normal; return 0; }; f"
	}
	{
		L_unittest_cmd -o $'first\nnormal' bash -c ". $L_LIB_SCRIPT; f() { L_finally -r -f -v a echo first; L_finally -r -v b echo normal; L_finally_pop -i \"\$a\"; return 0; }; f"
	}
}