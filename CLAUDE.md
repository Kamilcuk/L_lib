# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Commands

### Testing
- `make test_local` - Run all tests on current system (uses local Bash)
- `make test` - Run comprehensive test suite (all 10 Bash versions + shellcheck + docs build)
- `make test_bash5.3`, `make test_bash4.4`, etc. - Test on specific Bash version via Docker
- `make watchtest` - Watch files and auto-run tests on changes
- `./tests/test.sh [ARGS]` - Run tests directly with optional arguments

### Linting & Code Quality
- `make shellcheck` - Run shellcheck linter (local if available, else Docker)
- `make shellchecklocal` - Run shellcheck directly (requires shellcheck installed)
- `make shellcheckvim` - Run shellcheck with GCC-format output for editor integration

### Documentation
- `make docs_build` - Build documentation site locally
- `make docs_serve` - Build and serve documentation at http://localhost:8000
- `make docs_docker` - Build documentation in Docker, output to `./public`

### Interactive Development
- `make term-5.2` - Interactive Bash 5.2 shell with library loaded (Docker)
- `make term-4.4` - Interactive Bash 4.4 shell with library loaded
- `make termnoload-5.2` - Interactive shell WITHOUT library pre-loaded
- `make run-5.2` - Run library ad-hoc in Bash 5.2

## Repository Architecture

### Core Structure

**Distribution Entry Point** (`/bin/`)
- `L_lib.sh` - Main library (~9,800 lines) containing 25+ sections of Bash utilities
- Distributed as a single file via GitHub releases and GHCR Docker images

**Project Layout**
- `/tests/` - Test suite (main: `test.sh` with 123k+ lines of tests)
- `/scripts/` - Example implementations and demo utilities (L_df, argparse examples, process examples)
- `/docs/` - Manual documentation and auto-generated API reference (via mkdocstrings-sh)
- `/.github/workflows/` - CI/CD: main.yml (multi-version testing), release.yml (automated versioning)

### Library Organization

The main `L_lib.sh` is organized into **25 documented sections**, each with auto-generated documentation:

**Core Utilities**: globals, colors, ansi, has, assert, func, stdlib, json, exit_to
**String/Data**: string, array, args, map, asa, path, utilities
**Control Flow**: trap, finally, with, unittest
**Advanced**: argparse (complex parsing with subparsers), proc (process management), log (multi-level logging), sort
**System**: lib (library management)

Each section has a corresponding markdown file in `/docs/section/`.

### Documentation System

- Auto-generated from JSDoc-style comments in source code using `mkdocstrings-sh` plugin
- Material theme with automatic dark mode detection
- Function extraction regex: includes `L_*` (public), excludes `_L_*` (private)
- Source linking enabled - documentation links back to source code in GitHub
- Navigation organized by sections + comprehensive `all.md` reference

### Testing Infrastructure

**Multi-version Testing**: Tests run on Bash 3.2, 4.0-4.4, 5.0-5.3
- Local testing: native Bash via `./tests/test.sh`
- Docker testing: isolated environments via Dockerfile (one stage per Bash version)
- Parallel execution: `make test_parallel` or `make test_parallel2` for speed

**Test Framework**: Custom `L_unittest_*` functions defined in L_lib.sh
- Exit code validation: `L_unittest_checkexit`
- Command execution: `L_unittest_cmd`
- Variable equality: `L_unittest_eq`
- Special handling for different Bash versions via feature detection variables

### Version Management

**`.github/bump.yml`** - Automated version bumping configuration:
- Updates version in: `bin/L_lib.sh` (line 27)
- Updates version in: `bpkg.json` (line 3)
- Updates version in: `shpkg.json` (line 3)
- Updates version in: `bash.yml` (line 18)
- Keeps all package manager configs in sync with main library version

### CI/CD Pipeline

**`.github/workflows/main.yml`** runs:
1. Tests across all 10 Bash versions (parallelized)
2. Shellcheck validation
3. Documentation build
4. Docker image push to GHCR
5. GitHub Pages deployment

