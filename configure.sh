#/bin/bash

PLATFORM="linux"
INSTALL_ONLY=false

setup_configs() {
	# bashrc
	if [[ -e $HOME/.bashrc ]]; then
		cp $HOME/.bashrc $HOME/.bashrc.old
	fi
	if [[ $PLATFORM = "mac" ]]; then
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
	cp common/tmux $HOME/.tmux.conf

	# vim
	if [[ -e $HOME/.vimrc ]]; then
    	    	cp $HOME/.vimrc $HOME/.vimrc.old
	fi
	cp common/vimrc $HOME/.vimrc

	# git
	if [[ -e $HOME/.gitconfig ]]; then
    	    	cp $HOME/.gitconfig $HOME/.gitconfig.old
	fi
	cp common/gitconfig $HOME/.gitconfig
}

install_plugins() {
	# tmux tpm
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

# should I configure?
if [ "$INSTALL_ONLY" = false ]; then
	setup_configs
fi

install_plugins
