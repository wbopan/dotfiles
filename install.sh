#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Define source (in dotfiles repo) and target (in home dir) paths
# Using indexed arrays for better compatibility with older bash versions
SOURCE_PATHS=(
    "fish/config.fish"
    "lazyvim/lazyvim.json"
    "lazyvim/option.lua"
    "lazyvim/plugins.lua"
    "tmux/.tmux.conf"
    # Add more source paths here
)

TARGET_PATHS=(
    "$HOME/.config/fish/config.fish"
    "$HOME/.config/nvim/lazyvim.json"
    "$HOME/.config/nvim/lua/config/options.lua"
    "$HOME/.config/nvim/lua/plugins/plugins.lua"
    "$HOME/.tmux.conf"
    # Add corresponding target paths here, ensure order matches SOURCE_PATHS
)

# Function to create backup and link
link_config() {
    local source_rel=$1
    local target=$2
    local source_abs="$SCRIPT_DIR/$source_rel"
    local target_dir=$(dirname "$target")

    echo "Processing $source_rel -> $target"

    # Ensure source file exists
    if [ ! -f "$source_abs" ]; then
        echo "  [SKIP] Source file not found: $source_abs"
        return
    fi

    # Ensure target directory exists
    if [ ! -d "$target_dir" ]; then
        echo "  [INFO] Target directory does not exist: $target_dir"
        read -p "  Create directory? (y/N): " confirm_create_dir
        if [[ "$confirm_create_dir" =~ ^[Yy]$ ]]; then
            mkdir -p "$target_dir"
            echo "  [OK] Created directory: $target_dir"
        else
            echo "  [SKIP] Skipping linking for $target as directory was not created."
            return
        fi
    fi


    # Check if target exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # Check if it's already linked correctly
        if [ -L "$target" ] && [ "$(readlink "$target")" == "$source_abs" ]; then
            echo "  [SKIP] Already linked correctly."
            return
        fi

        # Ask to backup
        read -p "  Target '$target' exists. Backup? (y/N): " confirm_backup
        if [[ "$confirm_backup" =~ ^[Yy]$ ]]; then
            backup_path="${target}.bak.$(date +%Y%m%d%H%M%S)"
            echo "  [INFO] Backing up existing file to $backup_path"
            mv "$target" "$backup_path"
            if [ $? -ne 0 ]; then
                echo "  [ERROR] Failed to back up $target. Skipping."
                return
            fi
        else
            # Ask to remove if not backing up
            read -p "  Remove existing '$target' without backup? (y/N): " confirm_remove
            if [[ "$confirm_remove" =~ ^[Yy]$ ]]; then
                echo "  [INFO] Removing existing file $target"
                rm -rf "$target"
                 if [ $? -ne 0 ]; then
                    echo "  [ERROR] Failed to remove $target. Skipping."
                    return
                fi
            else
                echo "  [SKIP] Did not back up or remove existing file. Skipping link."
                return
            fi
        fi
    fi

    # Create symbolic link
    echo "  [INFO] Creating symbolic link: $target -> $source_abs"
    ln -s "$source_abs" "$target"
    if [ $? -eq 0 ]; then
        echo "  [OK] Link created successfully."
    else
        echo "  [ERROR] Failed to create link for $target."
    fi
    echo "" # Newline for readability
}

# --- Main Script ---
echo "Starting dotfiles setup..."
echo "Script directory: $SCRIPT_DIR"
echo "Home directory: $HOME"
echo ""

# Iterate over the arrays and link files
num_configs=${#SOURCE_PATHS[@]}
for (( i=0; i<${num_configs}; i++ )); do
    src_rel="${SOURCE_PATHS[i]}"
    tgt_path="${TARGET_PATHS[i]}"
    if [ -n "$src_rel" ] && [ -n "$tgt_path" ]; then # Basic check to ensure pairs exist
        link_config "$src_rel" "$tgt_path"
    else
        echo "[WARN] Skipping configuration index $i due to missing source or target path."
    fi
done

echo "Dotfiles setup complete."

echo "Done."

# --- Install Dependencies ---
echo ""
echo "Installing dependencies..."

echo "Running tmux/install_tpm.sh..."
bash "$SCRIPT_DIR/tmux/install_tpm.sh"

echo "Running lazyvim/install_lazyvim.sh..."
bash "$SCRIPT_DIR/lazyvim/install_lazyvim.sh"

echo "Dependency installation complete."
