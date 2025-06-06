#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Parse command-line arguments
YES_MODE=false
INSTALL_FISH=false
INSTALL_TMUX=false
INSTALL_KITTY=false
INSTALL_LAZYVIM=false
INSTALL_ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y)
            YES_MODE=true
            shift
            ;;
        --fish)
            INSTALL_FISH=true
            shift
            ;;
        --tmux)
            INSTALL_TMUX=true
            shift
            ;;
        --kitty)
            INSTALL_KITTY=true
            shift
            ;;
        --lazyvim)
            INSTALL_LAZYVIM=true
            shift
            ;;
        --all|-a)
            INSTALL_ALL=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --fish      Install fish shell configuration"
            echo "  --tmux      Install tmux configuration"
            echo "  --kitty     Install kitty terminal configuration"
            echo "  --lazyvim   Install LazyVim configuration"
            echo "  --all, -a   Install all configurations"
            echo "  --yes, -y   Non-interactive mode (auto-backup existing files)"
            echo "  --help, -h  Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# If --all is specified, enable all components
if [ "$INSTALL_ALL" = true ]; then
    INSTALL_FISH=true
    INSTALL_TMUX=true
    INSTALL_KITTY=true
    INSTALL_LAZYVIM=true
fi

# If no specific flags are provided, show help and exit
if [ "$INSTALL_FISH" = false ] && [ "$INSTALL_TMUX" = false ] && [ "$INSTALL_KITTY" = false ] && [ "$INSTALL_LAZYVIM" = false ]; then
    echo "No installation targets specified."
    echo "Use --help for usage information or --all to install everything."
    exit 0
fi

# Define source (in dotfiles repo) and target (in home dir) paths
# Using indexed arrays for better compatibility with older bash versions
SOURCE_PATHS=()
TARGET_PATHS=()

# Add fish configuration if requested
if [ "$INSTALL_FISH" = true ]; then
    SOURCE_PATHS+=("fish/config.fish")
    TARGET_PATHS+=("$HOME/.config/fish/config.fish")
fi

# Add LazyVim configuration if requested
if [ "$INSTALL_LAZYVIM" = true ]; then
    SOURCE_PATHS+=("lazyvim/lazyvim.json")
    SOURCE_PATHS+=("lazyvim/option.lua")
    SOURCE_PATHS+=("lazyvim/plugins.lua")
    TARGET_PATHS+=("$HOME/.config/nvim/lazyvim.json")
    TARGET_PATHS+=("$HOME/.config/nvim/lua/config/options.lua")
    TARGET_PATHS+=("$HOME/.config/nvim/lua/plugins/plugins.lua")
fi

# Add tmux configuration if requested
if [ "$INSTALL_TMUX" = true ]; then
    SOURCE_PATHS+=("tmux/.tmux.conf")
    TARGET_PATHS+=("$HOME/.tmux.conf")
fi

# Add kitty configuration if requested
if [ "$INSTALL_KITTY" = true ]; then
    SOURCE_PATHS+=("kitty/kitty.conf")
    SOURCE_PATHS+=("kitty/current-theme.conf")
    TARGET_PATHS+=("$HOME/.config/kitty/kitty.conf")
    TARGET_PATHS+=("$HOME/.config/kitty/current-theme.conf")
