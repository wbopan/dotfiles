#!/bin/bash
set -e

OS="$(uname -s)"

# Install Homebrew / Linuxbrew if missing
if ! command -v brew &>/dev/null; then
    if [ "$OS" = "Linux" ] && [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        [ "$OS" = "Linux" ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi

# Core packages
brew install zoxide direnv fzf bat eza fd tmux uv ripgrep neovim starship age gh lazygit jq

# tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# macOS-specific
if [ "$OS" = "Darwin" ]; then
    brew install terminal-notifier
    brew install --cask 1password-cli
fi
