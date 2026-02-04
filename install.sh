#!/usr/bin/env bash

DOTFILES="$HOME/projects/dotfiles"
CONFIG="$HOME/.config"

mkdir -p "$CONFIG"

ln -sf "$DOTFILES/nvim" "$CONFIG/nvim"
ln -sf "$DOTFILES/wezterm" "$CONFIG/wezterm"
ln -sf "$DOTFILES/fastfetch" "$CONFIG/fastfetch"
