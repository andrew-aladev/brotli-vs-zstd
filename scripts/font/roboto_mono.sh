#!/usr/bin/env bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd "../../font"

FONT_URL="https://raw.githubusercontent.com/googlefonts/RobotoMono/main/fonts/ttf/RobotoMono-Regular.ttf"
FONT="RobotoMono.ttf"

LICENSE_URL="https://raw.githubusercontent.com/googlefonts/roboto/main/LICENSE"
LICENSE="LICENSE"

wget "$FONT_URL" -O "$FONT"
wget "$LICENSE_URL" -O "$LICENSE"
