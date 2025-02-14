#!/usr/bin/env bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "$DIR"/L_argparse \
	-- -r --root action=store_true help='root option' \
	-- call=subparser dest=sub \
	'{' \
		name=aa description='subparser aa help' \
		-- -r --subparser_aa type=int help='optiont to subparser aa help' \
	'}' \
	'{' \
		bb description='subparser bb help' \
		-- -r --baz --subparser_bb choices='X Y Z' help='baz option to subparser bb help' \
	'}' \
	'{' \
		cc description='subparser cc help' \
		-- -r --subparser_cc help='option to subparser cc help' \
		-- ARG1 help='positional argument to subparser cc help' \
	'}' \
	'{' \
		dd description='subparser dd help' \
		-- -r --subparser_dd help='option to subparser dd help' \
		-- call=subparser dest=subsub \
		'{' \
			ee description='subparser dd ee help' \
			-- -r --subparser_dd_ee help='option to subparser dd ee help' \
		'}' \
		'{' \
			ff description='subparser dd ff help' \
			-- -r --subparser_dd_ff help='option to subparser dd ff help' \
			-- call=subparser dest=subsubsub \
			'{' \
				gg description='subparser dd ff gg help' \
				-- -r --subparser_dd_ff_gg help='option to subparser dd ff gg help' \
			'}' \
			'{' \
				hh description='subparser dd ff hh help' \
				-- -r --subparser_dd_ff_hh help='option to subparser dd ff hh help' \
			'}' \
		'}' \
	'}' \
	---- "$@"
