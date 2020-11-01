#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../.."

rm -r "chart/wikipedia" || true

"./lib/chart/main.rb" \
  "wikipedia" \
  "html:any"
