#!/bin/sh
# claude/install.sh — manages all Claude Code symlinks
# Called by configure.sh during the configs target.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ECC_DIR="$REPO_DIR/vendor/everything-claude-code"
MANIFEST="$SCRIPT_DIR/manifest.conf"
CLAUDE_HOME="$HOME/.claude"
FORCE=0

usage() {
    echo "Usage: $0 [--force]"
    echo
    echo "Symlink Claude Code config, user skills, and ECC items into CLAUDE_HOME."
    echo
    echo "Options:"
    echo "  -f, --force  Back up user-owned symlinks before replacing them"
    echo "  -h, --help   Show this help"
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -f|--force)
                FORCE=1
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

# --- install_link: symlink with backup ---
is_managed_link() {
    link="$1"
    source_root="$2"

    [ -L "$link" ] || return 1
    source_canon=$(canonical_path "$source_root") || source_canon="$source_root"
    target=$(link_target_path "$link" "$(readlink "$link")")
    target_canon=$(canonical_path "$target") || target_canon="$target"

    case "$target_canon" in
        "$source_canon"|"$source_canon"/*) return 0 ;;
        *) return 1 ;;
    esac
}

link_matches_path() {
    link="$1"
    link_target="$2"
    expected="$3"

    target=$(link_target_path "$link" "$link_target")
    target_canon=$(canonical_path "$target") || target_canon="$target"
    expected_canon=$(canonical_path "$expected") || expected_canon="$expected"

    [ "$target_canon" = "$expected_canon" ]
}

link_target_path() {
    link="$1"
    target="$2"

    case "$target" in
        /*) echo "$target" ;;
        *) echo "$(dirname "$link")/$target" ;;
    esac
}

canonical_path() {
    path="$1"

    if [ -d "$path" ]; then
        (cd "$path" 2>/dev/null && pwd -P)
        return
    fi

    dir=$(dirname "$path")
    base=$(basename "$path")
    [ -d "$dir" ] || return 1

    dir=$(cd "$dir" 2>/dev/null && pwd -P) || return 1
    echo "$dir/$base"
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
    mv "$target" "$backup"
}

remove_managed_link() {
    link="$1"

    echo "Removing managed link: $link"
    rm "$link"
}

install_link() {
    src="$1"; dest="$2"
    source_root="$REPO_DIR"
    if [ -L "$dest" ]; then
        link_target=$(readlink "$dest")
        if [ "$link_target" = "$src" ] || link_matches_path "$dest" "$link_target" "$src"; then
            echo "Already linked: $dest -> $src"
            return 0
        fi
        if ! is_managed_link "$dest" "$source_root"; then
            if [ "$FORCE" -eq 0 ]; then
                echo "Refusing to replace user-owned symlink: $dest -> $link_target" >&2
                echo "Expected a link into $source_root." >&2
                echo "Use --force to back up the symlink and replace it." >&2
                exit 1
            fi
            backup_existing_path "$dest"
        else
            remove_managed_link "$dest"
        fi
    elif [ -e "$dest" ]; then
        backup_existing_path "$dest"
    fi
    echo "Linking $dest -> $src"
    ln -s "$src" "$dest"
}

# --- parse_section: emit lines belonging to a [section] ---
parse_section() {
    section="$1"; in_section=0
    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$line" ] && continue
        case "$line" in \#*) continue ;; esac
        case "$line" in
            \[*\])
                if [ "$line" = "[$section]" ]; then in_section=1; else in_section=0; fi
                continue ;;
        esac
        [ "$in_section" -eq 1 ] && echo "$line"
    done < "$MANIFEST"
}

# --- cleanup_stale: remove managed ECC symlinks not in wanted list ---
# User-owned symlinks in the same directory are never touched.
cleanup_stale() {
    target_dir="$1"; ecc_subpath="$2"; shift 2
    wanted="$*"
    [ -d "$target_dir" ] || return 0
    for link in "$target_dir"/*; do
        [ -L "$link" ] || continue
        source_root="$ECC_DIR/$ecc_subpath"
        is_managed_link "$link" "$source_root" || continue
        base=$(basename "$link")
        found=0
        for w in $wanted; do [ "$w" = "$base" ] && found=1 && break; done
        [ "$found" -eq 0 ] && remove_managed_link "$link"
    done
}

# --- migrate_old_symlinks: remove pre-namespace ECC symlinks ---
# Handles the transition from whole-dir symlinks and un-namespaced per-file
# symlinks to the ecc/ subdirectory namespace. Idempotent.
migrate_old_symlinks() {
    # Convert whole-dir symlinks to real directories
    for dir in commands agents; do
        target="$CLAUDE_HOME/$dir"
        if [ -L "$target" ]; then
            is_managed_link "$target" "$ECC_DIR" || continue
            echo "Migrating $target: whole-dir symlink -> directory"
            remove_managed_link "$target"
            mkdir -p "$target"
        fi
    done

    # Remove un-namespaced ECC symlinks from commands/ and agents/
    for dir in commands agents; do
        [ -d "$CLAUDE_HOME/$dir" ] || continue
        for link in "$CLAUDE_HOME/$dir"/*.md; do
            [ -L "$link" ] || continue
            is_managed_link "$link" "$ECC_DIR/$dir" || continue
            echo "Removing un-namespaced symlink: $link"
            remove_managed_link "$link"
        done
    done

    # Remove un-namespaced ECC skill symlinks (direct children of skills/, not ecc/)
    if [ -d "$CLAUDE_HOME/skills" ]; then
        for entry in "$CLAUDE_HOME/skills"/*; do
            [ -L "$entry" ] || continue
            is_managed_link "$entry" "$ECC_DIR/skills" || continue
            echo "Removing un-namespaced skill symlink: $entry"
            remove_managed_link "$entry"
        done
    fi

    # Remove un-namespaced ECC rule symlinks (rules/category/*.md, skipping rules/ecc/)
    if [ -d "$CLAUDE_HOME/rules" ]; then
        for category_dir in "$CLAUDE_HOME/rules"/*/; do
            [ -d "$category_dir" ] || continue
            category=$(basename "$category_dir")
            [ "$category" = "ecc" ] && continue
            for link in "$category_dir"*.md; do
                [ -L "$link" ] || continue
                is_managed_link "$link" "$ECC_DIR/rules" || continue
                echo "Removing un-namespaced rule symlink: $link"
                remove_managed_link "$link"
            done
            # Remove category dir if now empty
            if [ -z "$(ls -A "$category_dir" 2>/dev/null)" ]; then
                rmdir "$category_dir"
                echo "Removed empty dir: $category_dir"
            fi
        done
    fi
}

