#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")"/../bin/L_lib.sh

python_split() {
	# Python wrongly handles "\$" as ['\$'], but it should be ['$']
	# See https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
	# 'The <backslash> shall retain...'
	python -c "$(cat <<'EOF'
import sys, shlex
try:
 print(" ".join(shlex.split(sys.argv[1])))
except Exception as e:
 print(e)
 exit(2)
EOF
)" "$1"
}

L_argparse \
	description="
Program created to test L_str_split function
" \
	-- -r --repeat default=400 type=int \
	-- -v --verbose action=count default=0 \
	-- args nargs="*" default= \
	---- "$@"

if ((${#args[@]})); then
	python_split "${args[@]}" || :
	time L_setx L_str_split "${args[@]}"
	if [[ -v a ]]; then declare -p a; fi
	exit
fi

for ((i=0;i<repeat;++i)); do
	data="$(shuf -e -n 10 -r "'" "'" '$' '$' "'" "'" " " " " " " '"' '"' '^' '%' '\\n' "\\" 1 2 3 x | tr -d '\n') "
	#
	data="${data//\$[\"\$0-9a-z]}"
	#
	echo
	/bin/printf "INPUT: %q\n" "$data"
	L_exit_to myexit L_str_split -v tmp "$data"
	if ((myexit == 0)); then
		my=$(L_quote_bin_printf "${tmp[@]}")
	else
		my=""
	fi
	if [[ "$data" == *\$[\"\$a-z]* ]]; then
		if ((verbose)); then
			echo "$my"
		fi
	else
		shouldbexit=0
		shouldbe=$( (eval L_quote_bin_printf "$data") ) || shouldbexit=$?
		if [[ ! (
			( "$myexit" == 0 && "$shouldbexit" == 0 && "$my" == "$shouldbe" ) ||
			( "$myexit" != 0 && "$shouldbexit" != 0 )
		) ]]; then
			echo "ERROR"
			diff <(cat <<<"$shouldbe") - <<<"$my"
			exit
		elif ((verbose)); then
			echo "IS OK $myexit $shouldbexit: $my"
		fi
	fi
done

for ((i=0;i<repeat;++i)); do
	data=$(shuf -e -- a b c d "\\" '"' '"' "'" "'" " " " " " " " " | tr -d '\n')
	/bin/printf "INPUT: %q\n" "$data"
	pythonexit=0
	python=$(python_split "$data") || pythonexit=$?
	myexit=0
	my=$(L_str_split -v a -A "$data" 2>&1 && echo "${a[@]}") || myexit=$?
	if ((verbose)); then
		if [[ "$pythonexit$python" != "$myexit$my" ]]; then
			diff <(/bin/printf "%q\n" "$pythonexit" "$python") <(/bin/printf "%q\n" "$myexit" "$my") || :
		else
			/bin/printf "%q\n" "$myexit" "$my"
		fi
	fi
	if [[ ! (
			( "$myexit" == 0 && "$pythonexit" == 0 && "$python" == "$my" ) ||
			( "$myexit" != 0 && "$pythonexit" != 0 && (
				( "$python" == "No closing quotation"* && "$my" == "No closing quotation"* ) ||
				( "$python" == "No escaped character" && "$my" == 'No closing quotation "' ) ||
				( "$python" == "No escaped character" && "$my" == 'No escaped character' )
			) )
	) ]]; then
		echo "ERROR"
		sdiff <(/bin/printf "%q\n" "$pythonexit" "$python") <(/bin/printf "%q\n" "$myexit" "$my")
		exit
	fi
done


# time L_str_split -c "$(cat <<EOF
# # fdsa
# ()
# bla # bla
# fdas
# EOF
# )"
