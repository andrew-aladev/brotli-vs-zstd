#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../.."

"./lib/process_charts.rb" \
  "wikipedia" \
  "html:any"
