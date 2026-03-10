
_L_test_cache_file_backend() {
	local cachef
	L_with_tmpfile_to cachef
	#
	L_log "Testing L_cache with file backend: adding an entry"
	L_unittest_cmd L_cache -f "$cachef" -k mykey echo 123
	L_unittest_cmd -c -r "mykey" L_cache -f "$cachef" -l
	L_log "Testing L_cache with file backend: removing an entry"
	L_unittest_cmd L_cache -f "$cachef" -r -k mykey echo 123
	L_unittest_cmd -c -r "^empty$" L_cache -f "$cachef" -l
}

_L_test_cache_return_code() {
	local opt i
	L_with_tmpfile_to cachef
	#
	for opt in "" "-f$cachef"; do
		echo "USING $opt"
		{
			local ret=123
			cacheerr() { echo "$ret"; return "$ret"; }
			L_decorate L_cache $opt cacheerr
			for i in _ _; do
				L_cache $opt -r cacheerr
				ret=123
				L_log "Testing L_cache with return code: first run"
				L_unittest_cmd -c -e 123 cacheerr
				ret=1
				L_log "Testing L_cache with return code: cached run"
				L_unittest_cmd -c -e 123 cacheerr
				L_log "Testing L_cache with return code: cached run again"
				L_unittest_cmd -c -e 123 cacheerr
			done
		}
	done
	unset -f cacheerr
}

_L_test_cache_stdout() {
	local opt i
	L_with_tmpfile_to cachef
	#
	for opt in "" "-f$cachef"; do
		echo "USING $opt"
		{
			cachestdout() { echo 123; echo EXECUTED >&2; }
			L_decorate L_cache -T 10 -o $opt cachestdout
			for i in _ _; do
				L_unittest_cmd -c L_cache $opt -r cachestdout a
				L_log "Testing L_cache with stdout: first run"
				L_unittest_cmd -c -j -r EXECUTED$'\n'123 cachestdout a
				L_log "Testing L_cache with stdout: cached run"
				L_unittest_cmd -c -j -r "^123$" cachestdout a
				L_unittest_cmd -c L_cache $opt -r cachestdout
				L_unittest_cmd -c L_cache $opt -l
				L_log "Testing L_cache with stdout: first run without args"
				L_unittest_cmd -c -j -r EXECUTED$'\n'123 cachestdout
				L_log "Testing L_cache with stdout: cached run without args"
				L_unittest_cmd -c -j -r "^123$" cachestdout
				L_log "Testing L_cache with stdout: cached run without args again"
				L_unittest_cmd -c -j -r "^123$" cachestdout
				L_log "Testing L_cache with stdout: cached run with args again"
				L_unittest_cmd -c L_cache $opt -l
				L_unittest_cmd -c -j -r "^123$" cachestdout a
			done
		}
	done
	unset -f cachestdout
}

_L_test_cache_ttl() {
  local cachef
  L_with_tmpfile_to cachef

  # Add a cache entry with a TTL of 1 second
  L_log "Testing L_cache with TTL: adding an entry"
  L_unittest_cmd -- L_cache -f "$cachef" -T 1ms -k mykey echo 123
  L_unittest_cmd -c -r "mykey" -- L_cache -f "$cachef" -l

  # Wait for the cache entry to expire
  L_log "Testing L_cache with TTL: waiting for expiry: sleep 1.1"
  L_unittest_cmd -- sleep 0.002

  # Check that the cache entry has been removed
  L_log "Testing L_cache with TTL: checking for removal"
  L_unittest_cmd -c -r "^empty$" -- L_cache -T 1ms -f "$cachef" -l
}

_L_test_cache_vars() {
	local opt i
	L_with_tmpfile_to cachef
	#
	local shouldbevar=123 shouldbearray=(a b $' \t\n' "$L_SAFE_ALLCHARS" '*')
  if ((L_HAS_ASSOCIATIVE_ARRAY)); then
  	local -A shouldbeasa=()
  	shouldbeasa['a$%^']='*'
  	if (( L_HAS_BASH4_1 )); then
  		# Bash 4.1 really has issues with parsing associative arrays. Who cares.
  		shouldbeasa[$' \t\n']=$' \t\n'
  		shouldbeasa["$L_SAFE_ALLCHARS"]="$L_SAFE_ALLCHARS"
  	else
  		L_log "extra L_SAFE_ALLCHARS and space and tab disabled for bash 4.1, it has poor handling of associative arrays"
  	fi
		L_unittest_eq "${shouldbeasa['a$%^']}" '*'
  	if (( L_HAS_BASH4_1 )); then
			L_unittest_eq "${shouldbeasa[$' \t\n']}" $' \t\n'
			L_unittest_eq "${shouldbeasa["$L_SAFE_ALLCHARS"]}" "$L_SAFE_ALLCHARS"
		fi
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
					L_log "Testing L_cache with variables: run with executed=$i"
					cachevars
					L_unittest_vareq var "$shouldbevar"
					L_unittest_arreq array "${shouldbearray[@]}"
					if ((L_HAS_ASSOCIATIVE_ARRAY)); then
						L_unittest_eq "${asa['a$%^']}" '*'
  					if (( L_HAS_BASH4_1 )); then
							L_unittest_eq "${asa[$' \t\n']}" $' \t\n'
							L_unittest_eq "${asa["$L_SAFE_ALLCHARS"]}" "$L_SAFE_ALLCHARS"
						fi
					fi
					L_unittest_vareq executed "$i"
				done
			done
		}
	done
	unset -f cachevars
}
