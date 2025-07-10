#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Color functions
print_success() { echo -e "  ${GREEN}[OK]${NC} $1"; }
print_info() { echo -e "  ${BLUE}[INFO]${NC} $1"; }
print_skip() { echo -e "  ${YELLOW}[SKIP]${NC} $1"; }
print_sync() { echo -e "  ${YELLOW}[SYNC]${NC} $1"; }
print_error() { echo -e "  ${RED}[ERROR]${NC} $1"; }
print_command() { echo -e "    ${CYAN}$1${NC}"; }
print_header() { echo -e "${BOLD}$1${NC}"; }

# Function to install fish if not present
install_fish_if_needed() {
    if ! command -v fish &> /dev/null; then
        print_info "Fish shell not found. Installing fish..."
        
        # Detect OS and install fish
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew install fish
            else
                print_error "Homebrew not found. Please install fish manually: https://fishshell.com/"
                return 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            if command -v apt-get &> /dev/null; then
                # Use official Fish PPA for newest version on Ubuntu/Debian
                print_info "Adding Fish PPA for newest version..."
                sudo apt-get update
                sudo apt-get install -y software-properties-common
                sudo add-apt-repository -y ppa:fish-shell/release-4
                sudo apt-get update
                sudo apt-get install -y fish
            elif command -v yum &> /dev/null; then
                sudo yum install -y fish
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y fish
            elif command -v pacman &> /dev/null; then
                sudo pacman -S fish
            else
                print_error "Package manager not found. Please install fish manually: https://fishshell.com/"
                return 1
            fi
        else
            print_error "Unsupported OS. Please install fish manually: https://fishshell.com/"
            return 1
        fi
        
        if command -v fish &> /dev/null; then
            print_success "Fish shell installed successfully"
        else
            print_error "Failed to install fish shell"
            return 1
        fi
    else
        print_skip "Fish shell already installed"
    fi
    return 0
}

# Parse command-line arguments
YES_MODE=false
# Default to install all components
INSTALL_FISH=true
INSTALL_TMUX=true
INSTALL_CLAUDE=true
INSTALL_NVIM=true
SELECTIVE_MODE=false
FISH_CONFIGURED=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y)
            YES_MODE=true
            shift
            ;;
        --fish)
            if [ "$SELECTIVE_MODE" = false ]; then
                # First selective flag - disable all, then enable this one
                INSTALL_FISH=false
                INSTALL_TMUX=false
                INSTALL_CLAUDE=false
                INSTALL_NVIM=false
                SELECTIVE_MODE=true
            fi
            INSTALL_FISH=true
            shift
            ;;
        --tmux)
            if [ "$SELECTIVE_MODE" = false ]; then
                # First selective flag - disable all, then enable this one
                INSTALL_FISH=false
                INSTALL_TMUX=false
                INSTALL_CLAUDE=false
                INSTALL_NVIM=false
                SELECTIVE_MODE=true
            fi
            INSTALL_TMUX=true
            shift
            ;;
        --claude)
            if [ "$SELECTIVE_MODE" = false ]; then
                # First selective flag - disable all, then enable this one
                INSTALL_FISH=false
                INSTALL_TMUX=false
                INSTALL_CLAUDE=false
                INSTALL_NVIM=false
                SELECTIVE_MODE=true
            fi
            INSTALL_CLAUDE=true
            shift
            ;;
        --nvim)
            if [ "$SELECTIVE_MODE" = false ]; then
                # First selective flag - disable all, then enable this one
                INSTALL_FISH=false
                INSTALL_TMUX=false
                INSTALL_CLAUDE=false
                INSTALL_NVIM=false
                SELECTIVE_MODE=true
            fi
            INSTALL_NVIM=true
            shift
            ;;
        --no-fish)
            INSTALL_FISH=false
            shift
            ;;
        --no-tmux)
            INSTALL_TMUX=false
            shift
            ;;
        --no-claude)
            INSTALL_CLAUDE=false
            shift
            ;;
        --no-nvim)
            INSTALL_NVIM=false
            shift
            ;;
        --all|-a)
            INSTALL_FISH=true
            INSTALL_TMUX=true
            INSTALL_CLAUDE=true
            INSTALL_NVIM=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "By default, installs all configurations (fish, tmux, claude, nvim)."
            echo ""
            echo "Options:"
            echo "  --fish         Install only fish shell configuration"
            echo "  --tmux         Install only tmux configuration"
            echo "  --claude       Install only Claude custom commands"
            echo "  --nvim         Install only Neovim configuration"
            echo "  --all, -a      Install all configurations (default)"
            echo ""
            echo "  --no-fish      Skip fish shell configuration"
            echo "  --no-tmux      Skip tmux configuration"
            echo "  --no-claude    Skip Claude custom commands"
            echo "  --no-nvim      Skip Neovim configuration"
            echo ""
            echo "  --yes, -y      Non-interactive mode (auto-backup existing files)"
            echo "  --help, -h     Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Install everything"
            echo "  $0 --fish --tmux      # Install fish + tmux only"
            echo "  $0 --claude           # Install Claude commands only"
            echo "  $0 --yes              # Install everything non-interactively"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Define source (in dotfiles repo) and target (in home dir) paths
