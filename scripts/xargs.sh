#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")"/../bin/L_lib.sh
if ! L_is_main; then return; fi

L_log_configure -L

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




