#!/bin/bash

# --- Helper Functions ---

# Symlinks a file, backing up the original if it exists and isn't already a link.
install_file() {
    local src="$(pwd)/$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        echo "Backing up $dest to $dest.old"
        mv "$dest" "$dest.old"
    fi

    echo "Linking $dest -> $src"
    ln -s "$src" "$dest"
}

# Sets up shell entry points by linking directly to the repo files.
setup_shell_config() {
    local platform="$1"

    echo "Setting up shell entry points (linking directly to repo)..."

    if [[ "$platform" == "mac" ]]; then
        install_file "zsh/zprofile" "$HOME/.zprofile"
        install_file "zsh/zshrc"    "$HOME/.zshrc"
        [[ -e "$HOME/.profile" ]] && mv "$HOME/.profile" "$HOME/.profile.old"
    else
        install_file "bash/bash_profile" "$HOME/.bash_profile"
        install_file "bash/bashrc"       "$HOME/.bashrc"
        [[ -e "$HOME/.profile" ]] && mv "$HOME/.profile" "$HOME/.profile.old"
    fi
}

# Sets up configuration for Vim, Tmux, and Git.
setup_other_configs() {
    echo "Setting up Vim, Tmux, and Git..."

    # Tmux
    install_file "common/tmux" "$HOME/.tmux.conf"

    # Vim
    install_file "common/vimrc" "$HOME/.vimrc"
    mkdir -p "$HOME/.vim/ftplugin"
    install_file "common/vim/c.vim" "$HOME/.vim/ftplugin/c.vim"
    mkdir -p "$HOME/.vim/undodir"

    # Neovim
    mkdir -p "$HOME/.config"
    install_file "neovim" "$HOME/.config/nvim"

    # Git
    install_file "common/gitconfig" "$HOME/.gitconfig"

    # Claude Code
    mkdir -p "$HOME/.claude"
    install_file "claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
}

# Sets up local configuration files by copying templates if they don't exist.
setup_local_configs() {
    echo "Checking for local configuration files..."

    if [[ ! -f "$HOME/.gitconfig.local" ]]; then
        echo "Creating ~/.gitconfig.local from template..."
        cp "templates/gitconfig.local.example" "$HOME/.gitconfig.local"
        echo "PLEASE EDIT ~/.gitconfig.local WITH YOUR SECRETS!"
    fi

    if [[ ! -f "$HOME/.shrc.local" ]]; then
        echo "Creating ~/.shrc.local from template..."
        cp "templates/shrc.local.example" "$HOME/.shrc.local"
        echo "PLEASE EDIT ~/.shrc.local WITH YOUR LOCAL SETTINGS!"
    fi
}

# Installs core packages by parsing packages.list and choosing the right name for the platform.
install_packages() {
    local platform="$1"
    local pkgs=()
    local col=1

    if [[ "$platform" == "mac" ]]; then
        col=2
    elif command -v apt-get &> /dev/null; then
        col=3
    elif command -v dnf &> /dev/null; then
        col=4
    fi

    echo "Building package list for $platform..."
    if [[ ! -f packages.list ]]; then
        echo "Error: packages.list not found."
        return 1
    fi

    while IFS='|' read -r generic mac apt dnf || [ -n "$generic" ]; do
        # Skip comments and empty lines
        [[ "$generic" =~ ^[[:space:]]*#.*$ || -z "${generic// /}" ]] && continue

        # Trim whitespace
        generic=$(echo "$generic" | xargs)
        mac=$(echo "$mac" | xargs)
        apt=$(echo "$apt" | xargs)
        dnf=$(echo "$dnf" | xargs)

        local name=""
        case "$col" in
            2) name="${mac:-$generic}" ;;
            3) name="${apt:-$generic}" ;;
            4) name="${dnf:-$generic}" ;;
            *) name="$generic" ;;
        esac
        pkgs+=("$name")
    done < packages.list

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        echo "No packages found to install."
        return
    fi

    echo "Installing: ${pkgs[*]}"
    if [[ "$platform" == "mac" ]]; then
        if ! command -v brew &> /dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        brew install "${pkgs[@]}"
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y "${pkgs[@]}"
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y "${pkgs[@]}"
    else
        echo "Warning: No supported package manager found. Please install: ${pkgs[*]}"
    fi
}

# Installs plugin managers and plugins for Tmux (TPM) and Vim (vim-plug).
install_plugins() {
    local platform="$1"
    echo "Installing plugins..."
    
    # Tmux TPM
    local tmux_tpm="$HOME/.tmux/plugins/tpm"
    if [[ -f "$HOME/.tmux" ]]; then
        rm "$HOME/.tmux"
    fi
    if [ ! -d "$tmux_tpm" ]; then
        mkdir -p "$HOME/.tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "$tmux_tpm"
    fi
    "$tmux_tpm/bin/install_plugins"

    # Vim vim-plug
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +PlugInstall +qall

    # fzf shell integration (generates ~/.fzf.zsh / ~/.fzf.bash)
    if command -v fzf &>/dev/null; then
        local fzf_install
        if [[ "$platform" == "mac" ]]; then
            fzf_install="$(brew --prefix)/opt/fzf/install"
        else
            fzf_install="$HOME/.fzf/install"
        fi
        if [[ -x "$fzf_install" ]]; then
            "$fzf_install" --key-bindings --completion --no-update-rc
        fi
    fi
}

# --- Main Execution ---

usage() {
    echo "Usage: $0 [all|packages|configs|plugins]"
    echo "  all      - Install packages, set up configs, and install plugins (default)"
    echo "  packages - Install packages only"
    echo "  configs  - Set up configurations only"
    echo "  plugins  - Install plugins only"
    exit 1
}

main() {
    local target="all"
    local platform=""

    # 1. Platform Detection
    case "$(uname -s)" in
        Darwin*)  platform="mac";;
        Linux*)   platform="linux";;
        *)        echo "Unsupported OS"; exit 1;;
    esac

    # 2. Argument Parsing
    if [[ $# -gt 0 ]]; then
        case "$1" in
            all|packages|configs|plugins)
                target="$1"
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Unknown target: $1"
                usage
                ;;
        esac
    fi

    echo "Configuring for platform: $platform (Target: $target)"

    # 3. Pre-flight checks
    if [[ -z "$(ls -A neovim 2>/dev/null)" || ! -f "neovim/init.lua" ]]; then
        echo "ERROR: neovim submodule is not initialized. Did you run ./setup.sh first?"
        echo "  git submodule update --init --recursive"
        exit 1
    fi

    # 4. Execution based on target
    case "$target" in
        all)
            install_packages "$platform"
            setup_shell_config "$platform"
            setup_other_configs
            setup_local_configs
            install_plugins "$platform"
            ;;
        packages)
            install_packages "$platform"
            ;;
        configs)
            setup_shell_config "$platform"
            setup_other_configs
            setup_local_configs
            ;;
        plugins)
            install_plugins "$platform"
            ;;
    esac

    echo "Configuration complete!"
}

# Execute main with all passed arguments
main "$@"
