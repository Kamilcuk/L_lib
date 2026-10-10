# L_obj is a Bash array of 5 elements per node.

## Node fields:

| Offset | What  | Description                                                                            |
| ---    | ---   | ---                                                                                    |
| 0      | kind  | One of FREE MAP ARRAY STRING INTEGER FLOAT BOOL NULL                                   |
| 1      | key   | If root element, index of first FREE element. If parent is MAP, this is the key value. |
| 2      | value | For MAP/ARRAY it is the first child index.                                             |
| 3      | next  | If kind is FREE or parent is MAP, the next sibling index.                              |
| 4      | prev  | If parent is MAP, previous sibling index.                                              |

## Examples

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
