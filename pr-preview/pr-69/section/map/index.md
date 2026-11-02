## API Reference

## map

Key value store without associative array support

L_map consist of an null initial value. L_map stores keys and values separated by a tab, with an empty leading newline. Value is qouted by printf %q . Map key may not contain newline or tab characters.

```
                # empty initial newline
key<TAB>$'value'
key2<TAB>$'value2' # no trailing newline
```

This format matches the regexes used in L_map_get for easy extraction using bash variable substitution. The map depends on printf %q never outputting a newline or a tab character, instead using $'\\t\\n' form.

### L_map_assign

Initializes a map

Example

```
local var
L_map_assign var a 1 b 2
```

**Arguments:**

- **`$1`** var variable name holding the map
- **`$@`** Pairs of keys and values to assign to the map.

### L_map_clear

Clear a map

**Argument:** **`$1`** var variable name holding the map

### L_map_remove

Clear a key of a map

Example

```
L_map_assign var a 1
L_map_remove var a
if L_map_has var a; then
  echo "a is set"
else
  echo "a is not set"
fi
```

**Arguments:**

- **`$1`** var map
- **`$2`** str key

### L_map_set

Set a key in a map to value

Example

```
L_map_assign var
L_map_set var a 1
L_map_set var b 2
```

**Arguments:**

- **`$1`** var map
- **`$2`** str key
- **`$3`** str value

### L_map_set_noremove

Set a key in a map to value, potentially resulting in duplicate keys.

**Arguments:**

- **`$1`** var map
- **`$2`** str key
- **`$3`** str value

### L_map_get

Assigns the value of key in map.

If the key is not set, then assigns default if given and returns with 1. You want to prefer this version of L_map_get

Example

```
L_map_clear var
L_map_set var a 1
L_map_get -v tmp var a
echo "$tmp"  # outputs: 1
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** var map
- **`$2`** str key
- **`[$3]`** str default

### L_map_get_vL_RET

### L_map_has

Example

```
L_map_clear var
L_map_set var a 1
if L_map_has var a; then
  echo "a is set"
fi
```

**Arguments:**

- **`$1`** var map
- **`$2`** str key

**Exit:** 0 if map contains key, nonzero otherwise

### L_map_setdefault

set value of a map if not set

**Arguments:**

- **`$1`** var map
- **`$2`** str key
- **`$3`** str default value

### L_map_append

Append value to an existing key in map

**Arguments:**

- **`$1`** var map
- **`$2`** str key
- **`$3`** str value to append

### L_map_keys

List all keys in the map.

Example

```
L_map_clear var
L_map_set var a 1
L_map_set var b 2
L_map_keys -v tmp var
echo "${tmp[@]}"  # outputs: 'a b'
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** var map

### L_map_keys_vL_RET

### L_map_values

List all values in the map.

Example

```
L_map_clear var
L_map_set var a 1
L_map_set var b 2
L_map_values -v tmp var
echo "${tmp[@]}"  # outputs: '1 2'
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** var map

### L_map_values_vL_RET

### L_map_items

List items on newline separated key value pairs.

Example

```
L_map_clear var
L_map_set var a 1
L_map_set var b 2
L_map_items -v tmp var
echo "${tmp[@]}"  # outputs: 'a 1 b 2'
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** var map

### L_map_items_vL_RET

### L_map_load

Load all keys to variables with the name of $prefix$key.

Example

```
L_map_clear var
L_map_set var a 1
L_map_set var b 2
L_map_load var PREFIX_
echo "$PREFIX_a $PREFIX_b"  # outputs: 1 2
```

**Arguments:**

- **`$1`** map variable
- **`$2`** prefix
- **`$@`** Optional list of keys to load. If not set, all are loaded.

### L_map_save

Save all variables with prefix to a map.

Example

```
L_map_clear var
PREFIX_a=1
PREFIX_b=2
L_map_save var PREFIX_
L_map_items -v tmp var
echo "${tmp[@]}"  # outputs: 'a 1 b 2'
```

**Arguments:**

- **`$1`** map variable
- **`$2`** prefix
