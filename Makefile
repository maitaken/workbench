PWD := $(shell pwd)

.PHONY: symlink
symlink:
	ln -s $(PWD)/dotfiles/.zshrc ~/.zshrc
	ln -s $(PWD)/dotfiles/.vimrc ~/.vimrc
	ln -s $(PWD)/dotfiles/.tmux.conf ~/.tmux.conf

.PHONY: setup_tmux
setup_tmux:
# https://github.com/catppuccin/tmux
	mkdir -p ~/.config/tmux/plugins/catppuccin
	git clone -b v2.3.0 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
