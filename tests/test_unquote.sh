#!/usr/bin/env bash

# shellcheck disable=SC1012
_L_test_string_unquote() {
	local IFS=' '
	L_unittest_cmd -r ".*No closing quotation '" ! L_unquote "'"
	L_unittest_cmd -r ".*No escaped character" ! L_unquote "\\"
	L_unittest_cmd -r ".*No closing quotation \"" ! L_unquote '"'
	L_unittest_cmd -r ".*No closing quotation \"" ! L_unquote '"_\"'
	L_unittest_cmd -r ".*No closing quotation [$]'" ! L_unquote "$'"
	L_unittest_cmd -r ".*No closing quotation [$]'" ! L_unquote \$\'\ \\\'
	L_unittest_cmd -o 'a' L_unquote '\a'
	L_unittest_cmd -o 'abc' L_unquote $'a\\\nb\\\nc'
	L_unittest_cmd -o $'a\nb' L_unquote $'a\nb'
	L_unittest_cmd -o $'a\nb' L_unquote -c $'#e\na #c\nb #d'
	L_unittest_cmd -o $'\na' L_unquote "'' a"
	L_unittest_cmd -o $'\na' L_unquote "\"\" a"
	L_unittest_cmd -o $'\na' L_unquote "\$'' a"
	L_unittest_cmd -o $'\n\n\n\na' L_unquote "'' \"\" '' \$'' a"
	L_unittest_cmd -o $'a\nb\nc\nd' L_unquote "'''a''' \"\"'b'\"\" \$''\$'c'\$''''\"\" d"
	L_unittest_cmd -o $'\'\\\\\na' L_unquote "$(cat <<'EOF'
	$'\'\\\\' a
EOF
	)"
	L_unittest_cmd -o $'\'a \nb\'' L_unquote "$(cat <<'EOF'
	$'\'''a ' b$'\''
EOF
	)"
	local tmp
	L_unquote -v tmp -c "$(cat <<'EOF'
	$'\n\'' '' $'\\\\' $'\\\'' "\\\\" "\\\'"
EOF
	)"
	L_unittest_arreq tmp $'\n\'' "" "\\\\" "\\'" "\\\\" "\\\\'"
	L_unquote -v tmp -c "$(cat <<'EOF'
	"" "\"" "\$\`\\\\\\\\\a"
EOF
	)"
	L_unittest_arreq tmp "" "\"" "\$\`\\\\\\\\\\a"
	L_unittest_cmd -o \$a\$\'c\ \'b%\ \\\ \\n^ L_unquote \$\'\$\'a\$\"\'c\ \'b%\ \\\ \"\\\\n\'^\'
	L_unittest_cmd -o 'c""^'$'\n''\a\naa$   ' L_unquote '$'\''c""'\''^ '\''\a'\'''\'''\''\\n'\''aa$   '\'''
	L_unittest_cmd -o \\\'\\\'\\\'\\\'\'\\\'\'\\$'\n'a L_unquote " $'\\\\\\'\\\\\\'\\\\\\''$'\\\\\\'\\'\\\\\\'\\'\\\\''' a"
	L_unittest_cmd -o $'\a\b\c\d\e\E\f\n\r\t\v\\\'\"\?\002\x03\u0004\U5\c1'$'\n'a \
		L_unquote "$(cat <<'EOF'
	$'\a\b\c\d\e\E\f\n\r\t\v\\\'\"\?\002\x03\u0004\U5\c1'  a
EOF
	)"
}

_L_test_string_unquote_security_and_edge_cases() {
	# Ensure code injection is impossible (eval doesn't execute command substitutions or variable lookups inside $'' or "" parses)
	L_with_cd_tmpdir

	# Safe test wrappers
	local parsed=()

	# Payloads that must NOT execute and create 'exploit_file'
	local -a payloads=(
		# command substitution in $'...'
		"\$(touch exploit_file)"
		"\\\\\$(touch exploit_file)"
		"\\\\\`touch exploit_file\\\\\`"
		"\$'(touch exploit_file)'"
		"'\$(touch exploit_file)'"
		"\"\$(touch exploit_file)\""
		"\\\"\$(touch exploit_file)\\\""
		"\$'\$(touch exploit_file)'"
		"\\\$'\$(touch exploit_file)'"

		# Variable expansions
		"\$foo"
		"\$HOME"
		"\"\$HOME\""
		"\$'\$HOME'"
	)

	for payload in "${payloads[@]}"; do
		L_unquote -v parsed "$payload"
		# Verify that the sentinel file was NEVER created
		L_unittest_success test ! -f exploit_file
	done

	# Additional extreme edge cases
	# 1. Multiple nested single and double quote combinations
	L_unittest_cmd -o $'foo"bar'\''baz' L_unquote '"foo\"bar'\''baz"'
	L_unittest_cmd -o $'a'\''b"c' L_unquote "'a'\''b\"c'"

	# 2. Spaces and tabs inside quotes preserving spacing
	L_unittest_cmd -o $'  spaced  ' L_unquote '"  spaced  "'
	L_unittest_cmd -o $'  spaced  ' L_unquote "'  spaced  '"
	L_unittest_cmd -o $' \t\n ' L_unquote "$' \\t\\n '"

	# 3. Unclosed quote detection and exact error verification
	L_unittest_cmd -r ".*No closing quotation \"" ! L_unquote '"hello'
	L_unittest_cmd -r ".*No closing quotation '" ! L_unquote "'hello"
	L_unittest_cmd -r ".*No closing quotation [$]'" ! L_unquote "\$'hello"

	# 4. Comments disabled vs comments enabled
	L_unittest_cmd -o '#foo' L_unquote '#foo'
	L_unittest_cmd -o '' L_unquote -c '#foo'
	L_unittest_cmd -o $'bar' L_unquote -c $'#foo\nbar'

	# 5. Empty inputs
	local empty_out=()
	L_unquote -v empty_out ""
	L_unittest_eq "${#empty_out[@]}" 0

	L_unquote -v empty_out "$''\"\"''"
	L_unittest_eq "${#empty_out[@]}" 1
	L_unittest_eq "${empty_out[0]}" ""

	L_unquote -v empty_out '"" "" ""'
	L_unittest_eq "${#empty_out[@]}" 3
	L_unittest_eq "${empty_out[0]}" ""
	L_unittest_eq "${empty_out[1]}" ""
	L_unittest_eq "${empty_out[2]}" ""

	L_unittest_cmd -o '' L_unquote "''"
	L_unittest_cmd -o "''" L_unquote -q "''"
	L_unittest_cmd -o '' L_unquote "''" "''"
	L_unittest_cmd -o "'' ''" L_unquote -q "''" "''"

	# 6. Failure exit codes are handled and propagate correctly
	L_unittest_checkexit "$L_EX_DATAERR" L_unquote '"hello'
	L_unittest_checkexit "$L_EX_DATAERR" L_unquote "'hello"
	L_unittest_checkexit "$L_EX_DATAERR" L_unquote "\$'hello"
	L_unittest_checkexit "$L_EX_DATAERR" L_unquote "\\"
}
