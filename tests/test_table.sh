
_L_test_table() {
	{
		local tmp out="\
name1 name2 name3
a     b     c
d     e     f"
		L_unittest_cmd -c -o "$out" -- L_table "name1 name2 name3" "a b c" "d e f"
		L_table -v tmp "name1 name2 name3" "a b c" "d e f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1 name2 name3
    a     b c
    d     e f"
		L_unittest_cmd -o "$out" -- L_table -R1-2 "name1 name2 name3" "a b c" "d e f"
		L_table -v tmp -R1-2 "name1 name2 name3" "a b c" "d e f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1 name2 name3
    a     b
    d"
		L_unittest_cmd -o "$out" -- L_table -R1-2 "name1 name2 name3" "a b" "d"
		L_table -v tmp -R1-2 "name1 name2 name3" "a b" "d"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1   name3
    a b
    d e f"
		L_unittest_cmd -o "$out" -- L_table -R1-2 -s, "name1,,name3" "a,b" "d,e,f"
		L_table -v tmp -R1-2 -s, "name1,,name3" "a,b" "d,e,f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
}

_L_test_table_more() {
	{
		local tmp out="\
a |b
cc|d"
		L_unittest_cmd -o "$out" -- L_table -o '|' "a b" "cc d"
		L_table -v tmp -o '|' "a b" "cc d"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		# backslash in separator must stay literal
		local tmp out='a \tb
cc\td'
		L_unittest_cmd -o "$out" -- L_table -o '\t' "a b" "cc d"
		L_table -v tmp -o '\t' "a b" "cc d"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		# percent in separator must stay literal
		local tmp out='a %sb
cc%sd'
		L_unittest_cmd -o "$out" -- L_table -o '%s' "a b" "cc d"
		L_table -v tmp -o '%s' "a b" "cc d"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		# short row after a long row, right aligned first column
		local tmp out=" a b c
dd"
		L_unittest_cmd -o "$out" -- L_table -R1 "a b c" "dd"
		L_table -v tmp -R1 "a b c" "dd"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		# empty line
		local tmp out="\
a

b"
		L_unittest_cmd -o "$out" -- L_table "a" "" "b"
		L_table -v tmp "a" "" "b"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		# tab as default separator
		local tmp out="\
a  b
cc d"
		L_unittest_cmd -o "$out" -- L_table $'a\tb' $'cc\td'
		L_table -v tmp $'a\tb' $'cc\td'
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		# single column
		local tmp out="\
a
bb"
		L_unittest_cmd -o "$out" -- L_table "a" "bb"
		L_table -v tmp "a" "bb"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		# cells are never expanded or interpreted
		local tmp out='$(echo hi) `id`
b      c'
		L_unittest_cmd -o "$out" -- L_table '$(echo hi) `id`' 'b c'
		L_table -v tmp '$(echo hi) `id`' 'b c'
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		# -v overwrites previous value
		local tmp=junk
		L_table -v tmp "a b"
		L_unittest_eq "$tmp" $'a b\n'
	}
	{
		# -X: ansi escapes do not count toward width
		local tmp out=$'\e[31mab\e[0m   c\nabcd e'
		L_unittest_cmd -o "$out" -- L_table -X $'\e[31mab\e[0m c' "abcd e"
		L_table -v tmp -X $'\e[31mab\e[0m c' "abcd e"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		# -X with right alignment (original code does not correct this case)
		local tmp out=$'  \e[31mab\e[0m c\nabcd e'
		L_unittest_cmd -o "$out" -- L_table -X -R1 $'\e[31mab\e[0m c' "abcd e"
		L_table -v tmp -X -R1 $'\e[31mab\e[0m c' "abcd e"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		# without -X: escapes count toward width
		local tmp out=$'\e[31mab\e[0m c\nabcd        e'
		L_unittest_cmd -o "$out" -- L_table $'\e[31mab\e[0m c' "abcd e"
		L_table -v tmp $'\e[31mab\e[0m c' "abcd e"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
}
