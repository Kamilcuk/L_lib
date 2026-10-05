## API Reference

## array

Operations on various lists, arrays and arguments. L_array\_\*

### L_array_len

Get array length.

Example

```
L_array_len arr
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

### L_array_keys

Get array keys

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

### L_array_max_index

Find the maximum index (key) in an array.

Return failure if the array is empty.

Example

```
L_array_max_index -v max_idx arr
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** array nameref

### L_array_len_vL_RET

### L_array_keys_vL_RET

### L_array_assign

Set elements of array.

Example

```
L_array_assign arr 1 2 3
```

**Arguments:**

- **`$1`** array nameref
- **`$@`** elements to set

### L_array_set

Assign element of an array

Example

```
L_array_assign arr 5 "Hello"
```

**Arguments:**

- **`$1`** array nameref
- **`$2`** array index
- **`$3`** value to assign

### L_array_append

Append elements to array.

Example

```
L_array_append arr "Hello" "World"
```

**Arguments:**

- **`$1`** array nameref
- **`$@`** elements to append

### L_array_insert

Insert element at specific position in an array.

This will move all elements from the position to the end of the array.

Example

```
L_array_insert arr 2 "Hello" "World"
```

**Arguments:**

- **`$1`** array nameref
- **`$2`** index position
- **`$@`** elements to append

### L_array_pop_front

Remove first array element.

**Argument:** **`$1`** array nameref

### L_array_pop_back

Remove last array element.

Example

```
L_array_pop_back arr
```

**Argument:** **`$1`** array nameref

### L_array_is_dense

Return success, if all array elements are in sequence from 0.

Example

```
if L_array_is_dense arr; then echo "Array is dense"; fi
```

**Argument:** **`$1`** array nameref

### L_array_copy

Copy an array.

**Arguments:**

- **`$1`** Source array.
- **`$2`** Destination array.

### L_array_max_index_vL_RET

### L_array_prepend

Append elements to the front of the array.

Example

```
L_array_prepend arr "Hello" "World"
```

**Arguments:**

- **`$1`** array nameref
- **`$@`** elements to append

### L_array_clear

Clear an array.

Example

```
L_array_clear arr
```

**Argument:** **`$1`** array nameref

### L_array_extract

Assign array elements to variables in order.

Example

```
arr=("Hello" "World")
L_array_extract arr var1 var2
echo "$var1"  # prints Hello
echo "$var2"  # prints World
```

**Arguments:**

- **`$1`** array nameref
- **`$@`** variables to assign to

### L_array_reverse

Reverse elements in an array.

Example

```
arr=("world" "Hello")
L_array_reverse arr
echo "${arr[@]}"  # prints Hello world
```

**Argument:** **`$1`** array nameref

### L_readarray

Wrapper for readarray/mapfile for bash versions that do not have it.

Example

```
L_readarray arr <file
```

**Options:**

- **`-t`** Strip delimeter.
- **`-d <delim>`** separator to use, default: newline
- **`-u <fd>`** file descriptor to read from
- **`-s <count>`** skip first n lines
- **`-n <count>`** read at most n lines
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

### L_array_pipe

Pipe an array to a command and then read back into an array.

Example

```
arr=("Hello" "World")
L_array_pipe arr tr '[:upper:]' '[:lower:]'
echo "${arr[@]}"  # prints hello world
```

**Option:** **`-z`** Use null byte as separator instead of newline.

**Arguments:**

- **`$1`** array nameref
- **`$@`** command to pipe to

**Shellcheck disable=** [SC2059](https://www.shellcheck.net/wiki/SC2059)

### L_array_contains

check if array variable contains value

Example

```
arr=("Hello" "World")
L_array_contains arr "Hello"
echo $?  # prints 0
```

**Arguments:**

- **`$1`** array nameref
- **`$2`** needle

**See:** [L_args_contain](#L_lib.sh--L_args_contain)

### L_array_filter_eval

Remove elements from array for which expression evaluates to failure.

Example

```
arr=("Hello" "World")
L_array_filter_eval arr '[[ "$1" == "Hello" ]]'
echo "${arr[@]}"  # prints Hello
```

**Arguments:**

- **`$1`** array nameref
- **`$2`** expression to `eval`uate with array element of index L_i and value $1

### L_array_index

Find an index of an element in the array equal to second argument.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** array nameref
- **`$2`** element to find

### L_array_index_vL_RET

### L_array_join

Join array elements separated with the second argument.

Example

```
arr=("Hello" "World")
L_array_join -v res arr ", "
echo "$res"  # prints Hello, World
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** array nameref
- **`$2`** string to join elements with

**See:** [L_args_join](#L_lib.sh--L_args_join)

### L_array_join_vL_RET

### L_array_andjoin

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

**See:** [L_args_andjoin](#L_lib.sh--L_args_andjoin)

### L_array_andjoin_vL_RET
