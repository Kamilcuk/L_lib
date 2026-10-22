# L_obj

L_obj represents arbitrary nested data with two container types: MAP and ARRAY. MAP holds a mapping of string keys to values, while ARRAY holds a list of values. Values can be any type: STRING, INTEGER, FLOAT, BOOL, NULL, MAP, ARRAY.

## Container Types

- **MAP** – Holds a mapping of string keys to values
- **ARRAY** – Holds an ordered list of values

## Value Types

Each node holds one of these types: STRING, INTEGER, FLOAT, BOOL, NULL, DATETIME, DATE, TIME, MAP, ARRAY.

## Basic Usage

### Building an object

```bash
L_obj_clear obj
L_obj_set_typed_value obj name = STRING "MyApp"
L_obj_set_typed_value obj version = STRING "1.0.0"
```

The `=` argument is required as the 3rd argument from the back, separating path parts from the type and value. Path parts are all arguments between the object name and the `=`:

```
L_obj_set_typed_value <obj> <parts...> = <type> <value>
```

`L_obj_set_typed` and `L_obj_set_typed_value` auto-create intermediate container nodes as you descend through path parts. Each missing intermediate node is created as MAP by default (ARRAY if the path part is `0`). For example:

```bash
L_obj_set_typed_value obj server host = STRING "localhost"
# Auto-creates: root MAP -> child "server" (MAP) -> grandchild "host" (STRING = "localhost")
```

Only the final node in the path gets its type set; intermediate nodes default to MAP.

### Value type inference with `L_obj_set_value`

`L_obj_set_value` infers the type from the value without requiring an explicit type argument:

- **INTEGER** – whole numbers (e.g. `42`, `-7`, `+100`)
- **FLOAT** – numbers with a decimal point or exponent (e.g. `3.14`, `-2.5e10`, `1E3`)
- **STRING** – everything else

```bash
L_obj_set_value obj count = 42          # inferred: INTEGER
L_obj_set_value obj pi = 3.14           # inferred: FLOAT
L_obj_set_value obj name = "MyApp"      # inferred: STRING
L_obj_set_value obj exp = 1e10          # inferred: FLOAT
```

`L_obj_set_default_value` works the same but only sets the value if the node is not already set.

### Appending values

`L_obj_array_append_value` appends a new element to an ARRAY node. The `+=` argument is required as the second-to-last argument, before the value:

```bash
L_obj_array_append_value obj <parts...> += <value>
```

The type is inferred from the value (INTEGER, FLOAT, or STRING):

```bash
L_obj_set_typed obj arr = ARRAY
L_obj_array_append_value obj arr += 1        # INTEGER
L_obj_array_append_value obj arr += 2.5      # FLOAT
L_obj_array_append_value obj arr += "text"   # STRING
```

`L_obj_string_append` appends text to an existing STRING node. The `+=` argument is required as the second-to-last argument:

```bash
L_obj_string_append obj <parts...> += <text>
```

Example:

```bash
L_obj_set_typed_value obj msg = STRING "Hello"
L_obj_string_append obj msg += ", World"
L_obj_get -v RESULT obj msg     # "Hello, World"
```

### Reading values

Use `L_obj_get` with path parts as separate arguments:

```bash
L_obj_get -v name obj name          # "MyApp"
L_obj_get -v version obj version    # "1.0.0"
```

### Building nested objects

```bash
L_obj_set_typed obj server = MAP
L_obj_set_typed_value obj server host = STRING "localhost"
L_obj_set_typed_value obj server port = INTEGER 8080

L_obj_get -v host obj server host   # "localhost"
L_obj_get -v port obj server port   # 8080
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

## Internal Details

OBJ stores a tree structure in a flat Bash array where each node occupies 5 consecutive elements: [kind, key, value, next, prev].

### Node fields

| Offset | What | Description |
| --- | --- | --- |
| 0 | kind | One of FREE MAP ARRAY STRING INTEGER FLOAT BOOL NULL DATETIME DATE TIME |
| 1 | key | If root element, index of first FREE element. If parent is MAP, this is the key value. |
| 2 | value | For MAP/ARRAY it is the first child index. |
| 3 | next | If kind is FREE or parent is MAP, the next sibling index. |
| 4 | prev | If parent is MAP, previous sibling index. |
| 5 | parent | Pointer to parent |

```
"A" becomes: (
  [0]  STRING  ""  A  ""  ""
)
["a", 5] becomes: (
 [0]  ARRAY   ""  5   ""  ""
 [5]  STRING  ""  a   10  ""
 [10] INTEGER ""  5   ""  5
)
{"a":[0,1,2,3,4,5]} becomes: (
  [0]  MAP     ""  5   ""  ""
    [5]  ARRAY   a   10  ""  ""
       [10] INTEGER ""  0   15  ""
       [15] INTEGER ""  1   20  10
       [20] INTEGER ""  2   25  15
       [25] INTEGER ""  3   30  20
       [30] INTEGER ""  4   35  25
       [35] INTEGER ""  5   ""  30
)
{"a":"b","c":1} becomes: (
  [0]  MAP     ""  5  ""  ""
    [5]  STRING  a   b   10 ""
    [10] INTEGER c   1   "" 5
)
{"a":{"b":[1,"x"]},"c":null}  becomes: (
  [0]  MAP     ""  5   ""  ""
    [5]  MAP     a   10  25  ""
      [10] ARRAY   b   15  ""  ""
        [15] INTEGER ""  1   20  ""
        [20] STRING  ""  x   ""  15
    [25] NULL    c   ""  ""  5
)
```

With free list:

```
{"a":{"b":[1,"x"]},"c":null}  becomes: (
  [0]  MAP     10  5   ""  ""
    [5]  MAP     a   15  35  ""
 [10] FREE "" "" 20 ""
      [15] ARRAY   b   25  ""  ""
 [20] FREE "" "" "" ""
        [25] INTEGER ""  1   30  ""
        [30] STRING  ""  x   ""  25
    [35] NULL    c   ""  ""  5
)
```

### Implementation

- Tree structure stored in a flat Bash array (no associative arrays required)
- Nodes indexed by array position, enabling Bash 3.2+ compatibility
- Free list for memory reuse (deleted nodes return to the free list)
- Recursive traversal via `L_obj_walk`

This structure enables efficient lookup without associative arrays on Bash 3.2+.

## API Reference

::: bin/L_lib.sh obj
