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

rm -r "data/cdnjs" || true

datas=(
  "otf:any"
  "ttf:any"
  "svg:any"
  "css:min,not_min,any"
  "js:min,not_min,any"
)

for data in "${datas[@]}"; do
  "./lib/file/main.rb" "cdnjs" "$cdnjs_path" "$data"
done
