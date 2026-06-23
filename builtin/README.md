# L_lib.sh C Builtins

A collection of high-performance, loadable C builtins designed to extend Bash with advanced OS-level capabilities.

## Overview

These builtins are compiled into a shared library (`L_builtin.so`) which can be dynamically loaded into Bash using the `enable` command. They provide low-overhead abstractions for file operations, signal masking, high-precision polling, Lua integration, and advanced networking.

---

## Subcommands Reference

All subcommands are executed through the main entry point: `L_builtin <subcommand> [options] [args]`.

### File & Process Utilities

#### `lseek`
Reposition read/write file offset.
```bash
L_builtin lseek [-v var] fd offset [whence]
```
- **Options:**
  - `-v VAR`: Store the new offset in the shell variable `VAR`.
- **whence:** `0` (or `SET`), `1` (or `CUR`), `2` (or `END`).

#### `pipe`
Create a uni-directional data channel.
```bash
L_builtin pipe ARRAY
```
- Creates a pipe and stores the read file descriptor in `ARRAY[0]` and the write end in `ARRAY[1]`.

#### `sleep`
High-precision sub-second sleep.
```bash
L_builtin sleep SECONDS
```
- Accepts floating-point durations for microsecond-level precision (e.g. `L_builtin sleep 0.05`).

---

### Signal & Event Management

#### `sigmask`
Block or unblock signal delivery.
```bash
L_builtin sigmask [-s sigspec] [-u sigspec] [sigspec ...]
```
- Without options, prints the current signal mask.
- `-s`: Block signal.
- `-u`: Unblock signal.

#### `sigunmask`
Temporarily unblock signals and execute a command.
```bash
L_builtin sigunmask -s sigspec cmd [args...]
```

#### `poll` / `ppoll`
Wait for multiple file descriptors to become ready for I/O.
```bash
L_builtin poll [-t TIMEOUT] [-v ARRAY_VAR] [FD[:EVENTS] ...]
L_builtin ppoll [-t TIMEOUT] [-v ARRAY_VAR] [-u SIGSPEC] [FD[:EVENTS] ...]
```
- **Events:** `r` (read), `w` (write), `p` (priority).
- Results are populated into `ARRAY_VAR` as `FD:REVENTS`.

---

### Embedded Lua

#### `lua`
Execute inline LuaJIT code within the Bash process.
```bash
L_builtin lua [-v VAR] SCRIPT [args...]
```
- Exposes a global `bash` table to access shell variables, arrays, call shell functions, and perform expansions.

---

### Low-Overhead Networking

#### `listen`
Create a listening TCP socket.
```bash
L_builtin listen [-p PORT_VAR] LISTENFD_VAR [IP] [PORT]
```
- **Defaults:** `IP` defaults to `127.0.0.1`, `PORT` defaults to `0` (ephemeral port allocation).
- **Options:**
  - `-p PORT_VAR`: Store the actual dynamically bound port number (required if port is `0`).

#### `accept`
Accept a new connection on a listening socket.
```bash
L_builtin accept CLIENTFD_VAR ADDR_VAR LISTENFD
```
- Stores the client socket descriptor in `CLIENTFD_VAR` and the client's `IP:PORT` in `ADDR_VAR`.

#### `connect`
Establish an outgoing TCP connection.
```bash
L_builtin connect CLIENTFD_VAR IP PORT
```

#### `shutdown`
Semi-close a full-duplex TCP socket.
```bash
L_builtin shutdown FD [how]
```
- **how:** `RD` (0), `WR` (1), or `RDWR` (2).

#### `send`
Transmit raw or encoded data over a socket.
```bash
L_builtin send [-f format] [-v SENT_VAR] FD DATA
```
- **Options:**
  - `-f raw`: Send raw characters (default).
  - `-f hex`: Decode hexadecimal string and transmit binary safely.
  - `-v SENT_VAR`: Store the number of bytes successfully sent.

#### `recv`
Receive up to `SIZE` bytes from a socket.
```bash
L_builtin recv [-f format] [-v RECV_VAR] [-n] FD SIZE
```
- **Options:**
  - `-f raw`: Store received raw bytes (null-byte unsafe) (default).
  - `-f hex`: Store received bytes as hexadecimal string (null-byte safe).
  - `-n`: Non-blocking receive (MSG_DONTWAIT). Returns immediately with empty string if no data is available.

---

## Build, Format, & Static Analysis

All orchestration is managed via the top-level `Makefile` inside the `builtin/` directory.

### Build the Loadable Module
```bash
make build
```
Creates `build/L_builtin.so`.

### Run the Test Suite
```bash
make test
```
Compiles and runs all modular test files inside `tests/` and automatically executes style checks, formatting, and static analysis.

### Code Formatting
```bash
make format         # In-place format
make check-format   # Dry-run validation
```

### Static Analysis
```bash
make tidy           # Runs clang-tidy (zero-warning strict)
make cppcheck       # Runs cppcheck static analyzer
```
