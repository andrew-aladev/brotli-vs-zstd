#!/usr/bin/env bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

./cdnjs.sh
./google_fonts.sh
./wikipedia.sh
