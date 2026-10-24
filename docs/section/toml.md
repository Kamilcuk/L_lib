# TOML

TOML (Tom's Obvious, Minimal, Top-level) is a human-readable configuration format. L_lib.sh provides functions to parse TOML into L_obj structures and serialize L_obj back to TOML.

## Key Features

- Table-based hierarchy (nested sections)
- Type inference (strings, integers, floats, booleans, DATETIME, DATE, TIME)
- Round-trip compatibility (parse → object → TOML preserves structure)
- Inline tables and multiline strings

## Basic Usage

### Parsing TOML

```bash
L_obj_from_toml config <<'TOML'
[database]
host = "localhost"
port = 5432

[server]
host = "0.0.0.0"
port = 8080
TOML
```

### Extracting values

Use `L_obj_get` with separate path arguments (not dot notation):

```bash
L_obj_get -v DB_HOST config database host     # "localhost"
L_obj_get -v DB_PORT config database port     # 5432
L_obj_get -v S_HOST config server host        # "0.0.0.0"
```

### Converting L_obj to TOML

```bash
L_obj_to_toml -v toml_text config
```

## Examples

### Simple configuration

```bash
L_obj_from_toml cfg <<'TOML'
[database]
host = "db.example.com"
port = 5432
TOML

L_obj_get -v DB_HOST cfg database host
L_obj_get -v DB_PORT cfg database port
```

### Inline tables

```bash
L_obj_from_toml cfg <<'TOML'
a = { b = 1, c = 2 }
TOML

L_obj_get -v AB cfg a b   # 1
L_obj_get -v AC cfg a c   # 2
```

### Root key-value pairs

```bash
L_obj_from_toml cfg <<'TOML'
app_name = "MyApp"
version = "1.2.3"
TOML

L_obj_get -v NAME cfg app_name
L_obj_get -v VERSION cfg version
```

### Datetime, date, and time values

```bash
L_obj_from_toml cfg <<'TOML'
odt = 1979-05-27T07:32:00Z
ld = 1979-05-27
lt = 07:32:00
TOML

L_obj_get -v ODT cfg odt
L_obj_get -v LD cfg ld
L_obj_get -v LT cfg lt
```

### Multiline strings

```bash
L_obj_from_toml cfg <<'TOML'
[description]
text = """
This is a multiline
string value.
"""
TOML

L_obj_get -v TEXT cfg description text
```

## Notes

- `L_obj_get` takes path parts as separate arguments (e.g. `database host`), not dot notation (`database.host`)
- Inline arrays (`arr = [1, 2, 3]`) and arrays of tables (`[[servers]]`) have parser limitations
- Nested table headers (`[a.b]`) have parser limitations

## Internal Implementation

TOML parsing uses a recursive descent parser:

- `L_toml_read()` - Main entry point, reads TOML from stdin and dispatches to callbacks
- `L_toml_parse()` - Recursive parser that processes tokens and emits events
- `L_obj_from_toml()` - Wrapper that calls `L_toml_read` and builds an L_obj structure

Parser events include: VALUE, START/END (inline containers), TABLE MAP, TABLE ARRAY.

This design avoids process spawning overhead by doing all parsing in-process.

## API Reference

::: bin/L_lib.sh toml