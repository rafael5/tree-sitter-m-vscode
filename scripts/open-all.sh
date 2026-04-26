#!/usr/bin/env bash
# Open every .m / .mac / .int file under <dir> as tabs in VS Code so
# the tree-sitter-m extension parses them and you can click through
# verifying highlighting visually.
#
# Usage:
#   scripts/open-all.sh                          # default: test-routines/, max 50
#   scripts/open-all.sh ~/vista-meta/Packages    # walk a real corpus
#   scripts/open-all.sh test-routines 200        # raise the limit
#   scripts/open-all.sh test-routines all        # no limit (careful)
#
# The script also opens the dir as a workspace folder first so the
# Explorer sidebar lists everything; that lets you spot-check files
# you didn't auto-open.

set -euo pipefail

DIR="${1:-test-routines}"
LIMIT_RAW="${2:-50}"

if [ ! -d "$DIR" ]; then
    echo "ERROR: not a directory: $DIR" >&2
    exit 1
fi

# Open the workspace folder first so the Explorer is populated.
code "$DIR" >/dev/null 2>&1 || true

# Find files, limit, open. Sorted so order is reproducible.
mapfile -t FILES < <(find "$DIR" -type f \( -name '*.m' -o -name '*.mac' -o -name '*.int' \) | sort)

TOTAL=${#FILES[@]}
if [ "$LIMIT_RAW" = "all" ]; then
    LIMIT="$TOTAL"
else
    LIMIT="$LIMIT_RAW"
fi

OPENED=0
for f in "${FILES[@]}"; do
    if [ "$OPENED" -ge "$LIMIT" ]; then
        break
    fi
    code -r "$f" >/dev/null 2>&1
    OPENED=$((OPENED + 1))
done

echo "Opened $OPENED of $TOTAL .m/.mac/.int file(s) under $DIR."
if [ "$OPENED" -lt "$TOTAL" ]; then
    echo "Raise the limit with: $0 $DIR <higher-number-or-all>" >&2
fi
