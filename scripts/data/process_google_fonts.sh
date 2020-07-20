#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../.."

google_fonts_path="$1"
if [ -z "$google_fonts_path" ]; then
  >&2 echo "google fonts path is required"
  exit 1
fi

"./lib/process_files.rb" \
  "google_fonts" \
  "$google_fonts_path" \
  "ttf:any"
