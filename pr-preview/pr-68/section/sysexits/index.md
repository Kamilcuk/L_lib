# sysexits

Standard exit codes based on `sysexits.h`. See [sysexits(3head)](https://man7.org/linux/man-pages/man3/sysexits.h.3head.html) for more information.

| Variable           | Value | Description                             |
| ------------------ | ----- | --------------------------------------- |
| `L_EX_OK`          | 0     | Successful termination.                 |
| `L_EX_USAGE`       | 64    | Command line usage error.               |
| `L_EX_DATAERR`     | 65    | Data format error.                      |
| `L_EX_NOINPUT`     | 66    | Cannot open input.                      |
| `L_EX_NOUSER`      | 67    | Addressee unknown.                      |
| `L_EX_NOHOST`      | 68    | Host name unknown.                      |
| `L_EX_UNAVAILABLE` | 69    | Service unavailable.                    |
| `L_EX_SOFTWARE`    | 70    | Internal software error.                |
| `L_EX_OSERR`       | 71    | System error (e.g., can't fork).        |
| `L_EX_OSFILE`      | 72    | Critical OS file missing.               |
| `L_EX_CANTCREAT`   | 73    | Can't create (user) output file.        |
| `L_EX_IOERR`       | 74    | Input/output error.                     |
| `L_EX_TEMPFAIL`    | 75    | Temp failure; user is invited to retry. |
| `L_EX_PROTOCOL`    | 76    | Remote error in protocol.               |
| `L_EX_NOPERM`      | 77    | Permission denied.                      |
| `L_EX_CONFIG`      | 78    | Configuration error.                    |
| `L_EX_TIMEOUT`     | 124   | The command timed out.                  |

## API Reference

## sysexits

Standard exit codes based on sysexits.h.

These codes are used to standardize return values and exit statuses throughout the library.

### $L_EX_OK

Successful termination.

### $L_EX_USAGE

The command was used incorrectly, e.g., with the wrong number of arguments, a bad flag, a bad syntax in a parameter, or whatever.

### $L_EX_DATAERR

The input data was incorrect in some way. This should only be used for user's data & not system files.

### $L_EX_NOINPUT

An input file (not a system file) did not exist or was not readable.

### $L_EX_NOUSER

The user specified did not exist. This might be used for mail addresses or remote logins.

### $L_EX_NOHOST

The host specified did not exist. This is used in mail addresses or network requests.

### $L_EX_UNAVAILABLE

A service is unavailable. This can occur if a support program or file does not exist.

### $L_EX_SOFTWARE

An internal software error has been detected. This should be limited to non-operating system related errors as possible.

### $L_EX_OSERR

An operating system error has been detected. This is intended to be used for such things as "cannot fork", "cannot create pipe", or the like.

### $L_EX_OSFILE

Some system file (e.g., /etc/passwd, /var/run/utmp, etc.) does not exist, cannot be opened, or has some sort of error (e.g., syntax error).

### $L_EX_CANTCREAT

A (user specified) output file cannot be created.

### $L_EX_IOERR

An error occurred while doing I/O on some file.

### $L_EX_TEMPFAIL

Temporary failure, indicating something that is not really an error.

### $L_EX_PROTOCOL

The remote system returned something that was "not possible" during a protocol exchange.

### $L_EX_NOPERM

You did not have sufficient permission to perform the operation.

### $L_EX_CONFIG

Something was found in an unconfigured or misconfigured state.

### $L_EX_TIMEOUT

The command timed out. Convention from GNU timeout utility.
