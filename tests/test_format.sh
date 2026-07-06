#!/usr/bin/env bash
# shellcheck disable=SC2178,SC2034,SC2128,SC2190

_L_test_format() {
	{
		local name=John
		local age=21
		L_unittest_cmd -o "Hello, John! You are         21 years old." \
			L_percent_format "Hello, %(name)s! You are %(age)10s years old.\n"
		L_unittest_cmd -o "Hello, %John! You are %%        21 years old." \
			L_percent_format "Hello, %%%(name)s! You are %%%%%(age)10s years old.\n"
		L_unittest_cmd -o "Hello, John! You are         21 years old." \
			L_fstring 'Hello, {name}! You are {age:10s} years old.\n'
		L_unittest_cmd -o "Hello, {John}! You are {{        21}} years old." \
			L_fstring 'Hello, {{{name}}}! You are {{{{{age:10s}}}}} years old.\n'
	}
	{
		L_unittest_cmd -o "21" \
			L_percent_format "%(age)s"
		L_unittest_cmd -o "21 " \
			L_percent_format "%(age)s "
		L_unittest_cmd -o " 21" \
			L_percent_format " %(age)s"
		L_unittest_cmd -o "21" \
			L_fstring "{age}"
		L_unittest_cmd -o "21" \
			L_fstring "{age:}"
		L_unittest_cmd -o "21" \
			L_fstring "{age:d}"
		L_unittest_cmd -o " 21" \
			L_fstring " {age:d}"
		L_unittest_cmd -o "21 " \
			L_fstring "{age:d} "
		L_unittest_cmd -o "{" \
			L_fstring "{{"
		L_unittest_cmd -o "}" \
			L_fstring "}}"
		L_unittest_cmd -o "%%%" \
			L_fstring "%%%"
	}
	{
		L_unittest_cmd -r 'invalid' ! L_percent_format "%(age)"
		L_unittest_cmd -r 'invalid' ! L_percent_format "%()"
		L_unittest_cmd -r 'invalid' ! L_percent_format "%("
		L_unittest_cmd -r 'invalid' ! L_percent_format "%)d"
		L_unittest_cmd -r 'invalid' ! L_percent_format "%"
		L_unittest_cmd -r 'invalid' ! L_fstring "{age"
		L_unittest_cmd -r 'invalid' ! L_fstring "age}"
		L_unittest_cmd -r 'invalid' ! L_fstring "{}"
		L_unittest_cmd -r 'invalid' ! L_fstring "{:}"
		L_unittest_cmd -r 'invalid' ! L_fstring "}"
		L_unittest_cmd -r 'invalid' ! L_fstring "{"
	}
	{
		L_unittest_cmd -o "third" \
			L_percent_format "%(3)s" first second third
		L_unittest_cmd -o "third" \
			L_fstring "{3}" first second third

		local name="John"
		L_unittest_cmd -o "John got third place" \
			L_percent_format "%(name)s got %(3)s place" first second third
		L_unittest_cmd -o "John got third place" \
			L_fstring "{name} got {3} place" first second third
	}
}
