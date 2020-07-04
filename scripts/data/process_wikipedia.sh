#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../.."

wikipedia_path="$1"
if [ -z "$wikipedia_path" ]; then
  >&2 echo "wikipedia path is required"
  exit 1
fi

"./lib/process.rb" \
  "wikipedia" \
  "$wikipedia_path" \
  "html:any"
