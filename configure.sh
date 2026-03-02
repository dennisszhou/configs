#!/bin/bash

# --- Helper Functions ---

# Backs up a file to .old if it exists, then copies the source to destination.
install_file() {
    local src="$1"
    local dest="$2"
    if [[ -e "$dest" ]]; then
        echo "Backing up $dest to $dest.old"
        cp "$dest" "$dest.old"
    fi
    cp "$src" "$dest"
}

# Deploys modular shell components to ~/.shell_config and sets up shell entry points.
setup_shell_config() {
    local platform="$1"
    local CONFIG_HOME="$HOME/.shell_config"
    mkdir -p "$CONFIG_HOME/os"
    mkdir -p "$CONFIG_HOME/functions"

    echo "Deploying modular shell components to $CONFIG_HOME..."
    install_file "common/shrc"    "$CONFIG_HOME/shrc"
    install_file "common/aliases" "$CONFIG_HOME/aliases"
    cp common/functions/* "$CONFIG_HOME/functions/"

    if [[ "$platform" == "mac" ]]; then
        install_file "os/mac"       "$CONFIG_HOME/os/mac"
        install_file "zsh/zshrc"    "$HOME/.zshrc"
        install_file "zsh/zprofile" "$HOME/.zprofile"
        [[ -e "$HOME/.profile" ]] && mv "$HOME/.profile" "$HOME/.profile.old"
    else
        install_file "os/linux"          "$CONFIG_HOME/os/linux"
        install_file "bash/bashrc"       "$HOME/.bashrc"
        install_file "bash/bash_profile" "$HOME/.bash_profile"
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
    cp common/vim/c.vim "$HOME/.vim/ftplugin/"
    mkdir -p "$HOME/.vim/undodir"

    # Git
    install_file "common/gitconfig" "$HOME/.gitconfig"
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
        setup_shell_config "$platform"
        setup_other_configs
    fi

    # 5. Plugins
    install_plugins
    echo "Configuration complete!"
}

# Execute main with all passed arguments
main "$@"
