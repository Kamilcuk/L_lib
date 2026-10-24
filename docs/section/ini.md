# INI

INI is a configuration file format with sections, key-value pairs, and comments. L_lib.sh provides functions to parse INI into L_obj structures and serialize L_obj back to INI.

## Key Features

- Sections with `[header]` syntax
- Key-value pairs with `=` separator
- Comments with `#` or `;`
- Type inference (strings, numbers, booleans)
- Multi-line values
- Round-trip compatibility

## Basic Usage

### Parsing INI

```bash
L_obj_from_ini config <<'INI'
[database]
host = localhost
port = 5432

[server]
host = "0.0.0.0"
port = 8080
INI
```

### Extracting values

Use `L_obj_get` with separate path arguments. Section name comes first, then key:

```bash
L_obj_get -v DB_HOST config database host     # "localhost"
L_obj_get -v DB_PORT config database port     # 5432
L_obj_get -v S_HOST config server host        # "0.0.0.0"
```

### Root-level keys

Keys outside any section are stored under an empty section name (`""`):

```bash
L_obj_get -v ROOT config "" root              # value of root key
```

### Converting L_obj to INI

```bash
L_obj_to_ini -v ini_text config
```

### Parsing from file

```bash
L_obj_from_ini config < "/etc/app/config.ini"
```

## Examples

### Root and section keys

```bash
L_obj_from_ini obj <<'INI'
root = value1

[section]
key = value2
INI

L_obj_get -v ROOT obj "" root
L_obj_get -v SECTION_KEY obj section key
```

### Comments and quoted values

```bash
L_obj_from_ini obj <<'INI'
; this is a comment
# this is also a comment

[database]
host = "localhost"   ; production server
port = 5432
INI

L_obj_get -v HOST obj database host
L_obj_get -v PORT obj database port
```

### Multi-line values

Continuation lines are joined with newlines; leading whitespace is trimmed:

```bash
L_obj_from_ini obj <<'INI'
[server]
long = first line
   second line
   third line
INI

L_obj_get -v LONG obj server long   # "first line\nsecond line\nthird line"
```

## Notes

- `L_obj_get` takes path parts as separate arguments (e.g. `database host`), not dot notation
- Root-level keys use empty string `""` as the section name
- Values after `;` or `#` are treated as comments unless quoted
- Empty values are stored as empty strings

## Internal Implementation

INI parsing is line-based:

- `L_ini_read()` - Core parsing logic, reads INI from stdin and emits KV/CONTINUATION events
- `L_obj_from_ini()` - Wrapper that calls `L_ini_read` and builds an L_obj structure
- `L_obj_to_ini()` - Serializes an L_obj back to INI text

## API Reference

::: bin/L_lib.sh ini