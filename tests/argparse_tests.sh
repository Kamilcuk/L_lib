#!/bin/bash
# Argparse tests

_L_test_z_argparse01() {
	local ret tmp option storetrue storefalse store0 store1 storeconst append
	{
		L_log "check init"
		local -a parser=(
			prog=prog
			-- -t --storetrue action=store_true
			-- -f --storefalse action=store_false
			-- -0 --store0 action=store_0
			-- -1 --store1 action=store_1
			-- -c --storeconst action=store_const const=yes default=no
			-- -a --append action=append
			----
		)
		L_unittest_cmd -r 'argument' ! L_argparse "${parser[@]}" ----
		L_unittest_cmd -r 'error' ! L_argparse "${parser[@]}" --- -h
		L_unittest_cmd L_argparse "${parser[@]}" --
		L_unittest_cmd L_argparse "${parser[@]}"
		L_unittest_cmd L_argparse -- -o ----
		L_unittest_cmd L_argparse allow_abbrev=1 -- --option ---- --op 1
		L_unittest_cmd L_argparse -- --option ----
		L_unittest_cmd L_argparse -- --option ---- --option=1
		L_unittest_cmd L_argparse -- --option ---- -h
		L_unittest_cmd -r '----' ! L_argparse
		L_unittest_cmd -r '----' ! L_argparse --
		L_unittest_cmd -r '----' ! L_argparse help=123
	}
	{
		local append=()
		L_log "check defaults"
		L_unittest_cmd -c L_argparse "${parser[@]}"
		L_unittest_vareq storetrue false
		L_unittest_vareq storefalse true
		L_unittest_vareq store0 1
		L_unittest_vareq store1 0
		L_unittest_vareq storeconst no
		L_unittest_arreq append
	}
	{
		append=()
		L_log "check single"
		L_unittest_cmd -c L_argparse "${parser[@]}" -tf01ca1 -a2 -a 3
		L_unittest_vareq storetrue true
		L_unittest_vareq storefalse false
		L_unittest_vareq store0 0
		L_unittest_vareq store1 1
		L_unittest_vareq storeconst yes
		L_unittest_arreq append 1 2 3
	}
	{
		append=()
		L_log "check long"
		L_unittest_cmd -c L_argparse "${parser[@]}" --storetrue --storefalse --store0 --store1 --storeconst \
			--append=1 --append $'2\n3' --append $'4" \'5'
		L_unittest_vareq storetrue true
		L_unittest_vareq storefalse false
		L_unittest_vareq store0 0
		L_unittest_vareq store1 1
		L_unittest_vareq storeconst yes
		L_unittest_arreq append 1 $'2\n3' $'4" \'5'
	}
	{
		L_log "args"
		local arg=() ret=0
		L_unittest_failure_capture tmp -- L_argparse prog=prog -- arg nargs="+" ----
		L_unittest_contains "$tmp" "required"
		#
		local arg=()
		L_argparse prog=prog -- arg nargs="+" ---- 1
		L_unittest_arreq arg 1
		#
		local arg=()
		L_argparse prog=prog -- arg nargs="+" ---- 1 $'2\n3' $'4"\'5'
		L_unittest_arreq arg 1 $'2\n3' $'4"\'5'
	}
	{
		L_log "check help"
		L_unittest_failure_capture tmp -- L_argparse prog="ProgramName" -- arg nargs=2 ----
		L_unittest_contains "$tmp" "Usage: ProgramName"
		L_unittest_contains "$tmp" "arg arg"
	}
	{
		L_log "only short opt"
		local o=
		L_argparse prog="ProgramName" -- -o ---- -o val
		L_unittest_eq "$o" val
	}
	{
		L_log "abbrev"
		local option verbose
		L_argparse allow_abbrev=1 -- --option action=store_1 -- --verbose action=store_1 ---- --o --v --opt
		L_unittest_eq "$option" 1
		L_unittest_eq "$verbose" 1
		#
		L_unittest_cmd -r "ambiguous option: --op" -- ! \
			L_argparse allow_abbrev=1 -- --option action=store_1 -- --opverbose action=store_1 ---- --op
	}
	{
		L_log "count"
		local verbose=
		L_argparse -- -v --verbose action=count ---- -v -v -v -v
		L_unittest_eq "$verbose" 4
		local verbose=
		L_argparse -- -v --verbose action=count ---- -v -v
		L_unittest_eq "$verbose" 2
		local verbose=
		L_argparse -- -v --verbose action=count ----
		L_unittest_eq "$verbose" ""
		local verbose=
		L_argparse -- -v --verbose action=count default=0 ----
		L_unittest_eq "$verbose" "0"
	}
	{
		L_log "type"
		local tmp arg
		L_unittest_failure_capture tmp L_argparse -- arg type=int ---- a
		L_unittest_contains "$tmp" "not an integer"
	}
	{
		L_log "usage"
		L_unittest_cmd -N -- L_argparse prog=prog -- bar nargs=3 help="This is a bar argument" ---- --help
	}
	{
		L_log "required"
		L_unittest_failure_capture tmp L_argparse prog=prog -- --option required=true ----
		L_unittest_contains "$tmp" "the following arguments are required: --option"
		L_unittest_failure_capture tmp L_argparse prog=prog -- --option required=true -- --other required=true -- bar ----
		L_unittest_contains "$tmp" "the following arguments are required: --option, --other, bar"
	}
}

