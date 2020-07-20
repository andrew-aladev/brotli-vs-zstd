#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../.."

"./lib/process_charts.rb" \
  "cdnjs" \
  "otf:any" \
  "ttf:any" \
  "svg:any" \
  "css:min,not_min,any" \
  "js:min,not_min,any"
