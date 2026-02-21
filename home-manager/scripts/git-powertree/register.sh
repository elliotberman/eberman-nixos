#!/usr/bin/env bash

BASE="$(git config get --default="${XDG_DATA_HOME:-${HOME}/.local/share}/git-powertrees" powertrees.base)"

# Function to display usage
usage() {
  echo "Usage: $0 <name> <url> [remote_name]" >/dev/stderr
  echo "  name: Name of the repository" >/dev/stderr
  echo "  url: URL of the repository" >/dev/stderr
  echo "  remote_name: Remote name (optional, default: origin)" >/dev/stderr
  exit 1
}

# Check if at least two arguments are provided
if [ $# -lt 2 ]; then
  usage
fi

name="$1"
url="$2"
remote="${3}"

set -x

if [ -e "${BASE}/${name}" ]; then
  if [ $# -lt 3 ]; then
    echo "${name} already exists. Specify a remote, too." >/dev/stderr
    usage
  fi
  git -C "${BASE}/${name}" remote add --fetch "${remote}" "${url}"
else
  git clone --bare ${remote:+--origin "$remote"} "${url}" "${BASE}/${name}"
fi

echo "Set up powertree '$name' with remote ${remote:-"${remote} "} ${url}"
