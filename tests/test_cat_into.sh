_L_test_cat_into_1() {
	{
		local var=""
		L_cat_into var <<'EOF'
hello
world
EOF
		# Default behavior: trailing newlines are preserved
		L_unittest_eq "$var" $'hello\nworld\n'
	}
	{
		local var=""
		L_cat_into var <<'EOF'
line1

line3
EOF
		L_unittest_eq "$var" $'line1\n\nline3\n'
	}
	{
		local var="old"
		L_cat_into var <<<"new"
		L_unittest_eq "$var" $'new\n'
	}
	{
		local var=""
		L_cat_into var < /dev/null
		L_unittest_eq "$var" ""
	}
	{
		local var=""
		L_cat_into -n var <<'EOF'
hello
world

EOF
		# With -n, trailing newlines are stripped
		L_unittest_eq "$var" $'hello\nworld'
	}
}

_L_test_cat_into_2() {
	{
		local var=""
		L_cat_into -u 3 var 3<<'EOF'
fd content
EOF
		L_unittest_eq "$var" $'fd content\n'
	}
	{
		local var=""
		L_cat_into -n -u 3 var 3<<'EOF'
fd content with newline

EOF
		L_unittest_eq "$var" $'fd content with newline'
	}
}

_L_test_cat_into_invalid() {
	{
		L_unittest_checkexit 64 L_cat_into
	}
	{
		L_unittest_checkexit 64 L_cat_into var1 var2
	}
	{
		L_unittest_checkexit 64 L_cat_into "invalid name" <<<"hello"
	}
}
