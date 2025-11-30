# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository managing shell (Zsh), tmux, and Neovim configurations. All configs are symlinked from this repo to their expected locations.

## Commands

```bash
# Install dotfiles (creates symlinks, backs up existing files)
./install.sh

# Uninstall dotfiles (removes symlinks, restores backups)
./uninstall.sh

# Check dependency status (run in zsh after install)
health
```

## Structure

- `.zshrc` + `.zimrc` - Zsh config using Zim framework
- `.tmux.conf` - Tmux config with TPM plugin manager
- `init.lua` - Neovim config with lazy.nvim plugin manager
- `claude_settings.json` - Claude Code settings (symlinked to `~/.claude/settings.json`)

## Key Features

Zsh config includes:
- **Proxy detection**: Auto-detects local proxy on ports 7899/7890/7891/17890
- **Command timer**: Notifies when whitelisted long-running commands (>3min) complete
- **VS Code integration**: Shell integration with tmux passthrough for terminal markers
- **`notify` function**: Desktop notifications via OSC or ntfy.sh (when tmux detached)
- **`prune_vsct_tmux`**: Auto-cleanup of detached VSCode-created tmux sessions

## Plugin Managers

- **Tmux**: TPM - install with `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`, then `prefix + I`
- **Neovim**: lazy.nvim - auto-bootstraps on first launch
- **Zsh**: Zim framework - auto-downloads on first source
