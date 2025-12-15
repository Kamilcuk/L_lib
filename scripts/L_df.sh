#!/bin/bash
set -euo pipefail

. "$(dirname "$0")"/../bin/L_lib.sh

###############################################################################

# @description Appends to a variable using ASCII group separator character as separator.
# @arg $1 variable namereference
# @arg $2 Value to append.
L_list_append() { printf -v "$1" "%s" "${!1:+${!1}$L_GS}${!2:-}"; }

# @description Checks if a list containing ASCII group separator character separated elements
# contains an element.
# @arg $1 string with values separated by L_GS
# @arg $2 needle to search for
# @arg [$3] optionally different separator then L_GS, for example a space.
L_list_contains() { [[ "${3:-$L_GS}$1${3:-$L_GS}" == *"${3:-$L_GS}$2${3:-$L_GS}"* ]]; }

# @description Convert L_GS separated elements to an array.
# @arg $1 destination array variable namereference
# @arg $2 string with values separated by L_GS
# @arg [$3] optionally different separator then L_GS, for example a space.
L_list_to_array_to() { IFS="${3:-$L_GS}" read -r -a "$2" <<<"$1"; }

###############################################################################

data="\
id,customer,product,quantity,price,total,date
1,Alice,Keyboard,1,49.99,49.99,2025-01-02
2,Bob,Mouse,2,19.99,39.98,2025-01-03
3,Charlie,Monitor,1,199.99,199.99,2025-01-04
4,Diana,Laptop,1,899.99,899.99,2025-01-05
5,Eva,USB Cable,3,5.99,17.97,2025-01-06
6,Frank,Webcam,1,59.99,59.99,2025-01-07
7,Gina,Headphones,1,89.99,89.99,2025-01-08
8,Henry,Microphone,1,129.99,129.99,2025-01-09
9,Irene,Desk Lamp,2,14.99,29.98,2025-01-10
10,Jack,Chair,1,149.99,149.99,2025-01-11
11,Karen,Keyboard,1,49.99,49.99,2025-01-12
12,Luke,Mouse,1,19.99,19.99,2025-01-13
13,Maya,Monitor,2,199.99,399.98,2025-01-14
14,Nina,Laptop,1,999.99,999.99,2025-01-15
15,Oscar,USB Cable,5,5.99,29.95,2025-01-16
16,Paul,Webcam,2,59.99,119.98,2025-01-17
17,Quinn,Headphones,1,79.99,79.99,2025-01-18
18,Rita,Microphone,1,139.99,139.99,2025-01-19
19,Sam,Desk Lamp,1,14.99,14.99,2025-01-20
20,Tina,Chair,2,149.99,299.98,2025-01-21
21,Uma,Keyboard,1,45.99,45.99,2025-01-22
22,Victor,Mouse,3,18.99,56.97,2025-01-23
23,Wendy,Monitor,1,189.99,189.99,2025-01-24
24,Xavier,Laptop,1,899.99,899.99,2025-01-25
25,Yara,USB Cable,2,6.99,13.98,2025-01-26
26,Zack,Webcam,1,69.99,69.99,2025-01-27
27,Alice,Headphones,1,95.99,95.99,2025-01-28
28,Bob,Microphone,1,149.99,149.99,2025-01-29
29,Charlie,Desk Lamp,4,12.99,51.96,2025-01-30
30,Diana,Chair,1,159.99,159.99,2025-01-31
31,Eva,Keyboard,1,55.99,55.99,2025-02-01
32,Frank,Mouse,2,17.99,35.98,2025-02-02
33,Gina,Monitor,1,179.99,179.99,2025-02-03
34,Henry,Laptop,1,849.99,849.99,2025-02-04
35,Irene,USB Cable,3,7.49,22.47,2025-02-05
36,Jack,Webcam,1,65.99,65.99,2025-02-06 q
37,Karen,Headphones,2,85.99,171.98,2025-02-07
38,Luke,Microphone,1,159.99,159.99,2025-02-08
39,Maya,Desk Lamp,1,16.99,16.99,2025-02-09
40,Nina,Chair,3,149.99,449.97,2025-02-10
41,Oscar,Keyboard,2,49.49,98.98,2025-02-11
42,Paul,Mouse,1,19.49,19.49,2025-02-12
43,Quinn,Monitor,1,209.99,209.99,2025-02-13
44,Rita,Laptop,1,929.99,929.99,2025-02-14
45,Sam,USB Cable,4,6.49,25.96,2025-02-15
46,Tina,Webcam,1,72.99,72.99,2025-02-16
47,Uma,Headphones,1,99.99,99.99,2025-02-17
48,Victor,Microphone,1,169.99,169.99,2025-02-18
49,Wendy,Desk Lamp,2,13.99,27.98,2025-02-19
50,Xavier,Chair,1,139.99,139.99,2025-02-20
"

