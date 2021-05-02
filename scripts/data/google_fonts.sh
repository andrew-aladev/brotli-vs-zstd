#!/usr/bin/env bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../.."

google_fonts_path="$1"
if [ -z "$google_fonts_path" ]; then
  >&2 echo "google fonts path is required"
  exit 1
fi

rm -r "data/google_fonts" || true

"./lib/file/main.rb" "google_fonts" "$google_fonts_path" "ttf:any"
