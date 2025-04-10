#! /bin/bash

# Check if TPM is already installed
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "TPM is already installed. Skipping installation."
    exit 0
fi

# Ask for confirmation before installing
read -p "Install Tmux Plugin Manager (TPM)? (y/N): " install_tpm
if [[ "$install_tpm" =~ ^[Yy]$ ]]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "TPM installed successfully."
    echo "Run prefix + I (capital i) inside tmux to install plugins."
else
    echo "Skipping TPM installation."
    exit 0
fi

# Source tmux config
tmux source ~/.tmux.conf
