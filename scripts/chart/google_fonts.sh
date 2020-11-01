#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../.."

rm -r "chart/google_fonts" || true

"./lib/chart/main.rb" \
  "google_fonts" \
  "ttf:any"
