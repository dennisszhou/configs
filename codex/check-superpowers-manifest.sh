#!/bin/sh
# codex/check-superpowers-manifest.sh — report curated Superpowers manifest drift
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$SCRIPT_DIR/superpowers.manifest"
SUPERPOWERS_SKILLS_DIR="$REPO_DIR/vendor/superpowers/skills"

is_skill_dir() {
    dir="$1"

    [ -d "$dir" ] || return 1
    [ -f "$dir/SKILL.md" ]
}

parse_manifest_entries() {
    manifest="$1"

    [ -f "$manifest" ] || return 0

    while IFS= read -r line || [ -n "$line" ]; do
        line=$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$line" ] && continue
        case "$line" in
            \#*) continue ;;
            -[[:space:]]*) line=${line#- } ;;
        esac
        echo "$line"
    done < "$manifest"
}

is_listed() {
    needle="$1"
    shift

    for item in "$@"; do
        [ "$item" = "$needle" ] && return 0
    done

    return 1
}

if [ ! -f "$MANIFEST" ]; then
    echo "Manifest not found: $MANIFEST"
    exit 1
fi

if [ ! -d "$SUPERPOWERS_SKILLS_DIR" ]; then
    echo "Superpowers skills directory not found: $SUPERPOWERS_SKILLS_DIR"
    echo "Run: git submodule update --init vendor/superpowers"
    exit 1
fi

manifest_entries=$(parse_manifest_entries "$MANIFEST")
status=0

echo "Checking Superpowers manifest against $SUPERPOWERS_SKILLS_DIR"

missing_from_manifest=""
for skill_dir in "$SUPERPOWERS_SKILLS_DIR"/*; do
    [ -e "$skill_dir" ] || continue
    is_skill_dir "$skill_dir" || continue

    skill_name=$(basename "$skill_dir")
    if ! is_listed "$skill_name" $manifest_entries; then
        missing_from_manifest="$missing_from_manifest $skill_name"
    fi
done

stale_manifest_entries=""
for skill_name in $manifest_entries; do
    if ! is_skill_dir "$SUPERPOWERS_SKILLS_DIR/$skill_name"; then
        stale_manifest_entries="$stale_manifest_entries $skill_name"
    fi
done

if [ -n "$missing_from_manifest" ]; then
    status=1
    echo "Upstream skills missing from manifest:"
    for skill_name in $missing_from_manifest; do
        echo "  - $skill_name"
    done
fi

if [ -n "$stale_manifest_entries" ]; then
    status=1
    echo "Manifest entries not found upstream:"
    for skill_name in $stale_manifest_entries; do
        echo "  - $skill_name"
    done
fi

if [ "$status" -eq 0 ]; then
    echo "Superpowers manifest is in sync."
fi

exit "$status"
