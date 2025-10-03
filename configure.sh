#/bin/bash

mac_zshrc() {
    if [[ -e $HOME/.zshrc ]]; then
	    cp $HOME/.zshrc $HOME/.zshrc.old
    fi
    if [[ -e $HOME/.zprofile ]]; then
        cp $HOME/.zprofile $HOME/.zprofile.old
    fi
    if [[ -e $HOME/.profile ]]; then
        cp $HOME/.profile $HOME/.profile.old
    fi

    cp mac/zshrc $HOME/.zshrc
    cp mac/zprofile $HOME/.zprofile

    cp mac/profile $HOME/.profile
    echo -ne "\n" >> $HOME/.profile
    cat common/profile >> $HOME/.profile
}

linux_bashrc() {
    if [[ -e $HOME/.bashrc ]]; then
	    cp $HOME/.bashrc $HOME/.bashrc.old
    fi
    if [[ -e $HOME/.bash_profile ]]; then
        cp $HOME/.bash_profile $HOME/.bash_profile.old
    fi
    if [[ -e $HOME/.profile ]]; then
        cp $HOME/.profile $HOME/.profile.old
    fi

    cp linux/bashrc $HOME/.bashrc
    cp linux/bash_profile $HOME/.bash_profile

    cp linux/profile $HOME/.profile
    echo -ne "\n" >> $HOME/.profile
    cat common/profile >> $HOME/.profile
}

setup_configs() {
    # aliases
    if [[ -e $HOME/.sh_aliases ]]; then
        cp $HOME/.sh_aliases $HOME/.sh_aliases.old
    fi
    cp common/sh_aliases $HOME/.bash_aliases

    # helpers
    if [[ -e $HOME/.sh_helpers ]]; then
	    mv $HOME/.sh_helpers $HOME/.sh_helpers.old
    fi
    cp -r common/sh_helpers $HOME/.sh_helpers

    # rc files 
    if [[ $PLATFORM = "mac" ]]; then
        mac_zshrc
    else
        linux_bashrc
    fi

    # tmux
    if [[ -e $HOME/.tmux.conf ]]; then
        cp $HOME/.tmux.conf $HOME/.tmux.conf.old
    fi
    cp common/tmux $HOME/.tmux.conf

    # vim
    if [[ -e $HOME/.vimrc ]]; then
        cp $HOME/.vimrc $HOME/.vimrc.old
    fi
    cp common/vimrc $HOME/.vimrc
    mkdir -p $HOME/.vim/ftplugin
    cp common/vim/c.vim $HOME/.vim/ftplugin/
    # vim persistent undo
    mkdir -p $HOME/.vim/undodir

    # git
    if [[ -e $HOME/.gitconfig ]]; then
        cp $HOME/.gitconfig $HOME/.gitconfig.old
    fi
    cp common/gitconfig $HOME/.gitconfig
}

install_plugins() {
    # tmux tpm
    if [[ -e $HOME/.tmux ]]; then
        rm -rf $HOME/.tmux
    fi
    install_dir="$HOME/.tmux/plugins/tpm"
    if [ ! -d $install_dir ]; then
        git clone https://github.com/tmux-plugins/tpm $install_dir
    fi
    $HOME/.tmux/plugins/tpm/bin/install_plugins

    # vim
    install_dir="$HOME/.vim/bundle/Vundle.vim"
    if [ ! -d $install_dir ]; then
        echo $install_dir
        git clone https://github.com/VundleVim/Vundle.vim.git $install_dir
    fi
    vim +PluginInstall +qall
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -p) PLATFORM="$2"; shift 2;;
        --platform=*) PLATFORM="${1#*=}"; shift 1;;
        --install-only) INSTALL_ONLY=true; shift 1;;
    esac
done

if [[ -z "$PLATFORM" ]]; then
    echo "set platform -p or --platform=<linux|mac>"
    exit 1
fi

# should I configure?
if [[ -z "$INSTALL_ONLY" ]]; then
    setup_configs
fi

install_plugins