_L_test_z_argparse02() {
	{
		L_log "two args"
		local ret out arg1 arg2
		L_argparse -- arg1 -- arg2 ---- a1 b1
		L_unittest_eq "$arg1" a1
		L_unittest_eq "$arg2" b1
		L_argparse -- arg1 nargs=1 -- arg2 nargs='?' default=def ---- a2
		L_unittest_eq "$arg1" a2
		L_unittest_eq "$arg2" "def"
		L_argparse -- arg1 nargs=1 -- arg2 nargs='*' ---- a3
		L_unittest_eq "$arg1" a3
		L_unittest_eq "$arg2" "def"
		#
		L_unittest_failure_capture out -- L_argparse -- arg1 -- arg2 ---- a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse -- arg1 -- arg2 ---- a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse -- arg1 -- arg2 nargs='+' ---- a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse -- arg1 nargs=1 -- arg2 nargs='*' ----
		L_unittest_contains "$out" "are required: arg1"
		L_unittest_failure_capture out -- L_argparse -- arg1 nargs=1 -- arg2 nargs='+' ----
		L_unittest_contains "$out" "are required: arg1, arg2"
	}
}

_L_test_z_argparse03() {
	local foo bar count verbose filename
	{
		local count verbose filename
		L_argparse \
  		prog=ProgramName \
  		description="What the program does" \
  		epilog="Text at the bottom of help" \
  		-- filename \
  		-- -c --count \
  		-- -v --verbose action=store_1 \
  		---- -c 5 -v ./file1
  		L_unittest_eq "$count" 5
  		L_unittest_eq "$verbose" 1
  		L_unittest_eq "$filename" ./file1
	}
	{
		local tmp
		L_unittest_cmd -o "\
Usage: myprogram [-h]

Options:
  -h, --help  show this help message and exit" \
			-- L_argparse prog="myprogram" ---- -h
	}
	{
		tmp=$(L_argparse prog="myprogram" -- --foo help="foo of the myprogram program" ---- -h)
		L_unittest_eq "$tmp" "\
Usage: myprogram [-h] [--foo FOO]

Options:
  -h, --help     show this help message and exit
      --foo FOO  foo of the myprogram program"
	}
	{
		local foo bar
		L_unittest_cmd -o "\
Usage: PROG [options]

Arguments:
  bar  bar help

Options:
  -h, --help       show this help message and exit
      --foo [FOO]  foo help" \
			-- L_argparse prog=PROG usage="PROG [options]" \
			-- --foo nargs="?" help="foo help" \
			-- bar nargs="+" help="bar help" \
			---- -h
	}
	{
		L_unittest_cmd -o "\
Usage: argparse.py [-h]

A foo that bars

Options:
  -h, --help  show this help message and exit

And that's how you'd foo a bar" \
			-- L_argparse prog=argparse.py \
				description='A foo that bars' \
				epilog="And that's how you'd foo a bar" \
				---- -h
	}
	{
		local out foobar foonley
		L_unittest_failure_capture out \
			-- L_argparse prog=PROG allow_abbrev=False \
			-- --foobar action=store_true \
			-- --foonley action=store_false \
			---- --foon
		L_unittest_eq "$out" "\
Usage: PROG [-h] [--foobar] [--foonley]
PROG: error: unrecognized arguments: --foon"
	}
	{
		local foo='' bar=''
		L_argparse prog=PROG -- -f --foo -- bar ---- BAR
		L_unittest_eq "$bar" BAR
		L_unittest_eq "$foo" ""
		local foo='' bar=''
		L_argparse prog=PROG -- -f --foo -- bar ---- BAR --foo FOO
		L_unittest_eq "$bar" BAR
		L_unittest_eq "$foo" "FOO"
		local foo='' bar='' out=''
		L_unittest_failure_capture out -- L_argparse prog=PROG -- -f --foo -- bar ---- --foo FOO
		L_unittest_eq "$out" "\
Usage: PROG [-h] [-f FOO] bar
PROG: error: the following arguments are required: bar"
	}
	{
		local foo=''
		L_argparse -- --foo action=store_const const=42 ---- --foo
		L_unittest_eq "$foo" 42
		local foo='' bar='' baz=''
		L_argparse -- --foo action=store_true -- --bar action=store_false -- --baz action=store_false ---- --foo --bar
		L_unittest_eq "$foo" true
		L_unittest_eq "$bar" false
		L_unittest_eq "$baz" true
		local foo=()
		L_argparse -- --foo action=append ---- --foo 1 --foo 2
		L_unittest_arreq foo 1 2
		local foo=()
		L_argparse -- --foo action=append default='first_element "second element"' ----
		L_unittest_arreq foo "first_element" "second element"
		local types=()
		L_argparse -- --str dest=types action=append_const const=str -- --int dest=types action=append_const const=int ---- --str --int
		L_unittest_arreq types str int
		local foo=
		# bop
		local verbose=
		L_argparse -- --verbose -v action=count default=0 ---- -vvv
		L_unittest_eq "$verbose" 3
	}
	{
		local foo=() bar=''
		L_argparse -- --foo nargs=2 -- bar nargs=1 ---- c --foo a b
		L_unittest_eq "$bar" "c"
		L_unittest_arreq foo a b
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- XX --foo=YY
		L_unittest_eq "$foo" YY
		L_unittest_eq "$bar" XX
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- XX --foo
		L_unittest_eq "$foo" c
		L_unittest_eq "$bar" XX
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- --foo XX
		L_unittest_eq "$foo" c
		L_unittest_eq "$bar" XX
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ----
		L_unittest_eq "$foo" d
		L_unittest_eq "$bar" d
		local foo='' bar=''
		L_argparse -- -f --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- XX -fYY
		L_unittest_eq "$foo" YY
		L_unittest_eq "$bar" XX
		local foo='' bar=''
		L_argparse -- -f --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- -f YY
		L_unittest_eq "$foo" c
		L_unittest_eq "$bar" YY
		(
			tmpf1=$(mktemp)
			tmpf2=$(mktemp)
			trap 'rm "$tmpf1" "$tmpf2"' EXIT
			local outfile='' infile=''
			L_argparse -- infile nargs="?" type=file_r default=/dev/stdin -- outfile nargs="?" type=file_w default=/dev/stdout ---- "$tmpf1" "$tmpf2"
			L_unittest_eq "$infile" "$tmpf1"
			L_unittest_eq "$outfile" "$tmpf2"
			local outfile='' infile=''
			L_argparse -- infile nargs="?" type=file_r default=/dev/stdin -- outfile nargs="?" type=file_w default=/dev/stdout ---- "$tmpf1"
			L_unittest_eq "$infile" "$tmpf1"
			L_unittest_eq "$outfile" "/dev/stdout"
		)
		local outfile='' infile=''
		L_argparse -- infile nargs="?" type=file_r default=/dev/stdin -- outfile nargs="?" type=file_w default=/dev/stdout ----
		L_unittest_eq "$infile" "/dev/stdin"
		L_unittest_eq "$outfile" "/dev/stdout"
		# bop nargs="*"
		local foo=()
		L_argparse prog=PROG -- foo nargs="+" ---- a b
		L_unittest_arreq foo a b
		local out=''
		L_unittest_failure_capture out -- L_argparse prog=PROG -- foo nargs="+" ----
		L_unittest_eq "$out" "\
Usage: PROG [-h] foo [foo ...]
PROG: error: the following arguments are required: foo"
	}
	{
		local foo=''
		L_argparse -- --foo default=42 ---- --foo 2
		L_unittest_eq "$foo" 2
		L_argparse -- --foo default=42 ----
		L_unittest_eq "$foo" 42
		local length width
		L_unittest_cmd -c L_argparse -- --length default=10 type=int -- --width default=10.5 type=int ----
		L_unittest_eq "$length" 10
		L_unittest_eq "$width" 10.5
		local foo=''
		L_unittest_cmd -c L_argparse -- foo nargs="?" default=42 ---- a
		L_unittest_eq "$foo" a
		local foo=''
		L_unittest_cmd -c L_argparse -- foo nargs="?" default=42 ----
		L_unittest_eq "$foo" 42
		local foo=321
		L_unittest_cmd -c L_argparse -- foo nargs="?" default= ----
		L_unittest_eq "$foo" ""
	}
	{
		local move=''
		L_unittest_cmd -c L_argparse prog=game.py -- move choices="rock paper scissors" ---- rock
		L_unittest_vareq move rock
		L_unittest_cmd -o "\
Usage: game.py [-h] {rock,paper,scissors}
game.py: error: argument {rock,paper,scissors}: invalid choice: fire (choose from rock, paper, scissors)" \
			-- ! L_argparse prog=game.py -- move choices="rock paper scissors" ---- fire
	}
	{
		local foo=''
		L_unittest_cmd -c L_argparse prog=PROG -- --foo required=1 ---- --foo BAR
		L_unittest_vareq foo BAR
		L_unittest_cmd -o "\
Usage: PROG [-h] --foo FOO
PROG: error: the following arguments are required: --foo" \
			-- ! L_argparse prog=PROG -- --foo required=1 ----
	}
	{
		L_unittest_cmd -o "\
Usage: frobble [-h] [bar]

Arguments:
  bar  the bar to frobble (default: 42)

Options:
  -h, --help  show this help message and exit" \
			-- L_argparse prog=frobble -- bar nargs="?" type=int default=42 \
				help="the bar to frobble (default: 42)" ---- -h
		L_unittest_cmd -o "\
Usage: frobble [-h]

Options:
  -h, --help  show this help message and exit" \
			-- L_argparse prog=frobble -- --foo help=SUPPRESS ---- -h
	}
	{
		L_unittest_cmd -c L_argparse -- --foo -- bar ---- X --foo Y
		L_unittest_vareq foo Y
		L_unittest_vareq bar X
		L_unittest_cmd -o "\
Usage: prog [-h] [--foo FOO] bar

Arguments:
  bar

Options:
  -h, --help     show this help message and exit
      --foo FOO" \
			-- L_argparse prog=prog -- --foo -- bar ---- -h
  	}
}

