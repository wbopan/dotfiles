#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Parse command-line arguments
YES_MODE=false
COPY_MODE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y)
            YES_MODE=true
            shift
            ;;
        --copy|-c)
            COPY_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--yes|-y] [--copy|-c]"
            echo "  --yes|-y   : Non-interactive mode, automatically confirm actions"
            echo "  --copy|-c  : Copy files from repo to config location before unlinking"
            exit 1
            ;;
    esac
done

# Define source (in dotfiles repo) and target (in home dir) paths
# Using indexed arrays for better compatibility with older bash versions
SOURCE_PATHS=(
    "fish/config.fish"
    "tmux/.tmux.conf"
    "kitty/kitty.conf"
    "kitty/current-theme.conf"
    # Add more source paths here
)

TARGET_PATHS=(
    "$HOME/.config/fish/config.fish"
    "$HOME/.tmux.conf"
    "$HOME/.config/kitty/kitty.conf"
    "$HOME/.config/kitty/current-theme.conf"
    # Add corresponding target paths here, ensure order matches SOURCE_PATHS
)

# Auto-discover and add all .fish files in conf.d directory for unlinking
for conf_file in "$SCRIPT_DIR"/fish/conf.d/*.fish; do
    if [ -f "$conf_file" ]; then
        # Extract just the filename from the full path
        conf_filename=$(basename "$conf_file")
        SOURCE_PATHS+=("fish/conf.d/$conf_filename")
        TARGET_PATHS+=("$HOME/.config/fish/conf.d/$conf_filename")
    fi
done

# Add backward compatibility for directory-based conf.d linking (if it exists)
if [ -L "$HOME/.config/fish/conf.d" ]; then
    SOURCE_PATHS+=("fish/conf.d")
    TARGET_PATHS+=("$HOME/.config/fish/conf.d")
fi

# Keep backward-compatible uninstall for legacy Claude Code (cc) installs
# If the repo still contains command files, include them; otherwise we'll
# clean up the target directory later even without source files present.
if [ -d "$SCRIPT_DIR/claude/commands" ]; then
    for cmd_file in "$SCRIPT_DIR"/claude/commands/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_filename=$(basename "$cmd_file")
            SOURCE_PATHS+=("claude/commands/$cmd_filename")
            TARGET_PATHS+=("$HOME/.claude/commands/$cmd_filename")
        fi
    done
fi

# Add Neovim configuration path
SOURCE_PATHS+=("nvim/init.lua")
TARGET_PATHS+=("$HOME/.config/nvim/init.lua")

# Helper to resolve LazyGit config directory in a cross-platform way
get_lazygit_config_dir() {
    if command -v lazygit >/dev/null 2>&1; then
        local dir
        dir="$(lazygit -cd 2>/dev/null)"
        if [ -n "$dir" ]; then
            echo "$dir"
            return 0
        fi
    fi
    if [ -n "$XDG_CONFIG_HOME" ]; then
        echo "$XDG_CONFIG_HOME/lazygit"
        return 0
    fi
    case "$OSTYPE" in
        darwin*) echo "$HOME/Library/Application Support/lazygit" ;;
        *)       echo "$HOME/.config/lazygit" ;;
    esac
}

# Add LazyGit configuration path (use resolved directory)
SOURCE_PATHS+=("lazygit/config.yml")
TARGET_PATHS+=("$(get_lazygit_config_dir)/config.yml")

# Function to find the most recent backup file
find_latest_backup() {
    local target=$1
    local backup_pattern="${target}.bak.*"
    
    # Find all backup files and sort by timestamp (newest first)
    local latest_backup=$(ls -t ${backup_pattern} 2>/dev/null | head -n 1)
    
    if [ -n "$latest_backup" ] && [ -f "$latest_backup" ]; then
        echo "$latest_backup"
    else
        echo ""
    fi
}

# Function to unlink and optionally restore backup
unlink_config() {
    local source_rel=$1
    local target=$2
    local source_abs="$SCRIPT_DIR/$source_rel"

    echo "Processing $target"

    # Check if target exists and is a symlink
    if [ -L "$target" ]; then
        # Check if it's linked to our source
        if [ "$(readlink "$target")" == "$source_abs" ]; then
            echo "  [INFO] Found symlink pointing to $source_abs"
            
            # If copy mode is enabled, copy the file content before unlinking
            if [ "$COPY_MODE" = true ]; then
                echo "  [INFO] Copying content from repo to $target before unlinking"
                cp "$source_abs" "${target}.tmp"
                if [ $? -ne 0 ]; then
                    echo "  [ERROR] Failed to copy content. Skipping."
                    return
                fi
                rm "$target"
                mv "${target}.tmp" "$target"
                echo "  [OK] Replaced symlink with actual file."
            else
                # Remove the symlink
                rm "$target"
                echo "  [OK] Removed symlink."
                
                # Look for backup files
                local latest_backup=$(find_latest_backup "$target")
                
                if [ -n "$latest_backup" ]; then
                    echo "  [INFO] Found backup: $latest_backup"
                    
                    if [ "$YES_MODE" = true ]; then
                        echo "  [INFO] Restoring backup..."
                        mv "$latest_backup" "$target"
                        if [ $? -eq 0 ]; then
                            echo "  [OK] Backup restored."
                        else
                            echo "  [ERROR] Failed to restore backup."
                        fi
                    else
                        read -p "  Restore backup? (y/N): " confirm_restore
                        if [[ "$confirm_restore" =~ ^[Yy]$ ]]; then
                            mv "$latest_backup" "$target"
                            if [ $? -eq 0 ]; then
                                echo "  [OK] Backup restored."
                            else
                                echo "  [ERROR] Failed to restore backup."
                            fi
                        else
                            echo "  [SKIP] Backup not restored."
                        fi
                    fi
                else
                    echo "  [INFO] No backup found."
                fi
            fi
        else
            echo "  [SKIP] Symlink points to different location: $(readlink "$target")"
        fi
    elif [ -e "$target" ]; then
        echo "  [SKIP] Target exists but is not a symlink."
    else
        echo "  [SKIP] Target does not exist."
    fi
    
    echo "" # Newline for readability
}

# Function to clean up empty directories
cleanup_empty_dirs() {
    local dir=$1
    
    # Don't remove common config directories
    if [[ "$dir" == "$HOME/.config" ]] || [[ "$dir" == "$HOME" ]]; then
        return
    fi
    
    # Check if directory is empty
    if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; then
        if [ "$YES_MODE" = true ]; then
            rmdir "$dir"
            echo "  [OK] Removed empty directory: $dir"
        else
            read -p "  Remove empty directory $dir? (y/N): " confirm_remove
            if [[ "$confirm_remove" =~ ^[Yy]$ ]]; then
                rmdir "$dir"
                echo "  [OK] Removed empty directory: $dir"
            fi
        fi
    fi
}

# --- Main Script ---
echo "Starting dotfiles uninstall..."
echo "Script directory: $SCRIPT_DIR"
echo "Home directory: $HOME"
if [ "$COPY_MODE" = true ]; then
    echo "Mode: Copy files before unlinking"
else
    echo "Mode: Remove symlinks and restore backups"
fi
echo ""

# Iterate over the arrays and unlink files
num_configs=${#SOURCE_PATHS[@]}
for (( i=0; i<${num_configs}; i++ )); do
    src_rel="${SOURCE_PATHS[i]}"
    tgt_path="${TARGET_PATHS[i]}"
    if [ -n "$src_rel" ] && [ -n "$tgt_path" ]; then # Basic check to ensure pairs exist
        unlink_config "$src_rel" "$tgt_path"
    else
        echo "[WARN] Skipping configuration index $i due to missing source or target path."
    fi
done

# Clean up empty directories
echo "Checking for empty directories..."
for target_path in "${TARGET_PATHS[@]}"; do
    target_dir=$(dirname "$target_path")
    cleanup_empty_dirs "$target_dir"
done

echo ""
echo "Dotfiles uninstall complete."

# --- Compatibility cleanup for legacy Claude Code (cc) ---
# Remove any leftover symlinks under ~/.claude/commands even if
# the source files no longer exist in this repo.
CLAUDE_CMDS_DIR="$HOME/.claude/commands"
if [ -d "$CLAUDE_CMDS_DIR" ]; then
    echo ""
    echo "Cleaning legacy Claude Code symlinks..."
    removed_any=false
    for f in "$CLAUDE_CMDS_DIR"/*; do
        [ -L "$f" ] || continue
        rm "$f" && echo "  [OK] Removed symlink: $f" && removed_any=true
    done
    # Remove directory if empty after cleanup
    if [ -z "$(ls -A "$CLAUDE_CMDS_DIR" 2>/dev/null)" ]; then
        rmdir "$CLAUDE_CMDS_DIR" 2>/dev/null && echo "  [OK] Removed empty directory: $CLAUDE_CMDS_DIR"
        # Also try to remove parent ~/.claude if now empty
        CLAUDE_DIR="$HOME/.claude"
        if [ -d "$CLAUDE_DIR" ] && [ -z "$(ls -A "$CLAUDE_DIR" 2>/dev/null)" ]; then
            rmdir "$CLAUDE_DIR" 2>/dev/null && echo "  [OK] Removed empty directory: $CLAUDE_DIR"
        fi
    elif [ "$removed_any" = false ]; then
        echo "  [SKIP] No legacy Claude symlinks found."
    fi
fi

# Remove devcontainer devcontainer.json if it exists
DEVCONTAINER_DEFAULT="$HOME/.config/devcontainer/devcontainer.json"
if [ -f "$DEVCONTAINER_DEFAULT" ]; then
    echo ""
    echo "Checking devcontainer default configuration..."
    echo "  [INFO] Found default devcontainer configuration at $DEVCONTAINER_DEFAULT"
    
    if [ "$YES_MODE" = true ]; then
        echo "  [INFO] Removing default devcontainer configuration..."
        rm "$DEVCONTAINER_DEFAULT"
        if [ $? -eq 0 ]; then
            echo "  [OK] Removed devcontainer default configuration."
        else
            echo "  [ERROR] Failed to remove devcontainer default configuration."
        fi
    else
        read -p "  Remove default devcontainer configuration? (y/N): " confirm_remove_devcontainer
        if [[ "$confirm_remove_devcontainer" =~ ^[Yy]$ ]]; then
            rm "$DEVCONTAINER_DEFAULT"
            if [ $? -eq 0 ]; then
                echo "  [OK] Removed devcontainer default configuration."
            else
                echo "  [ERROR] Failed to remove devcontainer default configuration."
            fi
        else
            echo "  [SKIP] Default devcontainer configuration retained."
        fi
    fi
    
    # Check if devcontainer directory is empty and remove if so
    DEVCONTAINER_DIR="$HOME/.config/devcontainer"
    if [ -d "$DEVCONTAINER_DIR" ] && [ -z "$(ls -A "$DEVCONTAINER_DIR")" ]; then
        rmdir "$DEVCONTAINER_DIR"
        echo "  [OK] Removed empty devcontainer directory."
    fi
fi

# Clean up remaining backup files if requested
echo ""
echo "Checking for remaining backup files..."
backup_count=0
for target_path in "${TARGET_PATHS[@]}"; do
    backup_files=$(ls "${target_path}.bak."* 2>/dev/null)
    if [ -n "$backup_files" ]; then
        echo "$backup_files"
        backup_count=$((backup_count + $(echo "$backup_files" | wc -l)))
    fi
done

if [ $backup_count -gt 0 ]; then
    echo ""
    echo "Found $backup_count backup file(s)."
    if [ "$YES_MODE" = false ]; then
        read -p "Remove all backup files? (y/N): " confirm_remove_backups
        if [[ "$confirm_remove_backups" =~ ^[Yy]$ ]]; then
            for target_path in "${TARGET_PATHS[@]}"; do
                rm -f "${target_path}.bak."* 2>/dev/null
            done
            echo "[OK] Removed all backup files."
        else
            echo "[SKIP] Backup files retained."
        fi
    fi
else
    echo "No backup files found."
fi

echo ""
echo "Done."