parse_args "$@"

# =====================
# 1. Core: CLAUDE.md
# =====================
mkdir -p "$CLAUDE_HOME"
install_link "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

# =====================
# 2. User skills
# =====================
mkdir -p "$CLAUDE_HOME/skills"
if [ -d "$SCRIPT_DIR/skills" ]; then
    wanted_user_skills=""
    for src in "$SCRIPT_DIR/skills"/*/; do
        [ -d "$src" ] || continue
        skill=$(basename "$src")
        install_link "$src" "$CLAUDE_HOME/skills/$skill"
        wanted_user_skills="$wanted_user_skills $skill"
    done
    # Cleanup stale user skill symlinks
    for link in "$CLAUDE_HOME/skills"/*; do
        [ -L "$link" ] || continue
        case "$(readlink "$link")" in
            "$SCRIPT_DIR/skills/"*)
                base=$(basename "$link")
                found=0
                for w in $wanted_user_skills; do [ "$w" = "$base" ] && found=1 && break; done
                [ "$found" -eq 0 ] && remove_managed_link "$link" ;;
        esac
    done
fi

# =====================
# 3. ECC integration
# =====================
if [ ! -d "$ECC_DIR/agents" ]; then
    echo "Note: ECC submodule not initialized, skipping. Run: git submodule update --init"
    exit 0
fi

migrate_old_symlinks

# Agents: all ECC agents under agents/ecc/ (invoked as ecc:agent-name)
mkdir -p "$CLAUDE_HOME/agents/ecc"
wanted_agents=""
for src in "$ECC_DIR/agents"/*.md; do
    [ -f "$src" ] || continue
    base=$(basename "$src")
    install_link "$src" "$CLAUDE_HOME/agents/ecc/$base"
    wanted_agents="$wanted_agents $base"
done
cleanup_stale "$CLAUDE_HOME/agents/ecc" "agents" "$wanted_agents"

# Commands: all ECC commands under commands/ecc/ (invoked as /ecc:command-name)
mkdir -p "$CLAUDE_HOME/commands/ecc"
wanted_commands=""
for src in "$ECC_DIR/commands"/*.md; do
    [ -f "$src" ] || continue
    base=$(basename "$src")
    install_link "$src" "$CLAUDE_HOME/commands/ecc/$base"
    wanted_commands="$wanted_commands $base"
done
cleanup_stale "$CLAUDE_HOME/commands/ecc" "commands" "$wanted_commands"

# Skills: selective per-item symlinks under skills/ecc/ (invoked as /ecc:skill-name)
mkdir -p "$CLAUDE_HOME/skills/ecc"
wanted_skills=""
for skill in $(parse_section skills); do
    if [ -d "$ECC_DIR/skills/$skill" ]; then
        install_link "$ECC_DIR/skills/$skill" "$CLAUDE_HOME/skills/ecc/$skill"
        wanted_skills="$wanted_skills $skill"
    else
        echo "Warning: skill '$skill' not found in ECC, skipping"
    fi
done
cleanup_stale "$CLAUDE_HOME/skills/ecc" "skills" "$wanted_skills"

# Rules: selective per-item symlinks under rules/ecc/category/
for rule_entry in $(parse_section rules); do
    category=$(dirname "$rule_entry")
    filename=$(basename "$rule_entry")
    src="$ECC_DIR/rules/$category/${filename}.md"
    if [ -f "$src" ]; then
        mkdir -p "$CLAUDE_HOME/rules/ecc/$category"
        install_link "$src" "$CLAUDE_HOME/rules/ecc/$category/${filename}.md"
    else
        echo "Warning: rule '$rule_entry' not found in ECC, skipping"
    fi
done
# Cleanup stale rules per category under rules/ecc/
for category_dir in "$CLAUDE_HOME/rules/ecc"/*/; do
    [ -d "$category_dir" ] || continue
    category=$(basename "$category_dir")
    wanted_rules=""
    for rule_entry in $(parse_section rules); do
        rc=$(dirname "$rule_entry"); rf=$(basename "$rule_entry")
        [ "$rc" = "$category" ] && wanted_rules="$wanted_rules ${rf}.md"
    done
    cleanup_stale "$category_dir" "rules/$category" "$wanted_rules"
    # Remove category dir if now empty
    if [ -z "$(ls -A "$category_dir" 2>/dev/null)" ]; then
        rmdir "$category_dir"
        echo "Removed empty dir: $category_dir"
    fi
done

echo "Claude Code setup complete."