if ((L_HAS_ASSOCIATIVE_ARRAY)); then
_L_test_z_argparse_A() {
	{
		declare -A dest_dict=()
		L_unittest_cmd -c \
				L_argparse prog=python.py dest_dict=dest_dict \
				-- --asome \
				-- -a action=append \
				-- dest nargs=3 \
				---- 1 1 123 --asome 1123 -a 1 -a 2 -a 3
		local -a arr="(${dest_dict[dest]})"
		L_unittest_arreq arr 1 1 123
		local -a arr="(${dest_dict[a]})"
		L_unittest_arreq arr 1 2 3
		L_unittest_eq "${dest_dict[asome]}" 1123
	}
	{
		declare -A dest_dict=()
		L_unittest_cmd -c \
				L_argparse prog=python.py dest_dict=dest_dict dest_prefix=prefix_ \
				-- --asome \
				-- -a action=append \
				-- dest nargs=3 \
				---- 1 1 123 --asome 1123 -a 1 -a 2 -a 3
		local -a arr="(${dest_dict[prefix_dest]})"
		L_unittest_arreq arr 1 1 123
		local -a arr="(${dest_dict[prefix_a]})"
		L_unittest_arreq arr 1 2 3
		L_unittest_eq "${dest_dict[prefix_asome]}" 1123
	}
}
fi

