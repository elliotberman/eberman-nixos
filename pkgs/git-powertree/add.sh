#!/usr/bin/env bash

BASE="$(git config get --default="${XDG_DATA_HOME:-${HOME}/.local/share}/git-powertrees" powertrees.base)"

if [ $# -lt 2 ]; then
  usage
fi

name="$1"
directory="$2"
ref="$3"

git -C "${BASE}/${name}" worktree add -f "$(realpath "${directory}")" ${ref:+"${ref}"}
