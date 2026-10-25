# L_obj

L_obj represents arbitrary nested data with two container types: MAP and ARRAY. Values can be any type: STRING, INTEGER, FLOAT, BOOL, NULL, DATETIME, DATE, TIME, MAP, ARRAY.

## Container Types

- **MAP** – Holds a mapping of string keys to values
- **ARRAY** – Holds an ordered list of values

## Basic Usage

### Building an object

```bash
L_obj_new obj
L_obj_set_typed obj name = STRING "MyApp"
L_obj_set_typed obj version = STRING "1.0.0"
```

The `=` argument immediately follows the path parts, separating them from the type and value:

```
L_obj_set_typed <obj> <parts...> = <type> [value]
```

The `=` is the argument right after the last path part (or right after `<obj>` when no path parts are given). The `<value>` is optional — defaults to `""`. Container types (MAP, ARRAY) and NULL ignore it entirely. If you need a path part literally named `=`, provide a value (e.g., `= MAP ""`) to disambiguate.

### Auto-creation of intermediate nodes

`L_obj_set_typed` and `L_obj_set` auto-create intermediate container nodes as you descend. The type of each missing intermediate node is determined by the **next path part** descended into:

- **MAP** — when the next path part is a string key (anything other than `"0"`)
- **ARRAY** — when the next path part is `"0"` (integer index)

> **Note:** A key named `"0"` always creates an ARRAY child. To have a MAP with a key `"0"`, explicitly create it first with `L_obj_set_typed obj path = MAP`.

```bash
L_obj_set_typed obj server host = STRING "localhost"
# Auto-creates: root MAP -> child "server" (MAP) -> grandchild "host" (STRING)

L_obj_set_typed obj arr 0 = STRING "first"
# Auto-creates: root MAP -> child "arr" (ARRAY) -> index 0 (STRING)
```

Only the **final** node gets its specified type; intermediate nodes default to MAP (or ARRAY when descending via index `0`).

#### Auto-creation with `L_obj_array_append_typed`

`L_obj_array_append_typed` also auto-creates the target ARRAY if it doesn't exist, and can append container types (MAP, ARRAY):

```bash
# 'items' does not exist yet; auto-created as ARRAY, STRING appended at index 0
L_obj_array_append_typed obj items += STRING "first"

# Append an empty MAP, capturing its position with -v
L_obj_array_append_typed -v pos obj users += MAP
L_obj_set_typed obj+${pos} name = STRING "Alice"
```

### Value type inference with `L_obj_set`

`L_obj_set` infers the type from the value:

- **INTEGER** – whole numbers (e.g. `42`, `-7`)
- **FLOAT** – numbers with a decimal point or exponent (e.g. `3.14`, `-2.5e10`, `1E3`)
- **BOOL** – `true` and `false`
- **STRING** – everything else (including `+100`, since a leading `+` is not valid JSON)

```bash
L_obj_set obj count = 42          # INTEGER
L_obj_set obj pi = 3.14           # FLOAT
L_obj_set obj active = true       # BOOL
L_obj_set obj name = "MyApp"      # STRING
L_obj_set obj exp = 1e10          # FLOAT
```

`L_obj_set_default` works the same but only sets the value if the node is not already set.

### Appending values

`L_obj_array_append` appends to an ARRAY with type inferred from the value:

```bash
L_obj_set_typed obj arr = ARRAY
L_obj_array_append obj arr += 1        # INTEGER
L_obj_array_append obj arr += 2.5      # FLOAT
L_obj_array_append obj arr += "text"   # STRING
```

`L_obj_array_append_typed` is the explicit-type counterpart, with optional `<value>` and `-v <var>` to capture the new element's position:

```bash
L_obj_array_append_typed [-v <var>] obj <parts...> += <type> [value]

L_obj_array_append_typed obj arr += INTEGER 42
L_obj_array_append_typed obj arr += STRING "text"
L_obj_array_append_typed obj arr += FLOAT 3.14
L_obj_array_append_typed obj arr += BOOL true
L_obj_array_append_typed obj arr += NULL
```

`L_obj_string_append` appends text to an existing STRING node:

```bash
L_obj_set_typed obj msg = STRING "Hello"
L_obj_string_append obj msg += ", World"
L_obj_get -v RESULT obj msg     # "Hello, World"
```

### Reading values

```bash
L_obj_get -v name obj name          # "MyApp"
L_obj_get -v version obj version    # "1.0.0"
```

### Building nested objects