_L_test_z_argparse_dest_prefix() {
	{
		local config_a config_var
		L_unittest_cmd -c L_argparse dest_prefix=config_ -- -a flag=1 -- --var ---- -a
		L_unittest_vareq config_a 1
		L_unittest_cmd -c L_argparse dest_prefix=config_ -- -a flag=1 -- --var ---- --var abc
		L_unittest_vareq config_a 0
		L_unittest_vareq config_var abc
	}
}

_L_test_z_argparse04() {
	local foo arg
	{
		local a='' dest=()
		L_argparse prog=prog -- -a -- dest nargs="*" ---- -a 1 2 3 -a 2
		L_unittest_arreq dest 2 3
		L_unittest_eq "$a" 2
		#
		local a='' dest=()
		L_argparse prog=prog -- -a -- dest nargs=remainder ---- -a 1 2 3 -a
		L_unittest_arreq dest 2 3 -a
		L_unittest_eq "$a" 1
		#
		local a='' cmd="" args=()
		L_argparse prog=prog -- -a -- cmd nargs=1 -- args nargs=remainder ---- -a 1 cmd arg1 arg2
		L_unittest_vareq a 1
		L_unittest_vareq cmd cmd
		L_unittest_arreq args arg1 arg2
		#
		L_argparse prog=prog -- -a -- cmd nargs=1 -- args nargs=remainder ---- -a 1 cmd -h arg1 arg2
		L_unittest_vareq a 1
		L_unittest_vareq cmd cmd
		L_unittest_arreq args -h arg1 arg2
		#
		L_argparse prog=prog -- -a -- cmd nargs=1 -- args nargs=remainder ---- -a -h cmd -h -h -h
		L_unittest_vareq a -h
		L_unittest_vareq cmd cmd
		L_unittest_arreq args -h -h -h
	}
	{
		local tmp
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- -a action=append complete=filenames -- dest nargs=3 ---- --L_argparse_get_completion -a ''
		L_unittest_cmd -r dirnames -- L_argparse -- --asome -- -a action=append complete=dirnames -- dest nargs=3 ---- --L_argparse_get_completion -a ''
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs=3 ---- --L_argparse_get_completion -a b
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs=3 ---- --L_argparse_get_completion -a b c
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs="?" ---- --L_argparse_get_completion -a b
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs="?" ---- --L_argparse_get_completion --ignoreme b
		L_unittest_cmd -f L_argparse -- --asome nargs="**"
	}
	{
		L_argparse -- --foo action=store_true -- arg nargs="*" ---- a b c
		L_unittest_eq "$foo" false
		L_unittest_arreq arg a b c
		L_argparse -- --foo action=store_true -- arg nargs="*" ---- --foo a b c
		L_unittest_eq "$foo" true
		L_unittest_arreq arg a b c
	}
}

_L_test_z_argparse05() {
	{
		local foo bar baz cmd sub
		cmd=(
			L_argparse \
			-- --foo action=store_true help='foo help' \
			-- call=subparser dest=sub \
			'{' \
				name=aa description='a help' \
				-- bar type=int help='bar help' \
			'}' \
			'{' \
				bb description='b help' \
				-- --baz choices='X Y Z' help='baz help' \
			'}' \
			----
		)
		L_unittest_cmd -c "${cmd[@]}" --foo aa 1
		L_unittest_eq "$foo" true
		L_unittest_eq "$bar" 1
		L_unittest_arreq sub aa 1
		L_unittest_cmd -c "${cmd[@]}" bb --baz X
		L_unittest_arreq sub bb --baz X
		L_unittest_eq "$baz" X
		#
		L_unittest_cmd -r "plain${L_GS}aa${L_GS}a help" \
			"${cmd[@]}" --L_argparse_get_completion --foo a
		L_unittest_cmd -r \
			"plain${L_GS}X.*plain${L_GS}Y.*plain${L_GS}Z" \
			"${cmd[@]}" --L_argparse_get_completion bb --baz ''
	}
	{
		L_unittest_cmd -r 'missing.*\{' ! L_argparse -- dest=sub class=subparser ----
		L_unittest_cmd -r 'missing.*\}' ! L_argparse -- dest=sub class=subparser { ----
		L_unittest_cmd -r 'missing.*\}' ! L_argparse -- dest=sub class=subparser } ----
		L_unittest_cmd -r 'name' ! L_argparse -- dest=sub class=subparser { } ----
		L_unittest_cmd -r 'quoting' ! L_argparse -- dest=sub class=subparser { aliases="a'" } ----
		L_unittest_cmd -r 'name' ! L_argparse -- dest=sub class=subparser { a name=b } ----
	}
	{
		L_log "check argparse internal args"
		L_unittest_cmd -r '' L_argparse prog=progname ---- --L_argparse_bash_completion
	}
}