###############################################################################
# @section dataframe
#
# Dataframe:
# - [0] - The number of columns
# - [1] - Constant 10 + groups + attrs.
# - [2] - Space separated list of groupby column indexes.
# - [3] - The string DF.
# - [4] - Count of groups.
# - [5] - Count of indexes.
# - [10 + groups] - Groups
#
# - [df[1]        +i] - header of column i
# - [df[1]+df[0]  +i] - type of column i
# - [df[1]+df[0]*3+df[0]*j+i] - value at row j column i
#
# Groups Representation:
# - N_GROUPS - the number of groups
# - KEYLEN - The number of keys
# - <key... rowindex>...  The keys of group followed by space separated list of row indexes.

_L_DF_COLS="L_df[0]"
_L_DF_OFFSET=4  # L_df[1]
_L_DF_GROUPBYS="L_df[2]"
_L_DF_MARK="L_df[3]"
_L_DF_GROUPS="L_df[1]-$_L_DF_OFFSET"
_L_DF_COLUMNS="(L_df[1])+0"
_L_DF_TYPES="(L_df[1]+L_df[0])+0"
_L_DF_DATA="(L_df[1]+L_df[0]*2)+L_df[0]"
L_DF_NAN="$L_DEL"

# @description Create a dataframe.
# @arg $1 dataframe namereference
# @arg $2 number of columns
# @arg $@ list of headers followed by a list of types followed by rows
L_df_init_raw() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_df=(
    "$2" # [0] = number of columns
    "$_L_DF_OFFSET" # [1] = offset
    '' # [2] = groupby column indexes
    DF # [3] = constant MARK
    "${@:3}" # columns, types, rows
  )
}

# @description Create a dataframe.
# @arg $1 dataframe namereference
# @arg $@ optional list of headers
L_df_init() {
  local _L_df=$1
  shift
  L_df_init_raw "$_L_df" "$#" "$@" "${@//*/str}"
}

# @description Copy dataframe columns and types without values.
# @arg $1 dataframe namereference source
# @arg $2 dataframe namereference destination
L_df_copy_empty() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  if [[ "$2" != _L_df ]]; then local -n _L_df="$2" || return 2; fi
  _L_df=("${L_df[@]::$_L_DF_DATA*0}")
}

# @description Remove values from dataframe.
# @arg $1 dataframe namerefence
L_df_clear() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_df=("${L_df[@]::$_L_DF_DATA*0}")
}

# @description Create a dataframe from separated lists.
# Lists are split on IFS with read.
# @arg $1 dataframe namereference
# @arg $2 List of headers
# @arg $3 List of values.
L_df_from_lists() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_i
  read -r -a _L_i <<<"$2"
  L_df_init L_df "${_L_i[@]}"
  shift 2
  while (($#)) && read -r -a _L_i <<<"$1"; do
    L_df_add_row L_df "${_L_i[@]}"
    shift
  done
}

# @description Append dictionary to a dataframe.
# @arg $1 dataframe namereference
# @arg $2 associative array namereference
L_df_append_dict() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local -n _L_dict=$2
  local _L_key _L_val _L_columns _L_column_idx _L_end="${#L_df[*]}" _L_added=0
  L_df_get_columns -v _L_columns "$1"
  for _L_key in "${_L_columns[@]}"; do
    L_df[_L_end++]=${_L_dict["$_L_key"]:-$L_DF_NAN}
  done
  for _L_key in "${!_L_dict[@]}"; do
    if ! L_array_contains _L_columns "$_L_key"; then
      L_df_add_column "$1" "$_L_key"
    fi
    L_df[_L_end++]=${_L_dict["$_L_key"]}
  done
}

