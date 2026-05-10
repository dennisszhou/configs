#!/bin/sh
# codex/install.sh — symlink Codex AGENTS.md into ~/.codex and user skills into ~/.agents/skills
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
SKILLS_HOME="${SKILLS_HOME:-$AGENTS_HOME/skills}"
SKILLS_DIR="$SCRIPT_DIR/skills"
DRY_RUN=0
skill_list_file=""

usage() {
    echo "Usage: $0 [--dry-run]"
    echo
    echo "Symlink Codex AGENTS.md into CODEX_HOME and user skills into SKILLS_HOME."
    echo
    echo "Options:"
    echo "  -n, --dry-run  Show intended changes without modifying target directories"
    echo "  -h, --help     Show this help"
    echo
    echo "Environment:"
    echo "  CODEX_HOME     Target Codex home (default: \$HOME/.codex)"
    echo "  AGENTS_HOME    Target agents home (default: \$HOME/.agents)"
    echo "  SKILLS_HOME    Target skill dir (default: \$AGENTS_HOME/skills)"
}

cleanup_tmp() {
    [ -n "$skill_list_file" ] || return 0
    [ -f "$skill_list_file" ] || return 0
    rm -f "$skill_list_file"
}

trap cleanup_tmp EXIT
trap 'cleanup_tmp; exit 1' HUP INT TERM

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -n|--dry-run)
                DRY_RUN=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                usage >&2
                exit 1
                ;;
        esac
        shift
    done
}

ensure_dir() {
    dir="$1"

    if [ -d "$dir" ]; then
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        echo "Would create directory: $dir"
    else
        mkdir -p "$dir"
    fi
}

is_managed_link() {
    link="$1"
    source_root="$2"

    [ -L "$link" ] || return 1
    case "$(readlink "$link")" in
        "$source_root"|"$source_root"/*) return 0 ;;
        *) return 1 ;;
    esac
}

next_backup_path() {
    target="$1"
    backup="$target.old"
    i=1

    while [ -e "$backup" ] || [ -L "$backup" ]; do
        backup="$target.old.$i"
        i=$((i + 1))
    done

    echo "$backup"
}

backup_existing_path() {
    target="$1"
    backup=$(next_backup_path "$target")

    echo "Backing up $target to $backup"
    if [ "$DRY_RUN" -eq 0 ]; then
        mv "$target" "$backup"
    fi
}

remove_managed_link() {
    link="$1"

    echo "Removing managed link: $link"
    if [ "$DRY_RUN" -eq 0 ]; then
        rm "$link"
    fi
}

install_link() {
    src="$1"
    dest="$2"
    source_root="$3"

    if [ -L "$dest" ]; then
        link_target=$(readlink "$dest")
        if [ "$link_target" = "$src" ]; then
            echo "Already linked: $dest -> $src"
            return 0
        fi
        if ! is_managed_link "$dest" "$source_root"; then
            echo "Refusing to replace user-owned symlink: $dest -> $link_target" >&2
            echo "Expected a link into $source_root." >&2
            exit 1
        fi
        remove_managed_link "$dest"
    elif [ -e "$dest" ]; then
        backup_existing_path "$dest"
    fi

    echo "Linking $dest -> $src"
    if [ "$DRY_RUN" -eq 0 ]; then
        ln -s "$src" "$dest"
    fi
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
                [ "$found" -eq 0 ] && remove_managed_link "$link"
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

install_codex_agents() {
    install_link "$SCRIPT_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.md" "$SCRIPT_DIR"
    wanted_codex_entries=" AGENTS.md"
}

install_user_skills() {
    wanted_skill_entries=""

    [ -d "$SKILLS_DIR" ] || return 0

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
                exit 1
                ;;
        esac

        install_link "$src" "$SKILLS_HOME/$base" "$SKILLS_DIR"
        wanted_skill_entries="$wanted_skill_entries $base"
    done < "$skill_list_file"
}

cleanup_managed_links() {
    cleanup_stale "$CODEX_HOME" "$SCRIPT_DIR" $wanted_codex_entries
    cleanup_stale "$SKILLS_HOME" "$SKILLS_DIR" $wanted_skill_entries
}

main() {
    wanted_codex_entries=""
    wanted_skill_entries=""

    parse_args "$@"
    ensure_dir "$CODEX_HOME"
    ensure_dir "$SKILLS_HOME"

    install_codex_agents
    install_user_skills
    cleanup_managed_links
}

main "$@"
