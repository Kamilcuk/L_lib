#!/usr/bin/env bash
# shellcheck disable=SC2178,SC2034,SC2128,SC2190

_L_test_dedent() {
	{
		L_unittest_cmd -o $'  a\n  b\nc' \
			L_dedent "    a
    b
  c"
	}
	{
		L_unittest_cmd -o $'hello\n  world\n!' \
			L_dedent "    hello
      world
    !"
	}
	{
		L_unittest_cmd -o "noindent" \
			L_dedent "noindent"
	}
	{
		L_unittest_cmd -o "" \
			L_dedent ""
	}
	{
		L_unittest_cmd -o $'a\nb' \
			L_dedent "a
b"
	}
	{
		L_unittest_cmd -o $'a\nb' \
			L_dedent "		a
		b"
	}
	{
		local result
		L_dedent -v result "    hello
      world"
		L_unittest_eq "$result" $'hello\n  world'
	}
}

_L_test_strip_ansi() {
	{
		L_unittest_cmd -o "red" \
			L_strip_ansi $'\E[31mred\E[0m'
	}
	{
		L_unittest_cmd -o "plain" \
			L_strip_ansi "plain"
	}
	{
		L_unittest_cmd -o "bold green and under" \
			L_strip_ansi $'\E[1;32mbold green\E[0m and \E[4munder\E[0m'
	}
	{
		L_unittest_cmd -o "moving" \
			L_strip_ansi $'\E[2Kmoving'
	}
	{
		local result
		L_strip_ansi -v result $'\E[31mred\E[0m'
		L_unittest_eq "$result" "red"
	}
}
