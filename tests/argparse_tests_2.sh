
_L_test_z_argparse26_multiple_boolean_and_unknown_args() {
	{
		L_log "check multiple boolean options and unrecognized combined short option"
		local a b d out
		local parser=(
			-- -a flag=1
			-- -b flag=1
			-- -d flag=1
			----
		)

		# Test combined short options, with 'c' being unrecognized
		L_unittest_failure_capture out -- L_argparse "${parser[@]}" -abcd
		L_unittest_contains "$out" "unrecognized option -c in -abcd"
	}
	{
		L_log "check multiple boolean options and unrecognized combined short option with unknown_args"
		local a b d out extra=()
		local parser=(
			unknown_args=extra
			-- -a flag=1
			-- -b flag=1
			-- -d flag=1
			----
		)

		# Test with actual unknown arguments and a recognized combined short option
		L_unittest_cmd -c L_argparse "${parser[@]}" -abcd --foo bar positional_arg
		L_unittest_vareq a 1
		L_unittest_vareq b 1
		# -c is unknown arg, so we add -c followed by any potential argument, so d.
		# altough -d is known, -c is not known, and it is first, so takes precedence.
		# I think this is easy to implement and sane.
		L_unittest_arreq extra -cd --foo bar positional_arg
	}
}