_L_test_z_argparse06_call_function() {
	local cmd
	# "'
	{
		L_log "check argparse call=function 1"
		CMD_1() { L_argparse -- --one default=default ---- "$@"; echo "1 one=$one three=$three"; return 100; }
		CMD_2() { L_argparse -- --two choices='AA AB CC' ---- "$@"; echo "2 two=$two three=$three"; }
		cmd=(L_argparse show_default=1 -- --three default= -- call=function prefix=CMD_ subcall=yes ----)
		local one two three
		L_unittest_cmd -e 100 -r "1 one=one three=" "${cmd[@]}" 1 --one one
		L_unittest_cmd -r "2 two=AA three=" "${cmd[@]}" 2 --two AA
		L_unittest_cmd -r "2 two=AB three=" "${cmd[@]}" 2 --two AB
		L_unittest_cmd -r "2 two=CC three=a" "${cmd[@]}" --three a 2 --two CC
		L_unittest_cmd -r "invalid" ! "${cmd[@]}" 2 --two DD
		L_unittest_cmd -r "plain${L_GS}AA.*plain${L_GS}AB" \
			-- "${cmd[@]}" --L_argparse_get_completion 2 --two A
		L_log "check that show_default is inherited by subparsers"
		L_unittest_cmd -r '--one.*(default: default)' "${cmd[@]}" 1 -h
		L_log "check that default works"
		L_unittest_cmd -r '1 one=default three=' -e 100 "${cmd[@]}" 1
		unset -f CMD_1 CMD_2
	}
	{
		L_log "check argparse call=function 2"
		CMD_1() { L_argparse -- --one ---- "$@"; echo "1 one=$one three=$three"; return 100; }
		CMD_2() { L_argparse -- --two choices='AA AB CC' ---- "$@"; echo "2 two=$two three=$three"; }
		cmd=(L_argparse -- --three default= -- call=function prefix=CMD_ subcall=detect ----)
		local one two three
		L_unittest_cmd -e 100 -r "1 one=one three=" "${cmd[@]}" 1 --one one
		L_unittest_cmd -r "2 two=AA three=" "${cmd[@]}" 2 --two AA
		L_unittest_cmd -r "2 two=AB three=" "${cmd[@]}" 2 --two AB
		L_unittest_cmd -r "2 two=CC three=a" "${cmd[@]}" --three a 2 --two CC
		L_unittest_cmd -r "invalid" ! "${cmd[@]}" 2 --two DD
		L_unittest_cmd -r "plain${L_GS}AA.*plain${L_GS}AB" \
			-- "${cmd[@]}" --L_argparse_get_completion 2 --two A
		unset -f CMD_1 CMD_2
	}
	if ((L_HAS_BASH4_0)); then
		local IFS=f
	fi
	{
		L_log "check argparse call=function 3 with IFS=$IFS"
		dump() {
			local OLDIFS=$IFS IFS=' '
			echo "[${FUNCNAME[*]}] option=${option:-} one=${one:-} two=${two:-} three=$three four=${four[*]:-} IFS=$(printf %q "$OLDIFS")"
			IFS=$OLDIFS
		}
		AAAaaa_bbb() { local option four; L_argparse -- --option default=default -- four ---- "$@"; dump; }
		AAAaaa_ccc() { local four;L_argparse -- four choices='eqq eww ddd' ---- "$@"; dump; }
		AAAaaa_bbb2() { echo hi; }
		AAAaaa_ccc2() { echo hi; }
		AAAbbb_ddd() { local four;L_argparse -- four type=file nargs="?" ---- "$@"; dump; }
		AAAbbb_eee() { local four;L_argparse -- four nargs="+" ---- "$@"; dump; }
		AAAbbb_ggg() { echo 'ggg do not call me'; }
		AAA_aaa() { local one; L_argparse -- -1 --one type=dir -- call=function prefix=AAAaaa_ ---- "$@"; }
		AAA_bbb() { local two; L_argparse -- -2 --two choices='AA AB CC' -- call=function prefix=AAAbbb_ ---- "$@"; }
		AAA_fff() { echo 'fff do not call me'; }
		AAA_hhh() { : <<EOF
			docs
EOF
			L_argparse ---- "$@"
			wrapper;
		}
		local three argparse=(L_argparse show_default=1 -- -3 --three default= -- call=function prefix=AAA_ ----)
		#
		L_log "argparse6 check is_ok_to_call detection"
		local _L_opt_prefix=("") _L_opti=0 _L_opt_subcall=("detect")
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAAaaa_bbb
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAAaaa_ccc
		L_unittest_cmd ! _L_argparse_sub_function_is_ok_to_call AAAaaa_bbb2
		L_unittest_cmd ! _L_argparse_sub_function_is_ok_to_call AAAaaa_ccc2
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAAbbb_ddd
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAAbbb_eee
		L_unittest_cmd ! _L_argparse_sub_function_is_ok_to_call AAAbbb_ggg
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAA_aaa
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAA_bbb
		L_unittest_cmd ! _L_argparse_sub_function_is_ok_to_call AAA_fff
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAA_hhh
		unset _L_opt_prefix _L_opti _L_opt_subcall
		#
		L_log "argparse6 check calls"
		L_unittest_cmd -r "three= four=123" "${argparse[@]}" aaa bbb 123
		L_unittest_cmd -r "one=/tmp two= three=three four=ddd" "${argparse[@]}" -3 three aaa -1 /tmp ccc ddd
		L_unittest_cmd -r "does not exists" ! "${argparse[@]}" -3 three aaa -1 fdsa ccc ddd
		L_unittest_cmd -r "unrecognized option" ! "${argparse[@]}" aaa -2 ccc
		L_unittest_cmd -r "unrecognized option" ! "${argparse[@]}" bbb -1 ddd
		L_unittest_cmd -r "required" ! "${argparse[@]}" aaa bbb
		L_unittest_cmd -r "invalid choice" ! "${argparse[@]}" aaa ccc 123
		L_unittest_cmd -r "unrecognized command" ! "${argparse[@]}" aaa ddd
		L_unittest_cmd -r "one= two= three= four=" "${argparse[@]}" bbb ddd
		L_unittest_cmd -r "file" ! "${argparse[@]}" bbb ddd /tmp
		L_unittest_cmd -r "four=/dev/stdout" "${argparse[@]}" bbb ddd /dev/stdout
		L_unittest_cmd -r "four=a b c d" "${argparse[@]}" bbb eee a b c d
		#
		L_log "argparse6 check subparser completion is ok"
		L_unittest_cmd -r "plain${L_GS}aaa.*plain${L_GS}bbb" "${argparse[@]}" --L_argparse_get_completion ''
		L_unittest_cmd -r "directory" "${argparse[@]}" --L_argparse_get_completion aaa -1 ''
		L_unittest_cmd -r "plain${L_GS}bbb.*plain${L_GS}bbb2" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' b
		L_unittest_cmd -r "plain${L_GS}ccc.*plain${L_GS}ccc2" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' c
		L_unittest_cmd -r "plain${L_GS}eqq.*plain${L_GS}eww.*plain${L_GS}ddd" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' ccc ''
		L_unittest_cmd -r "plain${L_GS}eqq.*plain${L_GS}eww" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' ccc 'e'
		L_unittest_cmd -r "^$" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' ccc 'ek'
		L_unittest_cmd -r "plain${L_GS}eqq" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' ccc 'eq'
		L_unittest_cmd -r "filenames" "${argparse[@]}" --L_argparse_get_completion bbb -1 -invalid ddd ''
		L_unittest_cmd -r "plain${L_GS}ddd" "${argparse[@]}" --L_argparse_get_completion bbb ddd
		L_unittest_cmd -r "^$" "${argparse[@]}" --L_argparse_get_completion bbb ddde
		L_unittest_cmd -r "filenames" "${argparse[@]}" --L_argparse_get_completion bbb -1 -invalid --option=bla ddd '/dev/fd/'
		#
		L_log "argparse6 check completion of subparsers is ok"
		L_unittest_cmd -r "fff do not call me" "${argparse[@]}" fff
		L_unittest_cmd -r "ggg do not call me" "${argparse[@]}" bbb ggg
		L_unittest_cmd -r "plain${L_GS}fff" "${argparse[@]}" --L_argparse_get_completion fff
		L_unittest_cmd -r "plain${L_GS}ggg" "${argparse[@]}" --L_argparse_get_completion bbb ggg
		L_unittest_cmd -r "^$" "${argparse[@]}" --L_argparse_get_completion fff ''
		L_unittest_cmd -r "^$" "${argparse[@]}" --L_argparse_get_completion bbb ggg ''
		L_unittest_cmd -r "^plain${L_GS}-h.*plain${L_GS}--help$" "${argparse[@]}" --L_argparse_get_completion hhh ''
		L_unittest_cmd -r "^$" "${argparse[@]}" --L_argparse_get_completion hh ''
		#
		L_log "argparse6 check default is inherited"
		L_unittest_cmd -jr "-3, --three THREE.*\(default: ''\)" "${argparse[@]}" -h
		L_unittest_cmd -jr "--option OPTION.*\(default: default\)" "${argparse[@]}" aaa bbb -h
		#
		unset -f dump AAAaaa_bbb AAAaaa_ccc AAAbbb_ddd AAAbbb_eee AAA_aaa AAA_bbb AAAaaa_bbb2 AAAaaa_ccc2
	}
}

