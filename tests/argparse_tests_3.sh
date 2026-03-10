_L_test_z_argparse29_dir_types() {
	local tmpd1 tmpd2 tmp
	L_unittest_cmd -v tmpd1 mktemp -d
	L_unittest_cmd -v tmpd2 mktemp -d
	chmod -r "$tmpd1"
	chmod -w "$tmpd2"

	# Need to run in subshell because L_argparse exits on failure
	L_unittest_failure_capture tmp -- L_argparse -- --dir type=dir_r ---- --dir "$tmpd1"
	L_unittest_contains "$tmp" "directory not readable"

	L_unittest_failure_capture tmp -- L_argparse -- --dir type=dir_w ---- --dir "$tmpd2"
	L_unittest_contains "$tmp" "directory not writable"

	# Cleanup
	chmod +rwx "$tmpd1" "$tmpd2"
	rm -rf "$tmpd1" "$tmpd2"
}

_L_test_z_argparse30_file_type() {
	local tmpf1 tmp
	L_unittest_cmd -v tmpf1 mktemp
	
	L_unittest_cmd -c L_argparse -- --file type=file ---- --file "$tmpf1"

	L_unittest_failure_capture tmp -- L_argparse -- --file type=file ---- --file "/path/that/does/not/exist/hopefully"
	L_unittest_contains "$tmp" "file does not exists"

	rm -f "$tmpf1"
}

_L_test_z_argparse31_choices() {
	local tmp foo
	L_unittest_cmd -c L_argparse -- --foo choices="a b c" ---- --foo b
	L_unittest_vareq foo "b"

	L_unittest_failure_capture tmp -- L_argparse -- --foo choices="a b c" ---- --foo d
	L_unittest_contains "$tmp" "invalid choice: "
}

_L_test_z_argparse32_required() {
	local tmp foo
	L_unittest_cmd -c L_argparse -- --foo required=1 ---- --foo bar
	L_unittest_vareq foo "bar"

	L_unittest_failure_capture tmp -- L_argparse -- --foo required=1 ---- 
	L_unittest_contains "$tmp" "the following arguments are required: --foo"
}

_L_test_z_argparse33_action_help() {
	local tmp
	L_unittest_cmd -e 0 -v tmp L_argparse -- --foo action=help ---- --foo
	L_unittest_contains "$tmp" "Usage:"
	L_unittest_contains "$tmp" "Options:"
}

_L_test_z_argparse34_show_default() {
	local tmp
	L_unittest_cmd -e 0 -v tmp L_argparse -- --foo default="bar" show_default=1 ---- --help
	L_unittest_contains "$tmp" "(default: bar)"
}
