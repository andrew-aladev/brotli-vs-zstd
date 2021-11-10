#!/usr/bin/env bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../../.."

cdnjs_path="$1"
if [ -z "$cdnjs_path" ]; then
  >&2 echo "cdnjs path is required"
  exit 1
fi

rm -r "data/cdnjs/css/any"* || :

"./lib/file/main.rb" "cdnjs" "$cdnjs_path" "css:any"
