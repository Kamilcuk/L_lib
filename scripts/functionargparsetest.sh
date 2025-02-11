#!/usr/bin/env bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
C_aa_help='subparser aa help'
C_aa() {
	L_argparse description="$C_aa_help" \
		-- -r --subparser_aa type=int help='optiont to subparser aa help' \
		---- "$@"
}
C_bb_help='subparser bb help'
C_bb() {
	L_argparse description="$C_bb_help" \
		-- -r --baz --subparser_bb choices='X Y Z' help='baz option to subparser bb help' \
		---- "$@"
}
C_cc_help='subparser cc help'
C_cc() {
	L_argparse description="$C_cc_help" \
		-- -r --subparser_cc help='option to subparser cc help' \
		-- ARG1 help='positional argument to subparser cc help' \
		---- "$@"
}
C_dd_help='subparser dd help'
C_dd() {
	L_argparse description="$C_dd_help" \
		-- -r --subparser_dd help='option to subparser dd help' \
		-- call=function dest=subsub prefix=Cdd_ \
		---- "$@"
}
Cdd_ee_help='subparser dd ee help'
Cdd_ee() {
	L_argparse description="$Cdd_ee_help" \
		-- -r --subparser_dd_ee help='option to subparser dd ee help' \
		---- "$@"
}
Cdd_ff_help='subparser dd ff help'
Cdd_ff() {
	L_argparse description="$Cdd_ff_help" \
		-- -r --subparser_dd_ff help='option to subparser dd ff help' \
		-- call=function dest=subsubsub prefix=Cddff_ \
		---- "$@"
}
Cddff_gg_help='subparser dd ff gg help'
Cddff_gg() {
	L_argparse description="$Cddff_gg_help" \
		-- -r --subparser_dd_ff_gg help='option to subparser dd ff gg help' \
		---- "$@"
}
Cddff_hh_help='subparser dd ff hh help'
Cddff_hh() {
	L_argparse description="$Cddff_hh_help" \
		-- -r --subparser_dd_ff_hh help='option to subparser dd ff hh help' \
		---- "$@"
}
. "$DIR"/L_argparse \
	-- -r --root action=store_true help='root option' \
	-- call=function dest=sub prefix=C_ \
	---- "$@"
