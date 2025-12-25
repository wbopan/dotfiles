#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure directories exist
mkdir -p ~/.config/nvim
mkdir -p ~/.claude
mkdir -p ~/Library/Application\ Support/lazygit

# Backup existing file (if not a symlink) and create symlink
link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "Backed up $dst -> $dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "Linked $dst"
}

link "$DIR/.tmux.conf"           ~/.tmux.conf
link "$DIR/init.lua"             ~/.config/nvim/init.lua
link "$DIR/.zshrc"               ~/.zshrc
link "$DIR/.zimrc"               ~/.zimrc
link "$DIR/claude_settings.json" ~/.claude/settings.json
link "$DIR/lazygit.yml"          ~/Library/Application\ Support/lazygit/config.yml

echo "Done!"
