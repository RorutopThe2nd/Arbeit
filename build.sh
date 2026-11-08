#!/usr/bin/env bash
set -e

# 1. Clean previous dist folder
rm -rf dist

# 2. Generate sourcemap for darklua require resolution
rojo sourcemap default.project.json -o sourcemap.json

# 3. Process source code into dist directory
darklua process src dist

# 4. Copy package metadata to the build folder
cp wally.toml dist/shared/Arbeit/wally.toml
cp README.md dist/shared/Arbeit/README.md 2>/dev/null || true

# 5. Clean temporary sourcemap
rm sourcemap.json

echo "Build complete: dist/shared/Arbeit"