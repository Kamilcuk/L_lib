_L_test_date() {
	local d
	local -x TZ=UTC
	d=$(L_date "%Y")
	d=${d#+}
	L_unittest_cmd -e 0 L_float_cmp "$d" -ge "2024"

	d=$(L_date "%Y-%m-%d %H:%M:%S" "@0")
	d=${d#+}
	L_unittest_eq "$d" "1970-01-01 00:00:00"

	d=$(L_date "%s" "@0")
	d=${d#+}
	L_unittest_eq "$d" "0"

	if (( L_HAS_PRINTF_T )); then
		d=$(L_date "%s" -1)
		d=${d#+}
		L_unittest_cmd L_is_integer "$d"
	fi
}

_L_test_date_N() {
	if (( ! L_HAS_PRINTF_T )); then
		L_unittest_skip "No printf %T suport"
		return
	fi
	local d
	d=$(L_date '%s.%N' '@1.2345')
	L_unittest_eq "$d" "1.234500000"
	d=$(L_date '%s.%3N' '@1.2345')
	L_unittest_eq "$d" "1.234"
	d=$(L_date '%s.%6N' '@1.2345')
	L_unittest_eq "$d" "1.234500"
	d=$(L_date '%s.%f' '@1.2345')
	L_unittest_eq "$d" "1.234500"
}

_L_test_date_N_now() {
	if (( ! L_HAS_EPOCHREALTIME )) && ! _L_has_date_N; then
		L_unittest_skip "No EPOCHREALTIME or date with %N support for 'now' test"
		return
	fi
	d=$(L_date '%N')
	L_unittest_eq "${#d}" 9
}

_L_test_L_epochrealtime_and_date() {
	local -x TZ=UTC
	local epoch_usec epoch_sec d1 d2 epoch_sec_int
	L_epochrealtime_usec -v epoch_usec
	L_usec_to_sec -v epoch_sec "$epoch_usec"
	epoch_sec_int="${epoch_sec%%.*}"

	L_date -v d1 "%Y-%m-%d %H:%M:%S" "@$epoch_sec_int"
	d1=${d1#+}

	if date -u -d "@$epoch_sec_int" >/dev/null 2>&1; then
		d2=$(date -u -d "@$epoch_sec_int" +"%Y-%m-%d %H:%M:%S")
	elif date -u -r "$epoch_sec_int" >/dev/null 2>&1; then
		d2=$(date -u -r "$epoch_sec_int" +"%Y-%m-%d %H:%M:%S")
	else
		d2=""
	fi

	if [[ -n "$d2" ]]; then
		L_log "Comparing L_date output '$d1' with system date output '$d2'"
		L_unittest_eq "$d1" "$d2"
	else
		L_unittest_skip "Could not retrieve system date for timezone-independent epoch comparison"
	fi
}
