# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A chezmoi dotfiles repository managing personal development environment configuration across machines. Chezmoi uses a source-state directory (`~/.local/share/chezmoi`) that maps to the home directory via naming conventions.

## Chezmoi Naming Conventions

- `dot_` prefix → `.` (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_` prefix → file gets `0600` permissions
- `encrypted_` prefix → age-encrypted file (decrypted on apply)
- `executable_` prefix → file gets executable permission
- Prefixes stack: `encrypted_private_dot_env.age` → `~/.env` (encrypted, private)
- Subdirectories follow the same rules: `dot_config/nvim/` → `~/.config/nvim/`

## Commands

```bash
chezmoi apply                  # Apply all changes to home directory
chezmoi diff                   # Preview what would change
chezmoi edit <target>          # Edit a managed file (e.g., chezmoi edit ~/.zshrc)
chezmoi add <file>             # Start managing a new file
chezmoi add --encrypt <file>   # Add a file with age encryption
chezmoi cd                     # cd into the source directory
```

Git auto-commit and auto-push are enabled (`.chezmoi.toml.tmpl`), so `chezmoi edit` or `chezmoi add` will automatically commit and push changes.

## Encryption

Uses age encryption with key at `~/.config/chezmoi/key.txt`. Encrypted files have `.age` extension and `encrypted_` prefix. Currently encrypted: `~/.env` and `~/.config/gh/hosts.yml`.

## Repository Structure

| Source File | Target | Purpose |
|---|---|---|
| `dot_zshrc` | `~/.zshrc` | Zsh config: zim framework, aliases, `notify()`, `health()`, proxy detection, command timer |
| `dot_zimrc` | `~/.zimrc` | Zim module declarations (completion, fzf, syntax highlighting, autosuggestions) |
| `dot_tmux.conf` | `~/.tmux.conf` | Tmux: TPM plugins, vi-mode, status bar, clipboard, sesh integration |
| `dot_config/nvim/init.lua` | `~/.config/nvim/init.lua` | Neovim: lazy.nvim, telescope, oil.nvim, blink.cmp, catppuccin, vimtex |
| `dot_config/starship.toml` | `~/.config/starship.toml` | Starship prompt: nerd font symbols |
| `dot_config/lazygit/config.yml` | Lazygit config | Editor integration with nvim |
| `private_dot_claude/` | `~/.claude/` | Claude Code settings, hooks, statusline script |

## Key Design Decisions

- **Shell framework**: Zim (not oh-my-zsh). Module load order matters — completion before fzf, syntax-highlighting before autosuggestions.
- **Notification system**: `notify()` in zshrc sends OSC escape sequences for terminal notifications, with tmux passthrough support and ntfy.sh fallback for detached sessions.
- **Command timer**: Long-running commands (>180s) from a whitelist trigger notifications via `notify()`.
- **Claude Code hooks**: `executable_notify.sh` implements delayed (30s) macOS notifications via `terminal-notifier` with click-to-jump-to-tmux-pane. `executable_notify-cancel.sh` cancels pending notifications.
- **Proxy detection**: zshrc auto-detects local proxy on ports 7899/7890/7891/17890 at shell startup.
