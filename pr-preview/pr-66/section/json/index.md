# JSON

JSON (JavaScript Object Notation) is a data-interchange format. L_lib.sh provides functions to parse JSON into L_obj structures, query JSON directly, and serialize L_obj back to JSON.

## Key Features

- Full JSON support (objects, arrays, strings, numbers, booleans, null)
- Unicode handling with proper escaping
- Path-based access to nested values
- Round-trip compatibility
- Pretty printing with configurable indentation
- Direct JSON querying without L_obj conversion

## Basic Usage

### Parsing JSON into L_obj

```
L_obj_from_json obj <<'JSON'
{"name": "MyApp", "version": "1.2.3"}
JSON
```

### Extracting values from L_obj

Use `L_obj_get` with separate path arguments:

```
L_obj_get -v NAME obj name           # "MyApp"
L_obj_get -v VERSION obj version     # "1.2.3"
```

### Converting L_obj to JSON

```
L_obj_to_json -v json_text obj
```

### Pretty printing JSON

```
L_json_print -i 2 <<'JSON'
{"a":1,"b":{"c":2}}
JSON
```

## Examples

### Simple object

```
L_obj_from_json obj <<'JSON'
{"name": "MyApp", "version": "1.2.3"}
JSON

L_obj_get -v NAME obj name
L_obj_get -v VERSION obj version
```

### Nested object

```
L_obj_from_json obj <<'JSON'
{"server": {"host": "localhost", "port": 8080}}
JSON

L_obj_get -v SERVER_HOST obj server host
L_obj_get -v SERVER_PORT obj server port
```

### Direct JSON querying

Query a JSON string directly without converting to L_obj first:

```
L_json_get -v NAME '{"name": "MyApp"}' name
L_json_get -v COUNT '{"a": [1, 2, 3]}' a 1 c
```

### Removing elements from JSON

```
L_json_rm -v json_no_d '{"a": 1, "d": 2}' d
```

## Notes

- `L_obj_get` takes path parts as separate arguments (e.g. `server host`), not dot notation
- `L_json_get` queries raw JSON strings directly (no L_obj needed)
- `L_json_print` parses JSON to L_obj internally then serializes with formatting
- Use `-i <indent>` with `L_obj_to_json` or `L_json_print` for indented output
- Use `-c` for compact output

## Internal Implementation

JSON processing uses a recursive descent parser:

- `L_obj_from_json()` - Parses JSON from stdin into an L_obj structure
- `L_json_get()` / `L_json_get_all()` - Query raw JSON directly, returning value, type, and byte offsets
- `L_json_rm()` - Remove an element from a JSON string
- `L_obj_to_json()` - Serializes an L_obj back to JSON with formatting options
- `L_json_print()` - Convenience: parse to L_obj then pretty-print

## API Reference

## json

### L_json_quote

Convert Bash string into Json string.

**Option:** **`-v <var>`**

**Argument:** **`<str>`**

### L_json_quote_vL_RET

### L_json_quote_ascii

Convert Bash string into Json string with only ASCII characters.

**Option:** **`-v <var>`**

**Argument:** **`<str>`**

### L_json_quote_ascii_vL_RET

### L_json_unquote

Convert Json string into Bash string.

**Option:** **`-v <var>`**

**Argument:** **`<str>`**

### L_json_unquote_vL_RET

### L_json_get_all

Get a value from json including additional info.

**Options:**

- **`-v <var>`**
- **`-h`**

**Return:** ( )

### L_json_get_all_vL_RET

### L_json_get

Get a value from json.

**Options:**

- **`-v <var>`**
- **`-h`**

### L_json_get_vL_RET

### L_json_rm

Remove an element from json.

**Options:**

- **`-v <var>`**
- **`-h`**

### L_json_rm_vL_RET

### L_json_print

Print nicely looking version of the json.

**Options:**

- **`-a`** Use only ascii characters escapes in strings.
- **`-c`** Compact output.
- **`-i <int>`** Indent count of spaces.
- **`-C`** Color output.
- **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** JSON
