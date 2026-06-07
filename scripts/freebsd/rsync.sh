#!/bin/bash
set -xeuo pipefail
VAGRANT_DEFAULT_PROVIDER=libvirt vagrant rsync-auto