# @description Add row to dataframe.
# If there are not enough columns, they are created.
# @arg $1 dataframe namereference
# @arg $@ Row values.
L_df_add_row() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_i=$(( $# - 1 - L_df[0] ))
  if (( _L_i > 0 )); then
    while (( _L_i-- )); do
      L_df_add_column "$1"
    done
  fi
  L_df+=("${@:2}")
  if (( _L_i < 0 )); then
    while (( _L_i++ < 0 )); do
      L_df+=("$L_DF_NAN")
    done
  fi
}

# @description Add another column to dataframe.
# @arg $1 dataframe namereference
# @arg $2 column name
# @arg $@ values
L_df_add_column() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  # Make space for another column.
  eval eval " \
    'L_df=(' \
      '\"\${L_df[@]::\$_L_DF_TYPES}\"' \
      '\"\$2\"' \
      '\"\${L_df[@]:\$_L_DF_TYPES:L_df[0]}\"' \
      'str' \
      '\"\${L_df[@]:\$_L_DF_DATA*'{0..$((L_df[0]-1))}':L_df[0]}\" \"\$L_DF_NAN\"' \
    ')'"
  # Increment column count.
  (( ++L_df[0] ))
  # Set rows values of the column.
  local _L_i _L_rows
  L_df_get_len -v _L_rows L_df
  shift 2
  if (( $# > _L_rows )); then
    L_panic "Refusing to create a column with more values then rows"
  fi
  for (( _L_i = 0; $# && _L_i < _L_rows; ++_L_i )); do
    L_df_set_iat L_df "$_L_i" "$((L_df[0]-1))" "$1"
    shift
  done
}

L_df_read_csv() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_i IFS=,
  # Create the dataframe headers.
  read -ra _L_i || return "$?"
  L_assert "no headers to read from csv file" test "${#_L_i[*]}" -gt 0
  L_df_init "$1" "${_L_i[@]}"
  # Read dataframe values.
  while IFS= read -r _L_i; do
    # Skip empty lines.
    if [[ -n "$_L_i" ]]; then
      read -r -a _L_i <<<"$_L_i"
      L_df_add_row "$1" "${_L_i[@]}"
    fi
  done
}

# @description Get value at specific index.
# @arg $1 dataframe namereference
# @arg $2 row index
# @arg $3 column index
L_df_get_iat() { L_handle_v_array "$@"; }
L_df_get_iat_v() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_v="${L_df[$_L_DF_DATA * $2 + $3]}"
}

# @description Set value at specific index
# @arg $1 dataframe namereference
# @arg $2 row index
# @arg $3 column index
# @arg $4 value to set
L_df_set_iat() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_df[$_L_DF_DATA * $2 + $3]=$4
}


# @arg $2 row index
# @arg $3 column name
L_df_get_at() { L_handle_v_array "$@"; }
L_df_get_at_v() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_df_get_column_idx_v "$1" "$3"
  L_v=("${L_df[@]:$_L_DF_DATA * $2 + $L_v:L_df[0]}")
}

L_df_get_row() { L_handle_v_array "$@"; }
L_df_get_row_v() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_v=("${L_df[@]:$_L_DF_DATA * $2:L_df[0]}")
}

# @description Get number of rows in a dataframe.
L_df_get_len() { L_handle_v_scalar "$@"; }
L_df_get_len_v() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_v=$(( ( ${#L_df[@]} - ($_L_DF_DATA*0) ) / L_df[0] ))
}

L_df_get_shape() { L_handle_v_array "$@"; }
L_df_get_shape_v() {
  L_df_get_len_v "$1"
  L_v[1]=${L_df[0]}
}

# @description Get columns in a dataframe.
L_df_get_columns() { L_handle_v_array "$@"; }
L_df_get_columns_v() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_v=("${L_df[@]:$_L_DF_COLUMNS:L_df[0]}")
}

# @description Get column types of a dataframe.
L_df_get_dtypes() { L_handle_v_array "$@"; }
L_df_get_dtypes_v() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_v=("${L_df[@]:$_L_DF_TYPES:L_df[0]}")
}

L_df_copy() { L_array_copy "$1" "$2"; }

# @arg $1 dataframe namereference
# @arg $@ column names
L_df_get_column_idx() { L_handle_v_array "$@"; }
L_df_get_column_idx_v() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_i
  L_v=()
  while (($# >= 2)); do
    for (( _L_i = 0; _L_i < L_df[0]; _L_i++ )); do
      if [[ "${L_df[$_L_DF_COLUMNS + _L_i]}" == "$2" ]]; then
        L_v+=("$_L_i")
        break
      fi
    done
    if (( _L_i == L_df[0] )); then
      L_panic "Column named $2 not found: ${L_df[*]:$_L_DF_COLUMNS:L_df[0]}"
      return 1
    fi
    shift
  done
}

# @descriptino Convert column index to column name.
# @arg $1 dataframe namereference
# @arg $@ column indexes
L_df_get_column_name() { L_handle_v_array "$@"; }
L_df_get_column_name_v() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  if (($# == 1)); then
    L_func_usage_error "Not enough positional arguments" 2
    return 2
  fi
  local _L_i
  L_v=()
  while (($# >= 2)); do
    if (( 0 <= $2 && $2 < L_df[0] )); then
      L_v+=("${L_df[$_L_DF_COLUMNS + $2]}")
    else
      L_panic "Column index out of range: $2"
    fi
    shift
  done
}

# @descriptions Return one column values of all rows as an array.
L_df_get_column_to_array() { L_handle_v_array "$@"; }
L_df_get_column_to_array_v() {
  local _L_column_idx
  L_df_get_column_idx -v _L_column_idx "$1" "$2" || return $?
  L_df_get_column_idx_to_array_v "$@"
}

# @descriptions Return one column values of all rows as an array.
L_df_get_column_idx_to_array() { L_handle_v_array "$@"; }
L_df_get_column_idx_to_array_v() {
  local _L_rows
  L_df_get_len -v _L_rows "$1" || return $?
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  eval eval "'L_v=(' '\"\${L_df[\$_L_DF_DATA*'{0..$((_L_rows-1))}'+\$2]}\"' ')'"
}


# @description Return dataframe with only specific columns by index.
L_df_select_columns_idx() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_i IFS=' '
  #
  for (( _L_i = L_df[0] - 1; _L_i >= 0; --_L_i )); do
    if [[ " $* " != *" $_L_i "* ]]; then
      L_df_drop_column_idx "$1" "$_L_i"
    fi
  done
}

# @description Return dataframe with only specific columns by name.
L_df_select_columns() {
  local L_v _L_keep=()
  # Find indexes of selected columns
  for L_v in "${@:2}"; do
    L_df_get_column_idx_v "$1" "$L_v"
    _L_keep+=("$L_v")
  done
  L_df_select_columns_idx "$1" "${_L_keep[@]}"
}


# @description Drop column by name.
L_df_drop_column() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local L_v
  L_df_get_column_idx_v "$1" "$2"
  L_df_drop_column_idx "$1" "$L_v"
}

# @description Drop column by index.
L_df_drop_column_idx() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_column_idx=$2
  # Remove all indexes starting from _L_column_idx up until the end each column.
  eval "unset 'L_df['{$(( L_df[1] + _L_column_idx ))..${#L_df[*]}..${L_df[0]}}']'"
  # Reindex to fix numbering and size.
  L_df=("${L_df[@]}")
  # Decrement number of columns.
  (( L_df[0]-- ))
}

# @arg $1 first value
# @arg $1 second value
# @arg $3 type
# @env _L_sort_dtypes
# @env _L_sort_n
_L_df_sort_cmp_1() {
  case "$3" in
    int)
      if (( $1 < $2 )); then
        return 1
      elif (( $1 != $2 )); then
        return 2
      fi
      ;;
    float)
      if L_float_cmp "$1" "<" "$2"; then
        return 1
      elif L_float_cmp "$1" "!=" "$2"; then
        return 2
      fi
      ;;
    *)
      if [[ "$1" < "$2" ]]; then
        return 1
      elif [[ "$1" != "$2" ]]; then
        return 2
      fi
      ;;
  esac
}

