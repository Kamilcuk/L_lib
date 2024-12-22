#!/usr/bin/env bash
export PATH="${PATH:+$PATH:}$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/bin"
