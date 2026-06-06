cmake_minimum_required(VERSION 3.10)
project(L_builtins C)

set(BASH_INC "/usr/include/bash" CACHE PATH "Path to bash headers")

foreach(i "" "include" "builtins")
    if(NOT IS_DIRECTORY "${BASH_INC}/${i}")
        message(FATAL_ERROR "Required bash directory not found: ${BASH_INC}/${i}")
    endif()
endforeach()

function(add_bash_builtin name)
    add_library(${name} MODULE ${name}.c)
    set_target_properties(${name} PROPERTIES
        PREFIX ""
        SUFFIX ".so"
    )
    target_compile_definitions(${name} PRIVATE HAVE_CONFIG_H SHELL)
    target_include_directories(${name} PRIVATE
        ${BASH_INC}
        ${BASH_INC}/include
        ${BASH_INC}/builtins
    )
endfunction()

add_bash_builtin(bash_select)
add_bash_builtin(bash_lseek)