# @arg $1 Index 1
# @arg $2 Index 2
# @env L_df The dataframe
# @env _L_sort_idx Columns indexes to sort by.
# @return 0 if $1 < $2 else 1
_L_df_sort_cmp() {
  local _L_i _L_a _L_b
  L_df_get_row -v _L_a L_df "$1" || L_panic
  L_df_get_row -v _L_b L_df "$2" || L_panic
  # Sort by given columns.
  for _L_i in "${_L_sort_idx[@]}"; do
    _L_df_sort_cmp_1 "${_L_a[_L_i]}" "${_L_b[_L_i]}" "${_L_sort_dtypes[_L_i]}" || return "$(($?-1))"
  done
  # Fallback to sorting by all columns.
  for (( _L_i = 0; _L_i < _L_sort_rows; _L_i++ )); do
    _L_df_sort_cmp_1 "${_L_a[_L_i]}" "${_L_b[_L_i]}" "${_L_sort_dtypes[_L_i]}" || return "$(($?-1))"
  done
  # Stable sort.
  (( $1 < $2 ))
}

# @description Sort a dataframe values
# @option -r Reverse sort
# @option -n ignored, numeric sort depends on column type
# @arg $1 dataframe variable
# @arg $@ column names to sort by
L_df_sort() { L_getopts_in -p _L_sort_ "nr" _L_df_sort_in "$@"; }
_L_df_sort_in() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_sort_idx=() L_v _L_sort_dtypes _L_sort_rows
  # Get column indexes of all columns names.
  shift
  for _L_i; do
    L_df_get_column_idx_v L_df "$_L_i"
    _L_sort_idx+=("$L_v")
  done
  # Prepare dtypes.
  L_df_get_dtypes -v _L_sort_dtypes L_df
  # Generate a list of indexes to sort.
  L_df_get_len -v _L_sort_rows L_df
  eval "local _L_idx=({0..$((_L_sort_rows-1))})"
  # Sort.
  L_sort_bash ${_L_sort_r:+-r} -c _L_df_sort_cmp _L_idx
  # Shuffle the values according to _L_idx.
  local _L_copy=("${L_df[@]::$_L_DF_DATA*0}")
  for _L_i in "${_L_idx[@]}"; do
    L_df_get_row_v L_df "$_L_i"
    _L_copy+=("${L_v[@]}")
  done
  L_df=("${_L_copy[@]}")
}

