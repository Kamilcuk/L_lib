#!/usr/bin/env bash

_L_test_z_argparse35_allow_subparser_abbrev_on_subparser() {
	{
		L_log "check allow_abbrev on subparser"
		local cmd
		L_argparse -- call=subparser dest=cmd allow_abbrev=1 \
			{ name=clone help="Clone" } \
			{ name=commit help="Commit" } \
			---- clo
		L_unittest_vareq cmd clo
	}
}

_L_test_z_argparse36_default_subparser() {
	{
		L_log "check default subparser"
		local sub
		cmd=(
			L_argparse
			-- call=subparser dest=sub default=aa
			'{'
				name=aa description='a help'
				-- bar type=int help='bar help' default=123
			'}'
			'{'
				bb description='b help'
				-- --baz choices='X Y Z' help='baz help'
			'}'
			----
		)
		L_unittest_cmd -c "${cmd[@]}"
		L_unittest_vareq sub aa
		L_unittest_vareq bar 123
	}
}
