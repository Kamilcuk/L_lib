
_L_test_cache() {
	local opt i stdout cachef
	L_with_tmpfile_to cachef
	exec 100>&2
	local BASH_XTRACEFD=100
	# L_decorate L_setx L_cache
	#
	local shouldbevar=123 shouldbearray=(a b $' \t\n' "$L_SAFE_ALLCHARS")
  if ((L_HAS_ASSOCIATIVE_ARRAY)); then
  	local -A shouldbeasa=([a]=b [$' \t\n']=$' \t\n' ["$L_SAFE_ALLCHARS"]="$L_SAFE_ALLCHARS")
  fi
	#
	for opt in "" "-f$cachef"; do
		echo "USING $opt"
		{
			cachevars() {
  			var="$shouldbevar"
  			array=("${shouldbearray[@]}")
  			if ((L_HAS_ASSOCIATIVE_ARRAY)); then
  				L_asa_copy shouldbeasa asa
  				declare -p asa
  			fi
  			executed=1
			}
			L_cache $opt -r cachevars
			local asaarg=""
			if ((L_HAS_ASSOCIATIVE_ARRAY)); then
				asaarg="-sasa"
			fi
			L_decorate L_cache -T 1 -s var -s array $asaarg $opt cachevars
			#
			for i in _ _; do
				L_cache $opt -r cachevars
				for i in 1 0 0; do
					local var="" array=() executed=0
					if ((L_HAS_ASSOCIATIVE_ARRAY)); then
						local -A asa=()
					fi
					cachevars
					L_unittest_vareq var "$shouldbevar"
					L_unittest_arreq array "${shouldbearray[@]}"
					if ((L_HAS_ASSOCIATIVE_ARRAY)); then
						L_unittest_eq "${asa[a]}" "b"
						L_pretty_print asa IFS
						L_unittest_eq "${asa[" $L_TAB$L_NL"]}" $' \t\n'
						L_unittest_eq "${asa["$L_SAFE_ALLCHARS"]}" "$L_SAFE_ALLCHARS"
					fi
					L_unittest_vareq executed "$i"
				done
			done
		}
		{
			cachestdout() { echo 123; echo EXECUTED >&2; }
			L_decorate L_cache -T 1 -o $opt cachestdout
			for i in _ _; do
				L_cache $opt -r cachestdout a
				L_unittest_cmd -c -j -r EXECUTED$'\n'123 cachestdout a
				L_unittest_cmd -c -j -r "^123$" cachestdout a
				L_cache $opt -r cachestdout
				L_unittest_cmd -c -j -r EXECUTED$'\n'123 cachestdout
				L_unittest_cmd -c -j -r "^123$" cachestdout
				L_unittest_cmd -c -j -r "^123$" cachestdout
				L_unittest_cmd -c -j -r "^123$" cachestdout a
			done
		}
		{
			local ret=123
			cacheerr() { echo "$ret"; return "$ret"; }
			L_decorate L_cache $opt cacheerr
			for i in _ _; do
				L_cache $opt -r cacheerr
				ret=123
				L_unittest_cmd -c -e 123 cacheerr
				ret=1
				L_unittest_cmd -c -e 123 cacheerr
				L_unittest_cmd -c -e 123 cacheerr
			done
		}
	done
	#
	L_unittest_cmd L_cache -l
	L_unittest_cmd L_cache -f "$cachef" -l
	#
	unset -f cachevars cachestdout
}

