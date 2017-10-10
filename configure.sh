#/bin/bash

# bashrc
if [[ $1 = "mac" ]]; then
  cp mac/bashrc ~/.bashrc
else
  cp linux/bashrc ~/.bashrc
fi
echo -ne "\n" >> ~/.bashrc
cat common/bashrc >> ~/.bashrc
cat common/bash_profile >> ~/.bash_profile

# tmux
install_dir="$HOME/.tmux/plugins/tpm"
if [ ! -d $install_dir ]; then
  git clone https://github.com/tmux-plugins/tpm $install_dir
fi
cp common/tmux ~/.tmux.conf
~/.tmux/plugins/tpm/bin/install_plugins


# vim
install_dir="$HOME/.vim/bundle/Vundle.vim"
if [ ! -d $install_dir ]; then
echo $install_dir
  git clone https://github.com/VundleVim/Vundle.vim.git $install_dir
fi
cp common/vimrc ~/.vimrc
vim +PluginInstall +qall

# git
cp common/gitconfig ~/.gitconfig