L_df_astype() {
  local _L_column=$2 _L_type=$3 _L_rows _L_column_idx
  L_df_get_column_idx -v _L_column_idx "$1" "$2"
  L_df_get_len -v _L_rows "$1"
  if [[ "$_L_type" != "str" ]]; then
    for (( _L_i = 0; _L_i < _L_rows; _L_i++ )); do
      L_df_get_iat_v "$1" "$_L_i" "$_L_column_idx"
      if ! case "$_L_type" in
          int) L_is_integer "${L_v[0]}" ;;
          float) L_is_float "${L_v[0]}" ;;
          *) L_panic "Invalid type: $_L_type" ;;
        esac
      then
        L_panic "Non-numeric value found in column $_L_column_idx at row $_L_i: ${L_v[0]}"
      fi
    done
  fi
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_df[$_L_DF_TYPES+_L_column_idx]=$_L_type
}

L_df_head_v() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_df=("${L_df[@]::$_L_DF_DATA*$2}")
}

L_df_tail() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_rows
  L_df_get_len -v _L_rows "$1"
  L_df=(
    "${L_df[@]::$_L_DF_DATA * 0}"
    "${L_df[@]:$_L_DF_DATA * ( _L_rows > $2 ? _L_rows - $2 : _L_rows )}"
  )
}

L_df_get_row_as_dict() { L_handle_v_array "$@"; }
L_df_get_row_as_dict_v() {
  local _L_j _L_columns
  L_df_get_columns -v _L_columns "$1"
  L_v=()
  for _L_j in "${!_L_columns[@]}"; do
    L_v["${_L_columns[_L_j]}"]=${L_df[$_L_DF_DATA * $_L_i + _L_j]}
  done
}

L_df_row_slice() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_rows _L_i
  L_df_get_len -v _L_rows "$1"
  L_df=(
    "${L_df[@]::$_L_DF_DATA * 0}"
  )
  shift
  for _L_i; do
    if (( _L_i >= _L_rows )); then
      L_panic "No such row number $_L_i"
    fi
    L_df+=("${L_df[@]:$_L_DF_DATA * _L_i:L_df[0]}")
  done
}

# @description Drop a row from a dataframe.
# @arg $1 The dataframe namereference.
# @arg $2 The index of the row to drop.
# @example
#   # This will drop the row at index 1 from the dataframe df.
#   L_df_drop_row df 1
L_df_drop_row() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_rows _L_i="$2"
  L_df_get_len -v _L_rows "$1"
  if (( _L_i >= _L_rows )); then
    L_panic "No such row number $_L_i"
  fi
  eval "unset 'L_df['{"$(($_L_DF_DATA * _L_i))..$(($_L_DF_DATA * _L_i + L_df[0] - 1))"}']'"
  L_df=("${L_df[@]}")
}

# @description Filter rows in a dataframe based on a condition.
# @arg $1 The dataframe namereference.
# @arg $@ The condition to filter rows. This is a shell command that should return 0 (true) for rows to keep. The associative array variable L_v is exposed with the values of columns.
# @example
#   # This will keep only rows where the product name starts with "M".
#   L_df_filter_dict df L_eval '[[ "${L_v["product"]::1}" == "M" ]]'
L_df_filter_dict() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  shift
  local _L_rows _L_i _L_columns
  L_df_get_len -v _L_rows L_df
  L_df_get_columns -v _L_columns L_df
  local -A L_v=()
  for (( _L_i = 0; _L_i < _L_rows; ++_L_i )); do
    L_df_get_row_as_dict_v L_df "$_L_i"
    if ! "$@"; then
      L_df_drop_row L_df "$_L_i"
      (( --_L_i, --_L_rows, 1 ))
    fi
  done # "
}