_L_test_z_argparse07_custom_prefix() {
	{
		L_log "check argparse prefix_chars"
		local o
		local c=(prefix_chars='-+' -- +o flag=1 -- -o flag=0 ----)
		L_argparse "${c[@]}"
		L_unittest_vareq o 1
		L_argparse "${c[@]}" +o
		L_unittest_vareq o 1
		L_argparse "${c[@]}" +o -o
		L_unittest_vareq o 0
		#
		local o question option
		local c=(prefix_chars='/' -- /o flag=1 -- /? dest=question flag=1 -- /option ----)
		L_argparse "${c[@]}"
		L_unittest_vareq o 0
		L_unittest_vareq question 0
		L_argparse "${c[@]}" /o
		L_unittest_vareq o 1
		L_unittest_vareq question 0
		L_argparse "${c[@]}" /o /?
		L_unittest_vareq o 1
		L_unittest_vareq question 1
		L_argparse "${c[@]}" /o /? /option c
		L_unittest_vareq o 1
		L_unittest_vareq question 1
		L_unittest_vareq option c
	}
	{
		L_log "check argparse has errors on invalid"
		L_unittest_cmd -r 'error' ! L_argparse -- -"option with space" ---- -h
		L_unittest_cmd -r 'error' ! L_argparse -- --"option with space" ---- -h
		L_unittest_cmd -r 'error' ! L_argparse -- arg twice ---- -h
		L_unittest_cmd -r 'error' ! L_argparse -- --option$'\n'newline ---- -h
		L_unittest_cmd -r 'error' ! L_argparse -- --option$'\t'tab ---- -h
		L_unittest_cmd -r 'error' ! L_argparse -- --option dest='in valid' ---- -h
	}
}

