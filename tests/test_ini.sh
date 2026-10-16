###############################################################################
# @section ini .ini file parsers.

obj_skip_test() {
  if (( !L_HAS_BASH4_3 )); then
    L_unittest_skip "obj only available on bash 4.3+ because of namereference"
    exit 123
  fi
}

_L_test_ini() {
  obj_skip_test
  IFS= read -d '' -r var <<'EOF' || :
; full-line comment
# another comment

root1 = hello
root2 = "quoted ; not a comment"
root3 = 'single ; also not a comment'

[server]
host = localhost
port = 8080
long = first line
   second line
   third line

[  spaced section  ]
key = value
quoted = "with ; semicolon"
single = 'with # hash'
empty =
bare_no_eq
after = trailing ; comment

[section]
key = first line
    second line
    third line
EOF
  IFS= read -r -d '' expected <<'EOF' || :
root1 = hello
root2 = "quoted ; not a comment"
root3 = "single ; also not a comment"
[server]
host = localhost
port = 8080
long = first line
  second line
  third line
[spaced section]
key = value
quoted = "with ; semicolon"
single = "with # hash"
empty =
  bare_no_eq
after = trailing
[section]
key = first line
  second line
  third line
EOF
  declare out=() tmp
  echo "$var"
  L_ini_to_obj out <<<"$var"
  _L_obj_print_table out
  L_obj_to_ini -v tmp out
  if [[ "$tmp" != "$expected" ]]; then
    sdiff <(cat <<<"$tmp") - <<<"$expected" || :
    L_unittest_fail "ini obj roundtrip failure"
    exit 1
  fi
}