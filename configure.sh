#/bin/bash

# bashrc
if [[ -e $HOME/.bashrc ]]; then
    cp $HOME/.bashrc $HOME/.bashrc.old
fi
if [[ $1 = "mac" ]]; then
  cp mac/bashrc $HOME/.bashrc
else
  cp linux/bashrc $HOME/.bashrc
fi
echo -ne "\n" >> $HOME/.bashrc
cat common/bashrc >> $HOME/.bashrc
cat common/bash_profile >> $HOME/.bash_profile

# tmux
if [[ -e $HOME/.tmux.conf ]]; then
    cp $HOME/.tmux.conf $HOME/.tmux.conf.old
fi
install_dir="$HOME/.tmux/plugins/tpm"
if [ ! -d $install_dir ]; then
  git clone https://github.com/tmux-plugins/tpm $install_dir
fi
cp common/tmux $HOME/.tmux.conf
$HOME/.tmux/plugins/tpm/bin/install_plugins


# vim
if [[ -e $HOME/.vimrc ]]; then
    cp $HOME/.vimrc $HOME/.vimrc.old
fi
install_dir="$HOME/.vim/bundle/Vundle.vim"
if [ ! -d $install_dir ]; then
echo $install_dir
  git clone https://github.com/VundleVim/Vundle.vim.git $install_dir
fi
cp common/vimrc $HOME/.vimrc
vim +PluginInstall +qall

# git
if [[ -e $HOME/.gitconfig ]]; then
    cp $HOME/.gitconfig $HOME/.gitconfig.old
fi
cp common/gitconfig $HOME/.gitconfig
