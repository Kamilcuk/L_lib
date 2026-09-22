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

_L_test_z_argparse37_special_chars() {
	{
		L_log "check options with globbing/special characters like * and ?"
		L_with_cd_tmpdir
		local star_val="" question_val=""
		touch -- --file-matching-glob
		L_argparse \
			-- "--*" help="Option with star" dest=star_val \
			-- "--?" help="Option with question mark" dest=question_val \
			---- "--*" "star_data" "--?" "question_data"
		L_unittest_vareq star_val "star_data"
		L_unittest_vareq question_val "question_data"
	}
}

_L_test_z_argparse38_prefix_chars_star() {
	{
		L_log "check argparse prefix_chars='*' with wildcard matching prefix"
		L_with_cd_tmpdir
		local star_flag=0 long_flag=0
		touch -- file_ending_with_o option_file
		local c=(
			prefix_chars='*'
			-- "*o" dest=star_flag flag=1
			-- "**option" dest=long_flag flag=1
			----
		)
		L_argparse "${c[@]}" "*o"
		L_unittest_vareq star_flag 1
		L_unittest_vareq long_flag 0
		star_flag=0
		L_argparse "${c[@]}" "**option"
		L_unittest_vareq star_flag 0
		L_unittest_vareq long_flag 1
	}
}