**`.github/workflows/release.yml`**:
- Automated version bumping
- GitHub release creation with assets
- Tagged Docker image creation

## Development Conventions

### Naming & Function Design
- Public symbols: `L_*` prefix
- Private symbols: `_L_*` prefix
- Global constants: UPPERCASE
- Functions/variables: snake_case

**Standard Function Pattern**: Functions support `-v <var>` option to store result in variable (like `printf -v`). Without `-v`, output goes to stdout. Functions with `_v` suffix use scratch variable `L_v`.

### Return Codes Convention
- `0` - Success
- `2` - Usage/argument error
- `124` - Timeout

### Bash Version Compatibility
- Library supports Bash 3.2 through 5.3
- Feature detection via: `$L_HAS_BASH4_0`, `$L_HAS_BASH4_1`, `$L_HAS_COMPGEN_V`, `$L_HAS_WAIT_N`, etc.
- Portability helpers: `L_readarray`, `L_epochrealtime_usec`, `L_compgen`, etc.
- Sourcing enables `extglob` and `patsub_replacement` by default (disable with `-n` flag)
- Automatic ERR trap with nice traceback when `set -e` is enabled

## Key Implementation Patterns

### Complex Features in L_lib

**Argument Parsing** (`L_argparse`): Complex system supporting:
- Short/long options, optional/required args
- Sub-parsers and sub-functions
- Shell completion support
- See `/scripts/argparse*.sh` for examples

**Process Management** (`L_proc_popen`, `L_proc_communicate`): Advanced feature for:
- Creating and managing multiple processes with separate file descriptors
- Bidirectional communication with processes
- Graceful cleanup and signal handling

**Logging** (`L_log_*`): Multi-level logging system with:
- Configurable output destinations and filtering
- Integration with `L_logrun` for command execution
- Color output support with auto-detection

**Generator/Iterator** (`L_it.sh`): Functional programming patterns:
- Generator chaining and state management
- Pure Bash implementation without subshells (where possible)

### Documentation Generation

The library uses `mkdocstrings-sh` which:
1. Extracts JSDoc-style comments from functions
2. Uses regex filters to identify public functions (`L_*` prefix)
3. Generates markdown files in `/docs/section/`
4. Builds complete HTML docs with Material theme
5. Automatically links to source code on GitHub

## When Working on This Codebase

### Adding New Functions
1. Place in appropriate section of `L_lib.sh` (or create new section if needed)
2. Use `L_*` prefix for public functions, `_L_*` for private
3. Add JSDoc comments for auto-documentation:
   ```bash
   # @description Brief description of what function does
   # @arg $1 Description of first argument
   # @example
   # my_function arg1
   L_my_function() { ... }
   ```
4. Add corresponding tests to `/tests/test.sh`
5. Documentation will auto-generate on next build

### Testing Across Versions
- Use `make test` to verify across all versions before committing
- Use `make term-<version>` for interactive debugging in specific Bash versions
- Consult `L_HAS_*` variables for version-specific feature handling

### Documentation
- Manual docs go in `/docs/*.md`
- API reference is auto-generated; edit function comments in source, not markdown files
- Run `make docs_serve` to preview changes locally before committing
- Keep README.md focused on core content (Installation section includes package manager instructions)
- Keep package configuration files aligned with official specifications:
  - `bpkg.json` - Follows https://bpkg.sh/bpkg/#bpkgjson (scripts, install, files, dependencies)
  - `bash.yml` - Basher configuration with bin, executables, engines, install, usage, test
  - `shpkg.json` - Shpkg configuration following their standard format

### Current Development Focus
- Branch: `dfAndGen` (working on DataFrame and Generator implementations)
- Current version: 1.0.4
- Recent work: `L_df.sh` (DataFrame utilities) and `L_gen.sh` (generator functions)
- Related: `L_it.sh` (iterator/generator core functionality in `/scripts/`)
- work only on scripts/L_it.sh