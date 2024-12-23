#!/bin/sh
set -xeuo pipefail
sed '/#[ \t]*shellcheckparser=off/,/^}$/s/.*/:/' "$1"
