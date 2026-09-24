## API Reference

## sort

Array sorting function.

### L_shuf_bash

Shuffle an array

**Argument:** **`$1`** array nameref

### L_shuf_cmd

Shuffle an array using shuf command

**Option:** **`-z --zero-terminated`** use zero separated stream with shuf -z

**Arguments:**

- **`$*`** any options are forwarded to shuf command
- **`$-1`** array nameref

### L_shuf

Shuffle an array

**Argument:** **`$1`** array nameref

### L_sort_bash

Quicksort an array in place in pure bash.

**Options:**

- **`-z`** ignored. Always zero sorting.
- **`-n`** Numeric sort, otherwise lexical.
- **`-g`** Floating point number sort.
- **`-r`** Reverse sort.
- **`-u`** Unique values only.
- **`-c <compare>`** Custom compare function that returns 0 when $1 > $2 and 1 otherwise.
- **`-E <eval>`** Custom expression to evaluate just like -c option.
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

**See:** [L_sort](#L_lib.sh--L_sort)

### L_sort_cmd

Sort an array using sort command.

Even in most optimized code that I could write for bash sorting, still executing sort command is faster. The difference becomes significant for large arrays. Sorting 100 element array with bash is 0.049s and with sort is 0.022s.

Example

```
arr=(5 2 5 1)
L_sort_cmd -n arr
echo "${arr[@]}"  # 1 2 5 5
```

**Options:**

- **`-z --zero-terminated`** use zero separated stream with sort -z
- **`-n`** numeric sort

**Arguments:**

- **`$*`** any options are forwarded to sort command
- **`$-1`** last argument is the array nameref

### L_sort

Sort a bash array.

Dispatches to L_sort_bash if array length < 300 or a custom comparison (-c, -E) is provided. Otherwise, it uses L_sort_cmd for performance (calling the system sort command).

**Options:**

- **`-z`** Use zero separated stream with sort -z (forwarded to sort command)
- **`-n`** numeric sort
- **`-r`** reverse sort
- **`-u`** unique values only
- **`-c <compare>`** Custom compare function (uses L_sort_bash)
- **`-E <eval>`** Custom expression to evaluate (uses L_sort_bash)
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

**See:**

- [L_sort_bash](#L_lib.sh--L_sort_bash)
- [L_sort_cmd](#L_lib.sh--L_sort_cmd)
