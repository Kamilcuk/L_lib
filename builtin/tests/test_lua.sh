_L_test_lua_basic() {
    local out
    out=$(L_builtin lua "print('hello from lua')")
    L_unittest_eq "$out" "hello from lua"
}

_L_test_lua_arguments() {
    local out
    out=$(L_builtin lua "print(arg[1], arg[2])" val1 val2)
    L_unittest_eq "$out" "val1	val2"
}

_L_test_lua_bind_var() {
    local myvar
    L_builtin lua -v myvar "return 'my_test_value'"
    L_unittest_eq "$myvar" "my_test_value"
}
