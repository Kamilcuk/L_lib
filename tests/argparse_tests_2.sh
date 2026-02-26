
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
		L_unittest_vareq a ''
		L_unittest_vareq b ''
		L_unittest_vareq d ''
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
		L_unittest_cmd -c L_argparse "${parser[@]}" -abd --foo bar positional_arg
		L_unittest_vareq a 1
		L_unittest_vareq b 1
		L_unittest_vareq d 1
		L_unittest_arreq extra --foo bar positional_arg
	}
}

_L_test_z_argparse27_nested_subparsers() {
	{
		L_log "check nested sub-parser variable assignments"
		local verbose command remote_name remote_command name url
		local parser=(
			prog="mygit"
			-- -v --verbose action=store_true
			-- call=subparser dest=command
			"{"
				name=remote
				-- -r --remote-name default="origin"
				-- call=subparser dest=remote_command
				"{"
					name=add
					-- name default=""
					-- url default=""
				"}"
				"{"
					name=remove
					-- name default=""
				"}"
			"}"
			----
		)

		# Execute the parser with nested sub-commands and options at each level
		L_unittest_cmd -c L_argparse "${parser[@]}" \
			-v remote --remote-name test-remote add final-name http://example.com

		# Assert that all variables from all levels are correctly assigned
		L_unittest_vareq verbose true
		L_unittest_vareq command remote
		L_unittest_vareq remote_name "test-remote"
		L_unittest_vareq remote_command add
		L_unittest_vareq name "final-name"
		L_unittest_vareq url "http://example.com"
	}
}

_L_test_z_argparse28_nested_subparsers_positional() {
	local command remote_command remote_name url r
	{
		L_log "check nested sub-parser positional variable assignments"
		# local variables must be declared for the test to be able to check them
		local parser=(
			prog="mygit"
			-- call=subparser dest=command
			"{"
				name=remote
				-- -r flag=1
				-- call=subparser dest=remote_command
				"{"
					name=add
					-- remote_name
				"}"
			"}"
			----
		)

		# Execute the parser with a positional argument for the nested sub-command
		L_unittest_cmd -c L_argparse "${parser[@]}" remote add my-remote-name

		# Assert that variables from the sub-sub-parser are correctly assigned
		L_unittest_vareq command remote
		L_unittest_vareq remote_command add
		L_unittest_vareq remote_name "my-remote-name"
	}
	{

		local command="" remote_command="" remote_name="" url=""
		# Execute the parser with a positional argument for the nested sub-command
		L_unittest_cmd -c L_argparse "${parser[@]}" remote -r add my-remote-name

		# Assert that variables from the sub-sub-parser are correctly assigned
		L_unittest_vareq command remote
		L_unittest_vareq remote_command add
		L_unittest_vareq remote_name "my-remote-name"
	}
}
