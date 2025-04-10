#!/bin/bash

# Check if LazyVim is already installed
if [ -d "$HOME/.config/nvim" ] && [ -f "$HOME/.config/nvim/lua/config/lazy.lua" ]; then
    echo "LazyVim is already installed. Skipping installation."
    exit 0
fi

# Ask for confirmation before installing
read -p "Install LazyVim? (y/N): " install_lazyvim
if [[ "$install_lazyvim" =~ ^[Yy]$ ]]; then
    echo "Installing LazyVim..."
    
    # Ask about removing existing configs
    read -p "Remove existing Neovim configurations? (y/N): " remove_configs
    if [[ "$remove_configs" =~ ^[Yy]$ ]]; then
        rm -rf ~/.config/nvim
        rm -rf ~/.local/share/nvim
        rm -rf ~/.local/state/nvim
        rm -rf ~/.cache/nvim
    fi

    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    echo "LazyVim installed successfully."
    echo "Starting Neovim to complete setup..."
    nvim
else
    echo "Skipping LazyVim installation."
    exit 0
fi