# @description Generate descriptive statistics for a dataframe.
# @option -p <percentiles> Specify the percentiles to include in the output. Default: "25 50 75".
# @option -e <columns> Specify the columns to include in the output. Default: all numeric columns.
# @option -i <columns> Specify the columns to exclude from the output.
# @option -a All columns
# @arg $1 The dataframe namereference.
# @example
#   # This will generate descriptive statistics for the 'total' and 'quantity' columns with default percentiles.
#   L_df_describe -e total,quantity df
# @example
#   # This will generate descriptive statistics for all numeric columns with custom percentiles.
#   L_df_describe -p 10,25,50,75,90 df
L_df_describe() { L_getopts_in -p _L_opt_ "ap:e:i:" _L_df_describe_in "$@"; }
_L_df_describe_in() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_percentiles=(25 50 75) _L_include=() _L_exclude=() _L_columns _L_dtypes _L_col _L_col_idx _L_rows _L_values _L_min _L_max _L_mean _L_std _L_percentile_values _L_percentile _L_percentile_value _L_rows
  # Parse options
  if [[ -n "$_L_opt_p" ]]; then
    IFS=' ,' read -r -a _L_percentiles <<< "${_L_opt_p:-}"
  fi
  if [[ -n "$_L_opt_e" ]]; then
    IFS=' ,' read -r -a _L_include <<< "${_L_opt_e:-}"
  fi
  if [[ -n "$_L_opt_i" ]]; then
    IFS=' ,' read -r -a _L_exclude <<< "${_L_opt_i:-}"
  fi
  # Get columns and dtypes
  L_df_get_columns -v _L_columns L_df
  L_df_get_dtypes -v _L_dtypes L_df
  L_df_get_len -v _L_rows L_df
  # Filter columns based on include/exclude options
  local _L_filtered_columns=()
  for _L_col in "${_L_columns[@]}"; do
    if [[ " ${_L_include[*]} " =~ " ${_L_col} " && ! " ${_L_exclude[*]} " =~ " ${_L_col} " ]]; then
      _L_filtered_columns+=("$_L_col")
    elif [[ -z "${_L_include[*]}" && ! " ${_L_exclude[*]} " =~ " ${_L_col} " ]]; then
      _L_filtered_columns+=("$_L_col")
    fi
  done
  # Initialize output
  local _L_output=()
  _L_output+=("count mean std min ${_L_percentiles[*]} max")
  # Process each filtered column
  for _L_col in "${_L_filtered_columns[@]}"; do
    local _L_col_idx
    L_df_get_column_idx -v _L_col_idx L_df "$_L_col"
    L_df_get_column_to_array -v _L_values L_df "$_L_col"
    case "${_L_dtypes[_L_col_idx]}" in
      int|float)
        # Calculate statistics
        _L_min=$(printf "%s\n" "${_L_values[@]}" | sort -n | head -n 1)
        _L_max=$(printf "%s\n" "${_L_values[@]}" | sort -n | tail -n 1)
        _L_mean=$(printf "%s\n" "${_L_values[@]}" | awk '{sum+=$1} END {print sum/NR}')
        _L_std=$(printf "%s\n" "${_L_values[@]}" | awk -v mean="$_L_mean" '{sum+=($1-mean)^2} END {print sqrt(sum/NR)}')
        _L_percentile_values=()
        for _L_percentile in "${_L_percentiles[@]}"; do
          _L_percentile_value=$(printf "%s\n" "${_L_values[@]}" | sort -n | awk -v p="$_L_percentile" -v n="$_L_rows" 'NR >= p*n/100 {print; exit}')
          _L_percentile_values+=("$_L_percentile_value")
        done
        # Append statistics to output
        _L_output+=("$_L_col ${_L_rows} $_L_mean $_L_std $_L_min ${_L_percentile_values[*]} $_L_max")
        ;;
    esac
  done
  # Print output
  local IFS=$'\n'
  column -t -s ' ' <<<"${_L_output[*]}"
}

# @description Modify dataframe to contain only specific rows and columns.
# @option $1 Row number or start:stop or start:stop:step or : for all columns.
# @option $2 Column indexes separated by a comma.
L_df_iloc() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_row_spec=$2 _L_col_spec=${3:-} _L_start _L_end _L_step _L_col_indices _L_result=()
  # Parse row specification
  if [[ "$_L_row_spec" == ":" ]]; then
    _L_start=0
    L_df_get_len -v _L_end "$1"
    _L_step=1
  elif [[ $_L_row_spec =~ ^([0-9]+)(:([0-9]+)(:([0-9]+))?)?$ ]]; then
    #                    1       2 3       4 5
    _L_start=${BASH_REMATCH[1]}
    _L_end=${BASH_REMATCH[3]:-${_L_start}}
    _L_step=${BASH_REMATCH[5]:-1}
  else
    L_panic "Invalid row specification: $_L_row_spec"
  fi
  if [[ -z "$_L_col_spec" ]]; then
    eval "_L_col_indices=( {0..$((L_df[0]-1))} )"
  else
    IFS="," read -r -a _L_col_indices <<<"$_L_col_spec"
  fi
  # Extract selected rows and columns
  local _L_values=()
  for (( _L_i = _L_start; _L_i <= _L_end; _L_i += _L_step )); do
    for _L_col_idx in "${_L_col_indices[@]}"; do
      L_df_get_iat_v L_df "$_L_i" "$_L_col_idx"
      _L_values+=("$L_v")
    done
  done
  L_df=("${L_df[@]::$_L_DF_DATA*0}")
  L_df_select_columns_idx L_df "${_L_col_indices[@]}"
  L_df+=("${_L_values[@]}")
}

# @description Modify dataframe to contain only specific rows and columns.
# @option $1 Row number or start:stop or start:stop:step or : for all columns.
# @option $@ Column names
L_df_loc() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_row_spec=$2 _L_col_names _L_col_indices="" _L_col
  # Parse column specification
  for _L_col in "${@:3}"; do
    L_df_get_column_idx -v _L_col_idx L_df "$_L_col" || L_panic "Column $_L_col not found"
    _L_col_indices+=${_L_col_indices:+,}$_L_col_idx
  done
  #
  L_df_iloc "$1" "$2" "$_L_col_indices"
}