```bash
L_obj_set_typed obj server = MAP
L_obj_set_typed obj server host = STRING "localhost"
L_obj_set_typed obj server port = INTEGER 8080

L_obj_get -v host obj server host   # "localhost"
L_obj_get -v port obj server port   # 8080
```

### Position references (`obj+<pos>`)

`L_obj_pos` returns the numeric index of a node in the flat internal array. You can then use `obj+<pos>` to access that node directly, avoiding full path traversal from the root:

```bash
L_obj_set_typed obj a b c = STRING "deep"
L_obj_pos -v pos obj a b c     # pos = index of obj.a.b.c
L_obj_get -v val "obj+${pos}"   # "deep"
```

This is especially useful in loops:

```bash
# Efficient: resolve position once, reuse child positions directly
L_obj_pos -v pos obj a b
while L_obj_iter "obj+${pos}" it key val type child_pos; do
    L_obj_get -v name "obj+${child_pos}" name
done
```

#### Position validity

A position is **invalidated** when the node at that position is freed:

 - `L_obj_rm` — removes a node and its subtree
 - `L_obj_clear` — frees children of a container
 - `L_obj_new` — reallocates the entire object
 - `L_obj_copy` — replaces the destination's children with a deep copy
 - `L_obj_merge` — replaces destination children with merged content
 - `L_obj_array_pop` — removes the last element of an ARRAY
 - `L_obj_array_shift` — removes the first element of an ARRAY

**Adding** nodes (`L_obj_set_typed`, `L_obj_array_append`, etc.) **never** invalidates existing positions — new nodes are appended at the end or placed into freed slots without moving existing nodes. Only **removal** invalidates.

`L_obj_is_valid` checks whether a position still points to a non-FREE node, but it does **not** guarantee the position refers to the *original* node — a freed slot may be reused by a subsequent allocation.

> **Best practice:** Get positions once and reuse them freely. Adding nodes never invalidates positions — only removals (`L_obj_rm`, `L_obj_clear`, `L_obj_new`, `L_obj_copy`, `L_obj_merge`, `L_obj_array_pop`, `L_obj_array_shift`) do.

### Container lifecycle

| Function | What it does | Use for |
|---|---|---|
| `L_obj_new obj [type]` | Reinitializes to empty | Starting fresh or resetting |
| `L_obj_clear obj [parts...]` | Removes **children**; preserves the container (`{} / []`) | Emptying an existing MAP or ARRAY |
| `L_obj_rm obj [parts...]` | Removes the node **and its subtree** entirely | Deleting a key or subtree |

When `L_obj_new` is called without a type (e.g., `L_obj_new obj`), it creates an empty, untyped object. The first `L_obj_set_typed` call then determines the root type through path descent. When a type is specified (e.g., `L_obj_new obj MAP`), the root node is immediately created with that type.

> Use `L_obj_new` to initialize — not `L_obj_clear`.

#### `L_obj_clear` — empty an existing container

```bash
L_obj_set_typed obj data = MAP
L_obj_set_typed obj data a = STRING "x"
L_obj_set_typed obj data b = STRING "y"

L_obj_clear obj data       # obj.data is still MAP, but now empty: {}
```

#### `L_obj_rm` — remove a node entirely

```bash
L_obj_set_typed obj server = MAP
L_obj_set_typed obj server host = STRING "localhost"

L_obj_rm obj server host   # obj.server is still MAP, but "host" is gone
L_obj_rm obj server        # obj has no "server" key at all
```

### Iterating over keys

```bash
L_obj_keys -v keys obj
for key in "${keys[@]}"; do
    L_obj_get -v value obj "$key"
    echo "$key: $value"
done
```

### Checking existence and length

```bash
L_obj_has obj server && echo "server exists"
L_obj_len -v len obj                # number of top-level keys
```

### Converting to other formats

```bash
L_obj_to_json -v json_text obj
L_obj_to_toml -v toml_text obj
L_obj_to_ini -v ini_text obj
```

### Real-world example: building an array of objects

The `L_obj_array_append_typed -v <var>` pattern is the core building block for constructing arrays of objects. This self-contained example parses a JSON array of orders, filters unpaid ones, extracts compact fields, aggregates revenue, and groups by user:

```bash
input='{"orders":[
  {"id":1,"user":"anna","total":120.5,"items":["pen","book"],"paid":true},
  {"id":2,"user":"piotr","total":15,"items":["pen"],"paid":false},
  {"id":3,"user":"anna","total":60,"items":["lamp"],"paid":true}
]}'

L_obj_from_json ordersobj <<<"$input"

# Filter unpaid orders into a new ARRAY of MAPs
L_obj_new unpaid_orders ARRAY
it=""
while L_obj_iter ordersobj it index value type position; do
    L_obj_get -v paid ordersobj+${position} paid
    if [[ "$paid" == false ]]; then
        L_obj_array_append_typed -v elem unpaid_orders += MAP
        L_obj_copy ordersobj+${position} unpaid_orders+${elem}
    fi
done

# Extract only id and total
L_obj_new extractobj ARRAY
it=""
while L_obj_iter ordersobj it index value type position; do
    L_obj_array_append_typed -v elem extractobj += MAP
    L_obj_get -v id ordersobj+${position} id
    L_obj_set extractobj+${elem} id = "$id"
    L_obj_get -v total ordersobj+${position} total
    L_obj_set extractobj+${elem} total = "$total"
done
# extractobj: [{"id":1,"total":120.5},{"id":2,"total":15},{"id":3,"total":60}]

# Aggregate revenue from paid orders
totalsum=0
it=""
while L_obj_iter ordersobj it index value type position; do
    L_obj_get -v paid ordersobj+${position} paid
    if [[ "$paid" == true ]]; then
        L_obj_get -v total ordersobj+${position} total
        L_float -v totalsum "$totalsum + $total"
    fi
done
echo "Total revenue: $totalsum"   # 180.5

# Group by user (sum totals per user)
L_obj_new usersobj MAP
it=""
while L_obj_iter ordersobj it index value type position; do
    L_obj_get -v user ordersobj+${position} user
    L_obj_get -v total ordersobj+${position} total
    L_obj_get_or -v cur usersobj "$user" 0
    L_float -v sum "$cur + $total"
    L_obj_set usersobj "$user" = "$sum"
done
# usersobj: {"anna":180.5,"piotr":15}
```

## Internal Details

OBJ stores a tree structure in a flat Bash array where each node occupies 6 consecutive elements: [kind, key, value, next, prev, parent].

### Node fields

| Offset | What | Description |
| --- | --- | --- |
| 0 | kind | One of FREE MAP ARRAY STRING INTEGER FLOAT BOOL NULL DATETIME DATE TIME |
| 1 | key | If root element, index of first FREE element. If parent is MAP, this is the key value. |
| 2 | value | For MAP/ARRAY it is the first child index. |
| 3 | next | Next sibling index (for both MAP and ARRAY children) |
| 4 | prev | Previous sibling index (for both MAP and ARRAY children) |
| 5 | parent | Pointer to parent. Empty for the root node |

```
"A" becomes: (
  [0]  STRING  ""  A  ""  ""  ""
)
["a", 5] becomes: (
 [0]  ARRAY   ""  5   ""  ""  ""
 [5]  STRING  ""  a   10  ""  0
 [10] INTEGER ""  5   ""  5   0
)
{"a":[0,1,2,3,4,5]} becomes: (
  [0]  MAP     ""  5   ""  ""  ""
    [5]  ARRAY   a   10  ""  ""  0
       [10] INTEGER ""  0   15  ""  5
       [15] INTEGER ""  1   20  10  5
       [20] INTEGER ""  2   25  15  5
       [25] INTEGER ""  3   30  20  5
       [30] INTEGER ""  4   35  25  5
       [35] INTEGER ""  5   ""  30  5
)
{"a":"b","c":1} becomes: (
  [0]  MAP     ""  5  ""  ""  ""
    [5]  STRING  a   b   10 ""  0
    [10] INTEGER c   1   ""  5   0
)
{"a":{"b":[1,"x"]},"c":null}  becomes: (
  [0]  MAP     ""  5   ""  ""  ""
    [5]  MAP     a   10  25  ""  0
      [10] ARRAY   b   15  ""  ""  5
        [15] INTEGER ""  1   20  ""  10
        [20] STRING  ""  x   ""  15  10
    [25] NULL    c   ""  ""  5   0
)
```

With free list:

```
{"a":{"b":[1,"x"]},"c":null}  becomes: (
  [0]  MAP     10  5   ""  ""  ""
    [5]  MAP     a   15  35  ""  0
[10] FREE "" "" 20 ""  ""
      [15] ARRAY   b   25  ""  ""  5
[20] FREE "" "" ""  ""  ""
        [25] INTEGER ""  1   30  ""  15
        [30] STRING  ""  x   ""  25  15
    [35] NULL    c   ""  ""  5   0
)
```

## API Reference

::: bin/L_lib.sh obj
