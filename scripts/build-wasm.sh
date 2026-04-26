#!/usr/bin/env bash
# Rebuild dist/tree-sitter-m.wasm from the sibling tree-sitter-m repo's
# parser source. Uses tree-sitter-cli's docker emscripten path so the
# builder doesn't need emsdk installed locally — only docker.
#
# Run on every tree-sitter-m grammar change. The .wasm is committed to
# this repo so end users (extension consumers) never need docker.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PARSER_REPO="${TREE_SITTER_M_REPO:-$HOME/projects/tree-sitter-m}"

if [ ! -d "$PARSER_REPO" ]; then
    echo "ERROR: tree-sitter-m repo not found at $PARSER_REPO" >&2
    echo "       Set TREE_SITTER_M_REPO to override." >&2
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker not found on PATH (needed for emscripten)." >&2
    exit 1
fi

echo "Building WASM from $PARSER_REPO ..."
mkdir -p "$EXT_ROOT/dist"

cd "$PARSER_REPO"
npx tree-sitter build --wasm --docker -o "$EXT_ROOT/dist/tree-sitter-m.wasm"

ls -lh "$EXT_ROOT/dist/tree-sitter-m.wasm"
echo "Done. Commit the rebuilt .wasm in $EXT_ROOT before publishing."
