#!/usr/bin/env bash
. "$(dirname "${BASH_SOURCE[0]}")/../bin/L_lib.sh" -s

my_name="John Doe"
my_age=30
L_logrun declare -p my_name my_age
L_logrun L_pretty_print my_name my_age

shopping_list=("organic bread" "fresh milk" "organic avocados" "whole bean coffee" "green apples")
L_logrun declare -p shopping_list
L_logrun L_pretty_print -w 40 shopping_list
L_logrun L_pretty_print -C shopping_list

sparse_indices=([1]="first" [10]="middle" [100]="last")
L_logrun declare -p sparse_indices
L_logrun L_pretty_print -C sparse_indices

if (( L_HAS_ASSOCIATIVE_ARRAY )); then
    declare -A database_config
    database_config[host]="localhost"
    database_config[port]="5432"
    database_config["user name"]="admin_user"
    database_config["password_'\$_symbol"]="secret_'\$_value"
    
    L_logrun declare -p database_config
    L_logrun L_pretty_print database_config
    L_logrun L_pretty_print -C database_config
fi

log_prefix="[TRACE] "
formatted_output=""
L_logrun L_pretty_print -p "$log_prefix" -C shopping_list -v formatted_output
echo "$formatted_output"
