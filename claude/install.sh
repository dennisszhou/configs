#!/bin/sh
# claude/install.sh — manages all Claude Code symlinks
# Called by configure.sh during the configs target.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ECC_DIR="$REPO_DIR/everything-claude-code"
MANIFEST="$SCRIPT_DIR/manifest.conf"
CLAUDE_HOME="$HOME/.claude"

# --- install_link: symlink with backup ---
install_link() {
    src="$1"; dest="$2"
    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        echo "Backing up $dest to $dest.old"
        mv "$dest" "$dest.old"
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

# --- cleanup_stale: remove ECC symlinks in target_dir not in wanted list ---
# Only removes symlinks whose target contains everything-claude-code/$ecc_subpath,
# so user-owned symlinks in the same directory are never touched.
cleanup_stale() {
    target_dir="$1"; ecc_subpath="$2"; shift 2
    wanted="$*"
    [ -d "$target_dir" ] || return 0
    for link in "$target_dir"/*; do
        [ -L "$link" ] || continue
        link_target=$(readlink "$link")
        case "$link_target" in
            *everything-claude-code/$ecc_subpath*)
                base=$(basename "$link")
                found=0
                for w in $wanted; do [ "$w" = "$base" ] && found=1 && break; done
                if [ "$found" -eq 0 ]; then
                    echo "Removing stale link: $link"
                    rm "$link"
                fi ;;
        esac
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
            case "$(readlink "$target")" in
                *everything-claude-code*)
                    echo "Migrating $target: whole-dir symlink -> directory"
                    rm "$target"
                    mkdir -p "$target"
                    ;;
            esac
        fi
    done

    # Remove un-namespaced ECC symlinks from commands/ and agents/
    for dir in commands agents; do
        [ -d "$CLAUDE_HOME/$dir" ] || continue
        for link in "$CLAUDE_HOME/$dir"/*.md; do
            [ -L "$link" ] || continue
            case "$(readlink "$link")" in
                *everything-claude-code/$dir/*)
                    echo "Removing un-namespaced symlink: $link"
                    rm "$link" ;;
            esac
        done
    done

    # Remove un-namespaced ECC skill symlinks (direct children of skills/, not ecc/)
    if [ -d "$CLAUDE_HOME/skills" ]; then
        for entry in "$CLAUDE_HOME/skills"/*; do
            [ -L "$entry" ] || continue
            case "$(readlink "$entry")" in
                *everything-claude-code/skills/*)
                    echo "Removing un-namespaced skill symlink: $entry"
                    rm "$entry" ;;
            esac
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
                case "$(readlink "$link")" in
                    *everything-claude-code/rules/*)
                        echo "Removing un-namespaced rule symlink: $link"
                        rm "$link" ;;
                esac
            done
            # Remove category dir if now empty
            if [ -z "$(ls -A "$category_dir" 2>/dev/null)" ]; then
                rmdir "$category_dir"
                echo "Removed empty dir: $category_dir"
            fi
        done
    fi
}

# =====================
# 1. Core: CLAUDE.md
# =====================
mkdir -p "$CLAUDE_HOME"
install_link "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

# =====================
# 2. ECC integration
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
cleanup_stale "$CLAUDE_HOME/agents/ecc" "agents" $wanted_agents

# Commands: all ECC commands under commands/ecc/ (invoked as /ecc:command-name)
mkdir -p "$CLAUDE_HOME/commands/ecc"
wanted_commands=""
for src in "$ECC_DIR/commands"/*.md; do
    [ -f "$src" ] || continue
    base=$(basename "$src")
    install_link "$src" "$CLAUDE_HOME/commands/ecc/$base"
    wanted_commands="$wanted_commands $base"
done
cleanup_stale "$CLAUDE_HOME/commands/ecc" "commands" $wanted_commands

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
cleanup_stale "$CLAUDE_HOME/skills/ecc" "skills" $wanted_skills

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
    cleanup_stale "$category_dir" "rules/$category" $wanted_rules
    # Remove category dir if now empty
    if [ -z "$(ls -A "$category_dir" 2>/dev/null)" ]; then
        rmdir "$category_dir"
        echo "Removed empty dir: $category_dir"
    fi
done

echo "Claude Code setup complete."
