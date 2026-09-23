## API Reference

## asa

Collection of function to work on associative array.

Maybe will renamed to dict. "asa" sounds better than "assarray", less confusing than "asarray" and shorter that associative array.

Note

unstable

### L_asa_copy

Copy associative dictionary

Notice: the destination array is cleared. Much faster then L_asa_copy. Note: Arguments are in different order.

Example

```
local -A map=([a]=b [c]=d)
local -A mapcopy=()
L_asa_copy map mapcopy
```

**Arguments:**

- **`$1`** var Source associative array
- **`$2`** var Destination associative array

### L_asa_has

check if associative array has key

**Arguments:**

- **`$1`** associative array nameref
- **`$2`** key

### L_asa_get

Get value from associative array

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** associative array nameref
- **`$2`** key
- **`[$3]`** optional default value

**Exit:** 1 if no key found and no default value

### L_asa_get_vL_RET

### L_asa_len

get the length of associative array

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** associative array nameref

### L_asa_len_vL_RET

### L_asa_keys

get keys of an associative array

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** associative array nameref

### L_asa_keys_vL_RET

### L_asa_set

assign value to associative array

You might think why this function exists? In case you have associative array name in a variable.

Example

```
local -A map
printf -v "map[a]" "%s" val  # will fail in bash 4.0
L_asa_set map a val  # will work in bash4.0
```

**Arguments:**

- **`$1`** assoatiative array variable
- **`$2`** key to assign to
- **`$3`** value to assign

### L_asa_cmp

check if one associative array is equal to another

Example

```
local -A a=([a]=1 [b]=2)
local -A b=([a]=1 [b]=2)
if L_asa_cmp a b; then
    echo "equal"
fi
```

**Arguments:**

- **`$1`** associative array name
- **`$2`** associative array name

**Exit:** 0 if equal, 1 otherwise
