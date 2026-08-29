#!/usr/bin/env bash

_L_test_parse_range_list() {
	local out=(uninin) i _exp
	{
		L_unittest_cmd -c L_parse_range_list -v out "1-4"
		L_unittest_arreq out 1 2 3 4
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out "1-4,3-5"
		L_unittest_arreq out 1 2 3 4 5
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out "5"
		L_unittest_arreq out 5
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out "5-3"
		L_unittest_arreq out 3 4 5
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out -- "-5"
		L_unittest_arreq out 1 2 3 4 5
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out "8-"
		_exp=()
		for ((i=8;i<=100;++i)); do _exp+=("$i"); done

		L_unittest_arreq out "${_exp[@]}"
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out "3-"
		_exp=()
		for ((i=3;i<=100;++i)); do _exp+=("$i"); done
		L_unittest_arreq out "${_exp[@]}"
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out -m 10 "3-"
		L_unittest_arreq out 3 4 5 6 7 8 9 10
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out "1-3,7,10-12"
		L_unittest_arreq out 1 2 3 7 10 11 12
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out "2-2,9-9"
		L_unittest_arreq out 2 9
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out "1-4,foo,3-5"
		L_unittest_arreq out 1 2 3 4 5
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out ""
		L_unittest_arreq out
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out "1-4,3-5"
		L_unittest_eq "${!out[*]}" "${out[*]}"
	}
	{
		L_unittest_cmd -c L_parse_range_list -v out "7"
		L_unittest_eq "${!out[*]}" "${out[*]}"
	}
	{
		L_unittest_cmd -o $'1\n2\n3\n4\n5' L_parse_range_list "1-5"
	}
	{
		L_unittest_cmd -c -o '' L_parse_range_list -v out "1-5"
		L_unittest_arreq out 1 2 3 4 5
	}
}
