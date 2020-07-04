#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../.."

cdnjs_path="$1"
if [ -z "$cdnjs_path" ]; then
  >&2 echo "cdnjs path is required"
  exit 1
fi

"./lib/process.rb" \
  "cdnjs" \
  "$cdnjs_path" \
  "js:min,not_min,any" \
  "css:min,not_min,any"
