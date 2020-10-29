#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../.."

"./lib/chart/main.rb" \
  "wikipedia" \
  "html:any"
