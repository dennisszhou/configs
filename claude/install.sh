#!/bin/sh
# claude/install.sh — manages all Claude Code symlinks
# Called by configure.sh during the configs target.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ECC_DIR="$REPO_DIR/everything-claude-code"
MANIFEST="$SCRIPT_DIR/manifest.conf"
CLAUDE_HOME="$HOME/.claude"

# --- install_link: symlink with backup (mirrors install_file pattern) ---
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

# --- cleanup_stale: remove ECC symlinks not in wanted list ---
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

# Agents: whole-directory symlink
install_link "$ECC_DIR/agents" "$CLAUDE_HOME/agents"

# Commands: whole-directory symlink
install_link "$ECC_DIR/commands" "$CLAUDE_HOME/commands"

# Skills: selective per-item symlinks
mkdir -p "$CLAUDE_HOME/skills"
wanted_skills=""
for skill in $(parse_section skills); do
    if [ -d "$ECC_DIR/skills/$skill" ]; then
        install_link "$ECC_DIR/skills/$skill" "$CLAUDE_HOME/skills/$skill"
        wanted_skills="$wanted_skills $skill"
    else
        echo "Warning: skill '$skill' not found in ECC, skipping"
    fi
done
cleanup_stale "$CLAUDE_HOME/skills" "skills" $wanted_skills

# Rules: selective per-item symlinks (category/filename format)
for rule_entry in $(parse_section rules); do
    category=$(dirname "$rule_entry")
    filename=$(basename "$rule_entry")
    src="$ECC_DIR/rules/$category/${filename}.md"
    if [ -f "$src" ]; then
        mkdir -p "$CLAUDE_HOME/rules/$category"
        install_link "$src" "$CLAUDE_HOME/rules/$category/${filename}.md"
    else
        echo "Warning: rule '$rule_entry' not found in ECC, skipping"
    fi
done
# Cleanup stale rules per category
for category_dir in "$CLAUDE_HOME/rules"/*/; do
    [ -d "$category_dir" ] || continue
    category=$(basename "$category_dir")
    wanted_rules=""
    for rule_entry in $(parse_section rules); do
        rc=$(dirname "$rule_entry"); rf=$(basename "$rule_entry")
        [ "$rc" = "$category" ] && wanted_rules="$wanted_rules ${rf}.md"
    done
    cleanup_stale "$category_dir" "rules/$category" $wanted_rules
done

echo "Claude Code setup complete."
