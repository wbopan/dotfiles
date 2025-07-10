# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository for managing personal configuration files across different tools:
- Fish shell configuration
- Tmux configuration
- Claude Code custom slash commands

## Key Commands

### Installation
```bash
# Show help and available options
./install.sh --help

# Install specific components
./install.sh --fish      # Install fish shell configuration only
./install.sh --tmux      # Install tmux configuration only
./install.sh --claude    # Install Claude custom commands only

# Install all dotfiles and dependencies
./install.sh --all

# Combine flags for multiple components
./install.sh --fish --tmux

# Install with --yes mode (non-interactive, auto-backup existing files)
./install.sh --yes --all
./install.sh --yes --fish --tmux
```

### Fish Shell Commands
```bash
fish_deps health              # Check if all required tools are installed
fish_deps install <package>   # Install specific dependency packages
fish_deps check <package>     # Check if specific package is installed
tx                            # Create/attach to tmux session (creates session named after current directory if no args)
tx <command>                  # Run command in new tmux session
dcc                           # DevContainer CLI wrapper with enhanced features (defined in fish/conf.d/05-functions.fish)
dcc --dryrun                  # Preview commands without executing them
sshtmux <host>                # SSH to host and create/attach tmux session with timestamp
op-sync                       # Sync environment variables from 1Password to ~/.profile
op-status                     # Show 1Password integration status
```

## Architecture

The repository uses symbolic links to connect configuration files from this repository to their expected locations in the home directory:

### Fish Shell Configuration
- `fish/config.fish` → `~/.config/fish/config.fish` (Main configuration file)
- `fish/conf.d/*.fish` → `~/.config/fish/conf.d/*.fish` (Individual modular configuration files auto-discovered and linked separately)
  - Current files: 00-general.fish, 01-dependencies.fish, 02-aliases.fish, 03-git.fish, 04-plugins.fish, 05-functions.fish, 06-proxy.fish, 07-1password.fish
  - New `.fish` files added to `fish/conf.d/` are automatically discovered and linked by the install script
  - Functions like `dcc`, `sshtmux`, and `tx` are defined in `05-functions.fish`

### Other Configurations
- `tmux/.tmux.conf` → `~/.tmux.conf`

### Claude Code Custom Commands
- `claude/commands/*.md` → `~/.claude/commands/*.md` (Custom slash commands for Claude Code)
  - Commands are markdown files that define custom workflows and templates
  - Currently includes: `agent-loop.md` - A workflow template for iterative task orchestration
  - New `.md` files added to `claude/commands/` are automatically discovered and linked by the install script
  - Commands can be invoked in Claude Code using `/command-name` syntax
  - Commands sync to the user-wide directory `~/.claude/commands/` for use across all projects

### 1Password Integration
- `.env` → `~/.config/fish/.env` (Contains environment variables with 1Password secret references)
- Uses `op://` protocol for secret references (e.g., `op://Personal/vault/item/field`)
- Secrets are synced to `~/.profile` using `op-sync` command
- **POSIX Compatibility**: Fish cannot directly source `.profile` files with POSIX/bash syntax
  - The `_load_profile_env` function in `00-general.fish` uses bash to export environment variables
  - This approach safely loads `.profile` variables into Fish without syntax errors

The main `install.sh` script:
1. Creates symbolic links for all configuration files
2. Backs up existing files with timestamps if they exist
3. Automatically installs fish shell if not present
4. Sources fish configuration and runs dependency health check

## Recent Updates

### Fish Configuration Restructure
- **Modular configuration**: Split `config.fish` into modular `conf.d/` files for better organization
- **Automatic loading**: Fish automatically sources files from `conf.d/` directory
- **Auto-discovery linking**: Install script automatically discovers and links all `.fish` files in `conf.d/` individually
- **Logical grouping**: Configuration split into general utilities, dependencies check, aliases, git, plugins, functions, proxy, and 1password
- **Numbered prefixes**: Ensures proper loading order with `00-` through `07-` prefixes
- **Maintenance-free**: New files added to `conf.d/` are automatically included without updating install scripts

### Dependency Management System
- **Centralized dependency management**: All dependencies managed through `fish_deps` command defined in `01-dependencies.fish`
- **Cross-platform support**: Supports macOS (via Homebrew) and Linux (via apt/dnf/pacman)
- **Health monitoring**: Use `fish_deps health` to check status of all dependencies
- **Available packages**: zoxide, direnv, fzf, bat, eza, fd, tmux, uv, rg, nvim, tpm, op

### Installation and Uninstallation Scripts
- Update @install.sh and @uninstall.sh after add new scripts

### Claude Code Commands
- **Auto-discovery**: Install script automatically discovers and links all `.md` files in `claude/commands/`
- **Command usage**: Use `/agent-loop` in Claude Code to trigger the iterative task orchestration workflow
- **Adding commands**: Create new `.md` files in `claude/commands/` to add custom commands

## Code Maintenance Guidelines
- When you remove a feature, please consider leave some back-compat code in @uninstall.sh 
- When adding new fish configuration, create a new file in `fish/conf.d/` with appropriate numeric prefix
- Test installations using `./install.sh --yes` in a clean environment before committing
- Always handle both macOS and Linux platforms in dependency installation code

## Security Considerations
- The `.env` file contains sensitive API keys and tokens using 1Password references
- Never commit actual secrets - always use 1Password references (op://) in the .env file
- Use `op-sync` to securely inject secrets from 1Password to `~/.profile`
- The `.profile` file should have 600 permissions (automatically set by op-sync)

## Testing Changes
```bash
# Test installation without affecting existing setup
./install.sh --dryrun  # Note: --dryrun not currently implemented, use manual testing

# Test specific component installation
./install.sh --fish --yes
./install.sh --claude --yes

# Test uninstallation with copy mode (preserves configs)
./uninstall.sh --copy

# Check dependency health after changes
fish -c "fish_deps health"

# Test custom functions
fish -c "tx"
fish -c "dcc --dryrun up"
```

## DevContainer Integration
The `dcc` function provides enhanced DevContainer CLI functionality:
- Automatically detects and uses podman or docker
- Handles git worktree mounts for proper git integration
- Provides --dryrun mode for command preview
- Auto-starts container if not running
- Integrates with claude CLI for AI assistance within containers

## Common Development Tasks
- **Add new fish configuration**: Create file in `fish/conf.d/` with next numeric prefix
- **Add new dependency**: Update `01-dependencies.fish` to add to fish_deps system
- **Modify tmux config**: Edit `tmux/.tmux.conf`
- **Add new environment variable**: Add to `.env` with 1Password reference, then run `op-sync`
- **Add new Claude command**: Create `.md` file in `claude/commands/` with command definition