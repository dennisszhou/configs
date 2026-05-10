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

    return 0
}

is_skill_dir() {
    dir="$1"

    [ -d "$dir" ] || return 1
    [ -f "$dir/SKILL.md" ]
}

mkdir -p "$CODEX_HOME"
mkdir -p "$SKILLS_HOME"

wanted_codex_entries=" AGENTS.md"
wanted_skill_entries=""
skill_list_file=""

install_link "$SCRIPT_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.md"

if [ -d "$SKILLS_DIR" ]; then
    skill_list_file="$(mktemp)"
    # Keep repo skills nestable for organization, but install them flat because
    # Codex discovers user skills as direct children of ~/.agents/skills.
    find "$SKILLS_DIR" -type f -name SKILL.md -print | sort > "$skill_list_file"

    while IFS= read -r skill_file; do
        src=$(dirname "$skill_file")
        is_skill_dir "$src" || continue

        base=$(basename "$src")
        case " $wanted_skill_entries " in
            *" $base "*)
                echo "Duplicate Codex skill name: $base" >&2
                echo "Each skill directory must have a unique basename." >&2
                rm "$skill_list_file"
                exit 1
                ;;
        esac

        install_link "$src" "$SKILLS_HOME/$base"
        wanted_skill_entries="$wanted_skill_entries $base"
    done < "$skill_list_file"

    rm "$skill_list_file"
fi

cleanup_stale "$CODEX_HOME" "$SCRIPT_DIR" $wanted_codex_entries
cleanup_stale "$SKILLS_HOME" "$SKILLS_DIR" $wanted_skill_entries
