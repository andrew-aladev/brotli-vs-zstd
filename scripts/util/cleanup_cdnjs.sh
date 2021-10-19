#!/usr/bin/env bash
set -e

CDNJS_PATH="$1"

if [ -z "$CDNJS_PATH" ]; then
  echo "cdnjs path is required"
  exit 1
fi

# CDN keeps all versions of every package.
# Real world applications mostly uses single version of package.
# We can remove all package versions except last.

while read -r package; do
  name=$(basename "$package")
  echo "cleaning package: \"${name}\""

  ls --sort=version "$package" | \
    grep "^[[:digit:]]\+\." | \
    head -n -1 | \
    xargs -I {} rm -r "${package}/{}"
done < <(find "$CDNJS_PATH/ajax/libs" -mindepth 1 -maxdepth 1 -type "d")