# Using indexed arrays for better compatibility with older bash versions
SOURCE_PATHS=()
TARGET_PATHS=()

# Add fish configuration if requested
if [ "$INSTALL_FISH" = true ]; then
    SOURCE_PATHS+=("fish/config.fish")
    TARGET_PATHS+=("$HOME/.config/fish/config.fish")
    
    # Link .env file for 1Password integration
    SOURCE_PATHS+=(".env")
    TARGET_PATHS+=("$HOME/.config/fish/.env")
    
    # Auto-discover and add all .fish files in conf.d directory
    for conf_file in "$SCRIPT_DIR"/fish/conf.d/*.fish; do
        if [ -f "$conf_file" ]; then
            # Extract just the filename from the full path
            conf_filename=$(basename "$conf_file")
            SOURCE_PATHS+=("fish/conf.d/$conf_filename")
            TARGET_PATHS+=("$HOME/.config/fish/conf.d/$conf_filename")
        fi
    done
fi


# Add tmux configuration if requested
if [ "$INSTALL_TMUX" = true ]; then
    SOURCE_PATHS+=("tmux/.tmux.conf")
    TARGET_PATHS+=("$HOME/.tmux.conf")
fi

# Add Claude custom commands if requested
if [ "$INSTALL_CLAUDE" = true ]; then
    # Auto-discover and add all .md files in claude/commands directory
    for cmd_file in "$SCRIPT_DIR"/claude/commands/*.md; do
        if [ -f "$cmd_file" ]; then
            # Extract just the filename from the full path
            cmd_filename=$(basename "$cmd_file")
            SOURCE_PATHS+=("claude/commands/$cmd_filename")
            TARGET_PATHS+=("$HOME/.claude/commands/$cmd_filename")
        fi
    done
fi

# Add Neovim configuration if requested
if [ "$INSTALL_NVIM" = true ]; then
    SOURCE_PATHS+=("nvim/init.lua")
    TARGET_PATHS+=("$HOME/.config/nvim/init.lua")
fi

# Function to create backup and link
link_config() {
    local source_rel=$1
    local target=$2
    local source_abs="$SCRIPT_DIR/$source_rel"
    local target_dir=$(dirname "$target")
    local target_short="${target/#$HOME/~}"  # Replace home directory with ~

    # Track if we're configuring fish
    if [[ "$source_rel" == fish/* ]]; then
        FISH_CONFIGURED=true
    fi

    # Ensure source exists (file or directory)
    if [ ! -e "$source_abs" ]; then
        echo -e "  ${RED}❌${NC} ${source_rel} ${RED}(source not found)${NC}"
        return
    fi

    # Ensure target directory exists
    if [ ! -d "$target_dir" ]; then
        if [ "$YES_MODE" = true ]; then
            mkdir -p "$target_dir"
        else
            echo -e "  ${YELLOW}❓${NC} ${source_rel} -> ${target_short}"
            read -p "    Create directory $(dirname "$target_short")? (y/N): " confirm_create_dir
            if [[ "$confirm_create_dir" =~ ^[Yy]$ ]]; then
                mkdir -p "$target_dir"
            else
                echo -e "  ${YELLOW}⏭️${NC}  ${source_rel} ${YELLOW}(skipped)${NC}"
                return
            fi
        fi
    fi

    # Check if target exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # Check if it's already linked correctly
        if [ -L "$target" ] && [ "$(readlink "$target")" == "$source_abs" ]; then
            echo -e "  ${YELLOW}✅${NC} ${source_rel} -> ${target_short} ${YELLOW}(synced)${NC}"
            return
        fi

        # Handle existing file
        if [ "$YES_MODE" = true ]; then
            # In yes mode, always backup existing files
            backup_path="${target}.bak.$(date +%Y%m%d%H%M%S)"
            mv "$target" "$backup_path"
            if [ $? -ne 0 ]; then
                echo -e "  ${RED}❌${NC} ${source_rel} ${RED}(backup failed)${NC}"
                return
            fi
        else
            echo -e "  ${YELLOW}❓${NC} ${source_rel} -> ${target_short} ${YELLOW}(exists)${NC}"
            echo -e "    ${CYAN}1)${NC} Replace  ${CYAN}2)${NC} Backup  ${CYAN}3)${NC} Skip"
            read -p "    Choice (1-3): " choice
            
            case "$choice" in
                1)
                    rm -rf "$target"
                    if [ $? -ne 0 ]; then
                        echo -e "  ${RED}❌${NC} ${source_rel} ${RED}(failed to remove)${NC}"
                        return
                    fi
                    ;;
                2)
                    backup_path="${target}.bak.$(date +%Y%m%d%H%M%S)"
                    mv "$target" "$backup_path"
                    if [ $? -ne 0 ]; then
                        echo -e "  ${RED}❌${NC} ${source_rel} ${RED}(backup failed)${NC}"
                        return
                    fi
                    ;;
                3|*)
                    echo -e "  ${YELLOW}⏭️${NC}  ${source_rel} ${YELLOW}(skipped)${NC}"
                    return
                    ;;
            esac
        fi
    fi

    # Create symbolic link
    ln -s "$source_abs" "$target"
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✅${NC} ${source_rel} -> ${target_short}"
    else
        echo -e "  ${RED}❌${NC} ${source_rel} ${RED}(link failed)${NC}"
    fi
}

# --- Main Script ---
print_header "Starting dotfiles sync..."
echo -e "Script directory: ${CYAN}$SCRIPT_DIR${NC}"
echo -e "Home directory: ${CYAN}$HOME${NC}"
echo ""

# Install fish first if needed and configuring fish
if [ "$INSTALL_FISH" = true ]; then
    print_header "Checking Fish Shell..."
    if ! install_fish_if_needed; then
        print_error "Failed to install fish shell. Skipping fish configuration."
        INSTALL_FISH=false
    fi
    echo ""
fi

# Iterate over the arrays and link files
num_configs=${#SOURCE_PATHS[@]}
for (( i=0; i<${num_configs}; i++ )); do
    src_rel="${SOURCE_PATHS[i]}"
    tgt_path="${TARGET_PATHS[i]}"
    if [ -n "$src_rel" ] && [ -n "$tgt_path" ]; then # Basic check to ensure pairs exist
        link_config "$src_rel" "$tgt_path"
    else
        echo -e "${YELLOW}[WARN]${NC} Skipping configuration index $i due to missing source or target path."
    fi
done

print_header "Dotfiles sync complete!"
echo ""

# Source fish configuration if it was configured
if [ "$FISH_CONFIGURED" = true ] && command -v fish &> /dev/null; then
    print_header "Sourcing Fish Configuration..."
    if fish -c "source ~/.config/fish/config.fish" 2>/dev/null; then
        print_success "Fish configuration sourced successfully"
    else
        print_info "Fish configuration will be loaded on next fish session"
    fi
    echo ""
fi

# Run fish_deps health check if fish is configured
if [ "$FISH_CONFIGURED" = true ] && command -v fish &> /dev/null; then
    print_header "Dependency Health Check:"
    if fish -c "fish_deps health" 2>/dev/null; then
        echo ""
        print_info "Use ${CYAN}fish_deps install <package>${NC} to install missing dependencies"
    else
        print_info "Fish configuration not fully loaded. Run ${CYAN}fish_deps health${NC} manually to check dependencies"
    fi
else
    print_header "Dependencies:"
    print_info "After fish configuration is active, run ${CYAN}fish_deps health${NC} to check all dependencies"
    print_info "Use ${CYAN}fish_deps install <package>${NC} to install missing packages"
    print_info "Use ${CYAN}op-sync${NC} to sync 1Password secrets to .profile file"
fi

echo ""
print_header "All done! 🎉"
