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

    # Clean up old modular directory if it exists
    if [[ -d "$HOME/.shell_config" ]]; then
        echo "Removing old ~/.shell_config directory..."
        rm -rf "$HOME/.shell_config"
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

    # Git
    install_file "common/gitconfig" "$HOME/.gitconfig"
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

# Installs plugin managers and plugins for Tmux (TPM) and Vim (Vundle).
install_plugins() {
    echo "Installing plugins..."
    
    # Tmux TPM
    if [[ -e $HOME/.tmux ]]; then
        rm -rf $HOME/.tmux
    fi
    local tmux_tpm="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$tmux_tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "$tmux_tpm"
    fi
    "$tmux_tpm/bin/install_plugins"

    # Vim Vundle
    local vim_vundle="$HOME/.vim/bundle/Vundle.vim"
    if [ ! -d "$vim_vundle" ]; then
        git clone https://github.com/VundleVim/Vundle.vim.git "$vim_vundle"
    fi
    vim +PluginInstall +qall
}

# --- Main Execution ---

main() {
    local platform=""
    local install_only=false
    local detected_platform=""

    # 1. Platform Detection
    case "$(uname -s)" in
        Darwin*)  detected_platform="mac";;
        Linux*)   detected_platform="linux";;
        *)        echo "Unsupported OS"; exit 1;;
    esac

    # 2. Argument Parsing
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -p) platform="$2"; shift 2;;
            --platform=*) platform="${1#*=}"; shift 1;;
            --install-only) install_only=true; shift 1;;
            *) echo "Unknown option: $1"; exit 1;;
        esac
    done

    # 3. Validation
    if [[ -n "$platform" && "$platform" != "$detected_platform" ]]; then
        echo "Error: You specified '$platform' but I detected '$detected_platform'."
        exit 1
    fi
    platform=$detected_platform
    echo "Configuring for platform: $platform"

    # 4. Implementation
    if [[ "$install_only" = false ]]; then
        install_packages "$platform"
        setup_shell_config "$platform"
        setup_other_configs
    fi

    # 5. Plugins
    install_plugins
    echo "Configuration complete!"
}

# Execute main with all passed arguments
main "$@"
