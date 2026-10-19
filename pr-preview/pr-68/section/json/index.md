## API Reference

## json

### L_json_escape

Produces a string properly quoted for JSON inclusion

Poor man's jq

Example

```
L_json_escape -v tmp "some string"
echo "{\"key\":$tmp}" | jq .
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**See:**

- <https://ecma-international.org/wp-content/uploads/ECMA-404.pdf> figure 5
- <https://stackoverflow.com/a/27516892/9072753>

### L_json_escape_vL_RET

### L_json_create

Very simple function to create JSON.

Every second argument is quoted for JSON, unless This argument is preceeded by a previous argument ending with \] or }, when the counter starts over.

Example

```
L_json_create { \
  a : b , \
  b :[ 1 , 2 , 3 , 4 ] \
  c :[true, 1 ,null,false] \
}
#   ^^^^^^    ^^^^^^^^^^^^ - unquoted, added literally to the string
# outputs: {"a":"b","b":[1,2,3,4],"c":[true,"1",false,null]}
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

### L_json_create_vL_RET