_L_test_z_argparse08_one_dash_long_option() {
	{
		local o option
		L_argparse -- -o -- -option ----
		L_unittest_vareq o ''
		L_unittest_vareq option ''
		L_argparse -- -o -- -option ---- -option arg
		L_unittest_vareq o ''
		L_unittest_vareq option arg
		L_argparse -- -o default= -- -option default= ---- -o arg
		L_unittest_vareq o arg
		L_unittest_vareq option ''
		L_argparse allow_abbrev=1 -- -o default= -- -option default= ---- -opt arg
		L_unittest_vareq o ''
		L_unittest_vareq option arg
		L_argparse -- -o default= -- -option default= ---- -o pt -option arg
		L_unittest_vareq o pt
		L_unittest_vareq option arg
		local p t o
		L_argparse -- -p flag=1 -- -t flag=1 -- -o flag=1 -- -option default= ---- -pto -option a
		L_unittest_vareq p 1
		L_unittest_vareq t 1
		L_unittest_vareq o 1
		L_unittest_vareq option a
	}
}

_L_test_z_argparse09_time_profile() {
	local time uv
	uv=$L_DIR/argparse_uv.sh
	check() {
		local time output
		output=$(
			TIMEFORMAT="%R"
			{ time "$uv" "$@" ;} 2>&1
		)
		L_unittest_cmd L_regex_match "$output" "Options:"
		time=${output//*$'\n'}
		echo "$time"
		L_unittest_cmd L_float_cmp "$time" -gt 0.1
		L_unittest_cmd L_float_cmp "$time" -lt 3
	}
	check -h
	check run -h
}

_L_test_z_argparse10_remainder() {
	{
		local cmd args
		L_log "test that when the nargs=remainder is the second argument then you can start wiht a dash -"
		L_argparse -- cmd -- args nargs=remainder ---- a -v -h
		L_unittest_vareq cmd a
		L_unittest_arreq args -v -h
	}
}

_L_test_z_argparse11_action_store_1null() {
	{
		L_log "check action=store_1null"
		local foo bar
		L_argparse -- --foo action=store_1null ----
		L_unittest_vareq foo ""
		L_argparse -- --foo action=store_1null ---- --foo
		L_unittest_vareq foo 1
		#
		local baz
		L_argparse -- --baz action=store_1null default=default ----
		L_unittest_vareq baz default
	}
}

_L_test_z_argparse12_action_eval() {
	{
		L_log "check action=eval"
		local foo=0
		L_argparse -- --foo eval='((foo++))' ---- --foo --foo --foo
		L_unittest_eq "$foo" 3
		local bar
		L_argparse -- --bar eval='bar=${bar:-init}' ---- --bar
		L_unittest_vareq bar "init"
	}
}

_L_test_z_argparse13_validate() {
	{
		L_log "check validate"
		local num
		L_unittest_failure_capture tmp -- L_argparse -- --num validate='[[ "$1" =~ ^[0-9]+$ ]]' ---- --num abc
		L_unittest_contains "$tmp" "invalid"
		L_argparse -- --num validate='[[ "$1" =~ ^[0-9]+$ ]]' ---- --num 123
		L_unittest_vareq num 123
	}
}

_L_test_z_argparse15_float_type() {
	{
		L_log "check type=float"
		local num
		L_unittest_failure_capture tmp -- L_argparse -- --num type=float ---- --num abc
		L_unittest_contains "$tmp" "not a float"
		L_argparse -- --num type=float ---- --num 3.14
		L_unittest_vareq num 3.14
		L_argparse -- --num type=float ---- --num -2.5
		L_unittest_vareq num -2.5
	}
}

_L_test_z_argparse16_nonnegative_positive() {
	{
		L_log "check type=nonnegative and type=positive"
		local num
		L_unittest_failure_capture tmp -- L_argparse -- --num type=nonnegative ---- --num -1
		L_unittest_contains "$tmp" "lower than 0"
		L_argparse -- --num type=nonnegative ---- --num 0
		L_unittest_vareq num 0
		L_argparse -- --num type=nonnegative ---- --num 5
		L_unittest_vareq num 5
		#
		L_unittest_failure_capture tmp -- L_argparse -- --num type=positive ---- --num 0
		L_unittest_contains "$tmp" "lower than 0"
		L_unittest_failure_capture tmp -- L_argparse -- --num type=positive ---- --num -1
		L_unittest_contains "$tmp" "lower than 0"
		L_argparse -- --num type=positive ---- --num 1
		L_unittest_vareq num 1
	}
}

_L_test_z_argparse17_metavar() {
	{
		L_log "check metavar"
		local out
		L_unittest_cmd -r "Usage: prog \[-h\] \[--num NUM\]" -- L_argparse prog=prog -- --num metavar=NUM ---- -h
	}
}

_L_test_z_argparse18_color() {
	{
		L_log "check color"
		local out
		out=$(L_argparse color=0 prog=prog ---- -h 2>&1)
		L_unittest_cmd ! L_regex_match "$out" $'\033'
	}
}

_L_test_z_argparse20_allow_subparser_abbrev() {
	{
		L_log "check allow_subparser_abbrev"
		local cmd
		L_argparse -- call=subparser dest=cmd \
			{ name=clone help="Clone" } \
			{ name=commit help="Commit" } \
			---- clone
		L_unittest_vareq cmd clone
	}
}

_L_test_z_argparse21_unknown_args() {
	{
		L_log "check unknown_args="
		local verbose extra=()
		L_argparse unknown_args=extra -- -v --verbose action=store_true ---- -v --unknown value positional
		L_unittest_vareq verbose true
		L_unittest_arreq extra --unknown value positional
	}
	{
		local foo extra=()
		L_argparse unknown_args=extra -- --foo ---- --foo bar --unknown1 --unknown2 value
		L_unittest_vareq foo bar
		L_unittest_arreq extra --unknown1 --unknown2 value
	}
	{
		local extra=()
		L_argparse unknown_args=extra -- arg ---- knownarg
		L_unittest_vareq arg knownarg
		L_unittest_arreq extra
	}
	{
		local extra=()
		L_unittest_failure_capture tmp -- L_argparse -- arg ---- --unknown
		L_unittest_contains "$tmp" "unrecognized arguments"
	}
}

_L_test_z_argparse22_fromfile_prefix_chars() {
	{
		L_log "check fromfile_prefix_chars="
		local tmpfile=$(mktemp)
		echo -e "arg1\narg2\narg3" > "$tmpfile"
		local arg1 arg2 arg3
		L_argparse fromfile_prefix_chars=@ -- arg1 -- arg2 -- arg3 ---- "@$tmpfile"
		L_unittest_vareq arg1 arg1
		L_unittest_vareq arg2 arg2
		L_unittest_vareq arg3 arg3
		rm "$tmpfile"
	}
	{
		local tmpfile=$(mktemp)
		echo "--verbose" > "$tmpfile"
		echo "value" >> "$tmpfile"
		local verbose value
		L_argparse fromfile_prefix_chars=@ -- -v --verbose action=store_true -- --value ---- "@$tmpfile"
		L_unittest_vareq verbose true
		L_unittest_vareq value value
		rm "$tmpfile"
	}
	{
		local tmpfile=$(mktemp)
		echo "line1" > "$tmpfile"
		echo "line2 with space" >> "$tmpfile"
		local args=()
		L_argparse fromfile_prefix_chars=@ -- args nargs=+ ---- "@$tmpfile"
		L_unittest_arreq args line1 "line2 with space"
		rm "$tmpfile"
	}
}

_L_test_z_argparse23_shell_completion_scripts() {
	{
		L_log "check --L_argparse_complete_bash"
		local out
		out=$(L_argparse prog=testprog -- -v --verbose action=store_true -- arg ---- --L_argparse_complete_bash 2>&1)
		L_unittest_contains "$out" "complete"
		L_unittest_contains "$out" "test_sh"
	}
	{
		L_log "check --L_argparse_zsh_completion"
		local out
		out=$(L_argparse prog=testprog -- -v --verbose action=store_true -- arg ---- --L_argparse_zsh_completion 2>&1)
		L_unittest_contains "$out" "#compdef"
		L_unittest_contains "$out" "test.sh"
	}
	{
		L_log "check --L_argparse_fish_completion"
		local out
		out=$(L_argparse prog=testprog -- -v --verbose action=store_true -- arg ---- --L_argparse_fish_completion 2>&1)
		L_unittest_contains "$out" "testprog"
	}
	{
		L_log "check --L_argparse_completion_help"
		local out
		out=$(L_argparse prog=testprog -- -v --verbose action=store_true ---- --L_argparse_completion_help 2>&1)
		L_unittest_contains "$out" "bash"
	}
	{
		L_log "check --L_argparse_print_usage"
		local out
		out=$(L_argparse prog=testprog -- -v --verbose action=store_true ---- --L_argparse_print_usage 2>&1)
		L_unittest_contains "$out" "Usage:"
		L_unittest_contains "$out" "testprog"
	}
	{
		L_log "check --L_argparse_print_help"
		local out
		out=$(L_argparse prog=testprog -- -v --verbose action=store_true ---- --L_argparse_print_help 2>&1)
		L_unittest_contains "$out" "Usage:"
		L_unittest_contains "$out" "Options:"
		L_unittest_contains "$out" "testprog"
	}
}

_L_test_z_argparse24_append_const() {
	{
		L_log "check action=append_const"
		local types=()
		L_argparse -- --str dest=types action=append_const const=str -- --int dest=types action=append_const const=int ---- --str --int
		L_unittest_arreq types str int
	}
	{
		local types=()
		L_argparse -- --str dest=types action=append_const const=str -- --int dest=types action=append_const const=int ---- --str --str --int --int
		L_unittest_arreq types str str int int
	}
	{
		local types=()
		L_argparse -- --str dest=types action=append_const const=str default='a b' ----
		L_unittest_arreq types a b
	}
	{
		local types=()
		L_argparse -- --str dest=types action=append_const const=str ----
		L_unittest_arreq types
	}
}
