PWD := $(shell pwd)
XDG_CONFIG_HOME = ${HOME}/.config

.PHONY: symlink
symlink:
	mkdir -p $(XDG_CONFIG_HOME)/ghostty
	ln -sfn $(PWD)/dotfiles/config.ghostty $(XDG_CONFIG_HOME)/ghostty/config.ghostty

	mkdir -p ~/.codex
	ln -sfn $(PWD)/codex/config.toml ~/.codex/config.toml
	ln -sfn $(PWD)/codex/AGENT.md ~/.codex/AGENT.md

	ln -sfn $(PWD)/dotfiles/.zshrc ~/.zshrc
	ln -sfn $(PWD)/dotfiles/.vimrc ~/.vimrc
	ln -sfn $(PWD)/dotfiles/.tmux.conf ~/.tmux.conf

.PHONY: setup_tmux
setup_tmux:
# https://github.com/catppuccin/tmux
	mkdir -p ~/.config/tmux/plugins/catppuccin
	git clone -b v2.3.0 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux

install:
	brew tap homebrew/cask-fonts
	brew install --cask font-fira-code
