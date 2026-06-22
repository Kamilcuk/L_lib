cmake_minimum_required(VERSION 3.10)
project(L_builtin C)

set(BASH_INC "/usr/include/bash" CACHE PATH "Path to bash headers")
set(BASH_SRC "${CMAKE_CURRENT_SOURCE_DIR}/../tmp/bash" CACHE PATH "Path to bash source")

foreach(i "" "include" "builtins")
    if(NOT IS_DIRECTORY "${BASH_INC}/${i}")
        message(STATUS "Bash header directory not found: ${BASH_INC}/${i}")
    endif()
endforeach()

add_library(L_builtin MODULE L_builtin.c lseek.c select.c sig.c)
set_target_properties(L_builtin PROPERTIES
    PREFIX ""
    SUFFIX ".so"
)
target_compile_definitions(L_builtin PRIVATE HAVE_CONFIG_H SHELL)
target_include_directories(L_builtin PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${BASH_INC}
    ${BASH_INC}/include
    ${BASH_INC}/builtins
    ${BASH_SRC}
    ${BASH_SRC}/include
    ${BASH_SRC}/builtins
)
