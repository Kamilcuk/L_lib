# sysexits

Standard exit codes based on `sysexits.h`.
See [sysexits(3head)](https://man7.org/linux/man-pages/man3/sysexits.h.3head.html) for more information.

| Variable | Value | Description |
| :--- | :--- | :--- |
| `L_EX_OK` | 0 | Successful termination. |
| `L_EX_USAGE` | 64 | Command line usage error. |
| `L_EX_DATAERR` | 65 | Data format error. |
| `L_EX_NOINPUT` | 66 | Cannot open input. |
| `L_EX_NOUSER` | 67 | Addressee unknown. |
| `L_EX_NOHOST` | 68 | Host name unknown. |
| `L_EX_UNAVAILABLE` | 69 | Service unavailable. |
| `L_EX_SOFTWARE` | 70 | Internal software error. |
| `L_EX_OSERR` | 71 | System error (e.g., can't fork). |
| `L_EX_OSFILE` | 72 | Critical OS file missing. |
| `L_EX_CANTCREAT` | 73 | Can't create (user) output file. |
| `L_EX_IOERR` | 74 | Input/output error. |
| `L_EX_TEMPFAIL` | 75 | Temp failure; user is invited to retry. |
| `L_EX_PROTOCOL` | 76 | Remote error in protocol. |
| `L_EX_NOPERM` | 77 | Permission denied. |
| `L_EX_CONFIG` | 78 | Configuration error. |
| `L_EX_TIMEOUT` | 124 | The command timed out. |

## Generated documentation from source:

::: bin/L_lib.sh sysexits