fi

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
        if [ "$YES_MODE" = true ]; then
            mkdir -p "$target_dir"
            echo "  [OK] Created directory: $target_dir"
        else
            read -p "  Create directory? (y/N): " confirm_create_dir
            if [[ "$confirm_create_dir" =~ ^[Yy]$ ]]; then
                mkdir -p "$target_dir"
                echo "  [OK] Created directory: $target_dir"
            else
                echo "  [SKIP] Skipping linking for $target as directory was not created."
                return
            fi
        fi
    fi


    # Check if target exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # Check if it's already linked correctly
        if [ -L "$target" ] && [ "$(readlink "$target")" == "$source_abs" ]; then
            echo "  [SKIP] Already linked correctly."
            return
        fi

        # Handle existing file
        if [ "$YES_MODE" = true ]; then
            # In yes mode, always backup existing files
            backup_path="${target}.bak.$(date +%Y%m%d%H%M%S)"
            echo "  [INFO] Backing up existing file to $backup_path"
            mv "$target" "$backup_path"
            if [ $? -ne 0 ]; then
                echo "  [ERROR] Failed to back up $target. Skipping."
                return
            fi
        else
            echo "  Target '$target' exists. Choose an action:"
            echo "    1) Replace (remove existing file)"
            echo "    2) Backup and replace"
            echo "    3) Skip"
            read -p "  Enter choice (1-3): " choice
            
            case "$choice" in
                1)
                    echo "  [INFO] Removing existing file $target"
                    rm -rf "$target"
                    if [ $? -ne 0 ]; then
                        echo "  [ERROR] Failed to remove $target. Skipping."
                        return
                    fi
                    ;;
                2)
                    backup_path="${target}.bak.$(date +%Y%m%d%H%M%S)"
                    echo "  [INFO] Backing up existing file to $backup_path"
                    mv "$target" "$backup_path"
                    if [ $? -ne 0 ]; then
                        echo "  [ERROR] Failed to back up $target. Skipping."
                        return
                    fi
                    ;;
                3|*)
                    echo "  [SKIP] Skipping link for $target"
                    return
                    ;;
            esac
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

if [ "$INSTALL_TMUX" = true ]; then
    echo "Running tmux/install_tpm.sh..."
    bash "$SCRIPT_DIR/tmux/install_tpm.sh"
fi

if [ "$INSTALL_LAZYVIM" = true ]; then
    echo "Running lazyvim/install_lazyvim.sh..."
    bash "$SCRIPT_DIR/lazyvim/install_lazyvim.sh"
fi

echo "Dependency installation complete."

# --- Copy devcontainer.json to default location ---
echo ""
echo "Setting up default devcontainer configuration..."

DEVCONTAINER_SOURCE="$SCRIPT_DIR/.devcontainer/devcontainer.json"
DEVCONTAINER_TARGET="$HOME/.config/devcontainer/default.json"
DEVCONTAINER_DIR="$HOME/.config/devcontainer"

if [ -f "$DEVCONTAINER_SOURCE" ]; then
    # Ensure target directory exists
    if [ ! -d "$DEVCONTAINER_DIR" ]; then
        echo "  [INFO] Creating directory: $DEVCONTAINER_DIR"
        mkdir -p "$DEVCONTAINER_DIR"
    fi

    # Check if target already exists
    if [ -f "$DEVCONTAINER_TARGET" ]; then
        if [ "$YES_MODE" = true ]; then
            backup_path="${DEVCONTAINER_TARGET}.bak.$(date +%Y%m%d%H%M%S)"
            echo "  [INFO] Backing up existing default.json to $backup_path"
            cp "$DEVCONTAINER_TARGET" "$backup_path"
        else
            echo "  Target '$DEVCONTAINER_TARGET' already exists."
            echo "    1) Replace"
            echo "    2) Backup and replace"
            echo "    3) Skip"
            read -p "  Enter choice (1-3): " choice
            
            case "$choice" in
                1)
                    echo "  [INFO] Replacing existing file"
                    ;;
                2)
                    backup_path="${DEVCONTAINER_TARGET}.bak.$(date +%Y%m%d%H%M%S)"
                    echo "  [INFO] Backing up existing file to $backup_path"
                    cp "$DEVCONTAINER_TARGET" "$backup_path"
                    ;;
                3|*)
                    echo "  [SKIP] Skipping devcontainer.json copy"
                    echo "All done!"
                    exit 0
                    ;;
            esac
        fi
    fi

    # Copy the file
    echo "  [INFO] Copying devcontainer.json to $DEVCONTAINER_TARGET"
    cp "$DEVCONTAINER_SOURCE" "$DEVCONTAINER_TARGET"
    if [ $? -eq 0 ]; then
        echo "  [OK] DevContainer default configuration installed successfully."
    else
        echo "  [ERROR] Failed to copy devcontainer.json."
    fi
else
    echo "  [SKIP] devcontainer.json not found in repository."
fi

echo "All done!"