# @description Return 0 if dataframe is grouped.
L_df_is_grouped() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  [[ -n "${L_df[2]}" ]] && L_assert "internal error: grouped by columns list is invalid" \
    L_regex_match "${L_df[2]}" "^[0-9]+( [0-9]+)*$"
}

# @description Get column names by which dataframe was grouped.
L_df_get_grouped_columns() { L_handle_v_array "$@"; }
L_df_get_grouped_columns_v() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_df_is_grouped L_df && {
    L_v=()
    local _L_i=0 IFS=' '
    L_df_get_column_name_v L_df ${L_df[2]}
  }
}

# @description Create a grouped view of a DataFrame by one or more columns.
#              Stores the grouping column(s) internally for use by aggregation functions.
# @arg $1 dataframe nameref      Name of the DataFrame to group
# @arg $@ column names           One or more column names to group by
L_df_groupby() {
  local L_v
  L_df_get_column_idx_v "$@" || return $?
  L_df_igroupby "$1" "${L_v[@]}"
}

# @description Compute groups from given column indexes and store them
#              inside the dataframe’s internal GROUPS section.
# @arg $1 dataframe namereference
# @arg $@ column indexes to group by
L_df_igroupby() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_assert "dataframe is already grouped" L_not L_df_is_grouped L_df
  shift
  local -a _L_cols=( "$@" )   # groupby column indexes
  local -i _L_ncols=${#_L_cols[@]} _L_nrows
  L_df_get_len -v _L_nrows L_df
  # Build groups map: key → rows
  local -A _L_map=()
  local _L_row _L_col _L_val _L_key
  for (( _L_row=0; _L_row < _L_nrows; _L_row++ )); do
      _L_key=""
      for _L_col in "${_L_cols[@]}"; do
          _L_val=${L_df[$_L_DF_DATA * _L_row + _L_col]}
          _L_key+=${_L_key:+$L_DF_NAN}"${_L_val}"
      done
      _L_map["$_L_key"]+="${_L_map["$_L_key"]:+ }${_L_row}"
  done
  # Convert map into GROUPS array
  local -a _L_groups=()
  for _L_key in "${!_L_map[@]}"; do
      _L_groups+=("$_L_key" "${_L_map[$_L_key]}")
  done
  L_df=( "${L_df[@]:0:$_L_DF_COLUMNS}" "${_L_groups[@]}" "${L_df[@]:$_L_DF_COLUMNS}" )
  L_df[1]=$(( _L_DF_OFFSET + ${#_L_groups[@]} ))
  local IFS=' '
  L_df[2]="${_L_cols[*]}"
}

# @description Remove groups and reset index
# @arg $1 dataframe namereference
L_df_reset_index() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_cols_off=${L_df[1]}
  local _L_ngroups=$(( _L_cols_off - $_L_DF_OFFSET ))
  if (( _L_ngroups )); then
    L_df=( "${L_df[@]:0:_L_DF_OFFSET}" "${L_df[@]:$_L_DF_COLUMNS}" )
    L_df[1]=$_L_DF_OFFSET
    L_df[2]=""
  fi
}

_L_df_column() {
  if L_hash column; then
    column -t -s "$IFS" -o ' ' "${@:2}" <<<"$1"
  else
    echo "${1//"$IFS"/$'\t'}"
  fi
}

# @description Print a dataframe.
# @arg $1 dataframe namereference
L_df_print() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local i IFS=$'!' rows row txt="" right=() dtypes
  L_df_get_len -v rows "$1"
  echo "=== DataFrame $1 columns=${L_df[0]} rows=${rows} ===="
  txt+="ID$IFS${L_df[*]:$_L_DF_COLUMNS:L_df[0]}"$'\n'
  txt+="-$IFS${L_df[*]:$_L_DF_TYPES:L_df[0]}"$'\n'
  for (( i = 0; i < rows; ++i )); do
    L_df_get_row -v row "$1" "$i"
    txt+="$i$IFS${row[*]}"$'\n'
  done
  # Find all rows of type int and float and right justify them.
  L_df_get_dtypes -v dtypes "$1"
  for i in "${!dtypes[@]}"; do
    case "${dtypes[i]}" in
      int|float) right+=${right:+,}$((i+2)) ;;
    esac
  done
  _L_df_column "$txt" ${right:+"-R$right"}
}

