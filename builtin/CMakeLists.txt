cmake_minimum_required(VERSION 3.10)

option(L_DEV "Enable development options" OFF)
if(L_DEV)
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
endif()

project(L_builtin C)

add_compile_options(-std=gnu99)

set(BASH_INC "/usr/include/bash" CACHE PATH "Path to bash headers")

# Try to parse the Bash version from BASH_INC/version.h
if(EXISTS "${BASH_INC}/version.h")
    file(READ "${BASH_INC}/version.h" VERSION_H_CONTENT)
    string(REGEX MATCH "#define DISTVERSION \"([0-9]+\\.[0-9]+)\"" _ "${VERSION_H_CONTENT}")
    set(BASH_VER "${CMAKE_MATCH_1}")
endif()

# Fallback to the active system/container Bash version
if(NOT BASH_VER)
    execute_process(
        COMMAND bash -c "echo -n \$BASH_VERSION"
        OUTPUT_VARIABLE RAW_BASH_VER
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX MATCH "^([0-9]+\\.[0-9]+)" _ "${RAW_BASH_VER}")
    set(BASH_VER "${CMAKE_MATCH_1}")
endif()

message(STATUS "Determined Bash version: ${BASH_VER}")

string(REGEX MATCH "^([0-9]+)" _ "${BASH_VER}")
set(BASH_MAJOR_VERSION "${CMAKE_MATCH_1}")
add_definitions(-DBASH_MAJOR_VERSION=${BASH_MAJOR_VERSION})

if(NOT BASH_VER STREQUAL "3.2" AND NOT BASH_VER STREQUAL "5.2" AND NOT BASH_VER STREQUAL "5.3")
    message(WARNING "
#####################################################################
# WARNING: Bash version ${BASH_VER} is UNTESTED!
# This project is officially tested and optimized only for:
# - Bash 3.2
# - Bash 5.3
# Use at your own risk.
#####################################################################
")
endif()

set(BASH_SRC "${CMAKE_CURRENT_SOURCE_DIR}/../tmp/bash" CACHE PATH "Path to bash source")

message(STATUS "Using bash includes from: ${BASH_INC}")
message(STATUS "Using bash fallback source from: ${BASH_SRC}")

set(SOURCES src/L_builtin.c src/lseek.c src/poll.c src/sig.c src/pipe.c src/net.c)
set(LIBS "")
set(INC_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${BASH_INC}
    ${BASH_INC}/include
    ${BASH_INC}/builtins
    ${BASH_SRC}
    ${BASH_SRC}/include
    ${BASH_SRC}/builtins
)

include(CheckSymbolExists)
set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
check_symbol_exists(ppoll "poll.h" HAVE_PPOLL)
if(HAVE_PPOLL)
    add_definitions(-DHAVE_PPOLL)
    message(STATUS "ppoll(2) found, enabling ppoll subcommand")
else()
    message(WARNING "ppoll(2) not found, disabling ppoll subcommand")
endif()

find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
    pkg_check_modules(LUAJIT QUIET luajit)
    if(LUAJIT_FOUND)
        list(APPEND SOURCES src/lua.c)
        list(APPEND INC_DIRS ${LUAJIT_INCLUDE_DIRS})
        list(APPEND LIBS ${LUAJIT_LIBRARIES})
        add_definitions(-DHAVE_LUA)
        message(STATUS "LuaJIT found, enabling lua subcommand")
    else()
        message(WARNING "LuaJIT not found, disabling lua subcommand")
    endif()
else()
    message(WARNING "pkg-config not found, cannot check for LuaJIT")
endif()

add_library(L_builtin MODULE ${SOURCES})
set_target_properties(L_builtin PROPERTIES
    PREFIX ""
    SUFFIX ".so"
)
target_compile_definitions(L_builtin PRIVATE HAVE_CONFIG_H SHELL)
target_include_directories(L_builtin PRIVATE ${INC_DIRS})
target_link_libraries(L_builtin PRIVATE ${LIBS})

if(L_DEV)
    if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
        target_compile_options(L_builtin PRIVATE -Wall -Wextra -fanalyzer)
    endif()

    # Create a symlink to compile_commands.json in the root directory
    add_custom_target(symlink_compile_commands ALL
        COMMAND ${CMAKE_COMMAND} -E create_symlink
            ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json
            ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json
        COMMENT "Creating symlink to compile_commands.json"
    )
endif()
