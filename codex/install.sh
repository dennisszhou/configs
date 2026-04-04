#!/bin/sh
# codex/install.sh — symlink Codex AGENTS.md into ~/.codex and user skills into ~/.agents/skills
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CODEX_HOME="$HOME/.codex"
AGENTS_HOME="$HOME/.agents"
SKILLS_HOME="$AGENTS_HOME/skills"
SKILLS_DIR="$SCRIPT_DIR/skills"

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

remove_path_if_exists() {
    target="$1"

    if [ -L "$target" ]; then
        echo "Removing symlink: $target"
        rm "$target"
    elif [ -d "$target" ]; then
        echo "Removing directory: $target"
        rm -rf "$target"
    fi
}

mkdir -p "$CODEX_HOME"
mkdir -p "$SKILLS_HOME"

wanted_codex_entries=" AGENTS.md"
wanted_skill_entries=""

install_link "$SCRIPT_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.md"

if [ -d "$SKILLS_DIR" ]; then
    for src in "$SKILLS_DIR"/*; do
        [ -e "$src" ] || continue
        is_skill_dir "$src" || continue

        base=$(basename "$src")
        install_link "$src" "$SKILLS_HOME/$base"
        wanted_skill_entries="$wanted_skill_entries $base"
    done
fi

remove_path_if_exists "$SKILLS_HOME/superpowers"

cleanup_stale "$CODEX_HOME" "$SCRIPT_DIR" $wanted_codex_entries
cleanup_stale "$SKILLS_HOME" "$SKILLS_DIR" $wanted_skill_entries
