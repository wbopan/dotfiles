#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

# Remove symlink if it points to our repo, optionally restore backup
unlink() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    rm "$dst"
    echo "Removed $dst"
    if [ -e "$dst.bak" ]; then
      mv "$dst.bak" "$dst"
      echo "Restored $dst.bak -> $dst"
    fi
  fi
}

unlink "$DIR/.tmux.conf"           ~/.tmux.conf
unlink "$DIR/init.lua"             ~/.config/nvim/init.lua
unlink "$DIR/.zshrc"               ~/.zshrc
unlink "$DIR/.zimrc"               ~/.zimrc
unlink "$DIR/claude_settings.json" ~/.claude/settings.json
unlink "$DIR/lazygit.yml"          ~/Library/Application\ Support/lazygit/config.yml
unlink "$DIR/starship.toml"        ~/.config/starship.toml

echo "Done!"
