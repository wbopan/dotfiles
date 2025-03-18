#!/bin/bash

echo "Do you want to remove existing Neovim configurations? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim
    rm -rf ~/.cache/nvim
fi

git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

nvim