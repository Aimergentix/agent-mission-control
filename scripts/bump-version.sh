#!/usr/bin/env bash
# bump-version.sh — read/write the single version source of truth at .version
#
# Usage:
#   ./scripts/bump-version.sh              # print current version
#   ./scripts/bump-version.sh patch        # 0.1.0 → 0.1.1
#   ./scripts/bump-version.sh minor        # 0.1.0 → 0.2.0
#   ./scripts/bump-version.sh major        # 0.1.0 → 1.0.0
#   ./scripts/bump-version.sh set 2.3.4    # set an explicit version
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/../.version"

# ── helpers ──────────────────────────────────────────────────────────────────

read_version() {
    local v
    v="$(tr -d '[:space:]' < "$VERSION_FILE")"
    if [[ ! "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "ERROR: .version contains invalid semver: '$v'" >&2
        exit 1
    fi
    echo "$v"
}

write_version() {
    printf '%s\n' "$1" > "$VERSION_FILE"
}

# ── main ─────────────────────────────────────────────────────────────────────

CURRENT="$(read_version)"
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

CMD="${1:-}"

case "$CMD" in
    "")
        echo "$CURRENT"
        ;;
    patch)
        NEW="$MAJOR.$MINOR.$((PATCH + 1))"
        write_version "$NEW"
        echo "$CURRENT → $NEW"
        ;;
    minor)
        NEW="$MAJOR.$((MINOR + 1)).0"
        write_version "$NEW"
        echo "$CURRENT → $NEW"
        ;;
    major)
        NEW="$((MAJOR + 1)).0.0"
        write_version "$NEW"
        echo "$CURRENT → $NEW"
        ;;
    set)
        TARGET="${2:-}"
        if [[ -z "$TARGET" ]]; then
            echo "ERROR: 'set' requires a version argument, e.g.: $0 set 2.3.4" >&2
            exit 1
        fi
        if [[ ! "$TARGET" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "ERROR: '$TARGET' is not valid semver (expected MAJOR.MINOR.PATCH)" >&2
            exit 1
        fi
        write_version "$TARGET"
        echo "$CURRENT → $TARGET"
        ;;
    *)
        echo "Usage: $0 [patch|minor|major|set <version>]" >&2
        exit 1
        ;;
esac