# @description Print groupby groups stored in a flattened groups array.
# @arg $1 dataframe nameref (expects ${df}_groups)
L_df_print_groups() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  L_assert "dataframe not grouped" test -n "${L_df[2]}"
  local _L_cols_off=${L_df[1]}
  local _L_ngroups=$(( _L_cols_off - $_L_DF_OFFSET ))
  local _L_groups=("${L_df[@]:$_L_DF_OFFSET:$_L_ngroups}")
  local _L_i _L_key _L_vals IFS="$L_DF_NAN" _L_group_columns_idxs right="" dtypes _L_group_column_names
  # Get group names.
  L_df_get_grouped_columns -v _L_group_column_names L_df
  # Determing which groups to right justify.
  L_df_get_dtypes -v dtypes "$1"
  IFS=' ' read -r -a _L_group_columns_idxs <<<"${L_df[2]}"
  for _L_i in "${_L_group_columns_idxs[@]}"; do
    case "${dtypes[_L_i]}" in
      int|float) right+=${right:+,}$((_L_i+2)) ;;
    esac
  done
  # Print each group.
  echo "=== DataFrame Groups count=$((_L_ngroups/2)) ==="
  txt="${_L_group_column_names[*]}${IFS}rows"$'\n'
  for (( _L_i = 0; _L_i < _L_ngroups; _L_i += 2 )); do
    _L_key="${_L_groups[_L_i]}"
    _L_vals="${_L_groups[_L_i+1]}"
    txt+="$_L_key${IFS}$_L_vals"$'\n'
  done
  _L_df_column "$txt" ${right:+"-R$right"}
}

_L_df_filter_eq() {
  while (($# >= 2)); do
    if [[ "${L_v[$1]}" != "$2" ]]; then
      return 1
    fi
    shift 2
  done
}

# @dscription Filter dataframe on column values equal to given values.
# @arg $1 dataframe namereference
# @arg $@ Pairs of column name and value to match on.
L_df_filter_eq() {
  L_df_filter_dict "$1" _L_df_filter_eq "${@:2}";
}

# @description Sum numeric columns in a DataFrame or grouped DataFrame.
#              - If called on a normal DataFrame, sums each numeric column across all rows.
#              - If called on a grouped DataFrame (created by L_df_groupby), sums numeric columns per group.
# @arg $1 dataframe or grouped_df nameref   Name of the DataFrame or grouped object
# @arg $@ optional column names            Numeric columns to sum; if omitted, sum all numeric columns
L_df_sum() {
  if [[ "$1" != L_df ]]; then local -n L_df="$1" || return 2; fi
  local _L_df_new IFS=' ' _L_groupby_columns _L_values _L_col
  L_df_init _L_df_new
  if L_df_is_grouped L_df; then
    for _L_col in ${L_df[3]}; do
      L_df_get_column_to_array -v _L_values L_df "$_L_col"
      L_df_add_column_combinations L_df "$_L_col" "${_L_values[@]}"
    done
    local _L_sums=() _L_row _L_rows _L_col_name
    L_df_get_len -v _L_rows L_df
    for (( _L_col = 0; _L_col < L_df[0]; ++_L_col )); do
      for (( _L_row = 0; _L_row < _L_rows; ++_L_row )); do
        case "${L_df[$_L_DF_TYPES + _L_col]}" in
          int)
            _L_sums[_L_col]=$(( ${_L_sums[_L_col]:-0} + ${L_df[$_L_DF_DATA * _L_row + _L_col]} ))
            ;;
        esac
      done
    done
  else
    L_panic 'todo'
  fi
}

L_df_sourcegen_iterrows() {
  L_df_copy_empty L_df
}

###############################################################################

L_df_read_csv df < <(head -n 4 <<<"$data")
L_df_read_csv bigdf <<<"$data"
IFS=, L_df_from_lists df2 \
  "name,age,city" \
  "Alice,30,New York" \
  "Alice,40,New York" \
  "Bob,25,Los Angeles" \
  "Bob,35,Los Angeles" \
  "Charlie,35,Chicago" \
  "Charlie,25,Chicago"
if (($#)); then
  "$@"
  exit
fi

L_df_print bigdf
L_df_groupby bigdf product quantity
# L_df_select_columns df amount
# L_df_sum df
L_df_print bigdf
L_df_print_groups bigdf
exit

L_df_print df
L_df_select_columns df id quantity customer
L_df_filter_dict df L_eval '(( L_v["quantity"] < 30 ))'
L_df_print df
exit
# L_df_read_csv df <<<"$data"
L_df_astype df quantity int
L_df_astype df price float
L_df_astype df total float
# L_df_drop_row df 1
L_df_print df
# exit
echo
# L_df_drop_column df id
L_df_print df
echo
# L_df_sort df total
# L_df_tail df 5
# echo "Best customers:"
# L_df_print df

L_df_describe df quantity
# L_df_filter_dict df L_eval '[[ "${L_v["product"]::1}" == "M" ]]'
# L_df_print df

#
# L_setx L_df_get_columns df id total
# L_df_print df
#
exit 0

