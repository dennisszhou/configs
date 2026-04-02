#!/bin/sh
# codex/install.sh — symlink Codex config into ~/.codex and curated skills into ~/.agents/skills
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CODEX_HOME="$HOME/.codex"
AGENTS_HOME="$HOME/.agents"
SKILLS_HOME="$AGENTS_HOME/skills"
SKILLS_DIR="$SCRIPT_DIR/skills"
SUPERPOWERS_DIR="$REPO_DIR/vendor/superpowers"
SUPERPOWERS_SKILLS_DIR="$SUPERPOWERS_DIR/skills"
SUPERPOWERS_MANIFEST="$SCRIPT_DIR/superpowers.manifest"
SUPERPOWERS_NAMESPACE_DIR="$SKILLS_HOME/superpowers"

install_link() {
    src="$1"
    dest="$2"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        echo "Backing up $dest to $dest.old"
        mv "$dest" "$dest.old"
    fi

    echo "Linking $dest -> $src"
    ln -s "$src" "$dest"
}

cleanup_stale() {
    target_dir="$1"
    source_root="$2"
    shift 2
    wanted="$*"

    [ -d "$target_dir" ] || return 0

    for link in "$target_dir"/*; do
        [ -L "$link" ] || continue
        case "$(readlink "$link")" in
            "$source_root"/*)
                base=$(basename "$link")
                found=0
                for w in $wanted; do
                    [ "$w" = "$base" ] && found=1 && break
                done
                [ "$found" -eq 0 ] && echo "Removing stale link: $link" && rm "$link"
                ;;
        esac
    done
}

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

parse_enabled_manifest() {
    manifest="$1"

    [ -f "$manifest" ] || return 0

    while IFS= read -r line || [ -n "$line" ]; do
        line=$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$line" ] && continue
        case "$line" in
            \#*) continue ;;
            -*) continue ;;
        esac
        echo "$line"
    done < "$manifest"
}

ensure_directory() {
    dest="$1"

    if [ -L "$dest" ]; then
        echo "Removing symlink to create directory: $dest"
        rm "$dest"
    elif [ -e "$dest" ] && [ ! -d "$dest" ]; then
        echo "Backing up $dest to $dest.old"
        mv "$dest" "$dest.old"
    fi

    mkdir -p "$dest"
}

mkdir -p "$CODEX_HOME"
mkdir -p "$SKILLS_HOME"

wanted_codex_entries=""
wanted_skill_entries=""

for src in "$SCRIPT_DIR"/*; do
    [ -e "$src" ] || continue

    base=$(basename "$src")
    [ "$base" = "install.sh" ] && continue
    [ "$base" = "skills" ] && continue

    install_link "$src" "$CODEX_HOME/$base"
    wanted_codex_entries="$wanted_codex_entries $base"
done

if [ -d "$SKILLS_DIR" ]; then
    for src in "$SKILLS_DIR"/*; do
        [ -e "$src" ] || continue
        is_skill_dir "$src" || continue

        base=$(basename "$src")
        install_link "$src" "$SKILLS_HOME/$base"
        wanted_skill_entries="$wanted_skill_entries $base"
    done
fi

ensure_directory "$SUPERPOWERS_NAMESPACE_DIR"

if [ ! -f "$SUPERPOWERS_MANIFEST" ]; then
    echo "Note: no Superpowers manifest found at $SUPERPOWERS_MANIFEST, skipping curated upstream skills."
elif [ ! -d "$SUPERPOWERS_SKILLS_DIR" ]; then
    echo "Note: Superpowers submodule not initialized at $SUPERPOWERS_DIR, skipping curated upstream skills."
    echo "  To enable: git submodule update --init vendor/superpowers"
else
    wanted_superpowers_entries=""

    for skill in $(parse_enabled_manifest "$SUPERPOWERS_MANIFEST"); do
        src="$SUPERPOWERS_SKILLS_DIR/$skill"
        if is_skill_dir "$src"; then
            install_link "$src" "$SUPERPOWERS_NAMESPACE_DIR/$skill"
            wanted_superpowers_entries="$wanted_superpowers_entries $skill"
        else
            echo "Warning: superpowers skill '$skill' not found, skipping"
        fi
    done

    cleanup_stale "$SUPERPOWERS_NAMESPACE_DIR" "$SUPERPOWERS_SKILLS_DIR" $wanted_superpowers_entries
fi

cleanup_stale "$CODEX_HOME" "$SCRIPT_DIR" $wanted_codex_entries
cleanup_stale "$SKILLS_HOME" "$SKILLS_DIR" $wanted_skill_entries
