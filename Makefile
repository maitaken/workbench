PWD := $(shell pwd)

symlink:
	ln -s $(PWD)/dotfiles/.zshrc ~/.zshrc
	ln -s $(PWD)/dotfiles/.vimrc ~/.vimrc
	ln -s $(PWD)/dotfiles/.tmux.conf ~/.tmux.conf
