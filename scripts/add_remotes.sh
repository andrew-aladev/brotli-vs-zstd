#!/usr/bin/env bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

git remote add github    "git@github.com:andrew-aladev/brotli-vs-zstd.git"    || true
git remote add bitbucket "git@bitbucket.org:andrew-aladev/brotli-vs-zstd.git" || true
git remote add gitlab    "git@gitlab.com:andrew-aladev/brotli-vs-zstd.git"    || true
